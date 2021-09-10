# Introduction
!!! Note "Note"
    **The rule of thumb is if you can script it, you can create a playbook for it.**
- [Ansible 101](https://www.digitalocean.com/community/tutorials/configuration-management-101-writing-ansible-playbooks)
- [Ansible Cheat Sheet](https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide)
- [App Security](https://docs.openstack.org/project-deploy-guide/openstack-ansible/ocata/app-security.html)
- [Ansible Tips and Tricks](https://github.com/nfaction/ansible-tips-and-tricks/wiki)
- [DO Practise examples](https://github.com/do-community/ansible-practice) & [Explaination](https://www.digitalocean.com/community/tutorial_series/how-to-write-ansible-playbooks) & [Tutorials](https://www.digitalocean.com/community/tags/ansible)
- [YAML Spec Ref Card](https://yaml.org/refcard.html)
- [Full Application on Cloud](https://github.com/mmumshad/udemy-ansible-assignment)
- [Maintaining Playbooks - Pitfalls](https://opensource.com/article/20/1/ansible-playbooks-lessons)
# Documentation on cmdline
```BASH
# System outputs the man page for debug module
ansible-doc debug     
ansible-doc -l | grep aws  # List all plugins and then grep for aws plugins
ansible-doc -s shell       # Shows snippets on how to use the plugins
```
# Setup Server
## Default Configuration
- ansible.cfg and hosts files are present inside `/etc/ansible`
- Testing ansible on Ubuntu WSL `ansible localhost -m ping`
## Enabling SSH on the VM
- If you need SSH enabled on the system, follow the below steps:
1. Ensure the `/etc/apt/sources.list` file has been updated as per above
1. Run the command: apt-get update 
1. Run the command: apt-get install openssh-server
1. Run the command: service sshd start

```BASH
ssh-keygen -t rsa -C "ansible"

#OR

# Generate an SSH key pair for future connections to the VM instances (run the command exactly as it is):
ssh-keygen -t rsa  -b 4096 -f ~/.ssh/ansible-user -C ansible-user -P ""
#Add the SSH private key to the ssh-agent:
ssh-add ~/.ssh/ansible-user
#Verify that the key was added to the ssh-agent:
$ ssh-add -l
```
## Access VM over SSH
```BASH
ssh vagrant@127.0.0.1 -p 2222 -i ~/.ssh/insecure_private_key
```
## Copy files recursively from local desktop to remote server
```BASH
scp -r ./scripts vagrant@127.0.0.1:/home/vagrant -p 2222 -i ~/.ssh/insecure_private_key
```
## Target Docker containers for Ansible controller
The [Docker file](https://github.com/mmumshad/ubuntu-ssh-enabled ) used to create the ubuntu-ssh-enabled Docker image is located here.

## Issues installing Ansible and its dependencies
Once the Debian VM is up and running make the following changes to the /etc/apt/sources.list file to get the Ansible installation working right.

```BASH
deb http://security.debian.org/ jessie/updates main contrib
deb-src http://security.debian.org/ jessie/updates main contrib
deb http://ftp.debian.org/debian/ jessie-updates main contrib
deb-src http://ftp.debian.org/debian/ jessie-updates main contrib
deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
deb http://ftp.de.debian.org/debian sid main
```

# Ansible Directory Structure as per Best Practises

- This is the directory layout of this repository with explanation.

```YAML
production.ini            # inventory file for production stage
development.ini           # inventory file for development stage
test.ini                  # inventory file for test stage
vpass                     # ansible-vault password file
                          # This file should not be committed into the repository
                          # therefore file is ignored by git
########################## This segration can be done if there are changes in variable values between environments
├── inventories
│   ├── development
│   │   ├── group_vars
│   │   │   └── app.yml
│   │   ├── hosts
│   │   └── host_vars
│   └── production
│   ├── group_vars
│   │   └── app.yml
│   ├── hosts
│   └── host_vars
##########################
group_vars/
    all/                  # variables under this directory belongs all the groups
        apt.yml           # ansible-apt role variable file for all groups
    webservers/           # here we assign variables to webservers groups
        apt.yml           # Each file will correspond to a role i.e. apt.yml
        nginx.yml         # ""
    postgresql/           # here we assign variables to postgresql groups
        postgresql.yml    # Each file will correspond to a role i.e. postgresql
        postgresql-password.yml   # Encrypted password file
plays/
    ansible.cfg           # Ansible.cfg file that holds all ansible config
    webservers.yml        # playbook for webserver tier
    postgresql.yml        # playbook for postgresql tier

roles/
    roles_requirements.yml# All the information about the roles
    external/             # All the roles that are in git or ansible galaxy
                          # Roles that are in roles_requirements.yml file will be downloaded into this directory
    internal/             # All the roles that are not public
      common/             # common role
        tasks/            #
            main.yml      # installing basic tasks
scripts/
    setup/                 # All the setup files for updating roles and ansible dependencies
```
# Ansible Inventory
## Creating an inventory file and adding hosts
- Ansible supports two types of inventory—static and dynamic
- Static inventories are by their very nature static; they are unchanging unless a human being goes and manually edits them.
- Even in small, closed environments, static inventories are a great way to manage your environment, especially when changes to the infrastructure are infrequent.
```YAML
# Sample inventory file in INI format
target1.example.com ansible_host=192.168.81.142 ansible_port=3333
target2.example.com ansible_port=3333 ansible_user=danieloh
target3.example.com ansible_host=192.168.81.143 ansible_port=5555
```
    - ansible_host: If the inventory hostname cannot be accessed directly—perhaps because it is not in DNS, for example, this variable contains the hostname or IP address that Ansible will connect to instead.
    - ansible_port: By default, Ansible attempts all communication over port 22 for SSH—if you have an SSH daemon running on another port, you can tell Ansible about it using this variable.
    - ansible_user: By default, Ansible will attempt to connect to the remote host using the current user account you are running the Ansible command from—you can override this in several ways, of which this is one.
- Hence, the preceding three hosts can be summarized as follows:
    - The target1.example.com host should be connected to using the 192.168.81.142 IP address, on port 3333.
    - The target2.example.com host should be connected to on port 3333 also, but this time using the danieloh user rather than the account running the Ansible command.
    - The target3.example.com host should be connected to using the 192.168.81.143 IP address, on port 5555.
## Using host groups
- Let's assume you have a simple three-tier web architecture, with multiple hosts in each tier for high availability and/or load balancing. The three tiers in this architecture might be the following:
    - Frontend servers
    - Application servers
    - Database servers
- To keep the examples clear and concise, we'll assume that you can access all servers using their **Fully Qualified Domain Names (FQDNs)**, and hence won't add any host variables into these inventory files. 
```YAML
loadbalancer.example.com

[frontends]
frt01.example.com
frt02.example.com

[apps]
app01.example.com
app02.example.com

[databases]
dbms01.example.com
dbms02.example.com
```
- We have created three groups called frontends, apps, and databases. Note that, in INI-formatted inventories, group names go inside square braces. Under each group name goes the server names that belong in each group, so the preceding example shows two servers in each group. Notice the outlier at the top, loadbalancer.example.com — this host isn't in any group. **All ungrouped hosts must go at the very top of an INI-formatted file.**

- The preceding inventory stands in its own right, but what if our frontend servers are built on Ubuntu, and the app and database servers are built on CentOS? There will be some fundamental differences in the ways we handle these hosts — for example, we might use the apt module to manage packages on Ubuntu and the yum module on CentOS.
```YAML
loadbalancer.example.com

[frontends]
frt01.example.com
frt02.example.com

[apps]
app01.example.com
app02.example.com

[databases]
dbms01.example.com
dbms02.example.com

[centos:children]
apps
databases

[ubuntu:children]
frontends
```
- With the use of the children keyword in the group definition (inside the square braces), we can create groups of groups; hence, we can perform clever groupings to help our playbook design without having to specify each host more than once.
```BASH
ansible -i hostgroups-yml centos -m shell -a 'echo hello-yaml' -f 5
```
- This is a powerful way of managing your inventory and making it easy to run commands on just the hosts you want to. The possibility of creating multiple groups makes life simple and easy, especially when you want to run different tasks on different groups of servers.
-  Let's assume you have 100 app servers, all named sequentially, as follows: app01 to app100
```YAML
[apps]
app[01:100].prod.com
```
- The following inventory snippet actually produces an inventory with the same 100 app servers that we could create manually.
## Adding host and group variables to your inventory
-Suppose that we need to set two variables for each of our two frontend servers. These are not special Ansible variables, but instead are variables entirely of our own choosing.
    - https_port, which defines the port that the frontend proxy should listen on
    - lb_vip, which defines the FQDN of the load-balancer in front of the frontend servers
- You can assign variables to a host group as well as to hosts individually.
```YAML
[frontends]
frt01.example.com
frt02.example.com

[frontends:vars]
https_port=8443
lb_vip=lb.example.com
```
- There will be times when you want to work with host variables for individual hosts, and times when group variables are more relevant.
- It is also worth noting that **host variables override group variables**, so if we need to change the connection port to 8444 on the frt01.example.com one, we could do this as follows
```YAML
[frontends]
frt01.example.com https_port=8444
frt02.example.com

[frontends:vars]
https_port=8443
lb_vip=lb.example.com
```
- Right now, our examples are small and compact and only contain a handful of groups and variables; however, when you scale this up to a full infrastructure of servers, using a single flat inventory file could, once again, become unmanageable. 
- Luckily, Ansible also provides a solution to this. Two specially-named directories, **host_vars and group_vars**, are automatically searched for appropriate variable content if they exist within the playbook directory. 
- Under the host_vars directory, we'll create a file with the name of our host that needs the proxy setting, with .yml appended to it (that is, frt01.example.com.yml). 
```YAML
---
https_port: 8444
```
- Under the group_vars directory, create a YAML file named after the group to which we want to assign variables (that is, frontends.yml) 
```YAML
---
https_port: 8443
lb_vip: lb.example.com
```
- Finally, we will create our inventory file as before, except that it contains no variables.
```YAML
# Final directory structure should look like this
├── group_vars
│   └── frontends.yml
├── host_vars
│   └── frt01.example.com.yml
└── inventory
```
!!! Note "Note"
    If you define the same variable at both a group level and a child group level, the variable at the child group level takes precedence.
- Consider our earlier inventory where we used child groups to differentiate between CentOS and Ubuntu hosts — if we add a variable with the same name to both the ubuntu child group and the frontends group (which is a child of the ubuntu group) as follows, what will the outcome be?
```YAML
loadbalancer.example.com

[frontends]
frt01.example.com
frt02.example.com

[frontends:vars]
testvar=childgroup

[apps]
app01.example.com
app02.example.com

[databases]
dbms01.example.com
dbms02.example.com

[centos:children]
apps
databases

[ubuntu:children]
frontends

[ubuntu:vars]
testvar=group
```
- **Debugging variable at host level**
```BASH
ansible -i hostgroups-children-vars-ini ubuntu -m debug -a "var=testvar"
# Output
frt01.example.com | SUCCESS => {
    "testvar": "childgroup"
}
frt02.example.com | SUCCESS => {
    "testvar": "childgroup"
}
```
- It's important to note that the frontends group is a child of the ubuntu group in this inventory (hence, the group definition is [ubuntu:children]), and so the variable value we set at the frontends group level wins as this is the child group in this scenario.
## Special host management using patterns
- Let's look at how Ansible can work with patterns to figure out which hosts a command (or playbook) should be run against.
```YAML
loadbalancer.example.com

[frontends]
frt01.example.com
frt02.example.com

[apps]
app01.example.com
app02.example.com

[databases]
dbms01.example.com
dbms02.example.com

[centos:children]
apps
databases

[ubuntu:children]
frontends
```
- We shall use the --list-hosts switch with the ansible command to see which hosts Ansible would operate on. 
```BASH
ansible -i hostgroups-children-ini all --list-hosts

# The asterisk character has the same effect as all, but needs to be quoted in single quotes for the shell to interpret the command properly
ansible -i hostgroups-children-ini '*' --list-hosts

# Use : to specify a logical OR, meaning "apply to hosts either in this group or that group," 
ansible -i hostgroups-children-ini frontends:apps --list-hosts

# Use ! to exclude a specific group—you can combine this with other characters such as : to show all hosts except those in the apps group. # Again, ! is a special character in the shell and so you must quote your pattern string in single quotes for it to work.
ansible -i hostgroups-children-ini 'all:!apps' --list-hosts

# Use :& to specify a logical AND between two groups, for example, if we want all hosts that are in the centos group and the apps group .
ansible -i hostgroups-children-ini 'centos:&apps' --list-hosts

# Use * wildcards 
ansible -i hostgroups-children-ini 'db*.example.com' --list-hosts

# Another way you can limit which hosts a command is run on is to use the --limit switch with Ansible. 
ansible-playbook -i hostgroups-children-ini site.yml --limit frontends:apps
```

# WebApp  Installation Instructions for Centos 7
## Install Python Pip and dependencies on Centos 7
```BASH
sudo yum install -y epel-release python python-pip
sudo pip install flask flask-mysql
```
If you come across a certification validation error while running the above command, please use the below command.
```BASH
sudo pip install --trusted-host files.pythonhosted.org --trusted-host pypi.org --trusted-host pypi.python.org flask flask-mysql
```

## Install MySQL Server on Centos 7
```BASH
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum update
sudo yum -y install mysql-server
sudo service mysql start

The complete playbook to get the same workin on CentOS is here:
https://github.com/kodekloudhub/simple_web_application
```
# Setting up Ansible to run on localhost always
- Beneficial when testing roles or playbooks in docker images
- Remember: To set the `hosts` parameter matches in `ansible.cfg`
- This is useful for debugging ansible modules and syntax without having to use VMs or test in dev environments.
## Install ansible

- `pip install ansible`

## Make some relevant config files

- `~/.ansible.cfg`:

```YAML
[defaults]
inventory = ~/.ansible-hosts
```

- `~/.ansible-hosts`:

```YAML
localhost ansible_connection=local
```

## Make a test playbook and run

- `helloworld.yml`:

```YAML
---

- hosts: all
  tasks:
    - shell: echo 'hello world'
```
- run!

```BASH
ansible-playbook helloworld.yml
```
# Executing Ansible Playbook
## Launching Ansible situational commands
```BASH
# To check the inventory file 
ansible-inventory --list -y
# Test Connection 
ansible all -m ping -u root
# Ask for Sudo password
ansible all -m ping --ask-pass
# Using a specific SSH private key and a user
ansible -m ping hosts --private-key=~/.ssh/keys/id_rsa -u centos
# Check the disk usage of all servers 
ansible all -a "df -h" -u root
# Check the time of `uptime` each host in a group **servers** 
ansible servers -a "uptime" -u root
# Specify multiple hosts by separating their names with colons
ansible server1:server2 -m ping -u root
# Get system dat in json format of target
ansible target1 -i myhosts -m setup --private-key=~/.ssh/ansible-user -u root
# Filter json output
ansible target1 -i myhosts -m setup -a "filter=*ipv4*" --private-key=~/.ssh/ansible-user -u root
ansible all -i myhosts -m setup -a "filter=*ipv4*" --private-key=~/.ssh/ansible-user -u root
```
## Launching Ansible Playbook situational commands
```BASH
ansible-playbook -i myhosts site.yml
# Ask for Sudo password
ansible-playbook myplaybook.yml --ask-become-pass
# Or use the -K option
ansible-playbook -i inventory myplaybook.yml -u sammy -K
# Execute a play without making any changes to the remote servers
ansible-playbook myplaybook.yml --list-tasks
# List all hosts that would be affected by a play
ansible-playbook myplaybook.yml --list-hosts
ansible-playbook -i myhosts playbooks/atmo_playbook.yml --user atmouser
# Passing variables which executing playbooks
ansible-playbook playbooks/atmo_playbook.yml -e "ATMOUSERNAME=atmouser"
ansible host01 -i myhosts -m copy -a "src=test.txt dest=/tmp/"
ansible host01 -i myhosts -m file -a "dest=/tmp/test mode=644 state=directory"
ansible host01 -i myhosts -m apt -a "name=sudo state=latest"
ansible host01 -i myhosts -m shell -a "echo $TERM"
ansible host01 -i myhosts -m command -a "mkdir folder1"
# Run playbook on one host
ansible-playbook playbooks/PLAYBOOK_NAME.yml --limit "host1"
# Run playbook on multiple hosts
ansible-playbook playbooks/PLAYBOOK_NAME.yml --limit "host1,host2"
# Flush Ansible memory f pevious runs
ansible-playbook playbooks/PLAYBOOK_NAME.yml --flush-cache
# Dry run mode
ansible-playbook playbooks/PLAYBOOK_NAME.yml --check
# Starts playbook execution from an intermediate task, task name should match
ansible-playbook myplaybook.yml --start-at-task="Set Up Nginx"
# Increasing debug verbosity
ansible-playbook myplaybook.yml -v
ansible-playbook myplaybook.yml -vvvv
```
## Launching Ansible Vault situational commands
```BASH
# Create new encrypted file, enter password
ansible-vault encrypt credentials.yml
# View the contents of encrypted file
ansible-vault view credentials.yml
# Edit the encrypted file
ansible-vault edit credentials.yml
# Permanently decrypt the file
ansible-vault decrypt credentials.yml
# Creating multiple vaults per env like dev, prod  
# create a new vault ID named dev that uses prompt as password source. 
# Prompt will ask you to enter a password, or a valid path to a password file. 
ansible-vault create --vault-id dev@prompt credentials_dev.yml
ansible-vault create --vault-id prod@prompt credentials_prod.yml
# Editing , Decrypting multiple vaults
ansible-vault edit credentials_dev.yml --vault-id dev@prompt
# Using Password file when using 3rd party automation
ansible-vault create --vault-id dev@path/to/passfile credentials_dev.yml
# Running playbooks with encrypted password
ansible-playbook myplaybook.yml --ask-vault-pass
# Passing password file
ansible-playbook myplaybook.yml --vault-password-file my_vault_password.py
# Passing multi env password 
ansible-playbook myplaybook.yml --vault-id dev@prompt
ansible-playbook myplaybook.yml --vault-id dev@vault_password.py --vault-id test@prompt --vault-id ci@prompt
# To change the vault password for key rotation
ansible-vault rekey credentials.yml
```
# Understanding the playbook framework
- A playbook allows you to manage multiple configurations and complex deployments on many machines simply and easily. 
- This is one of the key benefits of using Ansible for the delivery of complex applications. 
- With playbooks, you can organize your tasks in a logical structure as tasks are (generally) executed in the order they are written, allowing you to have a good deal of control over your automation processes. 
```YAML
# Example inventory
[frontends]
frt01.example.com https_port=8443
frt02.example.com http_proxy=proxy.example.com

[frontends:vars]
ntp_server=ntp.frt.example.com
proxy=proxy.frt.example.com

[apps]
app01.example.com
app02.example.com

[webapp:children]
frontends
apps

[webapp:vars]
proxy_server=proxy.webapp.example.com
health_check_retry=3
health_check_interal=60
```
- Create a simple playbook to run on the hosts in the frontends host group defined in our inventory file. We can set the user that will access the hosts using the remote_user directive in the playbook 
```YAML
---
- hosts: frontends
  remote_user: danieloh

  tasks:
  - name: simple connection test
    ping:
    remote_user: danieloh
```
- The ignore_errors directive to this task to ensure that our playbook doesn't fail if the ls command fails (for example, if the directory we're trying to list doesn't exist). 
```YAML
  - name: run a simple command
    shell: /bin/ls -al /nonexistent
    ignore_errors: True
```
## Defining plays and tasks
- So far when we have worked with playbooks, we have been creating one single play per playbook (which logically is the minimum you can do). However, you can have more than one play in a playbook, and a "play" in Ansible terms is simply a set of tasks (and roles, handlers, and other Ansible facets) associated with a host (or group of hosts). 
- A task is the smallest possible element of a play and is responsible for running a single module with a set of arguments to achieve a specific goal.
## Understanding roles
- Roles are designed to enable you to efficiently and effectively reuse Ansible code. 
- They always follow a known structure and often will include sensible default values for variables, error handling, handlers, and so on.  
- The process of creating roles is in fact very simple—Ansible will (by default) look within the same directory as you are running your playbook from for a roles/ directory.
- The role name is derived from the subdirectory name—there is no need to create complex metadata or anything else—it really is that simple. 
- Within each subdirectory goes a fixed directory structure that tells Ansible what the tasks, default variables, handlers, and so on are for each role.
- The roles/ directory is not the only play Ansible will look for roles—this is the first directory it will look in, but it will then look in /etc/ansible/roles for any additional roles. 
### Setting up role-based variables and dependencies
- The Ansible role directory structure allows for role-specific variables to be declared in two locations. Although, at first, the difference between these two locations may not seem obvious, it is of fundamental importance.
- Roles based variables can go in one of two locations:
    - defaults/main.yml
    - vars/main.yml
- Variables that go in the defaults/ directory are one of the lowest in terms of precedence and so are easily overwritten. This location is where you would put variables that you want to override easily, but where you don't want to leave a variable undefined. For example, if you are installing Apache Tomcat, you might build a role to install a specific version. However, you don't want the role to exit with an error if someone forgets to set the version—rather, you would prefer to set a sensible default such as 7.0.76, which can then be overridden with inventory variables or on the command line (using the -e or --extra-vars switches). In this way, you know the role will work even without someone explicitly setting this variable, but it can easily be changed to a newer Tomcat version if desired.
- Variables that go in the vars/ directory, however, come much higher up on Ansible's variable precedence ordering. This will not be overridden by inventory variables, and so should be used for variable data that it is more important to keep static. Of course, this is not to say they can't be overridden—the -e or --extra-vars switches are the highest order of precedence in Ansible and so will override anything else that you define. 
- Most of the time, you will probably make use of the defaults/ based variables alone, but there will doubtless be times when having the option of variables higher up the precedence ordering becomes valuable to your automation, and so it is vital to know that this option is available to you. 
!!! Note "Note"
    I recommend that you make extensive use of the debug statement and test your playbook design to make sure that you don't fall foul of this during your playbook development.

# Ansible Playbook Examples
- Install Software only if it doesn't exist
```YAML
  - name: installing python2 minimal
    raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)
```
- Install latest software version
```YAML
- hosts: host01
---
    become: true
    tasks:
      - name: ensure latest sysstat is installed
        apt:
          name: sysstat
          state: latest
```
- Install software on all hosts 
```YAML
---
- name: install apache
  hosts: all
  sudo: yes
  tasks:
    - name: install apache2
      apt:
        name: apache2
        update_cache: yes
        state: latest
```
- Copy file only when it does not exists
```YAML
---
- hosts: host01
  tasks:
  - stat:
      path: /home/ubuntu/folder1/something.j2
    register: st

  - name: Template to copy file
    template:
      src: ./something.j2
      dest: /home/ubuntu/folder1/something.j2
      mode: '0644'
    when: st.stat.exists == False
```
- Add users using Loops
```YAML
# Looping
- name: add several users
  user:
    name: "{{ item }}"
    state: present
    groups: "developer"
  with_items:
    - raj
    - david
    - john
    - lauren
```
- Using Looping with debug
```YAML
# show all the hosts in the inventory
- debug:
    msg: "{{ item }}"
  with_items:
    - "{{ groups['all'] }}"
# show all the hosts in the current play
- debug:
    msg: "{{ item }}"
  with_items:
    - "{{ play_hosts }}"
```
- Conditionals
```YAML
# This Playbook will add Java Packages to different systems (handling Ubuntu/Debian OS)
- name: debian | ubuntu | add java ppa repo
  apt_repository:
    repo=ppa:webupd8team/java
    state=present
  become: yes
  when: ansible_distribution == 'Ubuntu'
- name: debian | ensure the webupd8 launchpad apt repository is present
    apt_repository:
      repo="{{ item }} http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main"
      update_cache=yes
      state=present
    with_items:
      - deb
      - deb-src
    become: yes
  when: ansible_distribution == 'Debian'
```
- Full Play
```YAML
---
- name: install software
  hosts: host01
  sudo: yes
  tasks:
    - name: Update and upgrade apt packages
      apt:
        upgrade: dist
        update_cache: yes
        cache_valid_time: 86400
    - name: install software
      apt:
        name: "{{item}}"
        update_cache: yes
        state: installed
      with_items:
        - nginx
        - postgresql
        - postgresql-contrib
        - libpq-dev
        - python-psycopg2
    - name: Ensure the Nginx service is running
      service:
        name: nginx
        state: started
        enabled: yes
    - name: Ensure the PostgreSQL service is running
      service:
        name: postgresql
        state: started
        enabled: yes

#file: vars.yml
---
var: 20

#file: playbook.yml
---
- hosts: all
  vars_files:
    - vars.yml
  tasks:
    - debug: msg="Variable 'var' is set to {{ var }}"

#host variables - Variables are defined inline for individual host
  [group1]
  host1 http_port=80
  host2 http_port=303
#group variables - Variables are applied to entire group of hosts
  [group1:vars]
  ntp_server= example.com
  proxy=proxy.example.com
```
- Full Play - Deploying an Nginx static site on Ubuntu
```YAML
# playbook.yml
---
- hosts: all
  become: yes
  vars:
    server_name: "{{ ansible_default_ipv4.address }}"
    document_root: /var/www
    app_root: html_demo_site-main
  tasks:
    - name: Update apt cache and install Nginx
      apt:
        name: nginx
        state: latest
        update_cache: yes

    - name: Copy website files to the server's document root
      copy:
        src: "{{ app_root }}"
        dest: "{{ document_root }}"
        mode: preserve

    - name: Apply Nginx template
      template:
        src: files/nginx.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: Restart Nginx

    - name: Enable new site
      file:
        src: /etc/nginx/sites-available/default
        dest: /etc/nginx/sites-enabled/default
        state: link
      notify: Restart Nginx

    - name: Allow all access to tcp port 80
      ufw:
        rule: allow
        port: '80'
        proto: tcp

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted

# Copy the static files and unzip to folder root
curl -L https://github.com/do-community/html_demo_site/archive/refs/heads/main.zip -o html_demo.zip
# files/nginx.conf.j2
server {
  listen 80;

  root {{ document_root }}/{{ app_root }};
  index index.html index.htm;

  server_name {{ server_name }};

  location / {
   default_type "text/html";
   try_files $uri.html $uri $uri/ =404;
  }
}

# Executing the playbook with sammy user and prompting for password
ansible-playbook -i inventory playbook.yml -u sammy -K

```

## Using ansible system variables in Jinja2 Templates

- Whenever you run Playbook, Ansible by default collects information (facts) about each host
- like host IP address, CPU type, disk space, operating system information etc.
```BASH
ansible host01 -i myhosts -m setup
```
- Create Dynamic templates 
- Consider you need the IP address of all the servers in you web group using 'group' variable
```BASH
  {% for host in groups.web %}

  server {{ host.inventory_hostname }} {{ host.ansible_default_ipv4.address }}:8080

  {% endfor %}
```
- Create a Webservice entry in Nginx
```BASH
  {% for host in groups.['jenkins'] %}
  
  define host {
    use         linux-server
    host_name   {{ host }}
    alias       {{ host }}
    address     {{ hostvars[host].ansible_default_ipv4.address }}
    hostgroups  jenkins
  }
  
  {% endfor %}
  # service checks to be applied to the webserver
  {% if jenkins_uses_proxy == true %}
  
  define service {
    use                     local-service
    hostgroup_name          jenkins
    service_description     HTTP
    check_command           check_jenkins_http
    notifications_enabled   1
  }

  {% endif %}
```
- Get a list of all the variables associated with the current host with the help of hostvars and inventory_hostname variables.
```YAML
---
- name: built-in variables
  hosts: all
  tasks:
    - debug: var=hostvars[inventory_hostname]
```
- Using register variables
```YAML
# register variable stores the output, after executing command module, in contents variable
# stdout is used to access string content of register variable
---
- name: check registered variable for emptiness
  hosts: all
  tasks:
    - name: list contents of the directory in the host
      command: ls /home/ubuntu
      register: contents
    - name: check dir is empty
      debug: msg="Directory is empty"
      when: contents.stdout == ""
    - name: check dir has contents
      debug: msg="Directory is not empty"
      when: contents.stdout != ""
```
- Variable Precedence => Command Line > Playbook > Facts > Roles
- CLI: While running the playbook in Command Line redefine the variable
```BASH
# Passing runtime values in plays
ansible-playbook -i myhosts test.yml --extra-vars "ansible_bios_version=Ansible"
```
## Async
- async - How long to run the task
- poll - How frequently to check the task status. Default is 10 seconds
- async_status - Check status of an async task

```YAML
-
  name: Deploy a mysql DB
  hosts: db_server
  roles:
    - python
    - mysql_db

-
  name: Deploy a Web Server
  hosts: web_server
  roles:
    - python
    - flask_web

# Below task will run the async in parallel as poll is 0 and register the output 
-
  name: Monitor Web Application for 6 Minutes
  hosts: web_server
  command: /opt/monitor_webapp.py
  async: 360
  poll: 0
  register: webapp_result
  
-
  name: Monitor Database for 6 Minutes
  hosts: db_server
  command: /opt/monitor_database.py
  async: 360
  poll: 0
  register: database_result
# To avoid job from completing, async_status can be used to poll all async jobs have completed
- 
  name: Check status of async task
  async_status: jid={{ webapp_result.ansible_job_id }}
  register: job_result
  until: job_result.finished
  retries: 30
```
## Deployment Strategy and Forks
- Serial - Default: All tasks are run after the previous once completes
- Free: Once the task completes in a host, it continues next execution without waiting for other hosts
- Batch: Based on serial, but takes action on multiple host (Rolling Updates)
- Forks: Deployment on multiple servers

```YAML
# Runs playbook on 2 servers at a time
-
  name: Deploy a web application
  hosts: app_servers
  serial: 2
  vars:
    db_name: employee_db
    db_user: db_user
    db_password: Passw0rd
  tasks:
    - name: Install dependencies

    - name: Install MySQL database

    - name: Start Mysql Service

    - name: Create Application Database

    - name: Create Application DB User

    - name: Install Python Flask dependencies

    - name: Copy web-server code

    - name: Start web-application
```
```YAML
# Deploy based on random rolling strategy
  name: Deploy a web application
  hosts: app_servers
  serial:
    - 2
    - 3
    - 5
```
```YAML
# Deploy based on percentage
  name: Deploy a web application
  hosts: app_servers
  serial: "20%"
```
```YAML
# Runs playbook to fail early, suppose there are 10 servers
-
  name: Deploy a web application
  hosts: app_servers
  serial: 5
  max_fail_percentage: 50
# The number of failed hosts must exceed the value of max_fail_percentage; if it is equal, the play continues. 
# So, in our example, if exactly 50% of our hosts failed, the play would still continue. 

# The first task has a special clause under it that we use to deliberately simulate a failure—this line starts with failed_when and we use it to tell the task that if it runs this task on the first tow hosts in the batch, then it should deliberately fail this task regardless of the result; otherwise, it should allow the task to run as normal.
  tasks:
    - name: A task that will sometimes fail
      debug:
        msg: This might fail
      failed_when: inventory_hostname in ansible_play_batch[0:3]
# We'll add a second task that will always succeed. 
    - name: A task that will succeed
      debug:
        msg: Success!
```
- We have also deliberately set up a failure condition that causes three of the hosts in the first batch of 5 (60%) to fail. 
```BASH
ansible-playbook -i morehosts maxfail.yml
```
- We deliberately failed three of the first batch of 5, exceeding the threshold for max_fail_percentage that we set. 
- This immediately causes the play to abort and the second task is not performed on the first batch of 5. 
- You will also notice that the second batch of 5, out of the 10 hosts, is never processed, so our play was truly aborted. 
- This is exactly the behavior you would want to see to prevent a failed update from rolling out across a cluster. 
- Through the careful use of batches and max_fail_percentage, you can safely run automated tasks across an entire cluster without the fear of breaking the entire cluster in the event of an issue. 
```YAML
# Deploy based on completion
  name: Deploy a web application
  hosts: app_servers
  strategy: free
```

## Error Handling
- [Playbook Error Handling](https://docs.ansible.com/ansible/latest/user_guide/playbooks_error_handling.html)
- We would like Ansible to stop execution of the entire playbook if a single server was to fail. 
```YAML
# To fail playbook on any failure and stop processing on all servers
  name: Deploy a web application
  hosts: app_servers
  any_errors_fatal: true  # This will stop all processing
```
```YAML
# To avoid failure of playbook due to an insignificant task
  name: Deploy a web application
  hosts: app_servers
  tasks:
    - mail:
        to: devops@abc.com
        subject: Server Deployed!
        body: Webserver is live!
      ignore_errors: yes    # Add this to ignore task failure
    
    - command: cat /var/log/server.log
      register: command_output
      failed_when: "'ERROR' in command_output.stdout"   # Conditional failure of task
```
## Jinja2 Templating
- Templating: A process a generating dynamic content or expressions
- String Manipulation - [Filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#filters-for-formatting-data)
```YAML
# Substitution
The name is {{ my_name }}
# Uppercase
The name is {{ my_name | upper }}
# Lowercase
The name is {{ my_name | lower }}
# Titlecase
The name is {{ my_name | title }}
# Replace
The name is {{ my_name | replace("Bond", "Bourne") }}
# Default value
The name is {{ first_name | default("James") }} {{ my_name }}
```
- Filters - List and Set 
```YAML
# Min
{{ [1,2,3] | min }}     => 1
# Max
{{ [1,2,3] | min }}     => 3
# Unique
{{ [1,2,3,2] | unique }}     => 1,2,3
# Union
{{ [1,2,3,4] | union([4,5]) }}     => 1,2,3,4,5
# Intersect
{{ [1,2,3,4] | intersect([4,5]) }}     => 4
{{ 100 | random }}       => generates random number between 1 to 100
# Join
{{ ["The","name","is","Bond"] | join(" ")}} => The name is Bond
```
- Filters - File
```YAML
{{ "/etc/hosts" | basename }}       => hosts
```
- Filters - expanduser
```YAML
tasks:
  - name: Ensure the SSH key is present on OpenStack
    os_keypair:
      state: present
      name: ansible_key
      public_key_file: "{{ '~' | expanduser }}/.ssh/id_rsa.pub"
```
## Lookups
- [Lookups](https://docs.ansible.com/ansible/latest/user_guide/playbooks_lookups.html): To get data from another source on the system
```BASH
# Credentials File csv
Hostname,Password
web_server,Passw0rd
db_server,Passw0rd
```
```YAML
# Format - Type of file, Value to Lookup, File to Lookup, Delimiter
vars:
  ansible_ssh_pass: "{{ lookup('csvfile', 'web_server file=/tmp/credentials.csv delimiter=,') }}"    => Passw0rd
```
```BASH
# Credentials File ini

[web_server]
password=Passw0rd

[db_server]
password=Passw0rd
```
```YAML
# Format - Type of file, Value to Lookup, File to Lookup, Delimiter
vars:
  ansible_ssh_pass: "{{ lookup('ini', 'password section=web_server  file=/tmp/credentials.ini') }}"    => Passw0rd
```
## Tags
* Tags are names pinned on individual tasks, roles or an entire play, that allows you to run or skip parts of your Playbook.
* Tags can help you while testing certain parts of your Playbook.
```YAML
# tag.yml
---
- name: Play1-install apache
  hosts: all
  sudo: yes
  tasks:
    - name: install apache2
      apt: name=apache2 update_cache=yes state=latest
    - name: displaying "hello world"
      debug: msg="hello world"
      tags:
        - tag1
- name: Play2-install nginx
  hosts: all
  sudo: yes
  tags:
    - tag2
  tasks:
    - name: install nginx
      apt: name=nginx update_cache=yes state=latest
    - name: debug module displays message in control machine
      debug: msg="have a good day"
      tags:
        - mymessage
    - name: shell module displays message in host machine.
      shell: echo "yet another task"
      tags:
        - mymessage
```
- Executing above play using tags
```BASH
# displays the list of tasks in the Playbook
ansible-playbook -i myhosts tag.yml --list-tasks 
# displays only tags in your Playbook
ansible-playbook -i myhosts tag.yml --list-tags 
# executes only certain tasks which are tagged as tag1 and mymessage
ansible-playbook -i myhosts tag.yml --tags "tag1,mymessage" 
```
## Includes (Outdated after 2.0)
- Ansible gives you the flexibility of organizing your tasks through include keyword, that introduces more abstraction and make your Playbook more easily maintainable, reusable and powerful.
```YAML
---
- name: testing includes
  hosts: all
  sudo: yes
  tasks:
    - include: apache.yml
    - include: content.yml
    - include: create_folder.yml
    - include: content.yml
- include: nginx.yml  
#  apache.yml will not have hosts & tasks but nginx.yml as a separate play will have tasks and can run independently

#nginx.yml
---
- name: installing nginx
  hosts: all
  sudo: yes
  tasks:
    - name: install nginx
      apt: name=nginx update_cache=yes state=latest
    - name: displaying message
      debug: msg="yayy!! nginx installed"
```
## Roles
- A Role is completely self contained or encapsulated and completely reusable
```YAML
# cat ansible.cfg
  [defaults]
  host_key_checking=False
  inventory = /etc/ansible/myhosts
  log_path = /home/scrapbook/tutorial/output.txt
  roles_path = /home/scrapbook/tutorial/roles/
# master-playbook.yml
---
- name: my first role in ansible
  hosts: all
  sudo: yes
  roles:
    - sample_role
    - sample_role2
# sample_role/tasks/main.yml
---
- include: nginx.yml
- include: copy-template.yml
- include: copy-static.yml
# sample_role/tasks/nginx.yml
---
- name: Installs nginx
  apt: pkg=nginx state=installed update_cache=true
  notify:
    - start nginx
# sample_role/handlers/main.yml
---
- name: start nginx
  service: name=nginx state=started
# sample_role/tasks/copy-template.yml
---
- name: sample template - x
  template:
    src: template-file.j2
    dest: /home/ubuntu/copy-template-file.j2
  with_items: var_x
# sample_role/vars/main.yml
var_x:
  - 'variable x'
var_y:
  - 'variable y'
# sample_role/tasks/copy-static.yml # Ensure some-file.txt is present under files folder of the role
---
- name: Copy a file
  copy: src=some-file.txt dest=/home/ubuntu/file1.txt
```
- Executing the play
```BASH
# Let us run the master_playbook and check the output:
ansible-playbook -i myhosts master_playbook.yml
```
## Ansible Galaxy
- ansible-galaxy is command line tool for scaffolding the creation of directory structure needed for organizing your code
ansible-galaxy init sample_role
## ansible-galaxy useful commands
- Install a Role from Ansible Galaxy
- To use others role, visit https://galaxy.ansible.com/ and search for the role that will achieve your goal.
- Goal: Install Apache in the host machines.

```BASH
# Ensure that roles_path are defined in ansible.cfg for a role to successfully install.
# Here, apache is role name and geerlingguy is name of the user in GitHub who created the role.
ansible-galaxy install geerlingguy.apache
# Forcefully Recreate Role
ansible-galaxy init geerlingguy.apache --force
# Listing Installed Roles
ansible-galaxy list
# Remove an Installed Role
ansible-galaxy remove geerlingguy.apache
```
## Environment Variables
- Ansible recommends maintaining inventory file for each environment, instead of keeping all your hosts in a single inventory.
- Each environment directory has one inventory file (hosts) and group_vars directory.

# Ansible Best Practises
## Inventory Files
-  To show you a great way of setting up your directory structure for a simple role-based playbook that has two different inventories — one for a development environment and one for a production environment.
```YAML
# inventories/development/hosts
[app]
app01.dev.example.com
app02.dev.example.com
# inventories/development/group_vars
---
http_port: 8080

# inventories/production/hosts
[app]
app01.prod.example.com
app02.prod.example.com
# inventories/production/group_vars
---
http_port: 80
```
```BASH
# To run it on the development inventory
ansible-playbook -i inventories/development/hosts site.yml
# To run it on the production inventory 
ansible-playbook -i inventories/production/hosts site.yml
```
- However, there are always differences between the two environments, not just in the hostnames, but also sometimes in the parameters, the load balancer names, the port numbers, and so on—the list can seem endless.
- Try and reuse the same playbooks for all of your environments that run the same code. For example, if you deploy a web app in your development environment, you should be confident that your playbooks will deploy the same app in the production environment
- This means that not only are you testing your application deployments and code, you are also testing your Ansible playbooks and roles as part of your overall testing process.
- Your inventories for each environment should be kept in separate directory trees, but all roles, playbooks, plugins, and modules (if used) should be in the same directory structure (this should be the case for both environments).
- It is normal for different environments to require different authentication credentials; you should keep these separate not only for security but also to ensure that playbooks are not accidentally run in the wrong environment.
- Your playbooks should be in your version control system, just as your code is. This enables you to track changes over time and ensure that everyone is working from the same copy of the automation code.
## The proper approach to defining group and host variables
- First and foremost, you should always pay attention to variable precedence. 
- Host variables are always of a higher order of precedence than group variables; so, you can override any group variable with a host variable. This behavior is useful if you take advantage of it in a controlled manner, but can yield unexpected results if you are not aware of it.
- There is a special group variables definition called all, which is applied to all inventory groups. This has a lower order of precedence than specifically defined group variables.
- What happens if you define the same variable twice in two groups? If this happens, both groups have the same order of precedence, so which one wins? 
```YAML
[app]
app01.dev.example.com
app02.dev.example.com
# inventories/development/group_vars/all.yml 
---
http_port: 8080
# inventories/development/group_vars/app.yml
---
http_port: 8081
# site.yml
---
- name: Play using best practise directory structure
  hosts: all

  tasks:
    - name: Display the value of our inventory variable
      debug:
        var: http_port
```
```BASH
ansible-playbook -i inventories/development/hosts site.yml
```
- As expected, the variable definition in the specific group won, which is in line with the order of precedence documented for Ansible. 
- Now, let's see what happens if we define the same variable twice in two specifically named groups. To complete this example, we'll create a child group, called centos, and another group that could notionally contain hosts built to a new build standard, called newcentos, which both application servers will be a member of. 
```YAML
[app]
app01.dev.example.com
app02.dev.example.com
[centos:children]
app
[newcentos:children]
app
# inventories/development/group_vars/centos.yml
---
http_port: 8082
# inventories/development/group_vars/newcentos.yml
---
http_port: 8083
```
- We've now defined the same variable four times at the group level! 
```BASH
ansible-playbook -i inventories/development/hosts site.yml
```
- The value we entered in newcentos.yml won—but why? The Ansible documentation states that where identical variables are defined at the group level in the inventory (the one place you can do this), the one from the last-loaded group wins. Groups are processed in alphabetical order and newcentos is the group with the name beginning furthest down the alphabet—so, its value of http_port was the value that won.
- Just for completeness, we can override all of this by leaving the group_vars directory untouched, but adding a file called inventories/development/host_vars/app01.dev.example.com.yml
```YAML
---
http_port: 9090
```
- We will see that the value we defined at the host level completely overrides any value that we set at the group level for app01.dev.example.com. app02.dev.example.com is unaffected as we did not define a host variable for it, so the next highest level of precedence—the group variable from the newcentos group—won
## Using top-level playbooks
- Imagine handing a playbook directory structure with 100 different playbooks to a new system administrator—how would they know which ones to run and in which circumstances? The task of training someone to use the playbooks would be immense and would simply move complexity from one area to another.
- The most important thing is that, on receipt of a new playbook directory structure, a new operator at least knows what the starting point for both running the playbooks, and understanding the code is. 
- If the top-level playbook they encounter is always site.yml, then at least everyone knows where to start. 
- Through the clever use of roles and the import_* and include_* statements, you can split your playbook up into logical portions of reusable code, all from one playbook file. 
## Leveraging version control tools
- Any changes to your Ansible code could mean big changes to your environment, and possibly even whether an important production service works or not. 
- As a result, it is vital that you maintain a version history of your Ansible code and that everyone works from the same version. 
## Setting OS and distribution variances
- This playbook demonstrates how you can group differing plays using an Ansible fact so that the OS distribution determines which play in a playbook gets run.
```YAML
# osvariants.yml - It will also contain a single task.
---
- name: Play to demonstrate group_by module
  hosts: all

  tasks:
    - name: Create inventory groups based on host facts
      group_by:
        key: os_{{ ansible_facts['distribution'] }}
```
- **group_by** module: It dynamically creates new inventory groups based on the key that we specify — in this example, we are creating groups based on a key comprised of the os_ fixed string, followed by the OS distribution fact obtained from the Gathering Facts stage. 
- The original inventory group structure is preserved and unmodified, but all the hosts are also added to the newly created groups according to their facts.
- So, the two servers in our simple inventory remain in the app group, but if they are based on Ubuntu, they will be added to a newly created inventory group called os_Ubuntu. Similarly, if they are based on CentOS, they will be added to a group called os_CentOS.
```YAML
# Play definition to the same playbook file to install Apache on CentOS
- name: Play to install Apache on CentOS
  hosts: os_CentOS    # Refer to the Dynamic group
  become: true

  tasks:
    - name: Install Apache on CentOS
      yum:
        name: httpd
        state: present
# Add a third Play definition, this time for installing the apache2 package on Ubuntu using the apt module
- name: Play to install Apache on Ubuntu
  hosts: os_Ubuntu
  become: true

  tasks:
    - name: Install Apache on Ubuntu
      apt:
        name: apache2
        state: present
```
```BASH
ansible-playbook -i hosts osvariants.yml
```
- Notice how the task to install Apache on CentOS was run. It was run this way because the group_by module created a group called os_CentOS and our second play only runs on hosts in the group called os_CentOS. As there were no servers running on Ubuntu in the inventory, the os_Ubuntu group was never created and so the third play does not run. We receive a warning about the fact that there is no host pattern that matches os_Ubuntu, but the playbook does not fail—it simply skips this play.
- It is up to you to choose the coding style most appropriate to you. You can make use of the group_by module, as detailed here, or write your tasks in blocks and add a when clause to the blocks so that they only run when a certain fact-based condition is met (for example, the OS distribution is CentOS)—or perhaps even a combination of the two. The choice is ultimately yours and these different examples are provided to empower you with multiple options that you can choose between to create the best possible solution for your scenario. 
## Setting task execution delegation
- We have assumed that all the tasks are executed on each host in the inventory in turn. 
- However, what if you need to run one or two tasks on a different host? 
- For example, we have talked about the concept of automating upgrades on clusters. 
- Logically, however, we would want to automate the entire process, including the removal of each host in turn from the load balancer and its return after the task is completed. 
- Although we still want to run our play across our entire inventory, we certainly don't want to run the load balancer commands from those hosts. 
- Imagine that you have a shell script (or other executables) that you can call that can add and remove hosts to and from a load balancer.
```BASH
# remove_from_loadbalancer.sh
#!/bin/sh
echo Removing $1 from load balancer...

# add_to_loadbalancer.sh
#!/bin/sh
echo Adding $1 to load balancer...
```
```YAML
[frontends]
frt01.example.com
frt02.example.com
```
```YAML
---
- name: Play to demonstrate task delegation
  hosts: frontends

  tasks:
    - name: Remove host from the load balancer
      command: ./remove_from_loadbalancer.sh {{ inventory_hostname }}
      args:
        chdir: "{{ playbook_dir }}"
      delegate_to: localhost
    - name: Deploy code to host
      debug:
        msg: Deployment code would go here....
    - name: Add host back to the load balancer
      command: ./add_to_loadbalancer.sh {{ inventory_hostname }}
      args:
        chdir: "{{ playbook_dir }}"
      delegate_to: localhost
```
- We are using the command module to call the script we created earlier, passing the hostname from the inventory being removed from the load balancer to the script. 
- We use the chdir argument with the **playbook_dir** magic variable to tell Ansible that the script is to be run from the same directory as the playbook.
- **The special part of this task is the delegate_to directive, which tells Ansible that even though we're iterating through an inventory that doesn't contain localhost, we should run this action on localhost (we aren't copying the script to our remote hosts, so it won't run if we attempt to run it from there).**
- Deploy task has no delegate_to directive, and so it is actually run on the remote host from the inventory (as desired):
- Finally, we add the host back to the load balancer using the second script we created earlier. This task is almost identical to the first.
```BASH
ansible-playbook -i hosts delegate.yml
```
- Notice how even though Ansible is working through the inventory (which doesn't feature localhost), the load balancer-related scripts are actually run from localhost, while the upgrade task is performed directly on the remote host. 
- In truth, you can delegate any task to localhost, or even another non-inventory host. You could, for example, run an **rsync command** delegated to localhost to copy files to remote hosts using a similar task definition to the previous one. This is useful because although Ansible has a copy module, it can't perform the advanced recursive copy and update functions that rsync is capable of.

- Note that you can choose to use a form of shorthand notation in your playbooks (and roles) for delegate_to, called **local_action**. This allows you to specify a task on a single line that would ordinarily be run with **delegate_to:** localhost added below it. 
```YAML
---
- name: Second task delegation example
  hosts: frontends

  tasks:
  - name: Perform an rsync from localhost to inventory hosts
    local_action: command rsync -a /tmp/ {{ inventory_hostname }}:/tmp/target/
```
- The preceding shorthand notation is equivalent to the following:
```YAML
tasks:
  - name: Perform an rsync from localhost to inventory hosts
    command: rsync -a /tmp/ {{ inventory_hostname }}:/tmp/target/
    delegate_to: localhost
```
- If we run this playbook, we can see that local_action does indeed run rsync from localhost, enabling us to efficiently copy whole directory trees across to remote servers in the inventory.
```BASH
ansible-playbook -i hosts delegate2.yml
```
## Using the run_once option
- When working with clusters, you will sometimes encounter a task that should only be executed once for the entire cluster. 
- For example, you might want to upgrade the schema of a clustered database.
- Instead, you can write your code as you normally would, but make use of the special run_once directive for any tasks you want to run only once on your inventory. For example, let's reuse the 10-host inventory.
```YAML
---
- name: Play to demonstrate the run_once directive
  hosts: frontends

  tasks:
    - name: Upgrade database schema
      debug:
        msg: Upgrading database schema...
      run_once: true
```
```BASH
ansible-playbook -i morehosts runonce.yml
```
- Notice that, just as desired, although the playbook was run on all 10 hosts (and, indeed, gathered facts from all 10 hosts), we only ran the upgrade task on one host. 
- **It's important to note that the run_once option applies per batch of servers, so if we add serial: 5 to our play definition (running our play in two batches of 5 on our inventory of 10 servers), the schema upgrade task actually runs twice! It runs once as requested, but once per batch of servers, not once for the entire inventory. Be careful of this nuance when working with this directive in a clustered environment.**

## Running playbooks locally
- It is important to note that when we talk about running a playbook locally with Ansible, it is not the same as talking about running it on localhost. 
- If we run a playbook on localhost, Ansible actually sets up an SSH connection to localhost (it doesn't differentiate its behavior or attempt to detect whether a host in the inventory is local or remote - it simply tries faithfully to connect).
```YAML
# Inventory file
[local]
localhost ansible_connection=local
```
- We've added a special variable to our localhost entry `ansible_connection` variable which defines which protocol is used to connect to this inventory host. So, we have told it to use a direct local connection instead of an SSH-based connectivity (which is the default).
- Note that this special value for the ansible_connection variable actually overrides the hostname you have put in your inventory. So, if we change our inventory to look as follows, Ansible will not even attempt to connect to the remote host called frt01.example.com it will connect locally to the machine running the playbook (without SSH).
```YAML
[local]
frt01.example.com ansible_connection=local
```
- The presence of ansible_connection=local meant that this command was run on the local machine without using SSH.
- This ability to run commands locally without the need to set up SSH connectivity, SSH keys, and so on can be incredibly valuable, especially if you need to get things up and running quickly on your local machine. 
## Working with proxies and jump hosts
- Often, when it comes to configuring core network devices, these are isolated from the main network via a proxy or jump host. 
- Ansible lends itself well to automating network device configuration as most of it is performed over SSH: however, this is only helpful in a scenario where Ansible can either be installed and operated from the jump host or, better yet, can operate via a host such as this.
-  Let's assume that you have two Cumulus Networks switches in your network (these are based on a special distribution of Linux for switching hardware, which is very similar to Debian). These two switches have the cmls01.example.com and cmls02.example.com hostnames, but both can only be accessed from a host called bastion.example.com.
```YAML
[switches]
cmls01.example.com
cmls02.example.com
[switches:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q bastion.example.com"'
```
- This special variable content **ansible_ssh_common_args** tells Ansible to add extra options when it sets up an SSH connection, including to proxy via the bastion.example.com host. The -W %h:%p options tell SSH to proxy the connection and to connect to the host specified by %h (this is either cmls01.example.com or cmls02.example.com) on the port specified by %p (usually port 22).
```BASH
ansible -i switches -m ping all
```
- On the surface, Ansible works just as it normally does and connects successfully to the two hosts. 
- However, behind the scenes it proxies via bastion.example.com. 
- Note that this simple example assumes that you are connecting to both the bastion host and switches using the same username and SSH credentials (or in this case, keys). 
## Configuring playbook prompts
- All of our playbooks have had their data specified for them at run time in variables we defined within the playbook. 
- However, what if you actually want to obtain information from someone during a playbook run? 
- Perhaps you want to obtain a password from a user for an authentication task without storing it anywhere.
- Ansible can prompt you for user input and store the input in a variable for future processing.
- We will prompt for two variables, one for a user ID and one for a password. One will be echoed to the screen, while the other won't be, by setting private: yes
```YAML
---
- name: A simple play to demonstrate prompting in a playbook
  hosts: frontends
  vars_prompt:
    - name: loginid
      prompt: "Enter your username"
      private: no
    - name: password
      prompt: "Enter your password"
      private: yes
  tasks:
    - name: Proceed with login
      debug:
        msg: "Logging in as {{ loginid }}..."
```
```BASH
ansible-playbook -i hosts prompt.yml
```
# Ansible Security Best Practices
## Working with Ansible Vault
-  It's really important to use Ansible Vault to store all the secret information in our playbooks.
- Some of the really good use cases include how we can use these playbooks without changing our version control systems, CI/CD integration pipelines, and so on.
### How to use Ansible Vault with variables and files
- Let's take an example of installing MySQL server in an Ubuntu operating system using the following playbook. 
- As per the Ansible documentation, it's easy and better to store Vault variables and normal variables differently. 
```YAML
├── group_vars
│   └── mysql.yml # contains vault secret values
├── hosts
├── main.yml
└── roles
    └── mysqlsetup
        └── tasks
            └── main.yml
```
- Now, if we see the group_vars/main.yml file, the content looks as shown in the codeblock. It contains the secrets variable to use in the playbook, called mysql_root_password.
```YAML
mysql_root_password: supersecretpassword​
```
- To encrypt the vault file, we will use the following command and it then prompts for the password to protect
```BASH
ansible-vault encrypt group_vars/mysql.yml
# Now, to execute the playbook run the following command, it will prompt for the vault password
ansible-playbook --ask-vault-pass -i hosts main.yml
```
- We can also pass the ansible-vault password file with playbook execution by specifying flag, it helps in our continuous integration and pipeline platforms.
- The following file contains the password which used to encrypt the mysql.yml file.
```BASH
cat ~/.vaultpassword

thisisvaultpassword

# To pass the vault password file through the command line, use the following command when executing playbooks
ansible-playbook --vault-password-file ~/.vaultpassword -i hosts main.yml
```
!!! Note "Note"
    Make sure to give proper permissions for this file, so others cannot access this file using chmod. 
    Also, it's good practice to add this file to your .gitignore, so it will not be version controlled when pushing playbooks.
    Vault password file can be an executable script, which can retrieve data stored somewhere securely rather than having to keep the key in plain text on disk and relying on file permissions to keep it safe.
    We can also use system environment variables such as ANSIBLE_VAULT_PASSWORD_FILE=~/.vaultpassword and Ansible will use this while executing playbooks.
### Ansible Vault single encrypted variable
- It allows us to use vaulted variables with the !vault tag in YAML files
- This playbook is used to perform reverse IP lookups using the ViewDNS API.
- We want to secure api_key as it contains sensitive information. 
```BASH
# We use the  ansible-vault encrypt_string command to perform this encryption. 
# Here, we used echo with the -n flag to remove the new line
echo -n '53ff4ad63849e6977cb652763g7b7c64e2fa42a' | ansible-vault encrypt_string --stdin-name 'api_key'
```
- We can place the variable, inside the playbook variables and execute the playbook as normal, using ansible-playbook with the --ask-vault-pass option.
```YAML
- name: ViewDNS domain information
  hosts: localhost
  vars:
    domain: google.com
    api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36623761316238613461326466326162373764353437393733343334376161336630333532626465
          6662383435303930303164353664643639303761353664330a393365633237306530653963353764
          64626237313738656530373639653739656564316161663831653431623832336635393637653330
          6632663563363264340a323537356166653338396135376161323435393730306133626635376539
          37383861653239326336613837666237636463396465393662666561393132343166666334653465
          6265386136386132363534336532623061646438363235383334
    output_type: json
  
  tasks:
    - name: "getting {{ domain }} server info"
      uri:
        url: "https://api.viewdns.info/reverseip/?host={{ domain }}&apikey={{ api_key }}&output={{ output_type }}"
        method: GET
      register: results
  
    - debug:
        msg: "{{ results.json }}"
```
- Playbook being executed will be automatically decrypted after we provide it with the given password.
```BASH
ansible-playbook --ask-vault-pass -i hosts main.yml
```
## Setting up and using Ansible Galaxy 
- Is an official centralized hub for finding, sharing, and reusing Ansible roles. 
- This allows the community to share and collaborate on Ansible playbooks, and allows new users to quickly get started with using Ansible. 
- To share our custom-written roles with the community, we can publish them to Ansible Galaxy using GitHub authentication.
- We can install or include roles direct from GitHub by specifying the GitHub URL. 
- This allows the use of private version control systems as local inventories of playbook roles.
```BASH
ansible-galaxy install git+https://github.com/geerlingguy/ansible-role-composer.git
```
## Ansible controller machine security
- The controller machine for Ansible requires SSH and Python to be installed and configured. 
- Ansible has a very low attack surface. 
!!! Note "Note"
    In January 2017, multiple security issues were found by a company called [Computest](https://www.computest.nl/advisories/CT-2017-0109_Ansible.txt).
    This vulnerability was dubbed owning the farm, since compromising the controller would imply that all the nodes could potentially be compromised.
- The controller machine should be a hardened server and treated with all the seriousness that it deserves. 
- In the vulnerability that was disclosed, if a node gets compromised attackers could leverage that to attack and gain access to the controller. - Once they have access, the could extend their control over all the other nodes being managed by the controller.
- Since the attack surface is already very limited, the best we can do is ensure that the server stays secure and hardened.
### Explanation of Ansible OS hardening playbook
- The following playbook is created by DevSec for Linux baselines. 
- It covers most of the required hardening checks based on multiple standards, which includes Ubuntu Security Features, NSA Guide to Secure Configuration, ArchLinux System Hardening and other. 
- This can be improved if required by adding more tasks (or) roles.
- Ansible OS Hardening Playbook covers
    - Configures package management, that is, allows only signed packages
    - Removes packages with known issues
    - Configures pam and the pam_limits module
    - Shadow password suite configuration
    - Configures system path permissions
    - Disables core dumps through soft limits
    - Restricts root logins to system console
    - Sets SUIDs
    - Configures kernel parameters through sysctl
```BASH
# download the os-hardening role from Ansible Galaxy
ansible-galaxy install dev-sec.os-hardening
```
- Call that role in your playbook and execute it to perform the baseline hardening, and also change the variables as required. Refer to https://galaxy.ansible.com/dev-sec/os-hardening for more detailed options.
```YAML
- hosts: localhost
  become: yes

  roles:
    - dev-sec.os-hardening
# Execute the playbook
ansible-playbook main.yml
```
## Best practices and reference playbook projects
- Projects such as Algo, DebOps, and OpenStack are large Ansible playbook projects that are well maintained and secure by default.
### DebOps – your Debian-based data center in a box
- [DebOps](https://debops.org) is a project created by Maciej Delmanowski. It contains a collection of various Ansible playbooks that can be used for Debian and Ubuntu hosts. 
- This project has more than 128 Ansible roles, which are customized for production use cases and work with multiple environments.
- We can see a list of available playbook services at https://github.com/debops/debops-playbooks
- There are two different ways we can quickly get started with a DebOps setup:
    - Vagrant setup
    - Docker setup
### Algo – set up a personal IPSEC VPN in the cloud
- Algo from Trail of Bits provides Ansible roles and scripts to automate the installation of a personal IPSEC VPN.
- By running the Ansible playbooks, you get a complete hardened VPN server, and deployments to all major cloud providers are already configured (https://github.com/trailofbits/algo/blob/master/docs/deploy-from-ansible.md).
### OpenStack-Ansible
- Not only does this project use Ansible playbooks extensively, but their security documentation is also worth reading and emulating. 
- The best part is that all of the security configuration is declarative security codified in Ansible playbooks.
- Documentation on this project is available at https://docs.openstack.org/project-deploy-guide/openstack-ansible/ocata/app-security.html.
### AWX – open source version of Ansible Tower
- AWX provides a web-based user interface, REST API, and task engine built on top of Ansible. 
- AWX can be used with the tower-CLI tool and client library.
- Get started with AWX here: https://github.com/ansible/awx.
- Get started with tower-cli here: https://github.com/ansible/tower-cli/.

```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
```YAML

```
