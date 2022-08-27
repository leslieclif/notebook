# Example Apps to run on K8s
- [Kuard](https://github.com/kubernetes-up-and-running/kuard)
- [Kubectl Book](https://kubectl.docs.kubernetes.io/references/kubectl/)
# Kubernetes API
- The Kubernetes API is a RESTful API based on HTTP and JSON and provided by an API server. All of the components in Kubernetes communicate through the API. 
1. **Basic Objects**: Pods, ReplicaSets, and Services
2. **STORAGE**: PERSISTENT VOLUMES, CONFIGMAPS, AND SECRETS
3. **Organizing Your Cluster** with Namespaces, Labels, and Annotations
4. **Advanced Concepts**: Deployments, Ingress, and StatefulSets
# API via Command Line
```BASH
# reveal all the API resources
kubectl get --raw /
# At the top of this list is v1 and under that is namespaces, so request the namespaces
kubectl get --raw /api/v1/namespaces
# One of the namespaces is called default, so request details on the default namespace
kubectl get --raw /api/v1/namespaces/default
# jq is like sed for JSON data. Using jq can make the JSON output from kubectl much easier to read with syntax highlighting.
kubectl get --raw /api/v1/namespaces/default | jq .
# There is also a Python json.tool
kubectl get -v=9 --raw /api/v1/namespaces/default | python -m json.tool
```
- These are all the versions behind the API root path /apis/. In the version list, most of the lines are composed of two parts separated with a slash (/). The left token is the API Group and the right side is the version in that group. 
- Such as: `batch/v1` and `batch/v1beta
`
## Proxy
There is a proxy command that will allow you to access the cluster via localhost. This proxy will run in the background.
```BASH
kubectl proxy 8001 > /dev/null &
# Hit Enter to ensure you get the shell prompt back.
# With this proxy you can access the Kubernetes API locally at the specified port.
curl localhost:8001
curl localhost:8001/api/v1/namespaces/default | jq .
# if you want to stop the proxy, use the command fg to move the proxy to the foregound and then exit the proxy
```
- The easiest way to “access a terminal” within a namespace is to launch a pod with an interactive terminal inside the desired namespace.
```BASH
kubectl run curl --namespace $SESSION_NAMESPACE --image=radial/busyboxplus:curl -i --tty --rm --overrides='{"spec": { "securityContext": { "runAsUser": 1000 }}}'
```

## API-Resources
```BASH
# Get a list of api-resources
kubectl api-resources
# Most resources are associated with Namespaces, however, some cluster scope resources do not make sense to be associated with a Namespace. 
# List the cluster scoped resources
kubectl api-resources --namespaced=false
# As you can see, resources like PersistentVolumes are scoped at the cluster level and not associated with Namespaces.
# Most of the api-resources are grouped. 
# For instance, the two job types are grouped in the batch group.
kubectl api-resources --api-group=batch
# Check Permissions on the User
kubectl auth can-i --list
```
## Explaining Resources
- The Explain command is a great way to understand the defined structure of a resource or kind. 
```BASH
kubectl explain ns
# To get the full structure of this kind, use the --recursive flag
  kubectl explain ns --recursive | less
# Notice the status field phase. Let's display that as an output
kubectl get ns -o custom-columns=NAME:.metadata.name,PHASE:.status.phase
```
## Describe
- Don't confuse the `Explain` command with the `Describe` command. 
- While **Explain** reports on the type of the resource, **Describe** reports the details of the instance of a resource. 
```BASH
kubectl describe namespace kube-system
```

## Cluster Components
```BASH
# Kubernetes proxy is responsible for routing network traffic to load-balanced services in the Kubernetes cluster. To do its job, the proxy must be present on every node in the cluster. 
kubectl get daemonSets --namespace=kube-system kube-proxy
# Kubernetes also runs a DNS server, which provides naming and discovery for the services that are defined in the cluster. Can be replaced by coredns
kubectl get deployments --namespace=kube-system kube-dns [coredns]
# Kubernetes service that performs load-balancing for the DNS server.
kubectl get services --namespace=kube-system kube-dns 
```

## Contexts
```BASH
# creates a new context, but it doesn’t actually start using it yet. 
kubectl config set-context my-context --namespace=mystuff
# use this newly created context
kubectl config use-context my-context
# Contexts can also be used to manage different clusters or different users for authenticating to those clusters using the --users or --clusters flags with the set-context command.
```

## Labeling and Annotating Objects
```BASH
kubectl label pods bar color=red,env=dev        # Add Label
# By default, label and annotate will not let you overwrite an existing label. To do this, you need to add the `--overwrite` flag
# Remove a label, you can use the -<label-name> syntax
kubectl label pods bar color-
kubectl get pods --show-labels
kubectl get pods -L labels            # L adds a custom column called labels in tablular output
kubectl get pods --selector="env=dev"
# If we specify two selectors separated by a comma, only the objects that satisfy both will be returned. This is a logical AND operation:
kubectl get pods --selector="color=red,env=dev"
kubectl label deployments alpaca-test "canary=true"
kubectl get deployments --show-labels
```
============================================================
Operator                    Description
------------------------------------------------------------
key=value                   key is set to value
key!=value                  key is not set to value
key in (value1, value2)     key is one of value1 or value2
key notin (value1, value2)  key is not one of value1 or value2
key                         key is set
!key                        key is not set

- Filter output using jq
`kubectl get pods -n kube-system calico -o json | jq .metadata.labels`

## Debugging Commands
```BASH
kubectl logs <pod-name>                  
# If you have multiple containers in your pod you can choose the container to view using the -c flag.
# If you instead want to continuously stream the logs back to the terminal without exiting, you can add the -f (follow) command-line flag.
# Adding the --previous flag will get logs from a previous instance of the container. This is useful, for example, if your containers are continuously restarting due to a problem at container startup.

# Use the exec command to execute a command in a running container
kubectl exec -it <pod-name> -- bash

# copy files to and from a container using the cp command
kubectl cp <pod-name>:/path/to/remote/file /path/to/local/file
# You can also specify directories, or reverse the syntax to copy a file from your local machine back out into the container.

# A secure tunnel is created from your local machine, through the Kubernetes master, to the instance of the Pod running on one of the worker nodes.
kubectl port-forward nginx 80:8080
```
# Replacing Objects
- Download Deployment or any object into a YAML file and then use the replace command
- Adding `--save-config` adds an annotation so that, when applying changes in the future, kubectl will know what the last applied configuration was for smarter merging of configs. 
```BASH
kubectl get deployments nginx --export -o yaml > nginx-deployment.yaml
kubectl replace -f nginx-deployment.yaml --save-config
```

# Pods
- In general, the right question to ask yourself when designing Pods is, “Will these containers work correctly if they land on different machines?” If the answer is “no,” a Pod is the correct grouping for the containers. If the answer is “yes,” multiple Pods is probably the correct solution. 
- **Declarative configuration** means that you write down the desired state of the world in a configuration and then submit that configuration to a service that takes actions to ensure the desired state becomes the actual state.
- **Imperative configuration**, where you simply take a series of actions (e.g., apt-get install foo) to modify the world. 
- Years of production experience have taught us that maintaining a written record of the system’s desired state leads to a more manageable, reliable system. 
- Pod manifests can be written using YAML or JSON, but YAML is generally preferred because it is slightly more human-editable and has the ability to add comments. 
- All Pods have a termination grace period. By default, this is 30 seconds. 
- **Liveness** health checks run application-specific logic (e.g., loading a web page) to verify that the application is not just still running, but is functioning properly. 
- **Readiness** describes when a container is ready to serve user requests. Containers that fail readiness checks are removed from service load balancers. 
- What probe type (liveness/readiness) should be used for each and what handler should be used (TCP, HTTP, EXEC)? Figure out which ones to use? 
- Port Check - Liveness using TCP handler
- DB Query - Readiness using an EXEC handler executing a SQL query
- **“request”** specifies a minimum. It does not specify a maximum cap on the resources a Pod may use. 
- If a container is over its memory request, the OS can’t just remove memory from the process, because it’s been allocated. Consequently, when the system runs out of memory, the `kubelet` terminates containers whose memory usage is greater than their requested memory. These containers are automatically restarted, but with less available memory on the machine for the container to consume.
- **"limits"** specifies a maximum cap on the resources a Pod may use.
- When you establish limits on a container, the kernel is configured to ensure that consumption cannot exceed these limits. A container with a CPU limit of 0.5 cores will only ever get 0.5 cores, even if the CPU is otherwise idle. A container with a memory limit of 256 MB will not be allowed additional memory.
- **Labels**  selectors are used to filter Kubernetes objects based on a set of labels. 
- **Annotations** provide a place to store additional metadata for Kubernetes objects with the sole purpose of assisting tools and libraries. 
- Annotations can be used for the tool itself or to pass configuration information between external systems.
- There is overlap with labels, and it is a matter of taste as to when to use an annotation or a label. 
- When in doubt, add information to an object as an **annotation** and promote it to a label if you find yourself wanting to use it in a selector.
- During rolling deployments, annotations are used to track rollout status and provide the necessary information required to roll back a deployment to a previous state.
```BASH


```

# Service
- Real service discovery in Kubernetes starts with a Service object.
```BASH
kubectl run alpaca-prod \
  --image=gcr.io/kuar-demo/kuard-amd64:1 \
  --replicas=3 \
  --port=8080 \
  --labels="ver=1,app=alpaca,env=prod"
kubectl expose deployment alpaca-prod
kubectl run bandicoot-prod \
  --image=gcr.io/kuar-demo/kuard-amd64:2 \
  --replicas=2 \
  --port=8080 \
  --labels="ver=2,app=bandicoot,env=prod"
kubectl expose deployment bandicoot-prod
kubectl get services -o wide
```
- After running these commands, we have three services. The ones we just created are alpaca-prod and bandicoot-prod.
- The kubernetes service is automatically created for you so that you can find and talk to the Kubernetes API from within the app.
- **Endpoints** are a lower-level way of finding what a service is sending traffic to.
```BASH
kubectl get endpoints alpaca-prod --watch
```
- At some point, we have to allow new traffic in! The most portable way to do this is to use a feature called **NodePorts**. You use the NodePort without knowing where any of the Pods for that service are running.
```BASH
kubectl expose deployment alpaca-prod --type=NodePort
kubectl describe svc alpaca-prod  # Assume Port 32711 is assigned
#  If your cluster is in the cloud someplace, you can use SSH tunneling with something like this:
ssh <node> -L 8080:localhost:32711
# Now if you open your browser to http://localhost:8080 you will be connected to that service. 
```

# ReplicaSets
- A ReplicaSet acts as a cluster-wide Pod manager, ensuring that the right types and number of Pods are running at all times.
- When we define a ReplicaSet, we define a specification for the Pods we want to create (the “cookie cutter”), and a desired number of replicas. Additionally, we need to define a way of finding Pods that the ReplicaSet should control. The actual act of managing the replicated Pods is an example of a **reconciliation loop**.
-Though ReplicaSets create and manage Pods, they do not own the Pods they create. ReplicaSets use label queries to identify the set of Pods they should be managing. 
- Because ReplicaSets are decoupled from the Pods they manage, you can simply create a ReplicaSet that will “adopt” the existing Pod, and scale out additional copies of those containers. In this way you can seamlessly move from a single imperative Pod to a replicated set of Pods managed by a ReplicaSet. 
- A Pod can be misbehaving but still be part of the replicated set. You can modify the set of labels on the sick Pod. Doing so will disassociate it from the ReplicaSet (and service) so that you can debug the Pod. The ReplicaSet controller will notice that a Pod is missing and create a new copy, but because the Pod is still running, it is available to developers for interactive debugging, which is significantly more valuable than debugging from logs.
- ReplicaSets are designed to represent a single, scalable microservice inside your architecture. ReplicaSets are designed for stateless (or nearly stateless) services. 
## Finding a ReplicaSet from a Pod
- Sometimes you may wonder if a Pod is being managed by a ReplicaSet, and, if it is, which ReplicaSet.
- To enable this kind of discovery, the ReplicaSet controller adds an annotation to every Pod that it creates. - The key for the annotation is `kubernetes.io/created-by`. If you run the following, look for the kubernetes.io/created-by entry in the annotations section:
```BASH
kubectl get pods <pod-name> -o yaml
```
- Note that such annotations are best-effort; they are only created when the Pod is created by the ReplicaSet, and can be removed by a Kubernetes user at any time.
## Finding a Set of Pods for a ReplicaSet
- First, you can get the set of labels using the `kubectl describe` command. 
- To find the Pods that match this selector, use the `--selector` flag or the shorthand `-l`:
```BASH
kubectl get pods -l app=kuard,version=2
```
- This is exactly the same query that the ReplicaSet executes to determine the current number of Pods.
## Scaling ReplicaSets
```BASH
kubectl scale replicasets kuard --replicas=4
```
## Horizontal Pod Autoscaling (HPA)
- HPA requires the presence of the heapster Pod on your cluster. heapster keeps track of metrics and provides an API for consuming metrics HPA uses when making scaling decisions.
```BASH
# Creates an autoscaler that scales between two and five replicas with a CPU threshold of 80%. 
kubectl autoscale rs kuard --min=2 --max=5 --cpu-percent=80
kubectl get hpa
```
## Deleting ReplicaSets
```BASH
# This also deletes the Pods that are managed by the ReplicaSet
kubectl delete rs kuard
# If you don’t want to delete the Pods that are being managed by the ReplicaSet you can set the --cascade flag to false
kubectl delete rs kuard --cascade=false
```
# DaemonSets
- A DaemonSet ensures a copy of a Pod is running across a set of nodes in a Kubernetes cluster. 
- DaemonSets are used to deploy system daemons such as log collectors and monitoring agents, which typically must run on every node. 
- However, there are some cases where you want to deploy a Pod to only a subset of nodes. In cases like these node labels can be used to tag specific nodes that meet workload requirements.
```BASH
# Using a label selector we can filter nodes based on labels. 
kubectl get nodes --selector ssd=true 
```
- Node selectors can be used to limit what nodes a Pod can run on in a given Kubernetes cluster. Node selectors are defined as part of the Pod spec when creating a DaemonSet. 
- The inverse is also true: if a required label is removed from a node, the Pod will be removed by the DaemonSet controller.
- Deleting a DaemonSet will also delete all the Pods being managed by that DaemonSet. Set the `--cascade` flag to false to ensure only the DaemonSet is deleted and not the Pods.

# Jobs
- Jobs are designed to manage batch-like workloads where work items are processed by one or more Pods. By default each Job runs a single Pod once until successful termination.
- `--restart=OnFailure` is the option that tells kubectl to create a Job object.
- Because Jobs have a finite beginning and ending, it is common for users to create many of them. This makes picking unique labels more difficult and more critical. For this reason, the Job object will automatically pick a unique label and use it to identify the pods it creates.
```BASH
kubectl run -i oneshot \
  --image=gcr.io/kuar-demo/kuard-amd64:1 \
  --restart=OnFailure \
  -- --keygen-enable \
     --keygen-exit-on-complete \
     --keygen-num-to-gen 10
# The -i option to kubectl indicates that this is an interactive command. kubectl will wait until the Job is running and then show the log output from the first (and in this case only) pod in the Job.
# All of the options after -- are command-line arguments to the container image. These instruct our test server (kuard) to generate 10 4,096-bit SSH keys and then exit.
kubectl get pod -l job-name=oneshot -a
# Without -a flag kubectl hides completed Jobs. 
kubectl delete jobs oneshot
```
# ConfigMaps
- Configmaps can be used as a set of variables that can be used when defining the environment or command line for your containers. The key thing is that the ConfigMap is combined with the Pod right before it is run. This means that the container image and the pod definition itself can be reused across many apps by just changing the ConfigMap that is used.
- There are three main ways to use a ConfigMap:
> **Filesystem**: You can mount a ConfigMap into a Pod. A file is created for each entry based on the key name. The contents of that file are set to the value.
> **Environment variable**: A ConfigMap can be used to dynamically set the value of an environment variable.
> **Command-line argument**: Kubernetes supports dynamically creating the command line for a container based on ConfigMap values.
```BASH
cat my-config.txt
parameter1 = value1
parameter2 = value2

kubectl create configmap my-config \
  --from-file=my-config.txt \
  --from-literal=extra-param=extra-value \
  --from-literal=another-param=another-value
```
# Secrets
- There is certain data that is extra-sensitive. This can include passwords, security tokens, or other types of private keys. Collectively, we call this type of data “secrets.” 
- Secret data can be exposed to pods using the secrets volume type. Secrets volumes are managed by the kubelet and are created at pod creation time. Secrets are stored on tmpfs volumes (aka RAM disks) and, as such, are not written to disk on nodes.
- Each data element of a secret is stored in a separate file under the target mount point specified in the volume mount. 
```BASH
# The TLS key and certificate for the kuard application can be downloaded by running the following commands.
curl -o kuard.crt  https://storage.googleapis.com/kuar-demo/kuard.crt
curl -o kuard.key https://storage.googleapis.com/kuar-demo/kuard.key
# With the kuard.crt and kuard.key files stored locally, we are ready to create a secret. 
kubectl create secret generic kuard-tls \
  --from-file=kuard.crt \
  --from-file=kuard.key

# Replacing secrets from file
kubectl create secret generic kuard-tls \
  --from-file=kuard.crt --from-file=kuard.key \
  --dry-run -o yaml | kubectl replace -f -
# This command line first creates a new secret with the same name as our existing secret. If we just stopped there, the Kubernetes API server would return an error complaining that we are trying to create a secret that already exists. Instead, we tell kubectl not to actually send the data to the server but instead to dump the YAML that it would have sent to the API server to stdout. We then pipe that to kubectl replace and use -f - to tell it to read from stdin. In this way we can update a secret from files on disk without having to manually base64-encode data.
```
- Extracting secrets into a file
```BASH
kubectl get secret demo-secret -o json | jq -r .data.value | base64 --decode > ./demo-secret
# Output the value of secret as JSON, run JQ to parse the output
# As the secret data is base64 encoded, decode it before writing the data to the client machine
```
# Deployments
- The Deployment object exists to manage the release of new versions. 
-In the output of describe there is a great deal of important information.
Two of the most important pieces of information in the output are `OldReplicaSets `and `NewReplicaSet`. These fields point to the ReplicaSet objects this Deployment is currently managing. If a Deployment is in the middle of a rollout, both fields will be set to a value. If a rollout is complete, OldReplicaSets will be set to <none>.
- You can use `kubectl rollout history` to obtain the history of rollouts associated with a particular Deployment. If you have a current Deployment in progress, then you can use `kubectl rollout status` to obtain the current status of a rollout.
- You can `undo` both partially completed and fully completed rollouts. An undo of a rollout is actually simply a rollout in reverse (e.g., from v2 to v1, instead of from v1 to v2), and all of the same policies that control the rollout strategy apply to the undo strategy as well. 
- Specifying a revision of `0` is a shorthand way of specifying the previous revision. Or `kubectl rollout undo`
- If you ever want to manage that ReplicaSet directly, you need to delete the Deployment (remember to set `--cascade` to false, or else it will delete the ReplicaSet and Pods as well!).
```BASH
# You can see the label selector
kubectl get deployments nginx \
  -o jsonpath --template {.spec.selector.matchLabels}     
# From this you can see that the Deployment is managing a ReplicaSet with the labels run=nginx. 
kubectl get replicasets --selector=run=nginx
# If you are in the middle of a rollout and you want to temporarily pause it for some reason (e.g., if you start seeing weird behavior in your system and you want to investigate), you can use the pause command:
kubectl rollout pause deployments nginx
# If, after investigation, you believe the rollout can safely proceed, you can use the resume command to start up where you left off:
kubectl rollout resume deployments nginx
# You can see the deployment history by running:
kubectl rollout history deployment nginx
# If you are interested in more details about a particular revision, you can add the --revision flag to view details about that specific revision:
kubectl rollout history deployment nginx --revision=2
# You can roll back to a specific revision in the history using the --to-revision flag:
kubectl rollout undo deployments nginx --to-revision=3
```
- **NOTE:** When you do a kubectl rollout undo you are updating the production state in a way that isn’t reflected in your source control.
An alternate (and perhaps preferred) way to undo a rollout is to revert your YAML file and kubectl apply the previous version. In this way your “change tracked configuration” more closely tracks what is really running in your cluster.
## Deployment strategies 
- Deployment strategies for `rollingUpdate` using the `maxUnavailable `parameter or the `maxSurge` parameter.
- The **maxUnavailable** parameter sets the maximum number of Pods that can be unavailable during a rolling update. 
- It can either be set to an absolute number (e.g., 3 meaning a maximum of three Pods can be unavailable) or to a percentage (e.g., 20% meaning a maximum of 20% of the desired number of replicas can be unavailable). Generally speaking, using a percentage is a good approach for most services, since the value is correctly applicable regardless of the desired number of replicas in the Deployment.
- If you have four replicas and have set maxUnavailable to 50%, it will scale it down to two replicas. The rolling update will then replace the removed pods by scaling the new ReplicaSet up to two replicas, for a total of four replicas (two old, two new). It will then scale the old ReplicaSet down to zero replicas, for a total size of two new replicas. Finally, it will scale the new ReplicaSet up to four replicas, completing the rollout. Thus, with maxUnavailableset to 50%, our rollout completes in four steps, but with only 50% of our service capacity at times.
- However, there are situations where you don’t want to fall below 100% capacity, but you are willing to temporarily use additional resources in order to perform a rollout. In these situations, you can set the `maxUnavailable parameter to 0%`, and instead control the rollout using the `maxSurge `parameter.
- The **maxSurge** parameter controls how many extra resources can be created to achieve a rollout. 
- To illustrate how this works, imagine we have a service with 10 replicas. We set maxUnavailable to 0 and maxSurge to 20%. The first thing the rollout will do is scale the new ReplicaSet up to 2 replicas, for a total of 12 (120%) in the service. It will then scale the old ReplicaSet down to 8 replicas, for a total of 10 (8 old, 2 new) in the service. This process proceeds until the rollout is complete. At any time, the capacity of the service is guaranteed to be at least 100% and the maximum extra resources used for the rollout are limited to an additional 20% of all resources.
- Setting `maxSurge to 100% `is equivalent to a **blue/green deployment**. The Deployment controller first scales the new version up to 100% of the old version. Once the new version is healthy, it immediately scales the old version down to 0%.
- Setting `minReadySeconds to 60` indicates that the Deployment must wait for 60 seconds after seeing a Pod become healthy before moving on to updating the next Pod.
- To set the timeout period, the Deployment parameter `progressDeadlineSeconds is set to 600`. This sets the progress deadline to 10 minutes. If any particular stage in the rollout fails to progress in 10 minutes, then the Deployment is marked as failed, and all attempts to move the Deployment forward are halted.

# Ingress
- **Service** objects provide a great way to do simple **TCP-level** load balancing, they don’t provide an application-level way to do load balancing and routing.
- The truth is that most of the applications that users deploy using containers and Kubernetes are HTTP web-based applications. These are better served by a load balancer that understands HTTP. To address these needs, the Ingress API was added to Kubernetes.
- **Ingress** represents a **path and host-based** HTTP load balancer and router. When you create an Ingress object, it receives a **virtual IP address** just like a Service, but instead of the one-to-one relationship between a Service IP address and a set of Pods, an Ingress can use the content of an HTTP request to route requests to different Services.

# StatefulSets
- Some applications, especially stateful storage workloads or sharded applications, require more differentiation between the replicas in the application. To resolve this, Kubernetes has recently introduced StatefulSets as a **complement** to ReplicaSets, but for more stateful workloads.
- Like ReplicaSets, **StatefulSets** create multiple instances of the same container image running in a Kubernetes cluster, but the manner in which containers are created and destroyed is **more deterministic**, as are the names of each container.
- With StatefulSets, each replica receives a monotonically increasing index (e.g., backed-0, backend-1, and so on). 
- StatefulSets guarantee that replica zero will be created and become healthy before replica one is created and so forth. 
- StatefulSets receive DNS names so that each replica can be accessed directly. This allows clients to easily target specific shards in a sharded service.
