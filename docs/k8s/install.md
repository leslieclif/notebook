# Installing K8s
## Vagrant Setup
[Install](https://www.itwonderlab.com/en/ansible-kubernetes-vagrant-tutorial/)
[Dev Setup](https://www.itwonderlab.com/en/installating-kubernetes-dashboard/)
[Publish a web app](https://www.itwonderlab.com/en/nodeport-kubernetes-cluster/)
[Deployment Pattern](https://www.itwonderlab.com/en/istio-patterns-traffic-splitting-in-kubernetes/)
[Terraform App Deployment](https://www.itwonderlab.com/en/kubernetes-with-terraform/)
## Kubeadm

## Kops

# Verification
- Networking
```BASH
# Check Routing within the master node
sudo apt-get install net-tools
route           # Displays the routing network
# Check syslog errors
tail -f /var/log/syslog     # Ctrl + Z to exit
# Copy file from Master Node to Host machine
mkdir -p ~/.kube
vagrant port k8s-m-1        # Find the SSH port of the k8s-m-1 server
# Copy the file using scp (ssh password is vagrant)
scp -P 2222 vagrant@127.0.0.1:/home/vagrant/.kube/config ~/.kube/config
# Get Cluster Information
kubectl cluster-info
# Get Master Node Component health
kubectl get componentstatus

# In case Scheduler or Controller Manager is showing as Unhealthy or Connection refused.
# Modify the following files on all master nodes:
sudo vi /etc/kubernetes/manifests/kube-scheduler.yaml
# Clear the line (spec->containers->command) containing this phrase: - --port=0
sudo vi /etc/kubernetes/manifests/kube-controller-manager.yaml
# Clear the line (spec->containers->command) containing this phrase: - --port=0
sudo systemctl restart kubelet.service
```