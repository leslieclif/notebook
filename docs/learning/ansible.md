# Introduction
- [Ansible 101](https://www.digitalocean.com/community/tutorials/configuration-management-101-writing-ansible-playbooks)
- [Ansible Cheat Sheet](https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide)
- [Ansible Tips and Tricks](https://github.com/nfaction/ansible-tips-and-tricks/wiki)
- [DO Practise examples](https://github.com/do-community/ansible-practice) & [Explaination](https://www.digitalocean.com/community/tutorial_series/how-to-write-ansible-playbooks) & [Tutorials](https://www.digitalocean.com/community/tags/ansible)
- [YAML Spec Ref Card](https://yaml.org/refcard.html)
- [Full Application on Cloud](https://github.com/mmumshad/udemy-ansible-assignment)

# Documentation on cmdline
```BASH
# System outputs the man page for debug module
ansible-doc debug     
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

scripts/
    setup/                 # All the setup files for updating roles and ansible dependencies
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
```
# Ansible Playbook Examples

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
## Using ansible system variables

- Whenever you run Playbook, Ansible by default collects information (facts) about each host
- like host IP address, CPU type, disk space, operating system information etc.
```BASH
ansible host01 -i myhosts -m setup
```
- Consider you need the IP address of all the servers in you web group using 'group' variable
```BASH
  {% for host in groups.web %}

  server {{ host.inventory_hostname }} {{ host.ansible_default_ipv4.address }}:8080

  {% endfor %}
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
