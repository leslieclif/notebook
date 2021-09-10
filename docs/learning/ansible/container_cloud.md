# Container and Cloud Management
- In the last few years, container-based workloads and cloud workloads have become more and more popular, and for this reason, we are going to look at how you can automate tasks related to those kinds of workloads with Ansible.
- First of all, even if you are in a very good place in your automation path and you have a lot of Ansible roles written for your infrastructure, you can't leverage them in Dockerfiles, so you would end up replicating your work to create containers.
- If this is not enough of a problem, this situation quickly deteriorates when you start considering cloud environments. All cloud environments have their own control planes and native automation languages, so in a very short time, you would find yourself rewriting the automation for the same operation over and over, thus wasting time and deteriorating the consistency of your environments.
# Designing and building containers with playbooks
- Ansible provides ansible-container so that you can create containers using the same components you would use for creating machines. The first thing you should do is ensure that you have ansible-container installed. 
```BASH
sudo pip install ansible-container[docker,k8s]
```
- The ansible-container tool comes with three supported engines at the time of writing:
    - docker: This is needed if you want to use it with Docker Engine (that is, on your local machine).
    - k8s: This is needed if you want to use it with a Kubernetes cluster, both local (that is, MiniKube) or remote (that is, a production cluster).
    - openshift: This is needed if you want to use it with an OpenShift cluster, both local (that is, MiniShift) or remote (that is, a production cluster).
- Follow these steps to build the container using playbooks
    - Issuing the ansible-container init command `ansible-container init`
    - Running this command will also create the following files:
        - ansible.cfg: An empty file to be (eventually) used to override Ansible system configurations
        - ansible-requirements.txt: An empty file to (eventually) list the Python requirements for the building process of your containers
        - container.yml: A file that contains the Ansible code for the build
        - meta.yml: A file that contains the metadata for Ansible Galaxy
        - requirements.yml: An empty file to (eventually) list the Ansible roles that are required for your build
    - Let's try building our own container using this tool – replace the contents of container.yml with the following
```YAML
version: "2"
settings:
  conductor:
    base: centos:7
  project_name: http-server
services:
  web:
    from: "centos:7"
    roles:
      - geerlingguy.apache
    ports:
      - "80:80"
    command:
      - "/usr/bin/dumb-init"
      - "/usr/sbin/apache2ctl"
      - "-D"
      - "FOREGROUND"
    dev_overrides:
      environment:
        - "DEBUG=1"
```
    - We can now run ansible-container build to initiate the build.
    - At the end of the building process, we will have a container built with the geerlingguy.apache role applied to it. The ansible-container tool performs a multi-stage build capability, spinning up an Ansible container that is then used to build the real container.
    - If we specified more than one role to be applied, the output would be an image with more layers, since Ansible will create a layer for every specified role. In this way, containers can easily be built using your existing Ansible roles rather than Dockerfiles.
## Managing multiple container platforms
- To be able to call a deployment "production-ready," you need to be able to demonstrate that the service your application is delivering will run reasonably, even in the case of a single application crash, as well as hardware failure. Often, you'll have even more reliability constraints from your customer.
- Today, the most successful one is Kubernetes due to its various distributions/versions, so we are going to focus on it primarily.
- The idea of Kubernetes is that you inform the Kubernetes Control Plane that you want X number of instances of your Y application, and Kubernetes will count how many instances of the Y application are running on the Kubernetes Nodes to ensure that the number of instances are X. If there are too few instances, Kubernetes will take care to start more instances, while if there are too many instances, the exceeding instances will be stopped.
- Due to the complexity of installing and managing Kubernetes, multiple companies have started to sell distributions of Kubernetes that simplify their operations and that they are willing to support.
## Deploying to Kubernetes with ansible-container
- We will assume that you have access to either a Kubernetes cluster for testing. 
- To deploy your application to your cluster, you need to change the container.yml file so that you can add some additional information. We will need to add a section called **settings** and a section called **k8s_namespace** to declare our deployment settings.
```YAML
k8s_namespace:
  name: http-server
  description: An HTTP server
  display_name: HTTP server
```
- We can proceed with the deployment- `ansible-container --engine kubernetes deploy`
- As soon as Ansible has completed its execution, you will be able to find the http-server deployment on your Kubernetes cluster.
- Based on the image that we built in the previous section and the additional information we added at the beginning of this section, Ansible is able to populate a deployment template and then deploy it using the k8s module.
## Managing Kubernetes Objects with Ansible
- You can do `kubectl get namespaces` with Ansible by creating a file called k8s-ns-show.yaml
```YAML
---
- hosts: localhost
  tasks:
    - name: Get information from K8s
      k8s_info:
        api_version: v1
        kind: Namespace     # Specify the k8s object Deployments, Services, Pods
      register: ns
    - name: Print info
      debug:
        var: ns
```
```BASH
ansible-playbook k8s-ns-show.yaml
```
```YAML
# Create a new namespace
---
- hosts: localhost
  tasks:
    - name: Ensure the myns namespace exists
      k8s:
        api_version: v1
        kind: Namespace
        name: myns
        state: present
```
```YAML
# Creates a new service
---
- hosts: localhost
  tasks:
    - name: Ensure the Service mysvc is present
      k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: mysvc
            namespace: myns
          spec:
            selector:
              app: myapp
              service: mysvc
            ports:
              - protocol: TCP
                targetPort: 800
                name: port-80-tcp
                port: 80
```
- Ansible allows you to manage your Kubernetes clusters with some modules:
    - k8s: Allows you to manage any kind of Kubernetes object
    - k8s_auth: Allows you to authenticate to Kubernetes clusters that require an explicit login step
    - k8s_facts: Allows you to inspect Kubernetes objects
    - k8s_scale: Allows you to set a new size for a Deployment, ReplicaSet, Replication Controller, or Job
    - k8s_service: Allows you to manage Services on Kubernetes

## Automating Docker with Ansible
- With Ansible, you can easily manage your Docker instance in Development environments.
- First of all, we need to create a playbook called start-docker-container.yaml that will contain the following code
```YAML
- hosts: localhost
  tasks:
    - name: Start a container with a command
      docker_container:
        name: test-container
        image: alpine
        command:
          - echo
          - "Hello, World!"
```
- Other modules include the following:
    - docker_config: Used to change the configurations of the Docker daemon
    - docker_container_info: Used to gather information from (inspect) a container
    - docker_network: Used to manage Docker networking configuration
# Automating against Amazon Web Services
To be able to use Ansible to automate your Amazon Web Service estate, you'll need to install the boto library.
```BASH
pip install boto
```
## Authentication
- The boto library looks up the necessary credentials in the `~/.aws/credentials` file. 
- There are two different ways to ensure that the credentials file is configured properly.
    - It is possible to use the AWS CLI tool. 
    - Alternatively, this can be done with a text editor of your choice by creating a file with the following structure
    ```BASH
    [default]
    aws_access_key_id = [YOUR_KEY_HERE]
    aws_secret_access_key = [YOUR_SECRET_ACCESS_KEY_HERE]
    ```
- Now that you've created the file with the necessary credentials, boto will be able to work against your AWS environment.
- Since Ansible uses boto for every single communication with AWS systems, this means that Ansible will be appropriately configured, even without you have to change any Ansible-specific configuration.
## Creating your first machine
- To launch a virtual machine in AWS, we need a few things to be in place, as follows:
    - An SSH key pair
    - A network
    - A subnetwork
    - A security group
- By default, a network and a subnetwork are already available in your accounts, but you need to retrieve their IDs.
- Create the aws.yaml Playbook with the following content
```YAML
- hosts: localhost
  tasks:
    - name: Ensure key pair is present
      ec2_key:
        name: fale
        key_material: "{{ lookup('file', '~/.ssh/fale.pub') }}"
    - name: Gather information of the EC2 VPC net in eu-west-1
      ec2_vpc_net_facts:
        region: eu-west-1
      register: aws_simple_net
    - name: Gather information of the EC2 VPC subnet in eu-west-1
      ec2_vpc_subnet_facts:
        region: eu-west-1
        filters:
          vpc-id: '{{ aws_simple_net.vpcs.0.id }}'
      register: aws_simple_subnet
    - name: Ensure wssg Security Group is present
      ec2_group:
        name: wssg
        description: Web Security Group
        region: eu-west-1
        vpc_id: '{{ aws_simple_net.vpcs.0.id }}'
        rules:
          - proto: tcp
            from_port: 22
            to_port: 22
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 80
            to_port: 80
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 443
            to_port: 443
            cidr_ip: 0.0.0.0/0
        rules_egress:
          - proto: all
            cidr_ip: 0.0.0.0/0
      register: aws_simple_wssg
    - name: Setup instance
      ec2:
        assign_public_ip: true
        image: ami-3548444c
        region: eu-west-1
        exact_count: 1
        key_name: fale
        count_tag:
          Name: ws01.ansible2cookbook.com
        instance_tags:
          Name: ws01.ansible2cookbook.coms
        instance_type: t2.micro
        group_id: '{{ aws_simple_wssg.group_id }}'
        vpc_subnet_id: '{{ aws_simple_subnet.subnets.0.id }}'
        volumes:
          - device_name: /dev/sda1
            volume_type: gp2
            volume_size: 10
            delete_on_termination: True
```
```BASH
ansible-playbook aws.yaml
```
- We started by uploading the public part of an SSH keypair to AWS, then queried for information about the network and the subnetwork, then ensured that the Security Group we wanted to use was present, and lastly triggered the machine build.
# Automating against Azure
- To let Ansible manage the Azure cloud, you need to install the Azure SDK for Python.
```BASH
 pip install 'ansible[azure]'
 ```
 ## Authentication
- There are different ways to ensure that Ansible is able to manage Azure for you, based on the way your Azure account is set up, but they can all be configured in the `~/.azure/credentials` file.
```BASH
[default]
subscription_id = [YOUR_SUBSCIRPTION_ID_HERE]
client_id = [YOUR_CLIENT_ID_HERE]
secret = [YOUR_SECRET_HERE]
tenant = [YOUR_TENANT_HERE]
```
- If you prefer to use Active Directories with a username and password.
```BASH
[default]
ad_user = [YOUR_AD_USER_HERE]
password = [YOUR_AD_PASSWORD_HERE]
```
- You can opt for an Active Directory login with ADFS.
```BASH
[default]
ad_user = [YOUR_AD_USER_HERE]
password = [YOUR_AD_PASSWORD_HERE]
client_id = [YOUR_CLIENT_ID_HERE]
tenant = [YOUR_TENANT_HERE]
adfs_authority_url = [YOUR_ADFS_AUTHORITY_URL_HERE]
```
## Creating your first machine
- Create the azure.yaml Playbook with the following content.
- In Azure, you will need all the resources to be ready before you can issue the machine creation command. 
- This is the reason you create the Storage Account, the Virtual Network, the Subnet, the Public IP, the security Group, and the NIC first, and only at that point, the machine itself.
```YAML
- hosts: localhost
  tasks:
    - name: Ensure the Storage Account is present
      azure_rm_storageaccount:
        resource_group: Testing
        name: mysa
        account_type: Standard_LRS
    - name: Ensure the Virtual Network is present
      azure_rm_virtualnetwork:
        resource_group: Testing
        name: myvn
        address_prefixes: "10.10.0.0/16"
    - name: Ensure the Subnet is present
      azure_rm_subnet:
        resource_group: Testing
        name: mysn
        address_prefix: "10.10.0.0/24"
        virtual_network: myvn
    - name: Ensure that the Public IP is set
      azure_rm_publicipaddress:
        resource_group: Testing
        allocation_method: Static
        name: myip
    - name: Ensure a Security Group allowing SSH is present
      azure_rm_securitygroup:
        resource_group: Testing
        name: mysg
        rules:
          - name: SSH
            protocol: Tcp
            destination_port_range: 22
            access: Allow
            priority: 101
            direction: Inbound
    - name: Ensure the NIC is present
      azure_rm_networkinterface:
        resource_group: Testing
        name: testnic001
        virtual_network: myvn
        subnet: mysn
        public_ip_name: myip
        security_group: mysg
    - name: Ensure the Virtual Machine is present
      azure_rm_virtualmachine:
        resource_group: Testing
        name: myvm01
        vm_size: Standard_D1
        storage_account: mysa
        storage_container: myvm01
        storage_blob: myvm01.vhd
        admin_username: admin
        admin_password: Password!
        network_interfaces: testnic001
        image:
          offer: CentOS
          publisher: OpenLogic
          sku: '8.0'
          version: latest
```
```BASH
ansible-playbook azure.yaml
```
