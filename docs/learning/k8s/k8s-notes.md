- [Tailing logs from multiple containers on laptop](https://github.com/wercker/stern)
- [K8s Tutorials](https://kubernetes.io/docs/tutorials/)
- [K8s DNS](https://github.com/kubernetes/dns/blob/master/docs/specification.md)
- [Kubectl Usage Convention](https://kubernetes.io/docs/reference/kubectl/conventions/)
- [K8s API Reference](https://kubernetes.io/docs/reference/#api-reference)
- [Operator Hub](https://operatorhub.io/)
- [Awesome Operator List](https://github.com/operator-framework/awesome-operators)
- [Creating EKS using Terraform](https://medium.com/swlh/kubernetes-launching-a-full-eks-cluster-in-13-steps-more-or-less-59451d3b115c)
# Why Kubernetes
- Orchestration: Next logical step in journey to faster DevOps
- First, understand why you *may* need orchestration
- Not every solution needs orchestration
- Servers + Change Rate = Benefit of orchestration

## K8s Learning Resources
- [Play with k8s](http://play-with-k8s.com)
- [Katacoda](http://katacoda.com)

## Install Kubernetes
- Linux - Microk8s
Install SNAP first using apt-get
```DOCKER
sudo snap install microk8s --classic --channel=1.17/stable # Install specific k8s version
microk8s.enable dns # Enbale DNS 
microk8s.status # Check status
```

- Windows - Minikube
```DOCKER
minikube start --kubernetes-version='1.17.4' # Install specific k8s version
minikube ip # IP of the machine
minikube status # Check status 
minikube stop # Stop minkube service    
```
## Kubernetes Container Abstractions
- Pod: one or more containers running together on one Node. Basic unit of deployment. Containers are always in pods
- Controller: For creating/updating pods and other objects. Many types of Controllers inc. Deployment, ReplicaSet, StatefulSet, DaemonSet, Job, CronJob, etc.
- Service: network endpoint to connect to a pod
- Namespace: Filtered group of objects in cluster - Secrets, ConfigMaps, and more.
## Our First Pod With Kubectl run
- Two ways to deploy Pods (containers): Via commands, or via YAML
- Object hieracrhy - Pods -> ReplicaSet -> Deployment
```DOCKER
kubectl run my-nginx --image nginx # Creates a single pod
kubectl run nginx-pod --generator=run-pod/v1 --
image nginx # Another way to create pod
kubectl get pods # list the pod
kubectl create deployment nginx --image nginx # Creates a deployment
kubectl deployment deployment nginx # Deletes a deployment
kubectl create deployment nginx --image nginx --dry-run --port 80 --
expose # Using Dry run option
```
## Scaling ReplicaSets

```DOCKER
kubectl create deployment my-apache --image httpd
kubectl scale deploy/my-apache --replicas 2 # Scale up by 2
kubectl scale deployment my-apache --replicas 2 # Scale up by 2
kubectl get all
```
## Inspecting Kubernetes Objects

```DOCKER
kubectl get deploy,pods # Get multiple resources in one line
kubectl get pods -o wide # Get all pods, in wide format (gives more info)
kubectl get pods --show-labels # Get all pods and show labels
kubectl logs deployment/my-apache 
kubectl logs deployment/my-apache --follow --tail 1 # Show the last line
kubectl logs -l run=my-apache # Show logs using label
kubectl describe pod/my-apache-<pod id> # Shows the pod configuration including events
kubectl get pods -w # Watches the pods in real time
kubectl delete pod/my-apache-<pod id> # Deletes a single instance
```
# Exposing Kubernetes Ports
- A service is a stable address for pod(s)
- If we want to connect to pod(s), we need a service
- CoreDNS allows us to resolve services by name
- There are different types of services
1. ClusterIP
1. NodePort
1. LoadBalancer
1. ExternalName
- ClusterIP and NodePort services are always available in Kubernetes
- `kubectl expose` creates a service for existing pods
## Basic Service Types
1. ClusterIP (default)
- Single, internal virtual IP allocated
- Only reachable from within cluster (nodes and pods)
- Pods can reach service on apps port number
2. NodePort
- High port allocated on each node
- Port is open on every node’s IP
- Anyone can connect (if they can reach node)
- Other pods need to be updated to this port
3. LoadBalancer
- Controls a LB endpoint external to the cluster
- Only available when infra provider gives you a LB (AWS ELB, etc)
- Creates NodePort+ClusterIP services, tells LB to send to NodePort
4. ExternalName
- Adds CNAME DNS record to CoreDNS only
- Not used for Pods, but for giving pods a DNS name to use for something outside Kubernetes

```DOCKER
# To show how to reach a ClusterIP deployment which is only accessible from the cluster in a Laptop
kubectl create deployment httpenv --image=bretfisher/httpenv # simple http server
kubectl scale deployment/httpenv --replicas=5
kubectl expose deployment/httpenv --port 8888 # Create a ClusterIP service (default)
kubectl get service # Shows services
# Uses Generator option and launches the pod and gives BASH terminal
kubectl run --generator run-pod/v1 tmp-shell --rm -it --image bretfisher/netshoot -- bash # Launch another pod to run curl
curl httpenv:8888
curl [ip of service]:8888 # 
```
## Creating a NodePort and LoadBalancer Service
- Nodeport Port Range: 30000 to 32767
- Did you know that a NodePort service also creates a ClusterIP?
- These three service types are additive, each one
creates the ones above it:
1. ClusterIP
1. NodePort
1. LoadBalancer
- If you're on Docker Desktop, it provides a built-in LoadBalancer
that publishes the --port on localhost
- If you're on kubeadm, minikube, or microk8s
1. No built-in LB
1. You can still run the command, it'll just stay at
- LoadBalancer recieves the packet on 8888, then transfers it to the Nodeport of the Node and then to the ClusterIP of the service.
"pending" (but its NodePort works)
```DOCKER
kubectl expose deployment/httpenv --port 8888 --name httpenv-np --type NodePort
kubectl get services
curl localhost:<Node Port> # Get this from svc output
kubectl expose deployment/httpenv --port 8888 --name httpenv-lb --type LoadBalancer
kubectl get services
curl localhost:8888 # Pod Port
kubectl delete service/httpenv service/httpenv-np
kubectl delete service/httpenv-lb deployment/httpenv
```
## Kubernetes Services DNS
- Internal DNS is provided by CoreDNS
- Services also have a FQDN
> curl `<hostname>.<namespace>.svc.cluster.local`
```DOCKER
curl <hostname>
kubectl get namespaces
curl <hostname>.<namespace>.svc.cluster.local
```
# Kubernetes Management Techniques
## Run, Expose and Create Generators
- These commands use helper templates called "generators"
- Every resource in Kubernetes has a specification or "spec"
- You can output those templates with --dry-run -o yaml
> kubectl create deployment sample --image nginx --dry-run -o yaml
- You can use those YAML defaults as a starting point
- Generators are "opinionated defaults"
### Generator Examples
• Using dry-run with yaml output we can see the generators
> kubectl create deployment test --image nginx --dry-run -o yaml
> kubectl create job test --image nginx --dry-run -o yaml
> kubectl expose deployment/test --port 80 --dry-run -o yaml
- You need the deployment to exist before this works

## Imperative vs. Declarative

> **Imperative**: Focus on how a program operates

>**Declarative**: Focus on what a program should accomplish
- Example: "I'd like a cup of coffee"
> **Imperative**: I boil water, scoop out 42 grams of medium-fine
grounds, poor over 700 grams of water, etc.

> **Declarative**: "Barista, I'd like a a cup of coffee".
(Barista is the engine that works through the
steps, including retrying to make a cup, and is
only finished when I have a cup)

### Kubernetes Imperative
- Examples: 
> kubectl run, kubectl create deployment, kubectl update
- We start with a state we know (no deployment exists)
- We ask kubectl run to create a deployment
- Different commands are required to change that deployment
- Different commands are required per object
- Imperative is easier when you know the state
- Imperative is easier to get started
- Imperative is easier for humans at the CLI
- Imperative is NOT easy to automate
### Kubernetes Declarative
- Example: 
> kubectl apply -f my-resources.yaml
- We don't know the current state
- We only know what we want the end result to be (yaml contents)
- Same command each time (tiny exception for delete)
- Resources can be all in a file, or many files (apply a whole dir)
- Requires understanding the YAML keys and values
- More work than `kubectl run` for just starting a pod
- The easiest way to automate
- The eventual path to GitOps happiness

## Three Management Approaches
1. Imperative commands:
> run, expose, scale, edit, create deployment
- Best for dev/learning/personal projects
- Easy to learn, hardest to manage over time
- [Imperative Commands](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/imperative-command/)
2. Imperative objects: 
> create -f file.yml, replace -f file.yml, delete...
- Good for prod of small environments, single file per command
- Store your changes in git-based yaml files
- Hard to automate
- [Imperative Config File](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/imperative-config/)
3. Declarative objects: apply -f file.yml or dir\, diff
- Best for prod, easier to automate
- Harder to understand and predict changes
- [Declarative Config File](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/)

## Recommendations
1. **Most Important Rule**: Don't mix the three approaches
2. Recommendations:
- Learn the Imperative CLI for easy control of local and test setups
- Move to apply -f file.yml and apply -f directory\ for prod
- Store yaml in git, git commit each change before
you apply
- This trains you for later doing GitOps (where git
commits are automatically applied to clusters)

# Moving to Declarative Kubernetes YAML
## Using kubectl apply
- create/update resources in a file
> kubectl apply -f myfile.yaml

- create/update a whole directory of yaml
> kubectl apply -f myyaml/

- create/update from a URL
> kubectl apply -f https://bret.run/pod.yml

- Be careful, lets look at it first (browser or curl)
```BASH 
# Using Shell 
curl -L https://bret.run/pod
# Using Windows CMD 
Win PoSH? start https://bret.run/pod.yml
```
## Kubernetes Configuration YAML
- Kubernetes configuration file (YAML or JSON)
- Each file contains one or more manifests
- Each manifest describes an API object (deployment, job, secret)
- Each manifest needs four parts (root key:values in the file)
```BASH
apiVersion:
kind:
metadata:
spec:
```
## Building Your YAML Files
1. **kind**: We can get a list of resources the cluster supports
> kubectl api-resources
- Notice some resources have multiple API's (old vs. new)
2. **apiVersion**: We can get the API versions the cluster supports
> kubectl api-versions
3. **metadata**: only name is required
4. **spec**: Where all the action is at!

## Building Your YAML spec - explain Command
- We can get all the keys each kind supports
> kubectl explain services --recursive
- Oh boy! Let's slow down
> kubectl explain services.spec
- We can walk through the spec this way
> kubectl explain services.spec.type
- spec: can have sub spec: of other resources
> kubectl explain deployment.spec.template.spec.volumes.nfs.server

!!! info "Use `kubectl api-versions` or `kubectl api-resources` along with `kubectl explain` as documentation on explain could be old"

- We can also use docs
> kubernetes.io/docs/reference/#api-reference

## Dry Runs With Apply YAML
- dry-run a create (client side only)
> kubectl apply -f app.yml --dry-run
- dry-run a create/update on server
> kubectl apply -f app.yml --server-dry-run
- see a diff visually
> kubectl diff -f app.yml
- [Difference between dry-run and diff](https://kubernetes.io/blog/2019/01/14/apiserver-dry-run-and-kubectl-diff/)

## Labels and Label Selectors

- **Labels** goes under metadata: in your YAML
- Simple list of key: value for identifying your resource later by
selecting, grouping, or filtering for it
- Common examples include tier: 
> frontend, app: api, env: prod,
customer: acme.co
- Not meant to hold complex, large, or non-
identifying info, which is what **annotations** are for
- filter a get command
> kubectl get pods -l app=nginx
- apply only matching labels
> kubectl apply -f myfile.yaml -l app=nginx
- [Label Recommendation](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)

### Label Selectors (Use case for Labels)
- The "glue" telling Services and Deployments which pods are theirs
- Many resources use Label Selectors to "link" resource dependencies
- You'll see these match up in the **Service and Deployment YAML**
- [Using Label selectors ](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors)
- Use Labels and Selectors to control which pods go to which nodes
- [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- Taints and Tolerations also control node placement
- [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

# Your Next Steps, and The Future of Kubernetes
## Storage in Kubernetes
- Storage and stateful workloads are harder in all systems
- Containers make it both harder and easier than before
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) is a new resource type, making Pods more sticky
- **Recommendation**: avoid stateful workloads for first few
deployments until you're good at the basics
- Use db-as-a-service whenever you can

### Volumes in Kubernetes
- Creating and connecting Volumes: 2 types
1. [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- Tied to lifecycle of a Pod
- All containers in a single Pod can share them
2. [PersistentVolumes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)
- Created at the cluster level, outlives a Pod
- Separates storage config from Pod using it
- Multiple Pods can share them
> CSI plugins are the new way to connect to storage

## [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- None of our Service types work at OSI Layer 7 (HTTP)
- How do we route outside connections based on hostname or URL?
> Example Usecase: app1.com and app2.com are 2 different deployments in the cluster and both listen on port 443. You will need Ingress to understand the DNS and route traffic to those apps
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) (optional) do this with 3rd party proxies
- Nginx is popular, but Traefik, HAProxy, F5, Envoy, Istio, etc.
- Recommendation: Check out [Traefik](https://doc.traefik.io/traefik/v2.0/providers/kubernetes-crd/#traefik-ingressroute-definition)
- Implementation is specific to Controller chosen
- Why Controller - To configure LB which is outside the cluster

## [CRD's](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) and [The Operator Pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- You can add 3rd party Resources and Controllers
- This extends Kubernetes API and CLI
- A pattern is starting to emerge of using these together
- **Operator**: automate deployment and management of complex apps
> e.g. Databases, monitoring tools, backups, and custom ingresses

## Higher Deployment Abstractions
- All our kubectl commands just talk to the Kubernetes API
- Kubernetes has limited built-in templating, versioning, tracking,
and management of your apps
- **Helm** is the most popular
- **[Compose on Kubernetes](https://github.com/docker/compose-on-kubernetes/tree/master/docs)** comes with Docker
Desktop
- Remember these are optional, and your distro may have a preference
- Most distros support Helm
### Templating YAML
- Many of the deployment tools have templating options
- You'll need a solution as the number of environments/apps grow
- Helm was the first "winner" in this space, but can be complex
- Official [Kustomize](https://kubernetes.io/blog/2018/05/29/introducing-kustomize-template-free-configuration-customization-for-kubernetes/) feature works out-of-the-box (as of 1.14)
- docker app and compose-on-kubernetes are Docker's way

## [Kubernetes Dashboard](https://github.com/kubernetes/dashboard)
- Default GUI for "upstream" Kubernetes
- Clouds don't have it by default
- Let's you view resources and upload YAML
- Safety first!

## [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/ ) and [Context](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
- Namespaces limit scope, aka "virtual clusters"
- Not related to Docker/Linux namespaces
- Won't need them in small clusters
- There are some built-in, to hide system stuff from kubectl "users"
> `kubectl get namespaces`

> `kubectl get all --all-namespaces`
- Context changes kubectl cluster and namespace
- See `~/.kube/config` file
> `kubectl config get-contexts`
```DOCKER 
# Selectively show output of Kube config
kubectl config get-contexts -o name
```
> `kubectl config set*`

```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
