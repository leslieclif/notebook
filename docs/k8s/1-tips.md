alias k=kubectl                         # will already be pre-configured

export do="--dry-run=client -o yaml"    # k create deploy nginx --image=nginx $do

export now="--force --grace-period 0"   # k delete pod x $now

alias ke='kubectl explain'
alias pe='k explain po --recursive'
alias kgp='k get po'
alias kns='k config set-context --current --namespace'

https://hackernoon.com/ckad-and-cka-certifications-which-to-take-first-and-how-to-prepare-bh4437mc
https://www.nisheetsinvhal.com/how-i-scored-a-perfect-100-on-cka/

- [CNCF Tips](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)
```BASH
# Vim config to be set in the exam terminal
echo "set ts=2 sts=2 sw=2 et number ai" >> ~/.vimrc

source ~/.vimrc
# This command will ensure that you set the namespace correctly for your current context. 
kubectl config view --minify | grep namespace 
# To test the service, launch a temporary POD with curl
kubectl curl --image=alpine/curl -it --rm  -- sh
# Aliases
######## Choose any style
# Step 1: enabled auto-complete feature in the bash shell after setting the aliases
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
complete -F __start_kubectl k
alias k=kubectl
alias kr='k run'
alias krun="k run -h | grep '# ' -A2"
alias kg='k get'
alias kd='k describe'
alias ke='kubectl explain'
alias kaf='k apply -f'
alias kdf='k delete -f'
alias kdp='k delete po'
alias kgp='k get po'
# if you’re sure that the Pod that you’re deleting has no Persistent Volumes attached to it (or other resources external to the Pod), then use below command
alias kpd='k delete pod --force --grace-period=0'  

# Step 2: create short cut using env variable
export dr="--dry-run=client -o yaml"
# Using k run mypod --image=nginx $dr > mypod.yaml

# Step 3: To avoid typing namespaces in the imperative command, set it once and then type all commands
k config get-contexts
# Copy paste the set-context and use-context
alias kns="kubectl config set-context --current --namespace"
# Set the alias as above
# Set the namespace where you want to execute the commands, like in myns
kns myns
# Tip: always remember to switch back to default namespace for the next question
kns default

# Changing namespaces
# Suppose your have namespaces test1, test2, test3
kubectl -n test1 get pods
# Now run the last command but in different namespace like test2
^test1^test2
```
```BASH
# Show all the Cert files in ETCD configuration
cat /etc/kubernetes/manifest/etcd.yaml | grep file

```
```BASH
# *** Important - Store the YAML files in home folder wth question number, so in case of review, you can verify and apply it say in correct namespace
# For Windows: Ctrl+Insert to copy and Shift+Insert to paste.
#  In addition, you might find it helpful to use the Notepad (see top menu under 'Exam Controls') to manipulate text before pasting to the command line.
# Only a single terminal console is available during the exam. Terminal multiplexers such as GNU Screen and tmux can be used to create virtual consoles.
# You can switch the cluster/configuration context using a command such as the following:
kubectl config use-context <cluster/context name>
# Nodes making up each cluster can be reached via ssh, using a command such as the following: 
ssh <nodename>
# You can assume elevated privileges on any node by issuing the following command: 
sudo -i
# You can also use `sudo` to execute commands with elevated privileges at any time
# You must return to the base node (`hostname node-1`) after completing each task.
# When you want to get some data quickly from a node without getting a shell
ssh <nodename> <command to execute>     # This will give you the output instead of changing nodes
# You can use kubectl and the appropriate context to work on any cluster from the base node. 
# When connected to a cluster member via ssh, you will only be able to work on that particular cluster via kubectl.

# For your convenience, all environments, in other words, the base system and the cluster nodes, have the following additional command-line tools pre-installed and pre-configured:
# - kubectl with k alias and Bash autocompletion
# - jq for YAML/JSON processing
# - tmux for terminal multiplexing
# - curl and wget for testing web services
# - man and man pages for further documentation

# Where no explicit namespace is specified, the default namespace should be acted upon.
# If you need to destroy/recreate a resource to perform a certain task, it is your responsibility to back up the resource definition appropriately prior to destroying the resource.
# Dont waste time waiting for prompt to come back when deleting pods, use the --force flag <Careful>
```
- Shortcuts
```BASH
po      Pod
rs      ReplciaSet
deploy  Deployment
svc     Service
ds      DaemonSet
ns      Namespace
netpol  Network Policy
pv      Persistent Volume
pvc     Persistent Volume Claims
sa      Service Account
sts     StatefulSets
```
- Implicit Commands
```BASH
# Do not copy paste from documentation into OS Editor. Copy into Notepad and then make changes. [Not recommended] to avoid wasting time in formatting. Type in Editor directly or use implicit commands
# Use Nano as preferred editor
KUBE_EDITOR=nano 
kubectl edit deploy nginx
# Nano Editor Shortcuts

# Set Context and Namespace
kubectl config set-context <cluster> --namespace=myns # Copy this command in notepad and save time
# Explain Commands
# When is it useful: sometimes when editing/creating yaml files, it is not clear where exaclty rsource should be placed (indented) in the file. Using this command gives a quick overview of resources structure as well as helpful explanation. Sometimes this is faster then looking up in k8s docs.
kubectl explain cronjob.spec.jobTemplate --recursive | less
kubectl explain pods.spec.containers --recursive | less

# Generators
--restart
--dry-run

# Tip
kubectl describe po      # Without po name, it will describe all pods which saves time in typing
# If the edit to po is not saved, do a force replace
# First exit the editor using q!, then execute the replace command
kubectl replace --force -f /tmp/<temp-file>         # This is the temp location k8s stores the edit yaml

kubectl run nginx --image=nginx   # (deployment)
kubectl run nginx --image=nginx --restart=Never   # (pod)
kubectl create job nginx --image=nginx --dry-run=client -o yaml > job.yml   #(job)  
kubectl create cronjob nginx --image=nginx --dry-run=client \
    --schedule="* * * * *" -o yaml > cronjob.yml # (cronJob)

kubectl run nginx -image=nginx \
    --restart=Never \
    --port=80 \
    --namespace=myname \
    --serviceaccount=mysa1 \
    --env=HOSTNAME=local \
    --labels=bu=finance,env=dev \ 
    --requests='cpu=100m,memory=256Mi' \ 
    --limits='cpu=200m,memory=512Mi' \
    --dry-run -o yaml - /bin/sh -c 'echo hello world' > pod.yaml

kubectl create deployment frontend --replicas=2 \
    --labels=run=load-balancer-example --image=busybox  --port=8080
kubectl expose deployment frontend --type=NodePort --name=frontend-service --port=6262 --target-port=8080 # OR
kubectl create service clusterip my-cs --tcp=5678:8080 --dry-run -o yaml 
kubectl set serviceaccount deployment frontend myuser


# If we specify two selectors separated by a comma, only the objects that satisfy both will be returned. This is a logical AND operation:
kubectl get pods --selector="bu=finance,env=dev"
# We can also ask if a label is one of a set of values. Here we ask for all pods where the app label is set to alpaca bandicoot (which will be all six pods):
kubectl get pods --selector="env in (dev,test)"

# Use of grep when selector filter doesnt work
kubectl describe pods | grep --context=10 annotations:
kubectl describe pods| grep --context=10 Events:

# Check last 10 events on pod
k describe pod <pod-name> | grep -i events -A 10
# Determine proper api_group/version for a resource
# When is it useful: after creating/modyfing pod or during troubleshooting exercise check quickly if there are no errors in pod
k api-resources | grep -i "resource name"
k api-versions | grep -i "api_group name"
# Example:
k api-resources | grep -i deploy # -> produces apps in APIGROUPS column
k api-versions | grep -i apps # -> produces apps/v1
# Quickly find kube api server setting
# When is it useful: since on all the exams, kubernetes services are running as pods, it is faster to check settings with grep rather than move to folder and look at the file.
ps -ef --forest | grep kube-apiserver | grep "search string"
# Example:
ps -ef --forest | grep kube-apiserver | grep admission-plugins # -> find admission plugins config

# Use busybox for running utilities
# When is it useful: this command will create temporary busybox pod. Full features of Busybox - https://busybox.net/downloads/BusyBox.html
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Verify pod connectivity
# When it is useful: when making changes to a pod, it is very important to veryify if it works. One of the best ways to verify is to check pod connectivity. If successful this command will return a response.
kubectl run -it --rm debug --image=radial/busyboxplus:curl --restart=Never -- curl http://servicename
# There is no way to add environment variable from a Secret or ConfigMap imperatively from CLI. So use the `--env SOMETHING=this --dry-run -o yaml` to generate a quick template then vim edit it to match the desired configuration. This is very useful considering you cannot copy-paste a whole yaml from documentation to the exam terminal.

# Create k8s resource on the fly from copied YAML
# When is it useful: sometimes it's quicker to just grab YAML from k8s documentation page and create a resource much quicker than writting YAML yourself
cat <<EOF | kubectl create -f -
<YAML content goes here>
EOF

# Command alternative: alternatively use 
cat > filename.yaml [enter] [Ctrl + Shift - to paste file content] [enter - adds one line to the file] [Ctrl + C - exit] # after that use vim/nano to edit the file and create resource based on it

# Save time on editing and re-creating running pods.
# During the exams you are often asked to change existing pod spec. This usually requires:

# 1. saving pod config as yaml file
kubectl get po <pod name> <optional -n namespace> -o yaml > <filename>.yaml
# check if file was correctly saves
cat <filename>.yaml
# 2. deleting existing pod
kubectl delete po <pod name> <optional -n namespace> --wait=false
# 3. editing the file and making required changes
vim <or nano> <filename>.yaml
# 4. creating new pod from the file
kubectl create -f <filename>.yaml
# The other template to remember is that of a Pod. It is especially useful for creating Static Pods on other Nodes.

# Do not skip the part about jsonpath thinking that it is too easy to come in the exam. Remember that jsonpath is required for sorting output and custom columns.

# Unix Bash one-liners

#if-else
a=10;b=5;if[$a -le $b];then echo "a is small";else echo "b is small";fi
# while
x=1;while [$x -le 10]; do echo "welcome $x times";x=$((x+1));done
# for
PODS=$(kubectl get pods -o jsonpath -template='{.items[*].metadata.name}')
for x in $PODS; do
  kubectl delete pods ${x}
  sleep 60
done

# Examples
args: ["-c", "while true;do date >> /var/log/app.txt;sleep 5;done"]
args: [/bin/sh, -c,'i=0; while true; do echo "$i:$(date)";i=$((i+1))";sleep 1;done']
args: ["-c", "mkdir -p collect;while true;do cat /var/data/* > /collect/data.txt;sleep 5;done"]

# Create file with implicit commands
kubectl run busybox --image=busybox --dry-run=client -o yaml --restart=Never > yamlfile.yaml
kubectl create job my-job --dry-run=client -o yaml --image=busybox -- date  > yamlfile.yaml
kubectl get deploy/nginx -o yaml > 1.yaml

kubectl run wordpress --image=wordpress --expose --port=8989 --restart=Never -o yaml
# Command shouls always at the end and all kubectl options before this
kubectl run test --image=busybox --restart=Never --dry-run=client -o yaml -- /bin/sh -c 'echo test;sleep 100' > yamlfile.yaml 
# OR
kubectl run test --image=busybox --restart=Never --dry-run=client -o yaml -- command sleep 1000 > yamlfile.yaml

# (Notice that -- /bin/sh comes at the end. This will create yaml file.)
kubectl run busybox --image=busybox --dry-run=client -o yaml --restart=Never -- /bin/sh -c "while true; do echo hello; echo hello again;done" > pod.yaml


# Test script to check if the application is live behind a service and is loadbalancing.
# A curl pod is running in kube-public namespace for testing
for i in {1..20}; do
   kubectl exec --namespace=kube-public curl -- sh -c 'test=`wget -qO- -T 2  http://webapp-service.default.svc.cluster.local:8080/ready 2>&1` && echo "$test OK" || echo "Failed"';
   echo ""
done
```

```BASH

# Type the above command and hit enter, Linux will substitute the namespace and rerun the get pods command
#################
    alias k='kubectl'
    alias kc='k config view --minify | grep name'
    # Many pods are created to save time when you go wrong during the exam
    alias kpd='k delete pod --force --grace-period=0'  
    alias kdp='kubectl describe pod'
    alias krh='kubectl run --help | more'
    alias kgh='kubectl get --help | more'
    alias c='clear'
    alias kd='kubectl describe'
    alias ke='kubectl explain'
    alias kf='kubectl create -f'
    alias kg='kubectl get pods --show-labels'
    alias kr='kubectl replace -f'
    alias kh='kubectl --help | more'
    alias krh='kubectl run --help | more'
    alias kgn='kubectl get namespaces'
    alias l='ls -lrt'
    alias ll='vi ls -rt | tail -1'
    alias kga='k get pod --all-namespaces'
    alias kgaa='kubectl get all --show-labels'

# Viewing resource utilization
kubectl top node
kubectl top pod
watch kubectl top node -n 5     # Runs the command every 5 sec
```
- [Linux Hard Way Mummshad](https://github.com/mmumshad/kubernetes-the-hard-way)
- Kubernetes the Hard Way

# Tools used
- vim
- kubectl
- kubeadm
- systemctl & journalctl
- nslookup

## [Vim](../ide/vim.md) 

# General Tips

1. Flag Questions You Can’t Immediately Answer

The exam environment comes with built-in flagging functionality. If you read a question that you don’t immediately know how to answer, flag it. Flagged questions will be highlighted in your question list, allowing you to return to them quickly once you’ve finished answering the ones you’re comfortable with.

2. Keep Score

Along with flagging capabilities, the exam provides you with a built-in notepad. Make use of the notepad to keep a running tally of questions you’ve answered and their percentage value (this number is given to you with each question). 

-   Format of scoring
Question Number %weight Total

I like to keep a list of the questions I haven’t answered and their associated percentages too. It’s a good way to inform how you should prioritise your time, particularly towards the end of the exam. If you're cutting it fine with the 74% pass mark, your time is probably better spent on a 7% question, than a 2% one.

3. Save YAML Files by Question Number

If you have to create a YAML file when answering a question, for example a Pod config file, make sure you name the file according to the question number.

4.  I rely heavily on a solid muscle memory for all commands. The most atomic part of a cluster is a Pod so creating one through `kubectl run --generator=run-pod/v1 nginx --image nginx` should be out under 10 seconds or so.

5. Even though the exam allows you to copy-paste content from the official documentation, it has a limit of 2-3 lines so I had to be prepared to --dry-run -o yaml > q2.yaml each time and edit the file as per the question.

6. Useful commands
```BASH
# list running processes
$ ps -aux

# search for string in the output
$ ps -aux | grep -i 'string' 

# search for multiple expressions in the output (exp can be plain a string too)
$ ps -aux | grep -e 'exp-one' -e 'exp-two'

# get details about network interfaces
$ ifconfig

# list network interfaces and their IP address
$ ip a

# get the route details
$ ip r

# check service status and also show logs
$ systemctl status kubelet

# restart a service
$ systemctl restart kubelet

# reload the service daemon, if you changed the service file
$ systemctl daemon reload

# detailed logs of the service
$ journalctl -u kubelet

# list out ports, protocol and what processes are listening on those ports
$ netstat -tunlp #-tupan
```

# Troubleshooting Tips
- What is the scope of the issue?
    > Entire Custer
    > User
    > Pod
    > Service
- How Long the issue has been going on?
- What can be done to reproduce the issue?

- Establish a Probable cause.
Develop a Hypothesis -->
    > Clue 1
    > + Clue 2
    > + Kubernetes Knowledge
    ========================
    Probable Cause

- Experiment - Test your Hypothesis