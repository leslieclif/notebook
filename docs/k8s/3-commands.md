# Useful subcommand
```BASH
kubectl set             # k set --help will tell you what parameters can be set
kubectl label
kubectl scale
kubectl edit
```
```BASH
kns default         # alias to set context to default
kubectl create deployment examplehttpapp --image=katacoda/docker-http-server --replicas=2
kubectl get deployments
kubectl get pods -o wide 
kubectl get pods -L labels            # L adds a custom column called labels in tablular output
# Set
# Changing images on both the pods at the same time
kubectl set image deploy examplehttpapp *=nginx:1.19
# Check if image has been updated
kubectl describe po <podname> | grep -i image   # -i for insensitive search
kubectl describe po <podname> | grep -i image -A 2  # -A for showing next 2 lines 'A'fter match
kubectl create ns testns
kns testns              # alias to set context to testns
kubectl create deployment namespacedeg -n testns --image=katacoda/docker-http-server
kubectl get pods -n testns
# Scaling
kns default             # alias to set context to default
kubectl scale deployment examplehttpapp --replicas=5 --record           # record is important for scaling
kubectl --record=true set image deployment examplehttpapp docker-http-server=katacoda/docker-http-server:v2
kubectl rollout status deployment examplehttpapp        # It will show 2 change cause records
kubectl rollout undo deployment examplehttpapp          # Incase you want to undo the last change
# Labels
# Edit
kubectl edit deploy examplehttpapp          # Change the image, another way to do instead of set

kubectl expose deployment examplehttpapp --port 80
kubectl get svc -o wide
kubectl describe svc examplehttpapp
# Incase you just want to see the labels on the svc, instead of describe
kubectl get svc --show-labels

kubectl get services -l app=examplehttpapp -o go-template='{{(index .items 0).spec.clusterIP}}'
curl $(kubectl get services -l app=examplehttpapp -o go-template='{{(index .items 0).spec.clusterIP}}')
kubectl logs $(kubectl get pods -l app=examplehttpapp -o go-template='{{(index .items 0).metadata.name}}')
```

- Create a temporary Pod and execute the `wget` command inside of its container using the IP address and the container port.

```BASH
kubectl run busybox --image=busybox --rm -it --restart=Never -n ckad -- wget 10.244.1.2:80
```


# All Commands
```BASH
#################
# How to navigate through your cluster.
#################

# To see only the Kubernetes kubectl client version and not the Kubernetes version
kubectl version --client=true
# You might need to gather information about the endpoints of the master and services in the cluster. This information will come in handy if you have to troubleshoot your cluster.
kubectl cluster-info
# Command autocompletion help and options
kubectl completion -h
# setup is using the bash shell
source <(kubectl completion bash)
# check the status of the Nodes
kubectl get no
# various Namespaces that are critical to Kubernetes operations
kubectl get ns
# look at the Pods in the cluster
kubectl get po
kubectl get po -n kube-system
# see the Pods in all the Namespaces
kubectl get pods -A
# see deployments
kubectl get deploy
# Shows key information about the Deployment such as:
# Labels, Number of Replicas, Annotations, Deployment Strategy Type, Events
kubectl describe deploy nginx
# Get additional information on the Pods 
kubectl get pod -o wide
# YAML output format
kubectl get pod -o yaml
# sort the output of queries, you can use the --sort-by flag
# sort by various data points for pod specs like
# Pod Ip, Pod name, Pod nodeName, Pod hostname, Pod volumes
kubectl get pod -o wide --sort-by=.status.podIP
kubectl get pod -o wide --sort-by=.spec.podName
# Get the documentation for Kubernetes resources such as Pods or Services: 
kubectl explain deployment
# View all the supported resource types: 
kubectl api-resources
# View all the resources
kubectl get all

#################
# How to switch between contexts and namespaces
# How to find resources and format their output
# How to update, patch, delete, and scale resources
#################

# View kubectl configuration
kubectl view config
# list of all our configured clusters 
kubectl config get-clusters
# From above 2 commands, you can see for example - there is currently one cluster named kubernetes and one user named kubernetes-admin.  
# Same can be seen in one line with below command. In this case, the context is kubernetes-admin@kubernetes.
kubectl config current-context
# create a new kubectl context using the existing kubernetes-admin user.
kubectl config set-context dev-context --cluster kubernetes --user=kubernetes-admin
kubectl config get-contexts
# Notice that the current active context is set to kubernetes-admin@kubernetes
# To switch to the dev-context context
kubectl config use-context dev-context
# Let's switch back to the kubernetes-admin@kubernetes context
kubectl config use-context kubernetes-admin@kubernetes
# As you can see, switching back and forth between contexts with the above kubectl command can be very tedious especially when dealing with multiple contexts.
# The alternative would be to install kubectx.
# When the installion is done, type the kubectx command to list all the contexts:
kubectx
# Notice that the current active context kubernetes-admin@kubernetes is highlighted in yellow
# To switch between contexts, you can now type kubectx CONTEXT NAME.
kubectx dev-context
# Go ahead and switch back to the kubernetes-admin@kubernetes context:
kubectx kubernetes-admin@kubernetes

# to create the namespace:
kubectl create ns frontend
# Declarative method
kubectl create namespace backend -o yaml --dry-run=client > ns-backend.yaml
kubectl apply -f ns-backend.yaml
# deploy a single redis container
kubectl run redis --image=quay.io/quay/redis -n backend
kubectl run nginx --image=quay.io/bitnami/nginx -n frontend
kubectl get pods -n frontend

# Switch to the appropriate namespace context where the resources live without having to specify ns
kubectl config set-context --current --namespace=frontend
# If you are constantly switching between namespaces and want to avoid using the long kubectl command above, then the kubens plugin becomes handy.
# Let's list all the namespaces using the kubens command.
kubens
# Notice again, the current active namespace default is highlighted in yellow.
# let's switch to the frontend namespace 
kubens frontend
# switch back to the default namespace:
kubens default

# You can use the --selector flag to filter and find resources based on their assigned labels. 
# Use the deployment yaml mentioned below
kubectl create -f ~/label-deploy.yaml
kubectl get pods -n frontend --show-labels
# find all the pods that have the label app: web in the frontend namespace:
kubectl get pods -n frontend --selector=app=web
# You can also use the -l flag, which represents label and is equivalent to the --selector flag.
kubectl get pods -n frontend -l app=haproxy
# let's find nodes within our cluster that do NOT have the taint label: node-role.kubernetes.io/master
kubectl get nodes --selector='!node-role.kubernetes.io/master'
# As you can see, the --selector or -l flags could come in very handy when identifying thousands of kubernetes resources with differing labels.

# Use jsonpath to find/filter resources
# The -o=jsonpath flag with the kubectl command allows you to filter resources and display them in the way you desire.

#  Let's say we want to find the names of all the kubernetes nodes along with their CPU resources. 
kubectl get nodes -o=jsonpath='{.items[*].metadata.name} {.items[*].status.capacity.cpu}'
# As you may notice, the output does not look pretty. What if we add a \n (newline character) between the two JSONPath pairs as:
kubectl get nodes -o=jsonpath='{.items[*].metadata.name}{"\n"}{.items[*].status.capacity.cpu}{"\n"}'

# we wanted to get an output that is formatted as the output shown below:
# master   2
# node01   4
# To achieve this, we would use the range JSONPath operator to iterate through each item (nodes in this case) and use tabulation \t as well as new line \n characters to achieve the desired output.
# To do this in JSONPath, we would use the range and end operators
kubectl get nodes -o=jsonpath='{range  .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\n"}{end}'

# Format output with custom-columns
# we want to get all nodes within our cluster and nicely format the output with a column header called NAME.
kubectl get nodes -o=custom-columns=NAME:.metadata.name
# You can add additional columns to the above command by adding JSONPath pairs (COLUMN HEADER:.metadata) separated by a comma.
kubectl get nodes -o=custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu
# let's find all the pods that were deployed and output them in a tabulated format with column headers POD_NAME and IMAGE_VER:
kubectl get pods -n frontend -o custom-columns=POD_NAME:.metadata.name,IMAGE_VER:.spec.containers[*].image

# Scale resources
kubectl create deployment nginx-deployment --image=quay.io/bitnami/nginx:1.20
kubectl scale deploy nginx-deployment --replicas=5
# scale the deployment down to 1 replica
kubectl scale deploy/nginx-deployment --replicas=1

# Update resources 
# we are going to update the nginx image from nginx:1.20 to nginx:1.21 with no downtime. 
kubectl set image deployment/nginx-deployment nginx=quay.io/bitnami/nginx:1.21 --record
# watch the status of the nginx-deployment deployment's rollingUpdate changes until completion. 
kubectl rollout status -w deployment/nginx-deployment
# output of the rollout history
kubectl rollout history deployment/nginx-deployment
# To undo the update
kubectl rollout undo deployment/nginx-deployment
# Let's change the image version back to nginx:1.21
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Patch and label resources
# Patching can be used to partially update any kubernetes resources such as nodes, pods, deployments, etc.
# we are going to deploy an nginx pod with a label of env: prod 
kubectl run nginx --image=quay.io/bitnami/nginx --labels=env=prod
kubectl get pod nginx --show-labels
# let's update the label to env=dev using the patch command:
kubectl patch pod nginx -p '{"metadata":{"labels":{"env":"dev"}}}'
kubectl get pod nginx --show-labels
# We can also use the kubectl label command to add a label, update an existing label, or delete a label. 
kubectl label pod nginx env=prod --overwrite
# Note: the --overwrite flag is used when the label already exists.
# To delete the label, append the - to env , which is the value of the label's key. 
# Alternatively, use the kubectl edit pod nginx command and manually edit the .metadata.label.env and save your changes.

# Delete resources
kubectl delete pod nginx

#################
# Advanced kubeclt commands that can be used in the field as a cluster operator/administrator. 
# > krew a kubectl plugin manager
# > Interaction with pods
#     kubectl logs
#     kubectl cp
#     kubectl exec
# > Interacting with nodes:
#     kubectl taint
#     Pod's Tolerations
#     kubectl cordon/uncordon
#     kubectl drain
#     kubectl top
#################

# krew is a plugin manager for kubectl.
#  We will be using the following plugins:
# access-matrix - shows an RBAC (role based access control) access matrix for server resources
# ns - view or change switch namespace contexts
# ctx - switch between Kubernetes cluster contexts

# Let's discover some of these plugins:
kubectl krew search
# Install plugins via krew
cat > ~/plugins <<EOF
access-matrix
ca-cert
ctx
get-all
iexec
images
ns
pod-dive
pod-logs
whoami
who-can
EOF
# Install the plugins
for plugin in $(cat ~/plugins); do echo -en $(kubectl krew install $plugin);done
# Verify and list the installed plugins:
kubectl krew list
# You can also list the installed plugins:
kubectl plugin list
# We can begin by listing who the current authenticated user is:
kubectl whoami
# Let's also look at the who-can plugin, which is equivalent to the kubectl auth can-i VERB [TYPE/NAME]:
kubectl who-can create nodes
kubectl who-can '*' pods
# list the namespaces:
kubectl ns
# Let's get the name of the first pod, assign it to a variable and run the pod-dive plugin:
POD=$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}') && echo $POD
kubectl pod-dive $POD
# The above output shows a nice pod resource tree (node, namespace, type of resource, etc.).
# display all the images in all namespaces:
kubectl images -A
# access-matrix plug-in, which is handy when looking for a RBAC Access matrix for Kubernetes resources:
kubectl access-matrix

# Interacting with pods 
# Let's switch to the kube-system namespace and access some logs:
kubectl ns kube-system
# Use the pod-logs plugin to get the weave pods logs:
kubectl pod-logs
# The pod-logs plug-in does not allow output redirection. Therefore, if you want to redirect the output use kubectl logs as such: 
kubectl logs POD  -c CONTAINER > logsfile

# kubectl exec /iexec
# Let's create a single container pod called test with an nginx image:
kubectl run test --image=quay.io/bitnami/nginx
# Let's get the output of the date command from the running test container without logging into it:
kubectl exec test -- date
# Using the iexec plug-in, let's get the content of the /etc/resolv.conf/ file from the running test container:
kubectl iexec test cat /etc/resolv.conf
# To login and interact with the container's shell
kubectl iexec test
# Alternatively, you can use the below command:
kubectl exec test -it -- /bin/sh

# kubectl cp
# The cp command can be used to copy files and directories to and from containers within a pod.
# let's copy the content of the krew-install directory to the test container's /tmp directory
kubectl cp ~/krew-install test:/tmp
# Let's verify whether the directory has been copied.
kubectl iexec test
ls /tmp/krew-install
# Now, let's copy the welcome.txt file from the test container to the master server's /tmp directory:
kubectl cp test:/tmp/welcome.txt /tmp/welcome.txt

# kubectl taint
# A taint consist of a key, value, and effect. As an argument, it is expressed as key=value:effect.
# The effect should be one these values: NoShedule, PreferNoSchedule, or NoExecute
# Here is how it is used with the kubectl command:
kubectl taint NODE NAME KEY_1=VAL_1:TAINT_EFFECT
# Let's taint node01 as dedicated to the devops-group only
kubectl taint node node01 dedicated=devops-group:NoSchedule
# Verify that node01 is tainted:
kubectl describe node node01 | grep -i taints
# You can also check the taints on all nodes:
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints[*].key
# Let's now try to deploy a single pod:
kubectl run my-app --image=quay.io/bitnami/nginx
# The newly deployed pod will be in a pending state, because it will not tolerate the taints applied to both nodes. Therefore, it will not be scheduled.
# To see the error, type the below command and check under the events section:
kubectl describe pod my-app
# Alternatively, you can run the below command:
kubectl get events
# There are 2 ways to solve this issue. We can add a toleration matching the taint that was applied to the nodes, or remove the taint from the nodes. For now, let's remove the taint on node01:
kubectl taint node node01 dedicated-
# Note: to remove a taint, append the - to the value of the key.
# And by default, the control node is tainted with node-role.kubernetes.io/master, therefore, any pod that does not have a toleration matching the node's taint cannot be deployed onto the control node.

# kubectl cordon
# Let's now try to get one of the pods that are deployed on node01 and assign its name to a variable:
APOD=$(kubectl get pods -ojsonpath='{.items[?(@.spec.nodeName == "node01")].metadata.name}') && echo $APOD
# let's run the pod-dive plugin:
kubectl pod-dive $APOD
# Before we drain the node, we will cordon it first. cordon means ensuring that no pod can be scheduled on the particular node.
kubectl cordon node01
# If you list the nodes now, you will find the status of node01 set to Ready,SchedulingDisabled
kubectl get nodes

# kubectl drain
# Draining a node means removing all running pods from the node, typically performed for maintenance activities.
# Open a second terminal and run the below command to watch the output in Terminal 2:
watch -d kubectl get pods -o wide
# Run the below command to drain node01:
kubectl drain node01 --ignore-daemonsets
# you will observe, how the pods in node01 are being terminated and re-deployed on the controlplane node.
# Now, let's uncordon node01:
kubectl uncordon node01
# In Terminal 2, you will notice that the pods have not been moved back to node01. These Pods will not be rescheduled automatically to the new nodes.
# let's try to scale up the deployment to 8 replicas.
kubectl scale deployment/nginx-deployment --replicas=8
# Note: The --ignore-daemonsets flag in the kubectl drain command is required because DaemonSet pods are required to run on each node when deployed. This allows pods that are not part of a DaemonSet to be re-deployed on another available node

# kubectl top
# The kubectl top allows you to see the resource consumption for nodes or pods. However, in order to use the top command, we have to install a metrics server.
git clone https://github.com/mbahvw/kubernetes-metrics-server.git
kubectl apply -f kubernetes-metrics-server/
# Let's verify that we are getting a response from the metric server API:
kubectl  get --raw /apis/metrics.k8s.io/
# Let's get the CPU and memory utilization for all nodes in the cluster:
kubectl top nodes
# let's try to get the memory and CPU utilization of pods in all namespaces:
kubectl top pods --all-namespaces
# We can also gather the metrics of all the pods in the kube-system namespace:
kubectl top pods -n kube-system




```
```YAML
# cat ~/label-deploy.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  labels:
    app: web
    tier: frontend
  namespace: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: quay.io/bitnami/nginx:1.20
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: haproxy-deployment
  labels:
    app: haproxy
    tier: frontend
  namespace: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: haproxy
  template:
    metadata:
      labels:
        app: haproxy
    spec:
      containers:
      - name: nginx
        image: quay.io/bitnami/nginx:1.20
        ports:
        - containerPort: 80
```
# Install kubectx
```BASH
cat ~/kubectx.sh 
#!/bin/bash

cd ~/

echo "You are on the $PWD directory"
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
```
# Install Krew
```BASH
# cat ~/krew-install/install-krew.sh 
#!/bin/bash

#Downloading  krew from repo"
echo -en "Downloading and installing krew\n"
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.3.4/krew.{tar.gz,yaml}" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" &&
  "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz &&
  "$KREW" update

#Adding it to home user ~/.bashrc file
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >>~/.bashrc

#source the bashrc and restart bash
source ~/.bashrc
exec bash

# Automation ideas
# cat kc_step3.sh 
#!/bin/bash
kubectl config set-context test-context --cluster kubernetes --user=kubernetes-admin
for x in developers admins dbadmins; do kubectl create namespace $x; done
cd ~/deployment
kubectl create -f explore-deploy.yaml

# cat kc_step4.sh 
#!/bin/bash
kubectl ns default
cd ~/deployment
kubectl delete -f explore-deploy.yaml
kubectl delete namespace developers
kubectl delete namespace dbadmins
kubectl delete namespace admins
```
```YAML
# cat explore-deploy.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  labels:
    app: webapp
    tier: devops
  namespace: developers
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: quay.io/bitnami/nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: haproxy-deployment
  labels:
    app: haproxy
    tier: admins
  namespace: admins
spec:
  replicas: 3
  selector:
    matchLabels:
      app: haproxy
  template:
    metadata:
      labels:
        app: haproxy
    spec:
      containers:
      - name: nginx
        image: quay.io/bitnami/nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-deployment
  labels:
    app: redis
    tier: dbadmins
  namespace: dbadmins
spec:
  replicas: 3
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: quay.io/quay/redis
```
```YAML
# Deploy pod on master node as pod taints match master node
# cat nginx-deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: web
    tier: frontend
  namespace: default
spec:
  replicas: 4
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: quay.io/bitnami/nginx:1.20
        ports:
        - containerPort: 80
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: Exists
        effect: NoSchedule
```