# Introduction
* [Ansible 101](https://www.digitalocean.com/community/tutorials/configuration-management-101-writing-ansible-playbooks)
* [Ansible Cheat Sheet](https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide)

# Launching situational commands
* To check the inventory file `ansible-inventory --list -y`
* Test Connection `ansible all -m ping -u root`
* Check the disk usage of all servers `ansible all -a "df -h" -u root`
* Check the time of `uptime` each host in a group **servers** 
`ansible servers -a "uptime" -u root`
* Specify multiple hosts by separating their names with colons
`ansible server1:server2 -m ping -u root`

``` yaml
- hosts: host01
---
    become: true
    tasks:
      - name: ensure latest sysstat is installed
        apt:
          name: sysstat
          state: latest

# ansible-playbook -i myhosts site.yml
# ansible host01 -i myhosts -m copy -a "src=test.txt dest=/tmp/"
# ansible host01 -i myhosts -m file -a "dest=/tmp/test mode=644 state=directory"
# ansible host01 -i myhosts -m apt -a "name=sudo state=latest"
# ansible host01 -i myhosts -m shell -a "echo $TERM"
# ansible host01 -i myhosts -m command -a "mkdir folder1"

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
  when: ansible_distribution == 'Debian

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

#file: playbook.yml
---
- hosts: all
  vars_files:
    - vars.yml
  tasks:
    - debug: msg="Variable 'var' is set to {{ var }}"
#file: vars.yml
---
var: 20
#host variables - Variables are defined inline for individual host
  [group1]
  host1 http_port=80
  host2 http_port=303
#group variables - Variables are applied to entire group of hosts
  [group1:vars]
  ntp_server= example.com
  proxy=proxy.example.com
### Whenever you run Playbook, Ansible by default collects information (facts) about each host
### like host IP address, CPU type, disk space, operating system information etc.
ansible host01 -i myhosts -m setup
 # Consider you need the IP address of all the servers in you web group using 'group' variable
  {% for host in groups.web %}

  server {{ host.inventory_hostname }} {{ host.ansible_default_ipv4.address }}:8080

  {% endfor %}

# get a list of all the variables associated with the current host with the help of hostvars and inventory_hostname variables.
---
- name: built-in variables
  hosts: all
  tasks:
    - debug: var=hostvars[inventory_hostname]
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
# Variable Precedence => Command Line > Playbook > Facts > Roles
# CLI: While running the playbook in Command Line redefine the variable
  ansible-playbook -i myhosts test.yml --extra-vars "ansible_bios_version=Ansible"
# Tags are names pinned on individual tasks, roles or an entire play, that allows you to run or skip parts of your Playbook.
# Tags can help you while testing certain parts of your Playbook.
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
ansible-playbook -i myhosts tag.yml --list-tasks # displays the list of tasks in the Playbook
ansible-playbook -i myhosts tag.yml --list-tags # displays only tags in your Playbook
ansible-playbook -i myhosts tag.yml --tags "tag1,mymessage" # executes only certain tasks which are tagged as tag1 and mymessage
# Ansible gives you the flexibility of organizing your tasks through include keyword, that introduces more abstraction and make your Playbook more easily maintainable, reusable and powerful.
---
- name: testing includes
  hosts: all
  sudo: yes
  tasks:
    - include: apache.yml
    - include: content.yml
    - include: create_folder.yml
    - include: content.yml
- include: nginx.yml  #  apache.yml will not hav hosts & tasks but nginx.yml as a separate play will have tasks and can run independently
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
# A Role is completely self contained or encapsulated and completely reusable
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
# Let us run the master_playbook and check the output:
ansible-playbook -i myhosts master_playbook.yml
# ansible-galaxy is command line tool for scaffolding the creation of directory structure needed for organizing your code
ansible-galaxy init sample_role
# ansible-galaxy useful commands
# Install a Role from Ansible Galaxy
To use others role, visit https://galaxy.ansible.com/ and search for the role that will achieve your goal.
Goal: Install Apache in the host machines.
# Ensure that roles_path are defined in ansible.cfg for a role to successfully install.
ansible-galaxy install geerlingguy.apache
# Here, apache is role name and geerlingguy is name of the user in GitHub who created the role.
# Forcefully Recreate Role
ansible-galaxy init geerlingguy.apache --force
# Listing Installed Roles
ansible-galaxy list
# Remove an Installed Role
ansible-galaxy remove geerlingguy.apache
# Environment Variables
# Ansible recommends maintaining inventory file for each environment, instead of keeping all your hosts in a single inventory.
# Each environment directory has one inventory file (hosts) and group_vars directory.
```
