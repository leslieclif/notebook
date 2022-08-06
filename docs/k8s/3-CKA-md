- To get the version of K8s , run `kubectl get nodes`
- Hit Ctrl + D to exit out of SSH session when moving to Nodes and coming back or type `exit`
## ETCD
- ETCDCTL can interact with ETCD Server using 2 API versions - Version 2 and Version 3. 
- By default its set to use Version 2. Each version has different sets of commands.
- To set the right version of API set the environment variable `ETCDCTL_API` command `export ETCDCTL_API=3`
- When API version is not set, it is assumed to be set to version 2. And version 3 commands listed below don't work. When API version is set to version 3, version 2 commands listed below don't work.
```BASH
# ETCDCTL version 2
etcdctl backup
etcdctl cluster-health
etcdctl mk
etcdctl mkdir
etcdctl set

# ETCDCTL version 3
etcdctl snapshot save 
etcdctl endpoint health
etcdctl get
etcdctl put

# This command sets the ETCD version to 3 and then shows all the keys in ETCD database and also sets the certificates
kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key" 
```
## API Server
- Api Server Configuration is stored
1. Using Kubeadm - Inside API Server Pod - `/etc/kubernetes/manifests/kube-apiserver.yaml`
2. As a Service - Inside the Master Node - `/etc/systemd/system/kube-apiserver.service`
```BASH
ps -ef | grep kube-apiserver        # To see all kube apiserver configuration
```
## Kube Controller Manager
- Watch Status
- Remediate Situation
1. Node Controller
2. Replicaton Controller
- Api Server Configuration is stored
1. Using Kubeadm - Inside API Server Pod - `/etc/kubernetes/manifests/kube-controller-manager.yaml`
2. As a Service - Inside the Master Node - `/etc/systemd/system/kube-controller-manager.service`
```BASH
ps -ef | grep kube-controller-manager        # To see all kube controller-manager configuration
```
## Kube Scheduler
- Assigning a Pod to a Node:
1. Filter Nodes
2. Rank Nodes
1. Using Kubeadm - Inside API Server Pod - `/etc/kubernetes/manifests/kube-scheduler.yaml`
2. As a Service - Inside the Master Node - `/etc/systemd/system/kube-scheduler.service`
```BASH
ps -ef | grep kube-scheduler       # To see all kube scheduler configuration
```
## Kubelet
- **NOTE**: Kubeadm does not install kubelet. Always install kubelet manually on the worker nodes.
- Always runs as a service on the worker nodes.
```BASH
ps -ef | grep kubelet       # To see all kubelet configuration
```
## Kube Proxy
- Process running on the worker node as a service.
## Manual Scheduling
- Add `nodeName` property in the pod definition to schedule a pod at creation time if there is no scheduler.

## DaemonSets
```BASH
kubectl get daemonsets
# TIP: There is no kubectl create daemonset, so do a create deployment, get this into a yaml.
# Format the yaml for Kind, Remove replicas, strategy and save the file.
```
## Static Pods
- When there is no Master Node and its components, you can create Pods on standalone Worker Node.
- Such a pod is called `Static Pod`
- The pod definitions have to be placed in `/etc/kubernetes/manifests` in a yaml file.
- Deleting the yaml file, removes the pod from the node.
- To inspect the path where the definition is defined, look at the kubelet.service. It could be in 2 places:
1. --config=<file name>     - kubeadm installation
2. --pod-manifest-path=<file path>  - manual installation 
- To identify static pods, `pod name` will have the `node name` appended at the end.
- kubeadm deploys the cluster components as static pods, which have `controlplane` appended in the pod name.
- Another way to identify static pod is to get the yaml of the pod and then searching for `ownerReferences`. In that if `kind: Node` then its a static pod.
```BASH
# To view the pods after creation, as kubectl will not work
docker ps
# To kill the pod
docker container rm <id>
# Kubelet config
/var/lib/kubelet/config.yaml
```
## Multiple Kube Schedulers
![K8s Multiple Scheduler Config](../assets/images/k8s-multiple-scheduler-config.png)
![K8s Multiple Scheduler Pod Config](../assets/images/k8s-multiple-scheduler-pod-config.png)
![K8s Multiple Scheduler Events](../assets/images/k8s-multiple-scheduler-events.png)
![K8s Multiple Scheduler Logs](../assets/images/k8s-multiple-scheduler-logs.png)

- Advanced Scheduling
https://github.com/kubernetes/community/blob/master/contributors/devel/sig-scheduling/scheduling_code_hierarchy_overview.md

https://kubernetes.io/blog/2017/03/advanced-scheduling-in-kubernetes/


https://jvns.ca/blog/2017/07/27/how-does-the-kubernetes-scheduler-work/

https://stackoverflow.com/questions/28857993/how-does-kubernetes-scheduler-work

## OS Upgrades
```BASH
kubectl drain node1         # Gracefully evict the pods
kubectl cordon node1        # Makes the node unschedulable
kubectl uncordon node1      # Makes its schedulable after maintenance
kubectl drain node01 --ignore-daemonsets        # Incase you get the ds exist error
# Even with ignore ds options, you can get error when there are pods which are not managed by a replicaSet
# error: unable to drain node "node01" due to error:cannot delete Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override)
# In this case, copy the pod data into yaml and apply it again after draining the nodes using --force
```
## K8s Release Strategy
https://kubernetes.io/docs/concepts/overview/kubernetes-api/
https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md
https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api_changes.md

## Cluster Upgrade
- First upgrade master, then the nodes
- Kubeadm does not update the kubelet, so it needs to be updated manually
```BASH
cat /etc/*release*          # Shows the OS version
# When you do apt-cache update, it will show which kubeadm minor version is present
# TIP: Copy the upgrade commands to notepad, before updating versions and pasting
kubeadm upgrade plan        # Shows the upgrade plan
apt-get upgrade -y kubeadm=1.12.0-00        # 1st Update kubeadm as per plan
kubeadm upgrade apply v1.12.0   # Upgrade the cluster controlplane 
# NOTE: Master will show version of kubelet, which has not been updated yet.
kubectl get nodes           # Master is still shown with V1.11 version
# Drain the master and then perform kubelet upgrade
apt-get upgrade -y kubelet=1.12.0-00  # Upgrade the kubelet
systemctl restart kubelet      # Make the change permanent
kubectl get nodes           # Master is now shown with V1.12 version
# Now follow the process of upgrading Nodes using drain and cordon
# IMPORTANT: the Node Drain command needs to be run on the master and not Node01. .e. all kubelet commands like drain and uncordon needs to be run on master
# Follow the upgrade process, upgrade kubeadm, upgrade kubelet , upgrade node and then restart kubelet
# Uncordon the Node
# NOTE: the Node upgrade command
kubeadm upgrade node config --kubelet-version v1.12.0   # Upgrade the node
```
# Backup and Restore
- To make use of etcdctl for tasks such as back up and restore, make sure that you set the ETCDCTL_API to 3. `export ETCDCTL_API=3`
- For example, if you want to take a snapshot of etcd, use: `etcdctl snapshot save -h` and keep a note of the mandatory global options.
- Since our ETCD database is TLS-Enabled, the following options are mandatory:
1. `--cacert` - verify certificates of TLS-enabled secure servers using this CA bundle
2. `--cert` - identify secure client using this TLS certificate file
3. `--endpoints=https://127.0.0.1:2379` - This is the default as ETCD is running on master node and exposed on localhost 2379.
4. `--key` - identify secure client using this TLS key file
- Similarly use the help option for snapshot restore to see all available options for restoring the backup.
`etcdctl snapshot restore -h`
```BASH
# Manual Backup of applications
kubectl get all --all-namespaces -o yaml > all-deployed-services.yaml
# Backup ETCD
ETCDCTL_API=3 etcdctl snapshot save snapshot.db
ETCDCTL_API=3 etcdctl snapshot status snapshot.db       # View backup status
# To restore ETCD
# First stop the kube-apiserver 
service kube-apiserver stop
# Execute restore from the saved state
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db --data-dir /var/lib/etcd-from-backup
# Here the data-dir is a new dir where the ETCD will start storing the data.
# This is done so that the existing data is not overwritten, in case of any issues during restore
# Reload the service daemon and restart etcd service
systemctl daemon-reload
service etcd restart
# Finally start the kube-apiserver 
service kube-apiserver start

# Tips: To check the version of etcd, check the etcd pod logs or the image version in the etcd pod
kubectl describe pod etcd-controlplane -n kube-system
# Get the below 4 parameters after describe etcd pod
ETCDCTL_API=3 etcdctl snapshot save /opt/snapshot-pre-boot.db \
	 --cacert="/etc/kubernetes/pki/etcd/ca.crt" \
	  --cert="/etc/kubernetes/pki/etcd/server.crt" \
	  --endpoints=https://127.0.0.1:2379  \
	  --key="/etc/kubernetes/pki/etcd/server.key" 
# Restore the etcd to a new directory from the snapshot 
# So move the backed up data to a new dir
ETCDCTL_API=3 etcdctl snapshot restore /opt/snapshot-pre-boot.db \
	 --data-dir="/var/lib/backup-from-etcd" 
# Certificate details are not required in restore as the file in in local directory.
# Next, update the /etc/kubernetes/manifests/etcd.yaml:
# We have now restored the etcd snapshot to a new path on the controlplane - /var/lib/etcd-from-backup, so, the only change to be made in the YAML file, is to change the hostPath for the volume called etcd-data from old directory (/var/lib/etcd) to the new directory (/var/lib/etcd-from-backup).
volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data
```
https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster
https://github.com/etcd-io/website/blob/main/content/en/docs/v3.5/op-guide/recovery.md
https://www.youtube.com/watch?v=qRPNuT080Hk

## Security
![K8s Security Across Components](../assets/images/k8s-security-across-components.png)
![K8s Security Actors](../assets/images/k8s-security-actors.png)
![K8s Security basics](../assets/images/k8s-security-basics.png)
### TLS
- There are 2 types of Encryption mechanisms: `Symmetric and Asymmetric`
- For TLS both the mechanims are used:
1. Symmetric - To encrypt the client data
2. Asymmetric - To encrypt the symmetric key after server auth
- In symmetric, one key is used to encrypt and decrypt the data, while in asymmetic 2 keys are used.
![TLS Key Types](../assets/images/tls-key-types.png)
- Public Key (will be refered as Lock). You can encrypt data with either private or public key.
- **NOTE**: Decryption is only done using the opposite key. For example, if you encrypt the data with public key, you cannot decrypt it using public key, you **MUST** using the private key.
![TLS Key Naming Convention](../assets/images/tls-key-naming.png)
- Keys have naming convention, private key will always have `key` in the name to identify it as private key.
- There are 3 usecases of using Asymmetric Encyption in the TLS process
1. Using SSH to login to any server. In this case, user private key is used to unlock the server access having the user's public key stored on the server.
![Server Auth using TLS](../assets/images/tls-auth-for-servers.png)
2. Using asymmetric keys to transfer client's symetric key over the Internet. These are called **Server Certificates**. This should ensure no hacker is allowed to decrypt the data in transit. 
![Websites Auth using TLS](../assets/images/tls-auth-for-websites.png)
![Websites Auth Usecase using TLS](../assets/images/tls-website-auth-usecase.png)
3. Using asymmetric keys to authenticate the website. These are called **Root Certificates**. In this case, the website presents a CA certificate which is having the CA pulic key embedded. The client presents this via the browser which has CA's public keys installed, which decrypts the certificate using the public key to authenticate the website. 
![CA Auth Usecase using TLS](../assets/images/tls-ca-auth-usecase.png)
![CA Functions using TLS](../assets/images/tls-ca-functions.png)
- **TLS Overview**
![TLS Process Overview](../assets/images/tls-process-overview.png)
- A system admin generates private and public key to enforce SSH authenication. The public key is stored in the server.
- Web Server generates private and public key to encrypt HTTPS trafic. For this, the web server generates a certificate signing request using its public key. This CSR (which has the public key of the server) is sent to the CA for signing the certificate.
- The CA signs the certificate using its private key and sends it back to the server after completing its validation process.
- When a client request comes, the web server sends its certificate having its encrypted public key back.
- The client presents the certificate to the browser. The browser using the CA public key, decrypts the certificate, thus authenticating the web server and thus the website.
- The decrypted certificate has the server's public key. The client generates its `symmetric key` and then encrypts this using the web server's public key and sends the request back to the web server.
- The web server decrypts the request using its private key and gets access to the client's symmetric key.
- Now the communication between the client and web server will continue happening using this symmetric key.
### TLS in Kubernetes
- There are 2 types of certificates used in Kubernetes components
1. Server Certificates - Used by the server components
2. Client Certificates - These are certificates used by Users or process to authenticate themselves.
![K8s TLS Certificate Types](../assets/images/ks8-tls-cert-types.png)
![K8s TLS Server Certificate](../assets/images/k8s-tls-server-certs.png)
- Types of Clients for the API server:
1. Admin Users
2. Kube Scheduler
3. Kube Controller Manager
4. Kube Proxy
- There is only one client for the ETCD server: Api Server
- There is also one client for the Kubelet server: Api Server
![K8s TLS Client Certificate](../assets/images/k8s-tls-client-certs.png)
- All the certificates (Server and Client) need to be signed by a Root certificate that is issued by a CA.
![K8s TLS CA Certificate](../assets/images/k8s-tls-ca-certs.png)
### Certificate Creation
```BASH
# We require only Private Keys and Certificates
# Generate CA certificates
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
# Sign the CSR to generate the Root Cert
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt

# Generating Client Key and Certificates
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=kube-admin/O=system:masters" -out admin.csr
# Remember CN will the user name that is used to login to API server
# O parameter should link to the user account, in this case its the admin group
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt
# Here the CA crt and CA key is used to sign the user csr

# Once the cluster is configured, you an use the certificates in Rest API calls
curl https://kube-apiserver:6443/api/v1/pods \
--key admin.key --cert admin.crt
--cacert ca.crt

# Generating Server Key and Certificates
openssl genrsa -out apiserver.key 2048
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr -config openssl.cnf
# Additional openssl.cnf contains DNS Alias or IP address which refers back to the apiserver
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt
```
### Debugging Certificates
```BASH
# View existing certificates
openssl x509 -req -in /etc/kubernetes/pki/apiserver.crt -text -noout
# Verify the Subject, Subject Alternative Names (Alias), Not After (to check validity), Issuer (CA)

# Debugging Certificate Issues
# When installed as service
journalctl -u etcd.service -l 		# List the service logs
# When installed using kubeadm
kubectl logs etcd-master
## Failure logs - Failed to dial 127.0.0.1:2379: connection error

# If ETCD or Apiserver is down, use docker
docker ps -a		# To view the containers
docker logs <container id>		# To view the logs
```
### Certificates API
![K8s Certificate Functions](../assets/images/k8s-certificate-functions.png)
![K8s Certificate Object](../assets/images/k8s-certificate-object.png)
- **NOTE**: To view the CA certificates, as its stored on the master look at the Controller Manager configuration and check the path mentioned under `--cluster-signing-cert-file` and `--cluster-signing-key-file`
```BASH
kubectl get csr				# Get pending CSR 
kubectl certificate approve jane # Approve CSR
kubectl get csr jane -o yaml	# View the CSR
echo "data" | base64 --decode	# Extract the Certificate from CSR after it is approved and send to user jane
# Now she will be able to login to the cluster
```
## Image Security
```BASH
# Create a Docker Registry secret in the cluster for Kubelet to pass this to the Docker Runtime on the worker nodes
kubectl create secret docker-registry regcred \
--docker-server=<URL> \
--docker-username=<> \
--docker-password=<> \
--docker-email=<email>
# Once the secret is created, use this in the Pod definition
imagePullSecrets:
- name: regcred
```
## Docker Volume
- Docker creates `Read Only` layers for the image
![Docker Image Layer](../assets/images/docker-image-layer.png)
- For the container a transient `Read-Write` layer is created.
![Docker Container Layer](../assets/images/docker-container-layer.png)
- When a volume is created and then it is mounted using the `-v` option, its is called `Volume Mount`.
- If a volume is not present, but a volume is mounted, Docker will create the volume at run time.
![Docker Volume Mount](../assets/images/docker-volume-mount.png)
- When a host directory is mounted, it is called `Bind Mount`
- Use the new convention `--mount` instead of `-v` in the new version of Docker.
![Docker Bind Mount](../assets/images/docker-bind-mount.png)

## Container Storage Interface
![K8s Interfaces](../assets/images/k8s-interfaces.png)
![K8s Storage Interface](../assets/images/k8s-storage-interface.png)

## Storage Class
- When we create PV, then it is called `Static Provisioning` of Storage.
- In cloud, there is need to create storage dynamically when PVC is used. 
- In this case, only Storage Class Objects are created. When a claim is made wihich references the Storage class, a PV is **dynamically** created. This is `Dynamic Provisioning` of Storage.
![K8s Storage Class](../assets/images/k8s-storage-class.png)
- The Storage Class makes use of `VolumeBindingMode` set to `WaitForFirstConsumer`. This will delay the binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created. Till then the PVC will be in `Pending State`.
```BASH
kubectl get storageclass
```
## Networking Basics
- Switching allows to configure machines to talk to each other in the same network
![Switching](../assets/images/switching.png)
- Routing allows machines to talk across 2 or more networks
![Routing](../assets/images/routing.png)
- Gateway allows machines to reach other network using a single entry point made in the routing table of each machine
![Gateway](../assets/images/gateway.png)
- When a machine wants to reach to the internet, manual routes can be made to reach the destination on each machine
![Manual Routing](../assets/images/manual-routing.png)
- To avoid the hassle of making entry for each IP address available on the Internet on each machine, a default route entry is made. When a route does not match, it goes through the default route.
- To separate Internal and External routing, you can make separate entries in the routing table of the machine.
![Default Gateway](../assets/images/default-gateway.png)
## DNS
- You need a DNS server and it can help manage name resolution in large environments with many hostnames and Ips and then configure your hosts to point to a DNS server. Domain names and the IP address of all the host in the network are added to the `/etc/hosts` file of the DNS server.
![DNS Basics](../assets/images/dns-basics.png)
- host file of the individual server is made to point to the DNS server for getting server names resolved to IP addresses. 
![DNS Basics 1](../assets/images/dns-basics-1.png)
- When the servers need to resolve a name which is not part of the internal network, the internal DNS server can point to an `external` DNS server to handle the name resolution. In this case, ping to facebook.com will get correctly resolved using Google DNS.
![DNS Basics 2](../assets/images/dns-basics-2.png)
- High level domain names are categorized based on their functions
![DNS Domains](../assets/images/dns-domains.png)
- Domains are further sub-divided into sub domains. Root (.) being the top most level. 
![DNS Domain Structure](../assets/images/dns-domain-structure.png)
- DNS resolution request originating from an internal company DNS traverses through the Root domain servers till it gets a match and then the IP address is sent back to the calling DNS, where the response is cached based on Time To Live parameter.
![DNS Domain Name Resolution](../assets/images/dns-domain-name-resolution.png)
- `A` records are stored which maps the DNS to the IP address. When you want yone DNS to map to multiple alias, you use the `CNAME` record.
- Using `search` inside an organization you can alias your domains. In this way, you can address your servers with only the sub-domain. search will append the domain name and then resolve the IP address
![DNS Search](../assets/images/dns-search.png)
