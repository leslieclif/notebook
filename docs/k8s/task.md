Cluster
- Use kubeadm to install a basic cluster
- Kubernetes the Hard way
- Perform a version upgrade (Minor version upgrade)
- Implement etcd backup and restore (Always check where the data directory is on the host path mentioned in Volume section)
- Provision underlying infrastructure to deploy a cluster
- Manage a HA cluster
RBAC
- Manage RBAC
Troubleshoot Worker Node (30%)
- Kubelet Service status  and Journald Log parsing
- Docker Service status
- Consult container logs directly from Docker
- Consult resources pod, ds, cm in kube-system namespaces

# Challenges
- Use etcdctl to get data of a pod
- Use etcdctl for changes by watching output
- docker commands to check logs, exec into running containers
- openssl to check expiry of certs
```BASH
# On Master
cd /etc/kubernetes/pki
openssl x509 -in ./apiserver.crt  -text -noout      # Commit to memory 
openssl x509 -in ./apiserver.crt -text -noout | grep Validity -A 2
```
- apt-get to check package information, cache, available versions

- ETCD has its own CA. The right CA must be used for the ETCD-CA file in /etc/kubernetes/manifests/kube-apiserver.yaml. You can change the CA for ETCD and watch what happens to Apiserver

- Kubeconfig Error `W0804 06:44:49.196716   17546 loader.go:221] Config not found:`. This could be mismatch in the current context information. Either User certificate path is incorrect

# Components

Understanding Kubernetes components and being able to fix and investigate clusters: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster
Know advanced scheduling: https://kubernetes.io/docs/concepts/scheduling/kube-scheduler
When you have to fix a component (like kubelet) in one cluster, just check how its setup on another node in the same or even another cluster. You can copy config files over etc
If you like you can look at Kubernetes The Hard Way once. But it's NOT necessary to do, the CKA is not that complex. But KTHW helps understanding the concepts
You should install your own cluster using kubeadm (one master, one worker) in a VM or using a cloud provider and investigate the components
Know how to use Kubeadm to for example add nodes to a cluster
Know how to create an Ingress resources
Know how to snapshot/restore ETCD from another machine