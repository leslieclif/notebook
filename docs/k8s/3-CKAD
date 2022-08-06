# CKAD
## Explain Commands
```BASH
# When is it useful: sometimes when editing/creating yaml files, it is not clear where exaclty rsource should be placed (indented) in the file. Using this command gives a quick overview of resources structure as well as helpful explanation. Sometimes this is faster then looking up in k8s docs.
kubectl explian pods --recursive | grep envFrom -A3   # Prints lines after a match is found
# Output would be 
envFrom        <[]Object>         # This is an array of Objects, so the next line will be start with -
  configMapRef        <Object>    # This is an Object
    name     <string>             # This is a dictionary
    optional <boolean>
# 
kubectl explain cronjob.spec.jobTemplate --recursive | less
kubectl explain pods.spec.containers --recursive | less
```
## Pods
```BASH
kubetcl get pods -o wide        # Get the Node on which pod is running
```
- **Remember**: You **CANNOT** edit specifications of an existing POD other than the below.
1. spec.containers[*].image
1. spec.initContainers[*].image
1. spec.activeDeadlineSeconds
1. spec.tolerations
- For example: when you edit a pod in vi editor for environment variables, service accounts, resource limits. When you try to save it, you will be denied. This is because you are attempting to edit a field on the pod that is not editable.
1. A copy of the file with your changes is saved in a temporary location when it fails. You can then delete the existing pod. Then create a new pod with your changes using the temporary file which was saved earlier in `/tmp`.
2. The second option is to extract the pod definition in YAML format to a file. Then make the changes to the exported file using an editor and save the file. Then delete the existing pod. Then create a new pod with the edited file. 
## Replicasets
- `selector` is the difference between ReplicaSet and ReplicationController aprat from apiVersion. 
```BASH
# Scaling RS
kubectl replace -f rs.yaml
kubectl scale --replicas=6 rs myapp-rs      # <Type> <Name of RS> format 
kubectl delete rs myapp-rs                  # Also deletes the underlying pods
### IMPORTANT
# Either delete and recreate the ReplicaSet or Update the existing ReplicaSet and then delete all PODs, so new ones with the correct image will be created.
```
## Deployments
```BASH
kubectl create deployment mydeploy --image=nginx --replicas=3
kubectl scale deployment mydeploy --replicas=6
```
- Edit Deployments - With Deployments you can easily edit any field/property of the POD template. Since the pod template is a child of the deployment specification,  with every change the deployment will automatically delete and create a new pod with the new changes. So if you are asked to edit a property of a POD part of a deployment.

## Formatting kubectl Output
```BASH
-o json         # Output a JSON formatted API object.
-o name         # Print only the resource name and nothing else.
-o wide         # Output in the plain-text format with any additional information.
-o yaml         # Output a YAML formatted API object.
```
## Namespaces
```BASH
kubectl config set-context $(kubectl config current-context) --namespace=test
# OR
alias kns=kubectl config set-context --current --namespace
kns test
# Testing services
# DNS resolution
<svc name>.<namespace>.svc.cluster.local:<svc port>  # cluster.local - Domain name, svc - subdomain name
```
## Imperative Commands
```BASH
`--dry-run`: # By default as soon as the command is run, the resource will be created. 
`-dry-run=client`: # This will not create the resource, instead, tell you whether the resource can be created and if your command is right.
# Generate POD Manifest 
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
# Generate Deployment with 4 Replicas
kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > deploy.yaml
# Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379
# This will automatically use the pod's labels as selectors
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml > svc.yaml
# OR
# This will not use the pods labels as selectors, instead it will assume selectors as app=redis.
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml 
# So it does not work very well if your pod has a different label set. So generate the file and modify the selectors before creating the service

# Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes
# This will automatically use the pod's labels as selectors, but you cannot specify the node port. 
kubectl expose pod nginx --port=80 --name nginx-service --type=NodePort --dry-run=client -o yaml
# OR
# This will not use the labels as selectors
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml
# I would recommend going with the `kubectl expose` command. If you need to specify a node port, generate a definition file using the same command and manually input the nodeport before creating the service.

# Create Pod and Svc in one command
kubetcl run nginx --image=nginx --port=8080 --expose
```
##  Docker Commands
```BASH
CMD ["command","parameters"]            # Process which is executed in Docker container continuously
# example
CMD ["sleep", "5"]                      # Sleep is executed every 5 secs
# What is you want to pass parameters to Docker during execution, Use ENTRYPOINT
ENTRYPOINT ["sleep"]                    # Process invoked at startup
# To execute
docker run sleeper-image 10             # This will pass 10 to the Sleep process
# If no parameter is passed to Docker command, it will fail.
# Passing default parameter when no parameter is passed, Use ENTRYPOINT and CMD both in Dockerfile
ENTRYPOINT ["sleep"]                    # Process invoked at startup
CMD ["5"]                      # Default parameter passed to sleep, if not given during docker execution
# Suppose you want to override the default sleep process during execution
docker run --entrypoint ping sleeper-image 8.8.8.8  # Override sleep with ping process
```
##  K8s Commands and Arguments
```BASH
# Docker           # K8s
#---------------------------#
# ENTRYPOINT  -->  command
# CMD         -->  args

# Example
# In Dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--color", "red"]
# In K8s, args is overriding the input
command: ["python", "app.py"]
args: ["--color", "pink"]
```
##  Environment Variables
- Passed as an array in key value format
- 3 Types of setting Env variables
1. Direct
1. Config Map
1. Secrets
```BASH
# Direct
env:
  - name: APP_COLOR
    value: pink
# ConfigMap
env:
  - name: APP_COLOR
    valueFrom: 
        configMapKeyRef:
# Secret
env:
  - name: APP_COLOR
    valueFrom:
        secretKeyRef:
```
## ConfigMap
```BASH
# From Literal
kubectl create configmap <config-map name> --from-literal=<key>-<value>
# From File
kubectl create configmap <config-map name> --from-file=<path-to-file>
# To reference a configMap file in pod definition
# ConfigMap with apiVersion etc defined
envFrom:
  - configMapRef:
      name: <configMap Name in Metadata>
# To reference a configMap volume in pod definition
volumes:
    - name: app-config-volume
      configMap:
        name:  <configMap Name in Metadata>
```
## Secrets
- Also the way kubernetes handles secrets. Such as:
- A secret is only sent to a node if a pod on that node requires it.
- Kubelet stores the secret into a tmpfs so that the secret is not written to disk storage.
- Once the Pod that depends on the secret is deleted, kubelet will delete its local copy of the secret data as well.
- Having said that, there are other better ways of handling sensitive data like passwords in Kubernetes, such as using tools like Helm Secrets, HashiCorp Vault. 
```BASH
# From Literal
kubectl create secret generic <secret name> --from-literal=<key>-<value> # Note: generic is added
# From File
kubectl create secret generic <secret name> --from-file=<path-to-file>
# To encode text to base64
echo -n "Hello" | base64
# To view the secret information 
kubectl get secret app-secret -o yaml     # Output in yaml, then decode using base64
echo -n "asas*#" | base64 -d
# To reference a secret in pod definition
envFrom:
  - secretRef:
      name: <secret Name in Metadata>
# To reference a configMap volume in pod definition
volumes:
    - name: app-secret-volume
      secret:
        secretName:  <secret Name in Metadata>    # Note the change of Key
```
## Security Context
- Security Context can be added at Pod and Container level.
- If defined at both levels, container configuration overrides the security context defined at pod level.
- **Note**: Capabilities are only supported at container level and NOT at Pod level.
```BASH
# Adding additional Linux capability during container execution in Docker
docker run --cap-add MAC_ADMIN ubuntu       # Adds additional capability to the container apart from defaults
# Adding security context to Pod
securityContext:
  runAsUser: 1000
  capabilities:
    add: ["MAC_ADMIN"]
```
## Service Accounts
- Service Accounts are used by applications or services and not by humans.
- **Note:** SA cannot be added to existing Pod. Always Delete and add SA to Pod definition to recreate.
- K8s automatically mounts the `default` namespace SA. To override this behavior, set `automountServiceAccountToken: false` in the Pod definition.
```BASH
kubectl create sa dashboard-sa            # Create a SA
kubectl get secret dashboard-sa-token-kdbm  # K8s creates a secret to store the token to auth the service
# You can use the token to run K8s API calls
curl https://192.168.0.10:6443/api -insecure --header "Authorization: Bearer <sa token>"
```
## Resource Requirments
```BASH
1 Gi   - Gibibyte
1 Mi   - Mebibyte
1 Ki   - Kibibyte

1 CPU  = 1 vCPU or 1 Hyperthread

# If a Pod uses more CPU than its limit, it will be throttled.
# If a Pod used more Mem than its limit, it will be terminated.
```
- When a pod is created the containers are assigned a default CPU request of .5 and memory of 256Mi". For the POD to pick up those defaults you must have first set those as default values for request and limit by creating a `LimitRange` in that namespace.
```YAML
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
---
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1
    defaultRequest:
      cpu: 0.5
    type: Container
```
## Taints and Tolerations
- If a taint is placed, by default no pods will be scheduled on the Node.
- Only when a Pod has tolerations matching the taint, will the K8s scheduler place the pod on the tainted node.
- 3 taint-effects:
1. NoSchedule
2. PreferNoSchedule
3. NoExecute
- **Important**: Taints does not neccessarily mean that Pods matching the tolerations will be placed always on that tainted node. It can be placed on another Node which is not tainted. Taints and Tolerations is used only for restricting certain pods from being placed in it. To always place a pod on a tainted node, use `Node Affinity`.
```BASH
# Node Taint
kubectl taint nodes <node name> key=value:taint-effect
# Example
kubectl taint nodes node1 app=blue:NoSchedule
# Tolerations added to Pod definition
tolerations:
- key: "app"            # Note: This is placed under Pod not containers section
  operator: "Equal"     # Note: All values should be doube quoted
  value: "blue"
  effect: "NoSchedule"
# By default, master Node is always tainted. To see the taint
kubectl describe node kubemaster | grep Taint
# To remove the taint from a node, add a minus (-) symbol at the end of the taint with NO spaces in between
kubectl taint nodes node1 app=blue:NoSchedule-    # Note the - with no spaces
```
## Node Selectors
- Labels placed on the Nodes which help scheduler place he pods matching the labels
```BASH
# Adding the lable to the node
kubectl label node <node name> key=value
# Example
kubectl label node node1 size=Large
# NodeSelectors added to Pod definition
nodeSelector:
  size: Large
# Important: Labels are simple and can't be used for complex selection using OR or NOT operators.
# For example: Place Pods in Large or Medium Nodes. OR Place Pods in Nodes which are not Small.
```
## Node Affinity
- To overcome NodeSelector limitations, Affinity and Anti-Affinity is used.
- Node Affinity Types:
1. `requiredDuringSchedulingIgnoredDuringExecution`: The scheduler can't schedule the Pod unless the rule is met. This functions like nodeSelector, but with a more expressive syntax.
2. `preferredDuringSchedulingIgnoredDuringExecution`: The scheduler tries to find a node that meets the rule. If a matching node is not available, the scheduler still schedules the Pod.
- 2 Types of Operators - `In` and `Exists`
- **Important**: Use a combination of taints and tolerations to Deny Pods from being placed on to it. Then Add labels to the Nodes. After that add NodeAffinity to ensure the matching Pod goes to the correct Node.
```YAML
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/os
          operator: In
          values:
          - linux
```
## Multi-Container Pods
- Design Patterns 
1. Side car - Example is a logging container which ships the logs to a central logging service
2. Adapter - Example is a logging container which converts the logs to a standard format before shipping
3. Ambassador - Outsourcing the database connection to a separate container based on environments which acts as a proxy to the database service. The application always refers to the database using a standard dns name.  
```BASH
```
## Init Pods
- In a multi-container pod, each container is expected to run a process that stays alive as long as the POD's lifecycle. For example in the multi-container pod that we talked about earlier that has a web application and logging agent, both the containers are expected to stay alive at all times. The process running in the log agent container is expected to stay alive as long as the web application is running. If any of them fails, the POD restarts.
- But at times you may want to run a process that runs to completion in a container. For example a process that pulls a code or binary from a repository that will be used by the main web application. That is a task that will be run only one time when the pod is first created. Or a process that waits for an external service or database to be up before the actual application starts. That's where initContainers comes in.
- When a POD is first created the initContainer is run, and the process in the initContainer must run to a completion before the real container hosting the application starts.
- You can configure multiple such initContainers as well, like how we did for multi-pod containers. In that case each init container is **run one at a time in sequential order**.
- If any of the initContainers fail to complete, Kubernetes restarts the Pod repeatedly until the Init Container succeeds.
```YAML
containers:
- name: myapp-container
  image: busybox:1.28
  command: ['sh', '-c', 'echo The app is running! && sleep 3600']
initContainers:
- name: init-myservice
  image: busybox
  command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ;']
# Another Example of Sequential execution of Init Containers
containers:
- name: myapp-container
  image: busybox:1.28
  command: ['sh', '-c', 'echo The app is running! && sleep 3600']
initContainers:
- name: init-myservice
  image: busybox:1.28
  command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
- name: init-mydb
  image: busybox:1.28
  command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
```
```BASH
# To debug the Init container logs
kubectl logs -c <Init container name>     # Shows the exact error
```
## Readiness and Liveness Probes
- Status of a Pod Lifecycle: `PodScheduled --> Initialized --> ConatinersReady --> Ready` 
- Liveness - Test for checking if your application is working
- Liveness and Readiness Probes have the same configuration.
```BASH
# Readiness probes based on the protocol
# Http
readinessProbe:
  httpGet:
    path: /api/ready
    port 8080
  initialDelaySeconds: 10     # Tells to wait before checking
  periodSeconds: 5            # Interval between each attempt
  failureThreshold: 8         # How many attempts
# TCP
readinessProbe:
  tcpSocket:
    port: 3306
# Exec
readinesProbe:
  exec:
    command:
      - cat
      - /app/is_ready
```
## Container Logging
```BASH
# Docker Logs
docker run -d kodekloud /event-simulator      # Logs are not streamed as its running in detached mode
docker logs -f <container id>                 # Shows the container logs
# K8s logs
kubectl logs -f event-simulator-pod           # -f = Live streaming of logs
# Multiple containers in pod
# Get pods and see if there are more than 1 containers and then after -c do a tab to see the container names
kubectl logs -f event-simulator-pod -c event-simulator  # You can skip -c and directy mention container name
```
## Monitor and Debug Aplications
- Open sources projects to monitor clusters, Metrics server, Prometheus
- You can have 1 Metrics server per cluster. It is a In-memory solution and does not store data in disk.
- Kubelet agent has cAdvisor (container Advisor) component which extracts performance metrics.
- cAdvisor then makes this data available via the K8s API to the Metrics server.
```BASH
# Download the Metrics server from Github
git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git
# Apply the metric server components
kubectl apply -f .
# OR
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# After metrics is collected after some time lag, run the commands
# To wait for the output to come
watch "kubectl top node" # Note: the command in double quote. Ctrl + c to exit      
kubectl top node         # Get the CPU and memory consumption of each node
kubectl top pod          # Pod performance       
```
## Labels, Selectors and Annotations
```BASH
kubectl get pods --show-labels        # List labels
kubectl get pods -l env=dev           # Filter Labels using short form
kubectl get all --selector=env=prod --no-headers | wc -l   # Filter all objects and remove headers 
kubectl get pods --selector=env=prod,bu=finance,tier=frontend # Logical AND
# Tip
# In ReplicaSet or Service, the matchLabels in the spec.selector section should always match the pod labels in the spec.template.metadata.labels.
# Error: "selector" does not match template 'labels'
```
## Update and Rollback Deployments
- 2 Deployment strategy - RollingUpdate (default) and Recreate
```BASH
# Create Deployments
kubectl create -f deployments-definition.yml          # Using yaml format
# OR
kubectl create deployment my-app-deployment --image=nginx
kubectl apply -f deployments-definition.yml           # To update a deployment
# OR Without changing definition file, updating parameters, 
# NOTE nginx is the container name in existing pod/deployment
kubectl set image deployment/my-app-deployment nginx=nginx:1.9  # Image is upgraded
# Roll-out strategy
kubectl rollout status deployment/my-app-deployment   # Shows rollout status
kubectl rollout history deployment/my-app-deployment  # Shows rollout history and revisions
# You can check the status of each revision individually by using the --revision flag:
kubectl rollout history deployment/my-app-deployment --revision=1 # Shows detailed history
# We can use the --record flag to save the command used to create/update a deployment against the revision number. Change is recorded as annotation in the deployment as "change-cause".
kubectl set image deployment/my-app-deployment nginx=nginx:1.7 --record
# OR
kubectl edit deployments my-app-deployment --record
kubectl rollout undo deployment/my-app-deployment     # Rollsback to previous version
```
## Jobs
```BASH
# Docker execution of mathematical problem
docker run ubuntu expr 3 + 2          # Task is completed and container exits
docker ps -a                          # Shows the exit status of the container
# For batch processing Jobs are used in K8s
kubectl create job throw-dice --image=kodekloud/throw-dice --dry-run=client -o yaml > job.yml
# NOTE: Add backofflimit parameter if its not in the generated template to avoid job from quiting before it succeeds
kubectl get jobs          # list the jobs
kubectl get pods          # lists the pods created by the job
kubectl logs <pod-name>   # shows the pod output
# Running multiple pods in sequence, add completions parameter to the Job spec. 
# NOTE: This is the successful pod completion count, it will keep on recreating pods till this number matches.
# Running multiple pods in parallel, add parallelism parameter to the Job spec along with completion. 
```
## Cronjobs
```BASH
# Min-Hour-DOM-Month-Day of Week (0-6)    # Sun - 0 & 7 both, Sat -6
# spec.schedule is the additional parameter added.
# NOTE: schedule is at the first spec
kubectl create job throw-dice --image=kodekloud/throw-dice --schedule="30 21 * * *"--dry-run=client -o yaml > cronjob.yml
kubectl get cronjob       # list the cronjob
```
## Services
- 3 Types to access a service
1. NodePort: Mapping a port on the Node to a port on the pod
2. ClusterIP: Internal Virtual IP not exposed out of the Node
3. LoadBalancer: External IP which load balances multiple ports on the Node
- NodePort: K8s takes care of deploying the service across all nodes, even though the pod is not on those nodes. This helps in getting the same Nodeport exposed on all the Nodes. When a http call hits a nodeport on a node, K8s will route traffic internally to the Pod on the correct Node. 
```BASH
# NodePort (Node) --> Port (Svc) --> TargetPort (Pod)
# Target Port is the Pod port where the service forwards requests to
# Port is on the Service
kubectl create deployment frontend --replicas=2 \
    --labels=run=load-balancer-example --image=busybox  --port=8080
kubectl expose deployment frontend --type=NodePort --name=frontend-service --port=6262 --target-port=8080 --dry-run=client -o yaml > svc.yml
# This is because we cant control the value of NodePort in imperative command. Edit the yaml file and add the nodePort parameter under spec.ports.port.nodePort 
kubectl get services      # List services
# Take the NodePort and use the Node IP to hit the service from outside the machine 
```
## Ingress Networking
![Ingress Rules](../assets/images/ingress-rules.png)
- Create a `default-backend` deployment to handle routes that are not managed.
![Ingress Default Backend](../assets/images/ingress-default-backend.png)
- Create a service `default-backend-service` to manage 404 error handling and link to the ingress resource.
![Ingress 404 Error](../assets/images/ingress-default-404.png)
![Ingress Host Based](../assets/images/ingress-host-based.png)
![Ingress Definition](../assets/images/ingress-definition.png)
- Ingress needs to be deployed in the same namespace as the deployment & service object.
```BASH
# Imperative command from K8s 1.20
kubectl create ingress <ingress-name> --rule="host/path=service:port"
# Example of Imperative
kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"
kubectl get ingress         # list the ingress
```
### Rewrite Target Option
- Our `watch` app displays the video streaming webpage at `http://<watch-service>:<port>/`
- Our `wear` app displays the apparel webpage at `http://<wear-service>:<port>/`
- We must configure Ingress to achieve the below. When user visits the URL on the left, his request should be forwarded internally to the URL on the right. Note that the /watch and /wear URL path are what we configure on the ingress controller so we can forwarded users to the appropriate application in the backend. 
```HTML
http://<ingress-service>:<ingress-port>/watch` --> http://<watch-service>:<port>/
http://<ingress-service>:<ingress-port>/wear --> http://<wear-service>:<port>/
```
- Without the rewrite-target option, this is what would happen:
```HTML
http://<ingress-service>:<ingress-port>/watch --> http://<watch-service>:<port>/watch
http://<ingress-service>:<ingress-port>/wear --> http://<wear-service>:<port>/wear
```
- **Notice** `watch` and `wear` at the end of the target URLs. The target applications are not configured with `/watch` or `/wear` paths. They are different applications built specifically for their purpose, so they don't expect `/watch` or `/wear` in the URLs. And as such the requests would fail and throw a 404 not found error.
- To fix that we want to **"ReWrite"** the URL when the request is passed on to the `watch` or `wear` applications. We don't want to pass in the same path that user typed in. So we specify the `rewrite-target` option. This rewrites the URL by replacing whatever is under `rules->http->paths->path` which happens to be `/pay` in this case with the value in rewrite-target. This works just like a **search and replace function**.
```BASH
For example: replace(path, rewrite-target)
In our case: replace("/path","/")
```
```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: critical-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /pay
        backend:
          serviceName: pay-service
          servicePort: 8282
```
```BASH
replace("/something(/|$)(.*)", "/$2")
```
- In this ingress definition, any characters captured by (.*) will be assigned to the placeholder $2, which is then used as a parameter in the rewrite-target annotation.
```BASH
rewrite.bar.com/something rewrites to rewrite.bar.com/
rewrite.bar.com/something/new rewrites to rewrite.bar.com/new
```
```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: rewrite
  namespace: default
spec:
  rules:
  - host: rewrite.bar.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /something(/|$)(.*)
```
## Network Policies
![Network Traffic](../assets/images/network-traffic.png)
![Network Traffic Details](../assets/images/network-traffic-details.png)
![Network Pod Traffic](../assets/images/network-pod-traffic.png)
- **Important**: Always look at Network policy from the perspective of the Pod. For Rules - Always pay attention to the **Request** (Ingress) and not the Response (Egress) as that may be already blocked due to cluster wide network policy.
- Example: If DB pod needs to be accessed by API pod, then in DB pod the traffic is Ingress.
- Flannel does not support Network Policy. If Network policy is still applied to this network, it will not have any effect.
- Usecase 1: Rule - Apply Ingress policy using Pod Labels
![Network Policy With Pod Selector](../assets/images/network-policy-1.png)
- Usecase 2: Rule - Apply Ingress policy using Pod Labels and Namespaces
- This is a Logical AND operation where pods have same labels in other namespaces are ignored.
![Network Policy With Pod And Namespace](../assets/images/network-policy-2.png)
- Usecase 3: Rule - Apply Ingress policy using Namespace only
![Network Policy With Namespace](../assets/images/network-policy-3.png)
- Usecase 4: Rule - Apply Ingress policy using External IP
- This is required, where the service resides outside the cluster and the service needs to connect to it.
- Along with the Pod label AND Namesace, External service is an OR. So the Pod should have the correct label AND in the namespace OR extrenal service should have the IP. Either of these 2 rule matches traffic will be allowed.
![Network Policy With External Service](../assets/images/network-policy-4.png)
- Usecase 5: Rule - Apply Ingress policy using 3 Rules and OR operation
- **NOTE**: There is a hypen to `namespaceSelector. This makes it as a separate rule. 
![Network Policy with Logical OR](../assets/images/network-policy-5.png)
- Usecase 6: Rule - Apply Egress policy using External Service
- The traffic is allowed from pod to the external service
![Network Polciy for Egress](../assets/images/network-policy-6.png)
```BASH
kubectl get networkpolicy
```
## Volumes
![Volumes and Host Path](../assets/images/volumes-hostpath.png)
## Persistent Volumes and Claims
![PV and PVC](../assets/images/pv-pvc.png)
- Once you create a PVC use it in a POD definition file by specifying the PVC Claim name under persistentVolumeClaim section in the volumes section like this:
```YAML
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```
```BASH
kubectl get persistentvolume
kubectl get persistentvolumeclaim
```
## Deployment Strategies
1. Recreate
2. RollingUpdate
- The above 2 deployments are native to K8s. While the below 2 needs several steps to complete.
3. Blue Green Deployment
![Blue Deployment](../assets/images/k8s-blue-deploy.png)
![Green Deployment](../assets/images/k8s-green-deploy.png)
![Blue Green Deployment](../assets/images/k8s-blue-green-deploy.png)
- Switch is done in the service object before the blue deployment is killed completely.
4. Canary Deployments
- Reduce the number of replicas in the canary deployment initially, then scale up after testing
![Canary Deployment](../assets/images/k8s-canary-deploy.png)
![Canary Deployment Manifest](../assets/images/k8s-canary-manifest.png)

## Kubeconfig
![Api Server Curl Call](../assets/images/k8s-api-server-curl.png)
![Kubeconfig Default data](../assets/images/kubeconfig-default-data.png)
![Kubeconfig Data Mapping](../assets/images/kubeconfig-mapping.png)
![Kubeconfig Data Mapping with Namespaces](../assets/images/kubeconfig-mapping-namespace.png)
```BASH
kubectl view config     # $HOME/.kube/config file which is default is read
kubectl view config --kubeconfig=my-custom-config   # Pass a config file not in .kube dir
kubectl config use-context prod-user@production   # Sets the current context
```
## API Versions
![K8s API Groups](../assets/images/k8s-apis.png)
![K8s Core API Group](../assets/images/k8s-core-api-group-resources.png)
![K8s Named API Group](../assets/images/k8s-named-api-group-resources.png)
- **Important**: kube proxy != kubectl proxy. 
```BASH
# To access the K8s API from a local server, start the kubectl proxy.
# This proxy will use the kubeconfig data in the default kubeconfig
kubectl proxy           # start the proxy service on port 8001. Use 8001 instead of 6443
kubectl http://localhost:8001 -k    # Shows all the API groups
kubectl http://localhost:8001 -k | grep "name"    # Shows the named API groups
```
## Deprecated AP Versions
![K8s API Versions](../assets/images/k8s-api-versions.png)
![K8s API Versions Identification](../assets/images/k8s-api-version-explain.png)
```BASH
# Convert an old API formatted file to a new stable version
kubectl convert -f <old-file> --output-version <new api version>    
kubectl convert -f nginx.yaml --output-version apps/v1
```

## Authentication and Authorization
- Authentication
![K8s User Account](../assets/images/k8s-user-interaction.png)
![K8s Auth Mechanisms](../assets/images/k8s-auth-mechanisms.png)
![K8s Basic Auth Setup](../assets/images/k8s-basic-auth.png)
![K8s Basic Auth Rest Call](../assets/images/k8s-basic-auth-curl.png)
![K8s Basic Auth Token Rest Call](../assets/images/k8s-basic-auth-token.png)
- Authorization
![K8s Authorization Overview](../assets/images/k8s-author-overview.png)
![K8s Authorization Types](../assets/images/k8s-author-mechanisms.png)
![K8s Node Authorizer](../assets/images/k8s-node-authorizer.png)
![K8s ABAC](../assets/images/k8s-abac.png)
![K8s RBAC](../assets/images/k8s-rbac.png)
![K8s Webhook](../assets/images/k8s-webhook.png)
![K8s Authorization Chaining](../assets/images/k8s-author-chaining.png)
## Roles and Rolebindings
![K8s Roles and Rolebindings](../assets/images/k8s-roles.png)
- **IMPORTANT**: Roles and RoleBindings are namespaced
```BASH
kubectl get roles
kubectl get rolebindngs
# Check access
kubect auth can-i create deployments        # As current user
kubectl auth can-i delete nodes --as dev-user # As an Admin user, you can impersonate and test for another user
```
## Cluster Roles and Clusetr RoleBindings
![K8s Roles and ClusterRole Scope](../assets/images/k8s-role-scope.png)
![K8s ClusterRoles and ClusterRolebindings](../assets/images/k8s-clusterrole.png)
```BASH
kubectl api-resources --namespaced=true     # Get resources which can be added to roles
kubectl api-resources --namespaced=false    # Get resources which can be added to clusterroles
kubectl get clusterroles
kubectl get clusterrolebindngs
```
## Admission Controllers
![K8s Authorization Drawbacks](../assets/images/k8s-author-drawbacks.png)
- Helps implement better security measures.
- Validates configuration.
- Performs additional operations before a pod is created.
![K8s Admission Controllers](../assets/images/k8s-admission-controllers.png)
- **Note**: The `NamespaceExists` and `NamespaceAutoProvision` admission controllers are deprecated and now replaced by `NamespaceLifecycle` admission controller.
- The `NamespaceLifecycle` admission controller will make sure that requests to a non-existent namespace is rejected and that the default namespaces such as `default`, `kube-system` and `kube-public` cannot be deleted.
```BASH
##NOTE:
# Since the kube-apiserver is running as pod you can check the process to see enabled and disabled plugins.
ps -ef | grep kube-apiserver | grep admission-plugins

# To check all the values that are valid for kube-apiserver
kube-apiserver -h | grep enable-admission-plugins   # Shows enabled admin controllers
# Incase kube-apiserver is running as a pod managed by kubeadm
kubectl exec kube-apiserver-controlplane -n kube-system \   # Exec into pod
  -- kube-apiserver -h | grep enable-admission-plugins      # NOTE: -- for comand execution
```
### Validating and Mutating Addmission Controllers
- **Validating AC**: Are the controllers which validate the request that is submitted to the API server
- **Mutating AC**: Are the controllers which change or mutate the request that is submitted to the API server if it does not meet the standards defined.
- Mutating AC are always invoked before Validating AC otherwise some requests may be rejected otherwise.
![K8s Webhook Admission Controller](../assets/images/k8s-webhook-admission-controller.png)
![K8s Webhook Admission Controller Configuration](../assets/images/k8s-webhook-admission-controller-config.png)
```YAML
# A pod with a conflicting securityContext setting: it has to run as a non-root
# user, but we explicitly request a user id of 0 (root).
# Without the webhook, the pod could be created, but would be unable to launch
# due to an unenforceable security context leading to it being stuck in a
# 'CreateContainerConfigError' status. With the webhook, the creation of
# the pod is outright rejected.
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-conflict
  labels:
    app: pod-with-conflict
spec:
  restartPolicy: OnFailure
  securityContext:
    runAsNonRoot: true
    runAsUser: 0
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "echo I am running as user $(id -u)"]
```
## Helm
```BASH
# Install helm
sudo snap install helm
# OR
sudo snap install helm --classic

# This is the default helm repo
helm install wordpress
helm upgrade wordpress
helm rollback wordpress
helm uninstall wordpress

# To work with a custom helm repo
helm repo add bitnami https://charts.bitnami.com/bitnami  # Add a custom helm repository
helm search repo wordpress     # Search for a chart in a named repository
helm install release-1 bitnami/wordpress
helm list
helm uninstall release-1
helm pull --untar bitnami/wordpress   # Just downloads the chart, does not install it
ls wordpress      # to check the chart contents
helm install release-2 ./wordpress
```
