# CKA exam testing

## Preparation

Q: Create a Job that run 60 time with 2 jobs running in parallel
https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/

Q: Find which Pod is taking max CPU
Use `kubectl top` to find CPU usage per pod

Q: List all PersistentVolumes sorted by their name
Use `kubectl get pv --sort-by=` <- this problem is buggy & also by default kubectl give the output sorted by name.

Q: Create a NetworkPolicy to allow connect to port 8080 by busybox pod only
https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
Make sure to use `apiVersion: extensions/v1beta1` which works on both 1.6 and 1.7

Q: fixing broken nodes, see
https://kubernetes.io/docs/concepts/architecture/nodes/

Q: etcd backup, see
https://kubernetes.io/docs/getting-started-guides/ubuntu/backups/
https://www.mirantis.com/blog/everything-you-ever-wanted-to-know-about-using-etcd-with-kubernetes-v1-6-but-were-afraid-to-ask/

Q: TLS bootstrapping, see
https://coreos.com/kubernetes/docs/latest/openssl.html
https://kubernetes.io/docs/admin/kubelet-tls-bootstrapping/
https://github.com/cloudflare/cfssl

Q: You have a Container with a volume mount. Add a init container that creates an empty file in the volume. (only trick is to mount the volume to init-container as well)

https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
```
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  initContainers:
  - name: init-touch-file
    image: busybox
    volumeMounts:
    - mountPath: /data
      name: cache-volume
    command: ['sh', '-c', 'echo "" > /data/harshal.txt']
  volumes:
  - name: cache-volume
    emptyDir: {}
````

Q: When running a redis key-value store in your pre-production environments many deployments are incoming from CI and leaving behind a lot of stale cache data in redis which is causing test failures. The CI admin has requested that each time a redis key-value-store is deployed in staging that it not persist its data.

Create a pod named non-persistent-redis that specifies a named-volume with name app-cache, and mount path /data/redis. It should launch in the staging namespace and the volume MUST NOT be persistent.
Create a Pod with EmptyDir and in the YAML file add namespace: CI

Q:  Setting up K8s master components with a binaries/from tar balls:

Also, convert CRT to PEM: openssl x509 -in abc.crt -out abc.pem
- https://coreos.com/kubernetes/docs/latest/openssl.html
- https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md
- https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md
- https://gist.github.com/mhausenblas/0e09c448517669ef5ece157fd4a5dc4b
- https://kubernetes.io/docs/getting-started-guides/scratch/
- http://alexander.holbreich.org/kubernetes-on-ubuntu/ maybe dashboard?
- https://kubernetes.io/docs/getting-started-guides/binary_release/
- http://kamalmarhubi.com/blog/2015/09/06/kubernetes-from-the-ground-up-the-api-server/

Q: Find the error message with the string “Some-error message here”.
https://kubernetes.io/docs/concepts/cluster-administration/logging/ see kubectl logs and /var/log for system services

Q 17: Create an Ingress resource, Ingress controller and a Service that resolves to cs.rocks.ch.

First, create controller and default backend
 ```BASH
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress/master/controllers/nginx/examples/default-backend.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress/master/examples/deployment/nginx/nginx-ingress-controller.yaml
```

Second, create service and expose
 ```
kubectl run ingress-pod --image=nginx --port 80
kubectl expose deployment ingress-pod --port=80 --target-port=80 --type=NodePort
```

Create the ingress
 ```
cat <<EOF >ingress-cka.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-service
spec:
  rules:
  - host: "cs.rocks.ch"
    http:
      paths:
      - backend:
          serviceName: ingress-pod
          servicePort: 80
EOF
```

To test, run a curl pod
```
kubectl run -i --tty client --image=tutum/curl
curl -I -L --resolve cs.rocks.ch:80:10.240.0.5 http://cs.rocks.ch/
```

Q: Run a Jenkins Pod on a specified node only.
https://kubernetes.io/docs/tasks/administer-cluster/static-pod/
Create the Pod manifest at the specified location and then edit the systemd service file for kubelet(/etc/systemd/system/kubelet.service) to include `--pod-manifest-path=/specified/path`. Once done restart the service.

Q: Use the utility nslookup to look up the DNS records of the service and pod.
From this guide, https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
Look for “Quick Diagnosis” 
$ kubectl exec -ti busybox -- nslookup mysvc.myns.svc.cluster.local
Naming conventions for services and pods: 
For a regular service, this resolves to the port number and the CNAME: my-svc.my-namespace.svc.cluster.local. 

For a headless service, this resolves to multiple answers, one for each pod that is backing the service, and contains the port number and a CNAME of the pod of the form auto-generated-name.my-svc.my-namespace.svc.cluster.local
When enabled, pods are assigned a DNS A record in the form of pod-ip-address.my-namespace.pod.cluster.local.
For example, a pod with IP 1.2.3.4 in the namespace default with a DNS name of cluster.local would have an entry: 1-2-3-4.default.pod.cluster.local

Q: Start a pod automatically by keeping manifest in /etc/kubernetes/manifests
Refer to https://kubernetes.io/docs/tasks/administer-cluster/static-pod/
Edit kubelet.service on any worker node to contain this flag --pod-manifest-path=/etc/kubernetes/manifests then place the pod manifest at /etc/kubernetes/manifests. 
Now restart kubelet.


Some other Questions:

1. Main container looks for a file and crashes if it doesnt find the file. Write an init container to create the file and make it available for the main container 
2. Install and Configure kubelet on a node to run pod on that node without contacting the api server
3. Take backup of etcd cluster
4. rotate TLS certificates
5.rolebinding
6.Troubleshooting - involved identifying failing nodes, pods , services and identifying cpu utilization of pods.

# General Questions
1. Backup/restore etcd on specific location using certificates.
2. Fix the broken node. You should check kubelet process. Mostly you have to start and
enable for permanent change.
3. Create network policy to allow incoming connection from specific namespace , port
combination. They might ask from specific pods.
4. Two questions related to jsonpath , you can output the resource in json format and
then find the details.
5. They ask to create ingress . Please note ingress controller was already there.
6. One question related to sidecar container. Trick is you have to mount the volume of
on the side container.
7. Question related to which pod consume most cpu. You don’t need to install metrics
server.

# Topics to focus on
1. Ingress
1. Role and Role Binding
1. Service Accounts
1. PV and PVC
1. Volumes
1. Network Policy
1. Services
1. Check logs from Pods, Scale Deployment and replica
1. ETCD Backup and restore
1. TLS Bootstraping

```BASH
Question 1 | Contexts
Task weight: 1%
You have access to multiple clusters from your main terminal through kubectl contexts. Write all those context names into /opt/course/1/contexts.

Next write a command to display the current context into /opt/course/1/context_default_kubectl.sh, the command should use kubectl.

Finally write a second command doing the same thing into /opt/course/1/context_default_no_kubectl.sh, but without the use of kubectl.

Answer:
k config get-contexts # copy manually
# OR
k config get-contexts -o name > /opt/course/1/contexts

# /opt/course/1/context_default_kubectl.sh
kubectl config current-context

# /opt/course/1/context_default_no_kubectl.sh
cat ~/.kube/config | grep current
```
```BASH
Question 2 | Schedule Pod on Master Node
Task weight: 3%
Use context: kubectl config use-context k8s-c1-H
Create a single Pod of image httpd:2.4.41-alpine in Namespace default. The Pod should be named pod1 and the container should be named pod1-container. This Pod should only be scheduled on a master node, do not add new labels any nodes.

Answer:
First we find the master node(s) and their taints:
k get node # find master node
k describe node cluster1-master1 | grep Taint -A3 # get master node taints
k get node cluster1-master1 --show-labels # get master node labels
# NOTE: In K8s 1.24 master/controlplane nodes have two Taints which means we have to add Tolerations for both. This is done during transitioning from the wording "master" to "controlplane".
Next we create the Pod template:

# check the export on the very top of this document so we can use $do
k run pod1 --image=httpd:2.4.41-alpine $do > 2.yaml
```
```YAML
# vim 2.yaml
tolerations:                                    # add
  - effect: NoSchedule                          # add
    key: node-role.kubernetes.io/master         # add
  - effect: NoSchedule                          # add
    key: node-role.kubernetes.io/control-plane  # add
nodeSelector:                                 # add
  node-role.kubernetes.io/control-plane: ""   # add
# Important here to add the toleration for running on master nodes, but also the nodeSelector to make sure it only runs on master nodes. If we only specify a toleration the Pod can be scheduled on master or worker nodes.
```
```BASH
Question 3 | Scale down StatefulSet
Task weight: 1%
Use context: kubectl config use-context k8s-c1-H
There are two Pods named o3db-* in Namespace project-c13. C13 management asked you to scale the Pods down to one replica to save resources.

Answer:
If we check the Pods we see two replicas:
k -n project-c13 get pod | grep o3db

# From their name it looks like these are managed by a StatefulSet. But if we're not sure we could also check for the most common resources which manage Pods:

k -n project-c13 get deploy,ds,sts | grep o3db

#Confirmed, we have to work with a StatefulSet. To find this out we could also look at the Pod labels:
k -n project-c13 get pod --show-labels | grep o3db

# To fulfil the task we simply run:
k -n project-c13 scale sts o3db --replicas 1
```
```BASH
Question 4 | Pod Ready if Service is reachable
Task weight: 4%
Use context: kubectl config use-context k8s-c1-H
# Do the following in Namespace default. Create a single Pod named ready-if-service-ready of image nginx:1.16.1-alpine. Configure a LivenessProbe which simply runs true. Also configure a ReadinessProbe which does check if the url http://service-am-i-ready:80 is reachable, you can use wget -T2 -O- http://service-am-i-ready:80 for this. Start the Pod and confirm it isn't ready because of the ReadinessProbe.
Create a second Pod named am-i-ready of image nginx:1.16.1-alpine with label id: cross-server-ready. The already existing Service service-am-i-ready should now have that second Pod as endpoint.
Now the first Pod should be in ready state, confirm that.

Answer:
# It's a bit of an anti-pattern for one Pod to check another Pod for being ready using probes, hence the normally available readinessProbe.httpGet doesn't work for absolute remote urls. Still the workaround requested in this task should show how probes and Pod<->Service communication works.

First we create the first Pod:
k run ready-if-service-ready --image=nginx:1.16.1-alpine $do > 4_pod1.yaml

# And confirm its in a non-ready state:
k get pod ready-if-service-ready
# We can also check the reason for this using describe:
k describe pod ready-if-service-ready

# Now we create the second Pod:

k run am-i-ready --image=nginx:1.16.1-alpine --labels="id=cross-server-ready"

# The already existing Service service-am-i-ready should now have an Endpoint:
k describe svc service-am-i-ready
k get ep # also possible

Which will result in our first Pod being ready, just give it a minute for the Readiness probe to check again:
k get pod ready-if-service-ready
```
```YAML
# 4_pod1.yaml
livenessProbe:                               # add from here
    exec:
    command:
    - 'true'
readinessProbe:
    exec:
    command:
    - sh
    - -c
    - 'wget -T2 -O- http://service-am-i-ready:80'   # to here
```
```BASH
Question 5 | Kubectl sorting
Task weight: 1%
Use context: kubectl config use-context k8s-c1-H
There are various Pods in all namespaces. Write a command into /opt/course/5/find_pods.sh which lists all Pods sorted by their AGE (metadata.creationTimestamp).
Write a second command into /opt/course/5/find_pods_uid.sh which lists all Pods sorted by field metadata.uid. Use kubectl sorting for both commands.

Answer:
A good resources here (and for many other things) is the kubectl-cheat-sheet. You can reach it fast when searching for "cheat sheet" in the Kubernetes docs.
# /opt/course/5/find_pods.sh
kubectl get pod -A --sort-by=.metadata.creationTimestamp

For the second command:
# /opt/course/5/find_pods_uid.sh
kubectl get pod -A --sort-by=.metadata.uid
```
```BASH
Question 6 | Storage, PV, PVC, Pod volume
Task weight: 8%
Use context: kubectl config use-context k8s-c1-H

Create a new PersistentVolume named safari-pv. It should have a capacity of 2Gi, accessMode ReadWriteOnce, hostPath /Volumes/Data and no storageClassName defined.

Next create a new PersistentVolumeClaim in Namespace project-tiger named safari-pvc . It should request 2Gi storage, accessMode ReadWriteOnce and should not define a storageClassName. The PVC should bound to the PV correctly.

Finally create a new Deployment safari in Namespace project-tiger which mounts that volume at /tmp/safari-data. The Pods of that Deployment should be of image httpd:2.4.41-alpine.

Answer
Create PV and PV using k8s docs.
Next we create a Deployment and mount that volume:

k -n project-tiger create deploy safari \
  --image=httpd:2.4.41-alpine $do > 6_dep.yaml

We can confirm its mounting correctly:
k -n project-tiger describe pod safari-5cbf46d6d-mjhsb  | grep -A2 Mounts: 
```
```YAML
# 6_pv.yaml
kind: PersistentVolume
apiVersion: v1
metadata:
 name: safari-pv
spec:
 capacity:
  storage: 2Gi
 accessModes:
  - ReadWriteOnce
 hostPath:
  path: "/Volumes/Data"
# 6_pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: safari-pvc
  namespace: project-tiger
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
     storage: 2Gi
# 6_dep.yaml
spec:
    volumes:                                      # add
    - name: data                                  # add
    persistentVolumeClaim:                      # add
        claimName: safari-pvc                     # add
    containers:
    - image: httpd:2.4.41-alpine
    name: container
    volumeMounts:                               # add
    - name: data                                # add
        mountPath: /tmp/safari-data               # add
```
```BASH
Question 7 | Node and Pod Resource Usage
Task weight: 1%
Use context: kubectl config use-context k8s-c1-H
The metrics-server has been installed in the cluster. Your college would like to know the kubectl commands to:
show Nodes resource usage
show Pods and their **containers** resource usage
Please write the commands into /opt/course/7/node.sh and /opt/course/7/pod.sh.
Answer:
The command we need to use here is top:
k top -h
We create the first file:
# /opt/course/7/node.sh
kubectl top node
For the second file we might need to check the docs again:
k top pod -h
# /opt/course/7/pod.sh
kubectl top pod --containers=true
```
```BASH
Question 8 | Get Master Information
Task weight: 2%
Use context: kubectl config use-context k8s-c1-H
# Ssh into the master node with ssh cluster1-master1. Check how the master components kubelet, kube-apiserver, kube-scheduler, kube-controller-manager and etcd are started/installed on the master node. Also find out the name of the DNS application and how it's started/installed on the master node.

Write your findings into file /opt/course/8/master-components.txt. The file should be structured like:

# /opt/course/8/master-components.txt
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]
Choices of [TYPE] are: not-installed, process, static-pod, pod

Answer:
We could start by finding processes of the requested components, especially the kubelet at first:
ssh cluster1-master1
ps aux | grep kubelet # shows kubelet process
We can see which components are controlled via systemd looking at /etc/systemd/system directory:
find /etc/systemd/system/ | grep kube
find /etc/systemd/system/ | grep etcd
# This shows kubelet is controlled via systemd, but no other service named kube nor etcd. It seems that this cluster has been setup using kubeadm, so we check in the default manifests directory:
find /etc/kubernetes/manifests/
# (The kubelet could also have a different manifests directory specified via parameter --pod-manifest-path in it's systemd startup config)
# This means the main 4 master services are setup as static Pods. Actually, let's check all Pods running on in the kube-system Namespace on the master node:
kubectl -n kube-system get pod -o wide | grep master1
# There we see the 5 static pods, with -cluster1-master1 as suffix.
# We also see that the dns application seems to be coredns, but how is it controlled?
kubectl -n kube-system get ds
kubectl -n kube-system get deploy
Seems like coredns is controlled via a Deployment. We combine our findings in the requested file:

# /opt/course/8/master-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
```
```BASH
Question 9 | Kill Scheduler, Manual Scheduling
Task weight: 5%
Use context: kubectl config use-context k8s-c2-AC
Ssh into the master node with ssh cluster2-master1. Temporarily stop the kube-scheduler, this means in a way that you can start it again afterwards.

Create a single Pod named manual-schedule of image httpd:2.4-alpine, confirm its created but not scheduled on any node.

# Now you're the scheduler and have all its power, manually schedule that Pod on node cluster2-master1. Make sure it's running.

# Start the kube-scheduler again and confirm its running correctly by creating a second Pod named manual-schedule2 of image httpd:2.4-alpine and check if it's running on cluster2-worker1.

Answer:
Stop the Scheduler
First we find the master node:
k get node
Then we connect and check if the scheduler is running:
ssh cluster2-master1
kubectl -n kube-system get pod | grep schedule
Kill the Scheduler (temporarily):
cd /etc/kubernetes/manifests/
mv kube-scheduler.yaml ..
And it should be stopped:
kubectl -n kube-system get pod | grep schedule
Create a Pod
Now we create the Pod:
k run manual-schedule --image=httpd:2.4-alpine
# And confirm it has no node assigned:
k get pod manual-schedule -o wide
Manually schedule the Pod
# Let's play the scheduler now:
k get pod manual-schedule -o yaml > 9.yaml
nodeName: cluster2-master1        # add the master node name
The only thing a scheduler does, is that it sets the nodeName for a Pod declaration. 
As we cannot kubectl apply or kubectl edit , in this case we need to delete and create or replace:
k -f 9.yaml replace --force
k get pod manual-schedule -o wide
# It looks like our Pod is running on the master now as requested, although no tolerations were specified. Only the scheduler takes taints/tolerations/affinity into account when finding the correct node name. That's why its still possible to assign Pods manually directly to a master node and skip the scheduler.
Start the scheduler again
ssh cluster2-master1
cd /etc/kubernetes/manifests/
mv ../kube-scheduler.yaml .
Schedule a second test Pod:
k run manual-schedule2 --image=httpd:2.4-alpine
```
```BASH
Question 10 | RBAC ServiceAccount Role RoleBinding
Task weight: 6%
Use context: kubectl config use-context k8s-c1-H
Create a new ServiceAccount processor in Namespace project-hamster. Create a Role and RoleBinding, both named processor as well. These should allow the new SA to only create Secrets and ConfigMaps in that Namespace.

Answer:
# Let's talk a little about RBAC resources
A ClusterRole|Role defines a set of permissions and where it is available, in the whole cluster or just a single Namespace.

A ClusterRoleBinding|RoleBinding connects a set of permissions with an account and defines where it is applied, in the whole cluster or just a single Namespace.

Because of this there are 4 different RBAC combinations and 3 valid ones:

1. Role + RoleBinding (available in single Namespace, applied in single Namespace)
2. ClusterRole + ClusterRoleBinding (available cluster-wide, applied cluster-wide)
3. ClusterRole + RoleBinding (available cluster-wide, applied in single Namespace)
4. Role + ClusterRoleBinding (NOT POSSIBLE: available in single Namespace, applied cluster-wide)

# To the solution
We first create the ServiceAccount:
k -n project-hamster create sa processor
Then for the Role:

k -n project-hamster create role processor \
  --verb=create \
  --resource=secret \
  --resource=configmap \
  --namespace=project-hamster
# Now we bind the Role to the ServiceAccount:
k -n project-hamster create rolebinding processor \
  --role processor \
  --serviceaccount project-hamster:processor \
  --namespace=project-hamster

To test our RBAC setup we can use kubectl auth can-i:
 k -n project-hamster auth can-i create secret \
  --as system:serviceaccount:project-hamster:processor
# yes
k -n project-hamster auth can-i create pod \
  --as system:serviceaccount:project-hamster:processor
# no
```
```BASH
Question 11 | DaemonSet on all Nodes
Task weight: 4%
Use context: kubectl config use-context k8s-c1-H
Use Namespace project-tiger for the following. Create a DaemonSet named ds-important with image httpd:2.4-alpine and labels id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462. The Pods it creates should request 10 millicore cpu and 10 mebibyte memory. The Pods of that DaemonSet should run on all nodes, master and worker.

Answer:
# As of now we aren't able to create a DaemonSet directly using kubectl, so we create a Deployment and just change it up:
k -n project-tiger create deployment --image=httpd:2.4-alpine ds-important --labels="id=ds-important,uuid=18426a0b-5f59-4e10-923f-c0e078e82462" $do > 11.yaml
# NOTE: In K8s 1.24 master/controlplane nodes have two Taints which means we have to add Tolerations for both. This is done during transitioning from the wording "master" to "controlplane".
It was requested that the DaemonSet runs on all nodes, so we need to specify the toleration for this.

```
```YAML
# 11.yaml
apiVersion: apps/v1
kind: DaemonSet                                     # change from Deployment to Daemonset
metadata:
  namespace: project-tiger                          # important
spec:
  #replicas: 1                                      # remove
  #strategy: {}                                     # remove
  template:
    spec:
      containers:
      tolerations:                                  # add
      - effect: NoSchedule                          # add
        key: node-role.kubernetes.io/master         # add
      - effect: NoSchedule                          # add
        key: node-role.kubernetes.io/control-plane  # add
#status: {}                                         # remove
```
```BASH
Question 12 | Deployment on all Nodes
Task weight: 6%
Use context: kubectl config use-context k8s-c1-H

Use Namespace project-tiger for the following. Create a Deployment named deploy-important with label id=very-important (the Pods should also have this label) and 3 replicas. It should contain two containers, the first named container1 with image nginx:1.17.6-alpine and the second one named container2 with image kubernetes/pause.

# There should be only ever one Pod of that Deployment running on one worker node. We have two worker nodes: cluster1-worker1 and cluster1-worker2. Because the Deployment has three replicas the result should be that on both nodes one Pod is running. The third Pod won't be scheduled, unless a new worker node will be added.

# In a way we kind of simulate the behaviour of a DaemonSet here, but using a Deployment and a fixed number of replicas.

Answer:
There are two possible ways, one using podAntiAffinity and one using topologySpreadConstraint.

PodAntiAffinity
The idea here is that we create a "Inter-pod anti-affinity" which allows us to say a Pod should only be scheduled on a node where another Pod of a specific label (here the same label) is not already running.

# Let's begin by creating the Deployment template:
k -n project-tiger create deployment \
  --image=nginx:1.17.6-alpine deploy-important $do > 12.yaml

```
```YAML
# 12.yaml
affinity:                                             # add
  podAntiAffinity:                                    # add
    requiredDuringSchedulingIgnoredDuringExecution:   # add
    - labelSelector:                                  # add
        matchExpressions:                             # add
        - key: id                                     # add
          operator: In                                # add
          values:                                     # add
          - very-important                            # add
      topologyKey: kubernetes.io/hostname             # add
# Specify a topologyKey, which is a pre-populated Kubernetes label, you can find this by describing a node.
```
```BASH
Question 13 | Multi Containers and Pod shared Volume
Task weight: 4%
Use context: kubectl config use-context k8s-c1-H
# Create a Pod named multi-container-playground in Namespace default with three containers, named c1, c2 and c3. There should be a volume attached to that Pod and mounted into every container, but the volume shouldn't be persisted or shared with other Pods.

Container c1 should be of image nginx:1.17.6-alpine and have the name of the node where its Pod is running available as environment variable MY_NODE_NAME.

Container c2 should be of image busybox:1.31.1 and write the output of the date command every second in the shared volume into file date.log. You can use while true; do date >> /your/vol/path/date.log; sleep 1; done for this.

Container c3 should be of image busybox:1.31.1 and constantly send the content of file date.log from the shared volume to stdout. You can use tail -f /your/vol/path/date.log for this.

Check the logs of container c3 to confirm correct setup.

Answer:
First we create the Pod template:
k run multi-container-playground --image=nginx:1.17.6-alpine $do > 13.yaml
And add the other containers and the commands they should execute:
we check if container c1 has the requested node name as env variable:

k exec multi-container-playground -c c1 -- env | grep MY
And finally we check the logging:
k logs multi-container-playground -c c3
```
```YAML
# 13.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: multi-container-playground
  name: multi-container-playground
spec:
  containers:
  - image: nginx:1.17.6-alpine
    name: c1                                                                      # change
    resources: {}
    env:                                                                          # add
    - name: MY_NODE_NAME                                                          # add
      valueFrom:                                                                  # add
        fieldRef:                                                                 # add
          fieldPath: spec.nodeName                                                # add
    volumeMounts:                                                                 # add
    - name: vol                                                                   # add
      mountPath: /vol                                                             # add
  - image: busybox:1.31.1                                                         # add
    name: c2                                                                      # add
    command: ["sh", "-c", "while true; do date >> /vol/date.log; sleep 1; done"]  # add
    volumeMounts:                                                                 # add
    - name: vol                                                                   # add
      mountPath: /vol                                                             # add
  - image: busybox:1.31.1                                                         # add
    name: c3                                                                      # add
    command: ["sh", "-c", "tail -f /vol/date.log"]                                # add
    volumeMounts:                                                                 # add
    - name: vol                                                                   # add
      mountPath: /vol                                                             # add
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:                                                                        # add
    - name: vol                                                                   # add
      emptyDir: {}                                                                # add
status: {}
```
```BASH
Question 14 | Find out Cluster Information
Task weight: 2%
Use context: kubectl config use-context k8s-c1-H
# You're ask to find out following information about the cluster k8s-c1-H:

How many master nodes are available?
How many worker nodes are available?
What is the Service CIDR?
Which Networking (or CNI Plugin) is configured and where is its config file?
Which suffix will static pods have that run on cluster1-worker1?
Write your answers into file /opt/course/14/cluster-info, structured like this:

# /opt/course/14/cluster-info
1: [ANSWER]
2: [ANSWER]
3: [ANSWER]
4: [ANSWER]
5: [ANSWER]

Answer:
How many master and worker nodes are available?
We see one master and two workers.
What is the Service CIDR?
ssh cluster1-master1
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep range
Which Networking (or CNI Plugin) is configured and where is its config file?
find /etc/cni/net.d/
cat /etc/cni/net.d/10-weave.conflist
By default the kubelet looks into /etc/cni/net.d to discover the CNI plugins. This will be the same on every master and worker nodes.
Which suffix will static pods have that run on cluster1-worker1?
The suffix is the node hostname with a leading hyphen. It used to be -static in earlier Kubernetes versions.
Result
The resulting /opt/course/14/cluster-info could look like:

# /opt/course/14/cluster-info

# How many master nodes are available?
1: 1

# How many worker nodes are available?
2: 2

# What is the Service CIDR?
3: 10.96.0.0/12

# Which Networking (or CNI Plugin) is configured and where is its config file?
4: Weave, /etc/cni/net.d/10-weave.conflist

# Which suffix will static pods have that run on cluster1-worker1?
5: -cluster1-worker1
```
```BASH
Question 15 | Cluster Event Logging
Task weight: 3%
Use context: kubectl config use-context k8s-c2-AC

Write a command into /opt/course/15/cluster_events.sh which shows the latest events in the whole cluster, ordered by time. Use kubectl for it.

Now kill the kube-proxy Pod running on node cluster2-worker1 and write the events this caused into /opt/course/15/pod_kill.log.

Finally kill the containerd container of the kube-proxy Pod on node cluster2-worker1 and write the events into /opt/course/15/container_kill.log.

Do you notice differences in the events both actions caused?

Answer:
# /opt/course/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp

Now we kill the kube-proxy Pod:
k -n kube-system get pod -o wide | grep proxy # find pod running on cluster2-worker1
k -n kube-system delete pod kube-proxy-z64cg

Now check the events:
sh /opt/course/15/cluster_events.sh
Write the events the killing caused into /opt/course/15/pod_kill.log
Finally we will try to provoke events by killing the container belonging to the container of the kube-proxy Pod:
ssh cluster2-worker1
crictl ps | grep kube-proxy
crictl stop 1e020b43c4423
crictl rm 1e020b43c4423
crictl ps | grep kube-proxy
We killed the main container (1e020b43c4423), but also noticed that a new container (0ae4245707910) was directly created. Thanks Kubernetes!
Now we see if this caused events again and we write those into the second file:
sh /opt/course/15/cluster_events.sh
# Comparing the events we see that when we deleted the whole Pod there were more things to be done, hence more events. For example was the DaemonSet in the game to re-create the missing Pod. Where when we manually killed the main container of the Pod, the Pod would still exist but only its container needed to be re-created, hence less events.
```
```BASH
Question 16 | Namespaces and Api Resources
Task weight: 2%
Use context: kubectl config use-context k8s-c1-H

Create a new Namespace called cka-master.

Write the names of all namespaced Kubernetes resources (like Pod, Secret, ConfigMap...) into /opt/course/16/resources.txt.

Find the project-* Namespace with the highest number of Roles defined in it and write its name and amount of Roles into /opt/course/16/crowded-namespace.txt.

Answer:
Namespace and Namespaces Resources
We create a new Namespace:
k create ns cka-master
Now we can get a list of all resources like:
k api-resources --namespaced -o name > /opt/course/16/resources.txt

Namespace with most Roles
k -n project-c13 get role --no-headers | wc -l
k -n project-c14 get role --no-headers | wc -l
# 300
Find all other namespaces
Finally we write the name and amount into the file:

# /opt/course/16/crowded-namespace.txt
project-c14 with 300 resources
```
```BASH
Question 17 | Find Container of Pod and check info
Task weight: 3%

Use context: kubectl config use-context k8s-c1-H

In Namespace project-tiger create a Pod named tigers-reunite of image httpd:2.4.41-alpine with labels pod=container and container=pod. Find out on which node the Pod is scheduled. Ssh into that node and find the containerd container belonging to that Pod.

Using command crictl:

Write the ID of the container and the info.runtimeType into /opt/course/17/pod-container.txt
Write the logs of the container into /opt/course/17/pod-container.log

Answer:
First we create the Pod:

k -n project-tiger run tigers-reunite \
  --image=httpd:2.4.41-alpine \
  --labels "pod=container,container=pod"
# Next we find out the node it's scheduled on:
k -n project-tiger get pod -o wide
Then we ssh into that node and and check the container info:
ssh cluster1-worker2
crictl ps | grep tigers-reunite
crictl inspect b01edbe6f89ed | grep runtimeType
Then we fill the requested file (on the main terminal):
# /opt/course/17/pod-container.txt
b01edbe6f89ed io.containerd.runc.v2
Finally we write the container logs in the second file:
ssh cluster1-worker2 'crictl logs b01edbe6f89ed' &> /opt/course/17/pod-container.log
# The &> in above's command redirects both the standard output and standard error.
You could also simply run crictl logs on the node and copy the content manually, if its not a lot. The file should look like:
```
```BASH
Question 18 | Fix Kubelet
Task weight: 8%
Use context: kubectl config use-context k8s-c3-CCC

There seems to be an issue with the kubelet not running on cluster3-worker1. Fix it and confirm that cluster has node cluster3-worker1 available in Ready state afterwards. You should be able to schedule a Pod on cluster3-worker1 afterwards.

Write the reason of the issue into /opt/course/18/reason.txt.

Answer:
The procedure on tasks like these should be to check if the kubelet is running, if not start it, then check its logs and correct errors if there are some.

Always helpful to check if other clusters already have some of the components defined and running, so you can copy and use existing config files. Though in this case it might not need to be necessary.

Check node status:
k get node
First we check if the kubelet is running:
ssh cluster3-worker1
ps aux | grep kubelet
Nope, so we check if its configured using systemd as service:
service kubelet status
# Yes, its configured as a service with config at /etc/systemd/system/kubelet.service.d/10-kubeadm.conf, but we see its inactive. Let's try to start it:
service kubelet start
We see its trying to execute /usr/local/bin/kubelet with some parameters defined in its service config file. A good way to find errors and get more logs is to run the command manually (usually also with its parameters).
/usr/local/bin/kubelet
# -bash: /usr/local/bin/kubelet: No such file or directory
whereis kubelet
# kubelet: /usr/bin/kubelet
Another way would be to see the extended logging of a service like using journalctl -u kubelet.
Well, there we have it, wrong path specified. Correct the path in file /etc/systemd/system/kubelet.service.d/10-kubeadm.conf and run:
systemctl daemon-reload && systemctl restart kubelet
Finally we write the reason into the file:
# /opt/course/18/reason.txt
wrong path to kubelet binary specified in service config
```
```BASH
Question 19 | Create Secret and mount into Pod
Task weight: 3%
NOTE: This task can only be solved if questions 18 or 20 have been successfully implemented and the k8s-c3-CCC cluster has a functioning worker node
Use context: kubectl config use-context k8s-c3-CCC
Do the following in a new Namespace secret. Create a Pod named secret-pod of image busybox:1.31.1 which should keep running for some time.

There is an existing Secret located at /opt/course/19/secret1.yaml, create it in the Namespace secret and mount it readonly into the Pod at /tmp/secret1.

# Create a new Secret in Namespace secret called secret2 which should contain user=user1 and pass=1234. These entries should be available inside the Pod's container as environment variables APP_USER and APP_PASS.
Confirm everything is working.

Answer
First we create the Namespace and the requested Secrets in it:
k create ns secret
cp /opt/course/19/secret1.yaml 19_secret1.yaml

k -f 19_secret1.yaml create
Next we create the second Secret:

k -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234
Now we create the Pod template:

k -n secret run secret-pod --image=busybox:1.31.1 $do -- sh -c "sleep 5d" > 19.yaml
# It might not be necessary in current K8s versions to specify the readOnly: true because it's the default setting anyways.
Finally we check if all is correct:
k -n secret exec secret-pod -- env | grep APP
k -n secret exec secret-pod -- find /tmp/secret1
```
```YAML
  env:                                  # add
  - name: APP_USER                      # add
    valueFrom:                          # add
      secretKeyRef:                     # add
        name: secret2                   # add
        key: user                       # add
  - name: APP_PASS                      # add
    valueFrom:                          # add
      secretKeyRef:                     # add
        name: secret2                   # add
        key: pass                       # add
  volumeMounts:                         # add
  - name: secret1                       # add
    mountPath: /tmp/secret1             # add
    readOnly: true                      # add
volumes:                                # add
- name: secret1                         # add
  secret:                               # add
    secretName: secret1                 # add
```
```BASH
Question 20 | Update Kubernetes Version and join cluster
Task weight: 10%
Use context: kubectl config use-context k8s-c3-CCC

# Your coworker said node cluster3-worker2 is running an older Kubernetes version and is not even part of the cluster. Update Kubernetes on that node to the exact version that's running on cluster3-master1. Then add this node to the cluster. Use kubeadm for this.

Answer:
Master node seems to be running Kubernetes 1.24.1 and cluster3-worker2 is not yet part of the cluster.
ssh cluster3-worker2
kubeadm version # kubeadm version matches
kubectl version # kubectl version is old
kubelet --version # kubelet version is old

kubeadm upgrade node
This is usually the proper command to upgrade a node. But this error means that this node was never even initialised, so nothing to update here. This will be done later using kubeadm join. For now we can continue with kubelet and kubectl:
apt update
apt show kubectl -a | grep 1.24
apt install kubectl=1.24.1-00 kubelet=1.24.1-00
# Now we're up to date with kubeadm, kubectl and kubelet. Restart the kubelet:
systemctl restart kubelet
We can ignore the errors and move into next step to generate the join command.
# Add cluster3-worker2 to cluster
First we log into the master1 and generate a new TLS bootstrap token, also printing out the join command:
ssh cluster3-master1
kubeadm token create --print-join-command
kubeadm token list
Next we connect again to cluster3-worker2 and simply execute the join command:
ssh cluster3-worker2
kubeadm join 192.168.100.31:6443 --token <token>
```
```BASH
Question 21 | Create a Static Pod and Service
Task weight: 2%
Use context: kubectl config use-context k8s-c3-CCC

Create a Static Pod named my-static-pod in Namespace default on cluster3-master1. It should be of image nginx:1.16-alpine and have resource requests for 10m CPU and 20Mi memory.

Then create a NodePort Service named static-pod-service which exposes that static Pod on port 80 and check if it has Endpoints and if its reachable through the cluster3-master1 internal IP address. You can connect to the internal node IPs from your main terminal.

Answer:
ssh cluster3-master1
cd /etc/kubernetes/manifests/
kubectl run my-static-pod \
    --image=nginx:1.16-alpine \
    -o yaml --dry-run=client > my-static-pod.yaml
And make sure its running:
k get pod -A | grep my-static
Now we expose that static Pod:
k expose pod my-static-pod-cluster3-master1 \
  --name static-pod-service \
  --type=NodePort \
  --port 80
Then run and test:
k get svc,ep -l run=my-static-pod
```
```YAML
# /etc/kubernetes/manifests/my-static-pod.yaml
resources:
  requests:
    cpu: 10m
    memory: 20Mi
```
```BASH
Question 22 | Check how long certificates are valid
Task weight: 2%

Use context: kubectl config use-context k8s-c2-AC

Check how long the kube-apiserver server certificate is valid on cluster2-master1. Do this with openssl or cfssl. Write the exipiration date into /opt/course/22/expiration.

Also run the correct kubeadm command to list the expiration dates and confirm both methods show the same date.

Write the correct kubeadm command that would renew the apiserver server certificate into /opt/course/22/kubeadm-renew-certs.sh.
Answer:
# First let's find that certificate:
ssh cluster2-master1
find /etc/kubernetes/pki | grep apiserver
Next we use openssl to find out the expiration date:
openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep Validity -A2
There we have it, so we write it in the required location on our main terminal:

# /opt/course/22/expiration
Jan 14 18:49:40 2022 GMT
And we use the feature from kubeadm to get the expiration too:
kubeadm certs check-expiration | grep apiserver

Looking good. And finally we write the command that would renew all certificates into the requested location:

# /opt/course/22/kubeadm-renew-certs.sh
kubeadm certs renew apiserver
```
```BASH
Question 23 | Kubelet client/server cert info
Task weight: 2%
Use context: kubectl config use-context k8s-c2-AC

Node cluster2-worker1 has been added to the cluster using kubeadm and TLS bootstrapping.

Find the "Issuer" and "Extended Key Usage" values of the cluster2-worker1:

kubelet client certificate, the one used for outgoing connections to the kube-apiserver.
kubelet server certificate, the one used for incoming connections from the kube-apiserver.
Write the information into file /opt/course/23/certificate-info.txt.

Compare the "Issuer" and "Extended Key Usage" fields of both certificates and make sense of these.

Answer:
To find the correct kubelet certificate directory, we can look for the default value of the --cert-dir parameter for the kubelet. For this search for "kubelet" in the Kubernetes docs which will lead to: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet. We can check if another certificate directory has been configured using ps aux or in /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.

First we check the kubelet client certificate:

ssh cluster2-worker1
openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep Issuer
openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep "Extended Key Usage" -A1
Next we check the kubelet server certificate:
openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer
openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1
We see that the server certificate was generated on the worker node itself and the client certificate was issued by the Kubernetes api. The "Extended Key Usage" also shows if its for client or server authentication.

More about this: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping
```
```BASH
Question 24 | NetworkPolicy
Task weight: 9%
Use context: kubectl config use-context k8s-c1-H
There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.

To prevent this create a NetworkPolicy called np-backend in Namespace project-snake. It should allow the backend-* Pods only to:

connect to db1-* Pods on port 1111
connect to db2-* Pods on port 2222
Use the app label of Pods in your policy.

After implementation, connections from backend-* Pods to vault-* Pods on port 3333 should for example no longer work.

Answer:
First we look at the existing Pods and their labels:
k -n project-snake get pod
k -n project-snake get pod -L app
We test the current connection situation and see nothing is restricted:
k -n project-snake get pod -o wide
k -n project-snake exec backend-0 -- curl -s 10.44.0.25:1111
k -n project-snake exec backend-0 -- curl -s 10.44.0.23:2222
k -n project-snake exec backend-0 -- curl -s 10.44.0.22:3333
Now we create the NP by copying and chaning an example from the k8s docs:

The NP below has two rules with two conditions each, it can be read as:

allow outgoing traffic if:
  (destination pod has label app=db1 AND port is 1111)
  OR
  (destination pod has label app=db2 AND port is 2222)

We create the correct NP:

k -f 24_np.yaml create
And test again:

k -n project-snake exec backend-0 -- curl -s 10.44.0.25:1111
k -n project-snake exec backend-0 -- curl -s 10.44.0.23:2222
k -n project-snake exec backend-0 -- curl -s 10.44.0.22:3333
```
```YAML
# 24_np.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Egress                    # policy is only about Egress
  egress:
    -                           # first rule
      to:                           # first condition "to"
      - podSelector:
          matchLabels:
            app: db1
      ports:                        # second condition "port"
      - protocol: TCP
        port: 1111
    -                           # second rule
      to:                           # first condition "to"
      - podSelector:
          matchLabels:
            app: db2
      ports:                        # second condition "port"
      - protocol: TCP
        port: 2222
```
```BASH
Question 25 | Etcd Snapshot Save and Restore
Task weight: 8%
Use context: kubectl config use-context k8s-c3-CCC

Make a backup of etcd running on cluster3-master1 and save it on the master node at /tmp/etcd-backup.db.

Then create a Pod of your kind in the cluster.

Finally restore the backup, confirm the cluster is still working and that the created Pod is no longer with us.

Etcd Backup
First we log into the master and try to create a snapshop of etcd:

ssh cluster3-master1
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db
But it fails because we need to authenticate ourselves. For the necessary information we can check the etc manifest:
vim /etc/kubernetes/manifests/etcd.yaml
# OR
But we also know that the api-server is connecting to etcd, so we can check how its manifest is configured:
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd
We use the authentication information and pass it to etcdctl:
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key
# NOTE: Dont use snapshot status because it can alter the snapshot file and render it invalid
Etcd restore
Now create a Pod in the cluster and wait for it to be running:
kubectl run test --image=nginx
# NOTE: If you didn't solve questions 18 or 20 and cluster3 doesn't have a ready worker node then the created pod might stay in a Pending state. This is still ok for this task.

Next we stop all controlplane components:
cd /etc/kubernetes/manifests/
mv * ..
watch crictl ps
Now we restore the snapshot into a specific directory:

ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
--data-dir /var/lib/etcd-backup \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key
We could specify another host to make the backup from by using etcdctl --endpoints http://IP, but here we just use the default value which is: http://127.0.0.1:2379,http://127.0.0.1:4001.

The restored files are located at the new folder /var/lib/etcd-backup, now we have to tell etcd to use that directory:

vim /etc/kubernetes/etcd.yaml
- hostPath:
    path: /var/lib/etcd-backup                # change

Now we move all controlplane yaml again into the manifest directory. Give it some time (up to several minutes) for etcd to restart and for the api-server to be reachable again:
mv ../*.yaml .
watch crictl ps
Then we check again for the Pod:
kubectl get pod -l run=test
Awesome, backup and restore worked as our pod is gone.
```
```BASH
Extra Question 1 | Find Pods first to be terminated
Use context: kubectl config use-context k8s-c1-H
Check all available Pods in the Namespace project-c13 and find the names of those that would probably be terminated first if the nodes run out of resources (cpu or memory) to schedule all Pods. Write the Pod names into /opt/course/e1/pods-not-stable.txt.

Answer:
When available cpu or memory resources on the nodes reach their limit, Kubernetes will look for Pods that are using more resources than they requested. These will be the first candidates for termination. If some Pods containers have no resource requests/limits set, then by default those are considered to use more than requested.

Kubernetes assigns Quality of Service classes to Pods based on the defined resources and limits, read more here: https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod

Hence we should look for Pods without resource requests defined, we can do this with a manual approach:
k -n project-c13 describe pod | less -p Requests # describe all pods and highlight Requests
k -n project-c13 describe pod | egrep "^(Name:|    Requests:)" -A1
# We see that the Pods of Deployment c13-3cc-runner-heavy don't have any resources requests specified. Hence our answer would be:

Hence our answer would be:

# /opt/course/e1/pods-not-stable.txt
c13-3cc-runner-heavy-65588d7d6-djtv9map
c13-3cc-runner-heavy-65588d7d6-v8kf5map
c13-3cc-runner-heavy-65588d7d6-wwpb4map
o3db-0
o3db-1 # maybe not existing if already removed via previous scenario 

To automate this process you could use jsonpath like this:
k -n project-c13 get pod \
  -o jsonpath="{range .items[*]} {.metadata.name}{.spec.containers[*].resources}{'\n'}"

Or we look for the Quality of Service classes:
k get pods -n project-c13 \
  -o jsonpath="{range .items[*]}{.metadata.name} {.status.qosClass}{'\n'}"
# Here we see three with BestEffort, which Pods get that don't have any memory or cpu limits or requests defined.
# A good practice is to always set resource requests and limits. If you don't know the values your containers should have you can find this out using metric tools like Prometheus. You can also use kubectl top pod or even kubectl exec into the container and use top and similar tools.
```
```BASH
Extra Question 2 | Curl Manually Contact API
Use context: kubectl config use-context k8s-c1-H
There is an existing ServiceAccount secret-reader in Namespace project-hamster. Create a Pod of image curlimages/curl:7.65.3 named tmp-api-contact which uses this ServiceAccount. Make sure the container keeps running.

Exec into the Pod and use curl to access the Kubernetes Api of that cluster manually, listing all available secrets. You can ignore insecure https connection. Write the command(s) for this into file /opt/course/e4/list-secrets.sh.

Answer:
https://kubernetes.io/docs/tasks/run-application/access-api-from-pod

# It's important to understand how the Kubernetes API works. For this it helps connecting to the api manually, for example using curl. You can find information fast by search in the Kubernetes docs for "curl api" for example.

First we create our Pod:  
k run tmp-api-contact \
  --image=curlimages/curl:7.65.3 $do \
  --command > e2.yaml -- sh -c 'sleep 1d'
Add the service account name and Namespace:

Then run and exec into:

k -f e2.yaml create

k -n project-hamster exec tmp-api-contact -it -- sh

Once on the container we can try to connect to the api using curl, the api is usually available via the Service named kubernetes in Namespace default (You should know how dns resolution works across Namespaces.). Else we can find the endpoint IP via environment variables running env.
So now we can do:

curl https://kubernetes.default
curl -k https://kubernetes.default # ignore insecure as allowed in ticket description
curl -k https://kubernetes.default/api/v1/secrets # should show Forbidden 403

The last command shows 403 forbidden, this is because we are not passing any authorisation information with us. The Kubernetes Api Server thinks we are connecting as system:anonymous. We want to change this and connect using the Pods ServiceAccount named secret-reader.
We find the the token in the mounted folder at /var/run/secrets/kubernetes.io/serviceaccount, so we do:
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"

# Now we're able to list all Secrets, registering as the ServiceAccount secret-reader under which our Pod is running.

To use encrypted https connection we can run:
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl --cacert ${CACERT} https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"
For troubleshooting we could also check if the ServiceAccount is actually able to list Secrets using:
k auth can-i get secret --as system:serviceaccount:project-hamster:secret-reader
# yes
Finally write the commands into the requested location:
# /opt/course/e4/list-secrets.sh
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"
```
```BASH
Preview Question 1
Use context: kubectl config use-context k8s-c2-AC

The cluster admin asked you to find out the following information about etcd running on cluster2-master1:

Server private key location
Server certificate expiration date
Is client certificate authentication enabled
Write these information into /opt/course/p1/etcd-info.txt

# Finally you're asked to save an etcd snapshot at /etc/etcd-snapshot.db on cluster2-master1 and display its status.
Answer:
Find out etcd information
# Let's check the nodes:
k get node
ssh cluster2-master1
First we check how etcd is setup in this cluster:
kubectl -n kube-system get pod
We see its running as a Pod, more specific a static Pod. So we check for the default kubelet directory for static manifests:
find /etc/kubernetes/manifests/
vim /etc/kubernetes/manifests/etcd.yaml
- command:
    - etcd
    - --advertise-client-urls=https://192.168.102.11:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt              # server certificate
    - --client-cert-auth=true                                      # enabled
    - --key-file=/etc/kubernetes/pki/etcd/server.key               # server private key

# We see that client authentication is enabled and also the requested path to the server private key, now let's find out the expiration of the server certificate:
openssl x509  -noout -text -in /etc/kubernetes/pki/etcd/server.crt | grep Validity -A2
# There we have it. Let's write the information into the requested file:

# /opt/course/p1/etcd-info.txt
Server private key location: /etc/kubernetes/pki/etcd/server.key
Server certificate expiration date: Sep 13 13:01:31 2022 GMT
Is client certificate authentication enabled: yes
Create etcd snapshot
ETCDCTL_API=3 etcdctl snapshot save /etc/etcd-snapshot.db \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key

This worked. Now we can output the status of the backup file:
ETCDCTL_API=3 etcdctl snapshot status /etc/etcd-snapshot.db
```
```BASH
Preview Question 2
Use context: kubectl config use-context k8s-c1-H
# You're asked to confirm that kube-proxy is running correctly on all nodes. For this perform the following in Namespace project-hamster:

Create a new Pod named p2-pod with two containers, one of image nginx:1.21.3-alpine and one of image busybox:1.31. Make sure the busybox container keeps running for some time.

Create a new Service named p2-service which exposes that Pod internally in the cluster on port 3000->80.

# Find the kube-proxy container on all nodes cluster1-master1, cluster1-worker1 and cluster1-worker2 and make sure that it's using iptables. Use command crictl for this.

Write the iptables rules of all nodes belonging the created Service p2-service into file /opt/course/p2/iptables.txt.

Finally delete the Service and confirm that the iptables rules are gone from all nodes.

Answer:
Create the Pod
First we create the Pod:
k run p2-pod --image=nginx:1.21.3-alpine $do > p2.yaml
# p2.yaml
- image: busybox:1.31                  # add
  name: c2                             # add
  command: ["sh", "-c", "sleep 1d"]    # add
Create the Service
Next we create the Service:
k -n project-hamster expose pod p2-pod --name p2-service --port 3000 --target-port 80
We should confirm Pods and Services are connected, hence the Service should have Endpoints.

k -n project-hamster get pod,svc,ep

Confirm kube-proxy is running and is using iptables
First we get nodes in the cluster:
k get node
The idea here is to log into every node, find the kube-proxy container and check its logs:
ssh cluster1-master1
crictl ps | grep kube-proxy
crictl logs 27b6a18c0f89c
This should be repeated on every node and result in the same output Using iptables Proxier.
Check kube-proxy is creating iptables rules
Now we check the iptables rules on every node first manually:
ssh cluster1-master1 iptables-save | grep p2-service
# Great. Now let's write these logs into the requested file:
ssh cluster1-master1 iptables-save | grep p2-service >> /opt/course/p2/iptables.txt
ssh cluster1-worker1 iptables-save | grep p2-service >> /opt/course/p2/iptables.txt
ssh cluster1-worker2 iptables-save | grep p2-service >> /opt/course/p2/iptables.txt
Delete the Service and confirm iptables rules are gone
Delete the Service:
k -n project-hamster delete svc p2-service
And confirm the iptables rules are gone:
ssh cluster1-master1 iptables-save | grep p2-service
# Kubernetes Services are implemented using iptables rules (with default config) on all nodes. Every time a Service has been altered, created, deleted or Endpoints of a Service have changed, the kube-apiserver contacts every node's kube-proxy to update the iptables rules according to the current state.
```
```BASH
Preview Question 3
Use context: kubectl config use-context k8s-c2-AC

Create a Pod named check-ip in Namespace default using image httpd:2.4.41-alpine. Expose it on port 80 as a ClusterIP Service named check-ip-service. Remember/output the IP of that Service.

Change the Service CIDR to 11.96.0.0/12 for the cluster.

Then create a second Service named check-ip-service2 pointing to the same Pod to check if your settings did take effect. Finally check if the IP of the first Service has changed.

Answer:
# Let's create the Pod and expose it:
k run check-ip --image=httpd:2.4.41-alpine
k expose pod check-ip --name check-ip-service --port 80
And check the Pod and Service ips:
k get svc,ep -l run=check-ip
Now we change the Service CIDR on the kube-apiserver:
ssh cluster2-master1
vim /etc/kubernetes/manifests/kube-apiserver.yaml
- --service-cluster-ip-range=11.96.0.0/12             # change
Give it a bit of time for the kube-apiserver and controller-manager to restart
Wait for the api to be up again:
kubectl -n kube-system get pod | grep api
Now we do the same for the controller manager:
vim /etc/kubernetes/manifests/kube-controller-manager.yaml
- --service-cluster-ip-range=11.96.0.0/12         # change
Give it a bit for the controller-manager to restart.

We can check if it was restarted using crictl:
crictl ps | grep scheduler
Checking our existing Pod and Service again:
k get pod,svc -l run=check-ip
Nothing changed so far. Now we create another Service like before:

k expose pod check-ip --name check-ip-service2 --port 80
And check again:
k get svc,ep -l run=check-ip
There we go, the new Service got an ip of the new specified range assigned. We also see that both Services have our Pod as endpoint.
```
