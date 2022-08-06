# Chaos Enginnering
- Generating Random number
```BASH
d=$(( ( RANDOM % 10 )  + 1 ))
```
- [Example Cluster with examples](https://github.com/wuestkamp/cka-example-environments)

## Pure Chaos
- [Install Registry](https://artifacthub.io/packages/helm/twuni/docker-registry)
```BASH
# It's helpful to have a container registry during the build, push, and deploy phases. There is no need to shuttle private images over the internet.
helm repo add twuni https://helm.twun.io
helm install registry twuni/docker-registry \
  --version 1.10.0 \
  --namespace kube-system \
  --set service.type=NodePort \
  --set service.nodePort=31500
kubectl get service --namespace kube-system
# Assign an environment variable to the common registry location
export REGISTRY=2886795330-31500-kira01.environments.katacoda.com
# It will be a few moments before the registry deployment reports it's Available
kubectl get deployments registry-docker-registry --namespace kube-system
# Once the registry is serving, inspect the contents of the empty registry
curl $REGISTRY/v2/_catalog | jq -c
```
- Install Sample Application
```BASH
# Let's create a small collection of applications. 
# you will create a deployment of applications that log random messages. 
kubectl create namespace learning-place
# Run the random-logger container in a Pod to start generating continuously random logging events
kubectl create deployment random-logger --image=chentex/random-logger -n learning-place
kubectl scale deployment/random-logger --replicas=10 -n learning-place
kubectl get pods -n learning-place
```
- [Random Logger](https://github.com/chentex/random-logger)
- Snowflake Melter
```PYTHON
# The most common chaos for Kubernetes is to periodically and randomly terminate Pods.
# To define the terminator, all we need is a container that has some logic in it to find the application Pods you just started and terminate them. The Kubernetes API offers all the control we need to find and remove Pods.

# We'll choose Python as we can import a helpful Kubernetes API and the script can be loaded into a Python container. 

# cat snowflake_melter.py
from kubernetes import client, config
import random

# Access Kubernetes
config.load_incluster_config()
v1=client.CoreV1Api()

# List Namespaces
all_namespaces = v1.list_namespace()

# Get Pods from namespaces annotated with chaos marker
pod_candidates = []
for namespace in all_namespaces.items:
    if (    namespace.metadata.annotations is not None 
        and namespace.metadata.annotations.get("chaos", None) == 'yes'
       ):
        pods = v1.list_namespaced_pod(namespace.metadata.name)
        pod_candidates.extend(pods.items)

# Determine how many Pods to remove
removal_count = random.randint(0, len(pod_candidates))
if len(pod_candidates) > 0:
    print("Found", len(pod_candidates), "pods and melting", removal_count, "of them.")
else:
    print("No eligible Pods found with annotation chaos=yes.")

# Remove a few Pods
for _ in range(removal_count):
    pod = random.choice(pod_candidates)
    pod_candidates.remove(pod)
    print("Removing pod", pod.metadata.name, "from namespace", pod.metadata.namespace, ".")
    body = client.V1DeleteOptions()
    v1.delete_namespaced_pod(pod.metadata.name, pod.metadata.namespace, body=body)
```
- Dockerfile
```BASH
# cat Dockerfile
# ARGS at this level referenced only by FROMs
ARG BASE_IMAGE=python:3.8.5-alpine3.12

# --------------------------------------
# Build dependencies in build stage
# --------------------------------------
FROM ${BASE_IMAGE} as builder
    
WORKDIR /app

# Cache installed dependencies between builds
COPY ./requirements.txt ./requirements.txt
RUN pip install -r ./requirements.txt --user

# --------------------------------------
# Create final container loaded with app
# --------------------------------------

FROM ${BASE_IMAGE}

LABEL scenario=pure-chaos

ENV USER=docker GROUP=docker \
    UID=12345 GID=23456 \
    HOME=/app PYTHONUNBUFFERED=1

# Create user/group
RUN addgroup --gid "${GID}" "${GROUP}" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "${GROUP}" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR ${HOME}

# TODO, will switching user work?
# USER ${USER}

COPY --from=builder /root/.local /usr/local
COPY --chown=${USER}:${GROUP} . .

CMD ["python", "snowflake_melter.py"]
```
```BASH
# cat requirements.txt
kubernetes==11.0.0
```
- Build and Push Image
```BASH
export IMAGE=$REGISTRY/snowflake_melter:0.1.0
docker build -t $IMAGE .
docker push $IMAGE
curl $REGISTRY/v2/_catalog | jq
```
- Invoke Chaos
```BASH
# Run your newly created application as a Kubernetes CronJob
kubectl create cronjob snowflake-melter --image=$IMAGE --schedule='*/1 * * * *'
# The chaos CronJob is will now be running once a minute. More flexible chaos systems would randomize this period. 
kubectl get cronjobs
# At the beginning of the next minute on the clock, the CronJob will create a new Pod. 
kubectl get pods
# Every minute a new Pod will create and run the chaos logic. Kubernetes automatically purges the older Job Pods. Getting the logs from all the Jobs is a bit tricky, but there is a common client tool called Stern that collates and displays logs from related Pods.
stern snowflake-melter --container-state terminated --since 2m --timestamps
# You will discover in the logs that the code is reporting that it's not finding Pods that are eligible for deleting.
```
- Target the Chaos
```BASH
# The current logic for the chaotic Pod deletion requires a namespace to be annotated with chaos=yes. Assign the random-logger Pods as chaos targets by annotating the learning-place namespace.
kubectl annotate namespace learning-place chaos=yes
kubectl describe namespace learning-place
# The next time chaos Job runs it will see this annotation and the interesting work will be reported. 
watch kubectl get pods -n learning-place
```
- For real applications, if scaled correctly, all this chaos and resilience will be happening behind the scenes in the cluster while your users experience no downtime or delays.
- You could modify the Python code a bit more and go crazy with other Kubernetes API calls to create clever forms of havoc.

## Chaos Mesh 
Chaos Mesh is a cloud native Chaos Engineering platform that orchestrates chaos on Kubernetes environments. At the current stage, it has the following components:
- **Chaos Operator**: the core component for chaos orchestration; fully open source.
- **Chaos Dashboard**: a Web UI for managing, designing, and monitoring Chaos Experiments; under development.
Choas Mesh is one of the better chaos engines for Kubernetes because:
    1. In a short amount of time there has been heavy community support and it's a CNCF sandbox project.
    2. It's a native experience to Kubernetes leveraging the Operator Pattern and CRDs permitting IaC with your pipelines.
    3. If you have followed the best practices by applying plenty of labels and annotations to your Deployments, then there is no need to make modifications to your apps for your chaos experiments.
    4. There are a wide variety of experiment types, not just Pod killing.
    5. Installs with a Helm chart and you have complete control over the engine with CRDs.
- Install Chaos Mesh
```BASH
kubectl create namespace chaos-mesh
# Add the chart repository for the Helm chart to be installed
helm search repo chaos-mesh -l
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm install chaos-mesh chaos-mesh/chaos-mesh \
  --version v2.0.0 \
  --namespace chaos-mesh \
  --set chaosDaemon.runtime=containerd \
  --set chaosDaemon.socketPath=/run/containerd/containerd.sock
# Verify
kubectl get deployments,pods,services --namespace chaos-mesh
```
The control plane components for the Chaos Mesh are:
    1. **chaos=controller-manager**: This is used to schedule and manage the lifecycle of chaos experiments. (This is a misnomer. This should be just named controller, not controller-manager, as it's the controller based on the Operator Pattern. The controller-manager is the Kubernetes control plane component that manages all the controllers like this one).
    2. **chaos-daemon**: These are the Pods that control the chaos mesh. The Pods run on every cluster Node and are wrapped in a DaemonSet. These DaemonSets have privileged system permissions to access each Node's network, cgroups, chroot, and other resources that are accessed based on your experiments.
    3. **chaos-dashboard**: An optional web interface providing you an alternate means to administer the engine and experiments. Its use is for convenience and any production use of the engine should be through the YAML resources for the Chaos Mesh CRDs.
- Chaos Mesh Dashboard
The chaos dashboard is accessible via a NodePort. For this scenario we need the nodePort at a specific value, rather than its current random port number. Set the nodePort to a specific port:
```BASH
kubectl patch service chaos-dashboard -n chaos-mesh --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31111}]'
# With the correct port value set, the web interface for Chaos Mesh dashboard can be seen from the tab Chaos Mesh above the command-line area or this link: https://2886795275-31111-kira01.environments.katacoda.com/.
```
- There are no experiments yet, but take a few moments to explore the general layout of the dashboard. There is a way through the user interface to create, update, and delete experiments. 
- Chaos Mesh Experiment Types
============================================================
Category 	    Type  	        Experiment Description
------------------------------------------------------------
Pod Lifecycle 	Pod Failure 	Killing pods.
Pod Lifecycle 	Pod Kill 	    Pods becoming unavailable.
Pod Lifecycle 	Container Kill 	Killing containers in pods.
Network 	    Partition 	    Separate Pods into independent subnets by blocking communication between them.
Network 	    Loss 	        Inject network communication loss.
Network 	    Delay 	        Inject network communication latency.
Network 	    Duplication 	Inject packet duplications.
Network 	    Corrupt 	    Inject network communication corruption.
Network 	    Bandwidth 	    Limit the network bandwidth.
I/O 	        Delay 	        Inject delay during I/O.
I/O 	        Errno 	        Inject error during I/O.
I/O 	        Delay and Errno Inject both delays and errors with I/O.
Linux Kernel 	                Inject kernel errors into pods.
Clock 	        Offset 	        Inject clock skew into pods.
Stress 	        CPU 	        Simulate pod CPU stress.
Stress 	        Memory 	        Simulate pod memory stress.
Stress 	        CPU & Memory 	Simulate both CPU and memory stress on Pods.

```YAML
# cat web-show-deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-show
  labels:
    app: web-show
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-show
  template:
    metadata:
      labels:
        app: web-show
    spec:
      containers:
        - name: web-show
          image: pingcap/web-show
          imagePullPolicy: Always
          command:
            - /usr/local/bin/web-show
            - --target-ip=$(TARGET_IP)
          env:
            - name: TARGET_IP
              valueFrom:
                configMapKeyRef:
                  name: web-show-context
                  key: target.ip
          ports:
            - name: web-port
              containerPort: 8081
              hostPort: 8081

# cat web-show-service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: web-show
  labels:
    app: web-show
spec:
  selector:
    app: web-show
  type: NodePort
  ports:
  - port: 8081
    protocol: TCP
    targetPort: 8081
    nodePort: 30081

# cat nginx.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  annotations:
    deployment.kubernetes.io/revision: "1"
  labels:
    app: nginx
spec:
  replicas: 8
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        chaos: blast-here
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shine-on-you-crazy-diamond 
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cant-touch-dis
  template:
    metadata:
      labels:
        app: cant-touch-dis
    spec:
      containers:
      - image: nginx
        name: nginx

# cat network-delay-experiment.yaml 
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: web-show-network-delay
spec:
  action: delay
  mode: one
  selector:
    namespaces:
    - default
    labelSelectors:
      app: web-show
  delay:
    latency: 10ms

# cat scheduled-network-delay-experiment.yaml 
apiVersion: chaos-mesh.org/v1alpha1
kind: Schedule
metadata:
  name: web-show-scheduled-network-delay
spec:
  schedule: '@every 60s'
  type: NetworkChaos
  historyLimit: 5
  concurrencyPolicy: Forbid
  networkChaos:
    action: delay
    mode: one
    selector:
      namespaces:
      - default
      labelSelectors:
        app: web-show
    delay:
      latency: 10ms
    duration: 30s

# cat pod-removal-experiment.yaml 
apiVersion: chaos-mesh.org/v1alpha1
kind: Schedule
metadata:
  name: pod-kill-example
  namespace: chaos-mesh
spec:
  schedule: '@every 15s'
  type: PodChaos
  historyLimit: 5
  concurrencyPolicy: Forbid
  podChaos:
    action: pod-kill
    mode: one
    selector:
      namespaces:
      - chaos-sandbox
      labelSelectors:
        chaos: blast-here
```
- Network Delay Experiment
```BASH
# Install an example application as a target for the experiment. This application is designed by the Chaos Mesh project as a hello world example for your first experiment.
# The application needs an environment variable for the TARGET_IP, which is the cluster IP, so this context you provide as a ConfigMap. That ConfigMap variable is referenced in the Deployment YAML.
TARGET_IP=$(kubectl get pod -n kube-system -o wide| grep kube-controller | head -n 1 | awk '{print $6}')
kubectl create configmap web-show-context --from-literal=target.ip=${TARGET_IP}

kubectl apply -f web-show-deployment.yaml
kubectl apply -f web-show-service.yaml

# With the web-show application running, its web interface can be accessed from the "Web Show" above the command-line area or this link: https://2886795275-30081-kira01.environments.katacoda.com/

# Define Experiment
kubectl get crds    # The Chaos Mesh has installed several custom resources
# You can reference these resources to create declarative YAML manifests that define your experiment. 

# For your first experiment, you will impose a network delay. The delay is defined in the NetworkChaos manifest 

# The experiment declares that a 10ms network delay should be injected. The delay will only be applied to the target service labeled "app": "web-show".
# This is the **blast radius**.
kubectl get deployments,pods -l app='web-show'
# Apply Experiment
kubectl apply -f network-delay-experiment.yaml
# The experiment is now running.
kubectl get NetworkChaos
# The application has a built-in graph that will show the latency it's experiencing. With the experiment applied you will see the 10ms delay. 

# Update Experiment
# At any time you can change the YAML declaration and apply further experiment updates.
kubectl apply -f network-delay-experiment.yaml
# The experiment can be paused
kubectl annotate networkchaos web-show-network-delay experiment.chaos-mesh.org/pause=true
# and resumed
kubectl annotate networkchaos web-show-network-delay experiment.chaos-mesh.org/pause-

# Since the NetworkChaos is like any other Kubernetes resource, the experiment can be easily removed.
kubectl delete -f network-delay-experiment.yaml
```
- Scheduled Experiment
```BASH
# This experiment will inject network chaos periodically: 10ms network delay should be injected every minute that lasts for 30 seconds
# Apply Scheduled Experiment
kubectl apply -f scheduled-network-delay-experiment.yaml

# The schedule experiment is now running. Scheduled experiment will not create NetworkChaos object immediately, intead it creates an Schedule object called web-show-scheduled-network-delay
kubectl get Schedule
# NetworkChaos is very similar with what between CronJob and Job: Schedule will spawn NetworkChaos when trigger by @every 60s.
kubectl get NetworkChaos -w
# The experiment can be paused
kubectl annotate schedule web-show-scheduled-network-delay experiment.chaos-mesh.org/pause=true
# and resumed:
kubectl annotate schedule web-show-scheduled-network-delay experiment.chaos-mesh.org/pause-
```
- Pod Removal Experiment
```BASH
# Install an example application as a target for the experiment. It's just a deployment of the common Nginx web server with Pod replications. Apply the Deployment to the chaos-sandbox namespace.
kubectl create namespace chaos-sandbox
kubectl apply -f nginx.yaml -n chaos-sandbox
# The experiment declares that the specific pod should be killed every 15s. The removal will only be applied to the target pod labeled "chaos": "blast here", which is the blast radius.
# Apply Experiment
kubectl apply -f pod-removal-experiment.yaml
kubectl get Schedule -n chaos-mesh
# Based on the cron time in the experiment, watch the Pods randomly terminate and new ones start.
watch kubectl get -n chaos-sandbox deployments,pods,services
# Notice the blast radius is targeting only the nginx Pods, while the shine-on-you-crazy-diamond Pods remain undisturbed.
```
## Litmus 
Litmus is a toolset to do cloud native chaos engineering. Litmus provides tools to orchestrate chaos on Kubernetes to help SREs find weaknesses in their deployments. SREs use Litmus to run chaos experiments initially in the staging environment and eventually in production to find bugs and vulnerabilities. Fixing the weaknesses leads to increased resilience of the system.
- Litmus offers you these compelling features:
    1. Kubernetes native CRDs to manage chaos. Using chaos API, orchestration, scheduling, and complex workflow management can be orchestrated declaratively.
    2. Most of the generic chaos experiments are readily available for you to get started with your initial chaos engineering needs.
    3. An SDK is available in GO, Python, and Ansible. A basic experiment structure is created quickly using SDK and developers and SREs just need to add the chaos logic to make a new experiment.
    4. It's simple to complex chaos workflows are easy to construct. Use GitOps and the chaos workflows to scale your chaos engineering efforts and increase the resilience of your Kubernetes platform.

```BASH
# For this scenario, we'll install the standard NGINX application and make it a target. Install NGINX into the default namespace.
kubectl create deploy nginx --image=nginx
kubectl get deployments,pods --show-labels
```
- Install Litmus Operator
```BASH
# The recommended way to start Litmus is by installing the Litmus Operator. 
kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator-v1.8.0.yaml
kubectl get namespaces
# In the list, you see litmus as a new namespace.
# An operator is a custom Kubernetes controller that uses custom resources (CR) to manage applications and their components. The Litmus Operator is comprised of a few controllers maintaining the CRs. 
kubectl get crds | grep litmus
# Check the Litmus API resources are available
kubectl api-resources | grep litmus
kubectl get all -n litmus
```
- The key components and object associated with Litmus are:
    1. RBAC for chaotic administration access targeted objects on your cluster.
    2. The Litmus controller that manages the custom resources and the following apps:
        - **ChaosEngine**: A resource to link a Kubernetes application or Kubernetes node to a ChaosExperiment. ChaosEngine is watched by Litmus' Chaos-Operator which then invokes Chaos-Experiments.
        - **ChaosExperiment**: A resource to group the configuration parameters of a chaos experiment. ChaosExperiment CRs are created by the operator when experiments are invoked by ChaosEngine.
        - **ChaosResult**: A resource to hold the results of a chaos-experiment. The Chaos-exporter reads the results and exports the metrics into a configured Prometheus server.
- Install Chaos Experiments - These experiments are installed on your cluster as Litmus resources declarations in the form of the Kubernetes CRDs. Because the chaos experiments are just Kubernetes YAML manifests, these experiments are published on [Chaos Hub](https://hub.litmuschaos.io/). 
- [generic/pod-delete](https://hub.litmuschaos.io/generic/pod-delete)
```BASH
kubectl apply -f https://hub.litmuschaos.io/api/chaos/1.8.0?file=charts/generic/pod-delete/experiment.yaml
# Verify the pod-delete experiment has been installed
kubectl get chaosexperiments

# Setup RBAC with Service Account
# A service account should be created to allow ChaosEngine to run experiments in your application namespace.
kubectl apply -f https://hub.litmuschaos.io/api/chaos/1.8.0?file=charts/generic/pod-delete/rbac.yaml
# Verify the ServiceAccount RBAC rules have been applied for pod-delete-sa
kubectl get serviceaccount,role,rolebinding

# Annotate Application
# In this case, we'll annotate the NGINX deployment with litmuschaos.io/chaos="true"
kubectl annotate deploy/nginx litmuschaos.io/chaos="true"
# Verify the annotation has been applied
kubectl get deployment nginx -o=custom-columns='ANNOTATIONS:metadata.annotations'

# Run the Experiment
kubectl apply -f https://hub.litmuschaos.io/api/chaos/1.8.0?file=charts/generic/pod-delete/engine.yaml
# Start watching the Pods in the default namespace
watch -n 1 kubectl get pods
# In a moment an nginx-chaos-runner Pod will start. This Pod is created by the Litmus engine based on the experiment criteria. 
# In a moment, the chaos-runner will create a new Pod called pod-delete-<hash>. This Pod is responsible for the actual Pod deletion. 
# Shortly after the pod-delete-<hash> Pod starts, you'll notice the NGINX Pod is killed. 

# Observe and Verify Experiments
kubectl describe chaosresult nginx-chaos-pod-delete

# The status.verdict is set to Awaited when the experiment is in progress, eventually changing to either Pass or Fail. 
```
## Chaoskube
- Chaoskube periodically kills random Pods in your Kubernetes cluster, which allows you to test how your system behaves under arbitrary Pod failures. 
- [Helm Input](https://github.com/helm/charts/tree/master/stable/chaoskube#configuration)
```BASH
kubectl version --short && \
kubectl get componentstatus && \
kubectl get nodes && \
kubectl cluster-info

helm version --short

kubectl create namespace chaoskube
helm repo add chaoskube https://linki.github.io/chaoskube
# Install the chart
# The interval parameter instructs Chaoskube to kill Pods every 20 seconds. 
# The targeted Pods are any with the label app-purpose=chaos, and the kube-system namespace has to be explicitly excluded (!) from the list of namespaces to look for Pods to kill. 
helm install chaoskube chaoskube/chaoskube \
  --version=0.1.0 \
  --namespace chaoskube \
  --set image.tag=v0.21.0 \
  --set dryRun=false \
  --set 'namespaces=!kube-system' \
  --set labels=app-purpose=chaos \
  --set interval=20s

kubectl get -n chaoskube deployments
kubectl rollout -n chaoskube status deployment chaoskube

# You can periodically check the Chaoskube log to see its Pod killing activity. 
POD=$(kubectl -n chaoskube get pods -l='app.kubernetes.io/instance=chaoskube' --output=jsonpath='{.items[0].metadata.name}')
kubectl -n chaoskube logs -f $POD
```
```YAML
# nginx.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  labels:
    app: nginx
    app-purpose: chaos
  name: nginx
spec:
  replicas: 8
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        app-purpose: chaos
    spec:
      containers:
      - image: nginx
        name: nginx

# cat ghost.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  labels:
    app: ghost
    app-purpose: chaos
  name: ghost
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ghost
  template:
    metadata:
      labels:
        app: ghost
        app-purpose: chaos
    spec:
      containers:
      - image: ghost:3.11.0-alpine
        name: ghost
```
- The Deployments and Pods are labeled to mark these Pods as potential victim targets of the Chaoskube Pod killer. 
- The Deployment and Pod template have the label `app-purpose: chaos` that makes the Pod an eligible target for Chaoskube. The label is provided as a configuration value during the Helm chart installation.
```BASH
kubectl apply -f nginx.yaml
kubectl create namespace more-apps
kubectl create --namespace more-apps 
kubectl apply -f ghost.yaml
```
- Observe the Chaos
- Notice as Pods are deleted every 20 secs, the Kubernetes resilience feature is making sure they are restored.
```BASH
watch kubectl get deployments,pods --all-namespaces -l app-purpose=chaos
```
- In a real chaos testing platform, you should complement this Pod killing activity with automated tests to ensure these disruptions are either unnoticed or acceptable for your business processes.