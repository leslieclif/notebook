# Introduction
- [Ansible Security](https://github.com/PacktPublishing/Security-Automation-with-Ansible-2)
- [Dev-Sec Community Playbooks](https://github.com/dev-sec)
- [Ansible Security Automation](https://www.Ansible.com/security-automation-with-Ansible)
## Why Ansible for this setup?
Ansible is made for security automation and hardening. It uses YAML syntax, which helps us to codify our entire process of repeated tasks. By using this, we can automate the process of continuous delivery and deployment of infrastructure using roles and playbooks.

The modular approach enables us to perform tasks very simply. For example, the operations teams can write a playbook to set up a WordPress site and the security team can create another role which can harden the WordPress site. 

It is very easy to use the modules for repeatability, and the output is idempotent, which means creating standards for the servers, applications, and infrastructure. Some use cases include creating base images for organizations using internal policy standards.

Ansible uses SSH protocol, which is by default secured with encrypted transmission and host encryption. Also, there are no dependency issues while dealing with different types of operating systems. It uses Python to perform; this can be easily extended, based on our use case. 

## Setting up nginx web server
- We are adding the signing key, then adding the repository, then installing. 
- This ensures that we can also perform integrity checks while downloading packages from the repositories. 
## Hardening SSH service
```YAML
# Disabling the root user login, and instead creating a different user, and, if required, providing the sudo privilege
    - name: create new user
      user:
        name: "{{ new_user_name }}"
        password: "{{ new_user_password }}"
        shell: /bin/bash
        groups: sudo
        append: yes
# Using key-based authentication to log in. Unlike with password-based authentication, we can generate SSH keys and add the public key to the authorized keys
    - name: add ssh key for new user
      authorized_key:
        user: "{{ new_user_name }}"
        key: "{{ lookup('file', '/home/user/.ssh/id_rsa.pub') }}"
        state: present
# Some of the configuration tweaks using the SSH configuration file; for example, PermitRootLogin, PubkeyAuthentication, and PasswordAuthentication
    - name: ssh configuration tweaks
      lineinfile:
        dest: /etc/ssh/sshd_config
        state: present
        line: "{{ item }}"
        backups: yes

      with_items:
        - "PermitRootLogin no"
        - "PasswordAuthentication no"

      notify:
        - restart ssh
```
- We can also set up services like fail2ban for protecting against basic attacks.
- Also, we can enable MFA, if required to log in. [Digitial Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04)
- The following playbook will provide more advanced features for SSH hardening by [dev-sec team](https://github.com/dev-sec/ansible-ssh-hardening)
## Hardening nginx 
- We can start looking at things like disabling server tokens to not display version information, adding headers like X-XSS-Protection, and many other configuration tweaks. 
- Most of these changes are done via configuration changes, and Ansible allows us to version and control and automate these changes based on user requirements.
    - The nginx server version information can be blocked by adding the server_tokens off; value to the configuration
    - add_header X-XSS-Protection "1; mode=block"; will enable the cross-site scripting (XSS) filter
    - SSLv3 can be disabled by adding  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```YAML
    - name: update the hardened nginx configuration changes
      template:
        src: "hardened-nginx-config.j2"
        dest: "/etc/nginx/sites-available/default"

      notify:
        - restart nginx
```
- Mozilla runs an updated web page on guidance for [SSL/TLS](https://wiki.mozilla.org/Security/Server_Side_TLS). 
- The guidance offers an opinion on what cipher suites to use, and other security measures. 
- Additionally, if you trust their judgment, you can also use their SSL/TLS configuration generator to quickly generate a configuration for your [web server configuration](https://mozilla.github.io/server-side-tls/ssl-config-generator/).
- Whichever configuration you decide to use, the template needs to be named as `hardened-nginx-config.j2`.
## Hardening WordPress
- This includes basic checks for WordPress security misconfigurations. Some of them include:
```YAML
# Directory and file permissions
    - name: update the file permissions
      file:
        path: "{{ WordPress_install_directory }}"
        recurse: yes
        owner: "{{ new_user_name }}"
        group: www-data

    - name: updating file and directory permissions
      shell: "{{ item }}"

      with_items:
        - "find {{ WordPress_install_directory }} -type d -exec chmod
         755 {} \;"
        - "find {{ WordPress_install_directory }} -type f -exec chmod 
        644 {} \;"
# Username and attachment enumeration blocking. The following code snippet is part of nginx's configuration
    # Username enumeration block
    if ($args ~ "^/?author=([0-9]*)"){
        return 403;
    }

    # Attachment enumeration block
    if ($query_string ~ "attachment_id=([0-9]*)"){
        return 403;
    }
# Disallowing file edits in the WordPress editor
    - name: update the WordPress configuration
      lineinfile:
        path: /var/www/html/wp-config.php
        line: "{{ item }}"
  
      with_items:
        - define('FS_METHOD', 'direct');
        - define('DISALLOW_FILE_EDIT', true);
```
## Hardening a database service
- We can harden the MySQL service by binding it to localhost and the required interfaces for interacting with the application. 
- It then removes the anonymous user and test databases
```YAML
- name: delete anonymous mysql user for localhost
  mysql_user:
    user: ""
    state: absent
    login_password: "{{ mysql_root_password }}"
    login_user: root

- name: secure mysql root user
  mysql_user:
    user: "root"
    password: "{{ mysql_root_password }}"
    host: "{{ item }}"
    login_password: "{{ mysql_root_password }}"
    login_user: root

  with_items:
    - 127.0.0.1
    - localhost
    - ::1
    - "{{ ansible_fqdn }}"

- name: removes mysql test database
  mysql_db:
    db: test
    state: absent
    login_password: "{{ mysql_root_password }}"
    login_user: root
```
## Hardening a host firewall service
- Ansible even has a module for UFW, so the following snippet starts with installing this and enabling logging. 
- It follows this by adding default policies, like default denying all incoming and allowing outgoing. 
- Then it will add SSH, HTTP, and HTTPS services to allow incoming. These options are completely configurable, as required. 
```YAML
- name: installing ufw package
  apt:
    name: "ufw"
    update_cache: yes
    state: present

- name: enable ufw logging
  ufw:
    logging: on

- name: default ufw setting
  ufw:
    direction: "{{ item.direction }}"
    policy: "{{ item.policy }}"

  with_items:
    - { direction: 'incoming', policy: 'deny' }
    - { direction: 'outgoing', policy: 'allow' }

- name: allow required ports to access server
  ufw:
    rule: "{{ item.policy }}"
    port: "{{ item.port }}"
    proto: "{{ item.protocol }}"

  with_items:
    - { port: "22", protocol: "tcp", policy: "allow" }
    - { port: "80", protocol: "tcp", policy: "allow" }
    - { port: "443", protocol: "tcp", policy: "allow" }

- name: enable ufw
  ufw:
    state: enabled

- name: restart ufw and add to start up programs
  service:
    name: ufw
    state: restarted
    enabled: yes
```
## Setting up automated encrypted backups in AWS S3
- Backups are always something that most of us feel should be done, but they seem quite a chore. 
- Over the years, people have done extensive work to ensure we can have simple enough ways to back up and restore our data. 
- In today's day and age, a great backup solution/software should be able to do the following:
    - Automated: Automation allows for process around it
    - Incremental: While storage is cheap overall, if we want backups at five minute intervals, what has changed should be backed up
    - Encrypted before it leaves our server: This is to ensure that we have security of data at rest and in motion
    - Cheap: While we care about our data, a good back up solution will be much cheaper than the server which needs to be backed up
- For our backup solution, we will pick up the following stack:
    - Software: Duply - A wrapper over duplicity, a Python script 
    - Storage: While duply offers many backends, it works really well with AWS S3 
    - Encryption: By using GPG, we can use asymmetric public and private key pairs
```YAML
- name: installing duply
  apt:
    name: "{{ item }}"
    update_cache: yes
    state: present
  
  with_items:
    - python-boto
    - duply

- name: check if we already have backup directory
  stat:
    path: "/root/.duply/{{ new_backup_name }}"
  register: duply_dir_stats

- name: create backup directories
  shell: duply {{ new_backup_name }} create
  when: duply_dir_stats.stat.exists == False

- name: update the duply configuration
  template:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
  
  with_items:
    - { src: conf.j2, dest: /root/.duply/{{ new_backup_name }}/conf }
    - { src: exclude.j2, dest: /root/.duply/{{ new_backup_name }}/exclude }

- name: create cron job for automated backups
  template:
    src: duply-backup.j2
    dest: /etc/cron.hourly/duply-backup
```
# LAMP stack playbook
## The high-level hierarchy structure of the entire playbook:
```YAML
inventory               # inventory file
group_vars/             #
   all.yml              # variables
site.yml                # master playbook (contains list of roles)
roles/                  #
    common/             # common role
        tasks/          #
            main.yml    # installing basic tasks
    web/                # apache2 role
        tasks/          #
            main.yml    # install apache
        templates/      #
            web.conf.j2 # apache2 custom configuration
        vars/           # 
            main.yml    # variables for web role 
        handlers/       #
            main.yml    # start apache2
    php/                # php role
        tasks/          # 
            main.yml    # installing php and restart apache2
    db/                 # db role
        tasks/          #
            main.yml    # install mysql and include harden.yml
            harden.yml  # security hardening for mysql
        handlers/       #
            main.yml    # start db and restart apache2
        vars/           #
            main.yml    # variables for db role
```
## Playbook Files
- Here is a very basic static inventory file where we will define a since host and set the IP address used to connect to it.
- Configure the following inventory file as required:
```YAML
[lamp]
lampstack    ansible_host=192.168.56.10
```
```YAML
#  group_vars/lamp.yml, which has the configuration of all the global variables
remote_username: "hodor"
```
```YAML
#  site.yml, which is the main playbook file to start
- name: LAMP stack setup on Ubuntu 16.04
 hosts: lamp
 gather_facts: False
 remote_user: "{{ remote_username }}"
 become: True

 roles:
   - common
   - web
   - db
   - php
```
```YAML
# roles/common/tasks/main.yml file, which will install python2, curl, and git
# In ubuntu 16.04 by default there is no python2
- name: install python 2
  raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)

- name: install curl and git
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - curl
    - git
```
```YAML
# roles/web/tasks/main.yml, performs multiple operations, such as installation and configuration of apache2. 
# It also adds the service to the startup process
- name: install apache2 server
  apt:
    name: apache2
    state: present

- name: update the apache2 server configuration
  template: 
    src: web.conf.j2
    dest: /etc/apache2/sites-available/000-default.conf
    owner: root
    group: root
    mode: 0644

- name: enable apache2 on startup
  systemd:
    name: apache2
    enabled: yes
  notify:
    - start apache2
```
```YAML
# notify parameter will trigger the handlers found in roles/web/handlers/main.yml
- name: start apache2
  systemd:
    state: started
    name: apache2

- name: stop apache2
  systemd:
    state: stopped
    name: apache2

- name: restart apache2
  systemd:
    state: restarted
    name: apache2
    daemon_reload: yes
```
```YAML
# The template files will be taken from role/web/templates/web.conf.j2, which uses Jinja templating, it also takes values from local variables
<VirtualHost *:80><VirtualHost *:80>
    ServerAdmin {{server_admin_email}}
    DocumentRoot {{server_document_root}}

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
```YAML
# The local variables file is located in roles/web/vars/main.yml
server_admin_email: hodor@localhost.local
server_document_root: /var/www/html
```
```YAML
# File roles/db/tasks/main.yml includes installation of the database server with assigned passwords when prompted. 
# At the end of the file, we included harden.yml, which executes another set of tasks
- name: set mysql root password
  debconf:
    name: mysql-server
    question: mysql-server/root_password
    value: "{{ mysql_root_password | quote }}"
    vtype: password

- name: confirm mysql root password
  debconf: 
    name: mysql-server
    question: mysql-server/root_password_again
    value: "{{ mysql_root_password | quote }}"
    vtype: password

- name: install mysqlserver
  apt:
    name: "{{ item }}"
    state: present 
  with_items:
    - mysql-server
    - mysql-client

- include: harden.yml
```
```YAML
#  harden.yml performs hardening of MySQL server configuration
- name: deletes anonymous mysql user
  mysql_user:
    user: ""
    state: absent
    login_password: "{{ mysql_root_password }}"
    login_user: root

- name: secures the mysql root user
  mysql_user: 
    user: root
    password: "{{ mysql_root_password }}"
    host: "{{ item }}"
    login_password: "{{mysql_root_password}}"
    login_user: root
 with_items:
   - 127.0.0.1
   - localhost
   - ::1
   - "{{ ansible_fqdn }}"

- name: removes the mysql test database
  mysql_db:
    db: test
    state: absent
    login_password: "{{ mysql_root_password }}"
    login_user: root

- name: enable mysql on startup
  systemd:
    name: mysql
    enabled: yes

  notify:
    - start mysql
```
```YAML
# db server role also has roles/db/handlers/main.yml and local variables similar to the web role
- name: start mysql
  systemd:
    state: started
    name: mysql

- name: stop mysql
  systemd:
    state: stopped
    name: mysql

- name: restart mysql
  systemd:
    state: restarted
    name: mysql
    daemon_reload: yes
```
```YAML
# roles/db/vars/main.yml, which has the mysql_root_password while configuring the server. 
# we can secure these plaintext passwords using ansible-vault in future.
mysql_root_password: R4nd0mP4$$w0rd
```
```YAML
# we will install PHP and configure it to work with apache2 by restarting the roles/php/tasks/main.yml service
- name: install php7
  apt:
    name: "{{ item }}"
    state: present
  with_items:
    - php7.0-mysql
    - php7.0-curl
    - php7.0-json
    - php7.0-cgi
    - php7.0
    - libapache2-mod-php7

- name: restart apache2
  systemd:
    state: restarted
    name: apache2
    daemon_reload: yes
```
```BASH
# Execute the following command against the Ubuntu 16.04 server to set up LAMP stack. 
# Provide the password when it prompts for system access for user hodor.
ansible-playbook -i inventory site.yml
```
# Setting up Ansible Tower

```BASH
# Make sure you have Vagrant installed in your host system before running the following command: 
vagrant init ansible/tower
vagrant up
vagrant ssh
# It will prompt you to enter  IP address, username, and password to login to the Ansible Tower dashboard.
```
- Then navigate the browser to https://10.42.0.42 and accept the SSL error to proceed. 
- This SSL error can be fixed by providing the valid certificates in the configuration at `/etc/tower` and need to restart the Ansible Tower service. 
- Enter the login credentials to access the Ansible Tower dashboard.
- Once you log in, it will prompt you for the Ansible Tower license.
- Ansible Tower also provides **Role-Based Authentication Control (RBAC)**, which provides a granular level of control for different users and groups to manage Tower.
- Create a new user with the System Administrator privilege
- To add inventory into Ansible Tower, we can simply enter it manually
- Add credentials (or) keys to the tower by providing them in credential management, which can be reused as well.
- Secrets store in Ansible Tower are encrypted with a symmetric key unique to each Ansible Tower cluster. 
- Once stored in the Ansible Tower database, the credentials may only be used, not viewed, in the web interface. 
- The types of credentials that Ansible Tower can store are passwords, SSH keys, Ansible Vault keys, and cloud credentials.
- Once we have the inventory gathered, we can create jobs to perform the playbook or ad-hoc command operations.
- The Ansible Tower REST API is a pretty powerful way to interact with the system
- Get started with the `pip install ansible-tower-cli` command.
# Setting up AWX
- Ansible is very powerful, but it does require the user to use the CLI. 
- In some situations, this is not the best option, such as in cases where you need to trigger an Ansible job from another job (where APIs would be better) or in cases where the person that should trigger a job should only be able to trigger that specific job. 
- For these cases, AWX or Ansible Tower are better options to use.
- The only differences between AWX and Ansible Tower are that AWX is the upstream and open source version, while Ansible Tower is the Red Hat and downstream product that is officially supported but for a price, and also the delivery method. 
- **We will use AWX and talk about AWX, but everything we discuss also applies to Ansible Tower.**
- Although there are several ways to install AWX, we are going to use the suggested AWX installation, which is container-based. 
- For this reason, the following software needs to be installed on your machine:
    - Ansible 2.4+.
    - Docker.
    - The docker Python module.
    - The docker-compose Python module.
    - If your system uses Security-Enhanced Linux (SELinux), you also need the libselinux Python module.
## Installing AWX
- We need to clone the AWX Git repository. `git clone https://github.com/ansible/awx.git`
- Modify the installer/inventory file by setting sensible values for the passwords and secrets (such as pg_password, rabbitmq_password, admin_password, and secret_key)
- Now that we have downloaded the Ansible AWX code and installer, we can move into the installer folder and execute the installation by running the following code.
```BASH
cd awx/installer
ansible-playbook -i inventory install.yml
```
- The install.yml playbook performs the whole installation for us. It starts by checking the environment for possible misconfigurations or missing dependencies. If everything seems to be correct, it moves on to downloading several Docker images (including PostgreSQL, memcached, RabbitMQ, AWX Web, and AWX workers) and then runs them all.
- As soon as the playbook completes, you can check the installation by issuing the docker ps command.
- As you can see from docker ps output, our system now has a container called awx_web, which has bound itself to port 80.
You can now access AWX by browsing to `http://<ip address of your AWX host>/` and using the credentials you specified in the inventory file earlier on and that the default administrator username is admin unless you change it in the inventory.
## Running your first playbook from AWX
- As in Ansible, in AWX, the goal is running an Ansible playbook and each playbook that is run is called a job. 
- Since AWX gives you more flexibility and automation than Ansible, it requires a little bit more configuration before you can run your first job.
### Creating an AWX project
- AWX uses the term **project** to identify a repository of Ansible playbooks. 
- AWX projects support the placement of playbooks in all major Source Control Management (SCM) systems, such as Git, Mercurial, and SVN, but also support playbooks on the filesystem or playbooks provided by Red Hat Insights. 
- Projects are the system to store and use playbooks in AWX. As you can imagine, there are many interesting additional configurations for AWX projects—and the most interesting one, in my view—is update revision on launch.
- If flagged, this option instructs Ansible to always update the playbook's repository before running any playbook from that project. This ensures it always executes the latest version of the playbook. This is an important feature to enable as if you don't have it checked, there is the possibility (and sooner or later, this will happen in your environment) that someone notices that there is a problem in a playbook and fixes it, then they run the playbook feeling sure that they are running the latest version. They then forget to run the synchronization task before running the playbook, effectively running the older version of the playbook. This could lead to major problems if the previous version was fairly buggy.
- The downside of using this option is that every time you execute a playbook, two playbooks are effectively run, adding time to your task execution. I think this is a very small downside and one that does not offset the benefits of using this option.
### Creating an inventory
- As with Ansible Core, to make AWX aware of the machines present in your environment, we use inventories. 
- Inventories, in the AWX world, are not that different from their equivalents in Ansible Core. 
- Since an empty inventory is not useful in any way, we are going to add `localhost` to it.
- We then need to add the hostname (localhost) and instruct Ansible to use the local connection by adding the following code to the VARIABLES box.
```YAML
---
ansible_connection: local
ansible_python_interpreter: '{{ ansible_playbook_python }}'
```
### Creating a job template
- A job template in AWX is a collection of the configurations that are needed to perform a job. 
- This is very similar to the ansible-playbook command-line options. 
- The reason why we need to create a job template is so that playbook runs can be launched with little or no user input, meaning they can be delegated to teams who might not know all the details of how a playbook works, or can even be run on a scheduled basis without anyone present.
-  Note that because we are running it using the local connection to localhost, we don't need to create or specify any credentials. 
- However, if you were running a job template against one or more remote hosts, you would need to create a machine credential and associate it with your job template.
- A machine credential is, for example, an SSH username and password or an SSH username and a private key—these are stored securely in the backend database of AWX, meaning you can again delegate playbook-related tasks to other teams without actually giving them passwords or SSH keys.
- The first thing we had to choose was whether we are creating a job template or a workflow template. We chose Job Template since we want to be able to create simple jobs out of this template. It's also possible to create more complex jobs, which are the composition of multiple job templates, with flow control features between one job and the next. This allows more complex situations and scenarios where you might want to have multiple jobs (such as the creation of an instance, company customization, the setup of Oracle Database, the setup of a MySQL database, and so on), but you also want to have a one-click deployment that would, for instance, set up the machine, apply all the company customization, and install the MySQL database. Obviously, you might also have another deployment that uses all the same components except the last one and in its place, it uses the Oracle Database piece to create an Oracle Database machine. This allows you to have extreme flexibility and to reuse a lot of components, creating multiple, nearly identical playbooks.
- It's interesting to note that many fields in the Job Template creation window have an option with the Prompt on launch caption. This is to be able to set this value optionally during the creation of the job template, but also allow the user running the job to enter/override it at runtime. This can be incredibly valuable when you have a field that changes on each run (perhaps the limit field, which operates in the same way as --limit when used with the ansible-playbook command) or can also be used as a sanity check, as it prompts the user with the value (and gives them a chance to modify it) before the playbook is actually run. However, it could potentially block scheduled job runs, so exercise caution when enabling this feature.
### Running a job
- A job is an instance of a job template. 
- This means that to perform any action on our machine, we have to create a job template instance or, more simply, a job.
- One of the great things about AWX and Ansible Tower is that they archive this job execution output in the backend database, meaning you can, at any point in the future, come back and query a job run to see what changed and what happened. This is incredibly powerful and useful for occasions such as auditing and policy enforcement.
## Controlling access to AWX
- In my opinion, one of the biggest advantages of AWX compared to Ansible is the fact that AWX allows multiple users to connect and control/perform actions. 
- This allows a company to have a single AWX installation for different teams, a whole organization, or even multiple organizations.
- A Role-Based Access Control (RBAC) system is in place to manage the users' permissions.
- Both AWX and Ansible Tower can link to central directories, such as Lightweight Directory Access Protocol (LDAP) and Azure Active Directory however, we can also create user accounts locally on the AWX server itself. 
### Creating a user
- One of the big advantages of AWX is the ability to manage multiple users. 
- This allows us to create a user in AWX for each person that is using the AWX system so that we can ensure they are only granted the permissions that they need. 
- Also, by using individual accounts, we can ensure that we can see who carried out what action by using the audit logs. 
- By adding the email address, the username, and the password (with confirmation), you can create the new user.
- Users can be of three types:
    - A normal user: Users of this type do not have any inherited permissions and they need to be awarded specific permissions to be able to do anything.
    - A system auditor: Users of this type have full read-only privileges on the whole AWX installation.
    - A system administrator: Users of this type have full privileges on the whole AWX installation.
### Creating a team
- Although having individual user accounts is an incredibly powerful tool, especially for enterprise use cases, it would be incredibly inconvenient and cumbersome to have to set permissions for each object (such as a job template or an inventory) on an individual basis. 
- Every time someone joins a team, their user account has to be manually configured with the correct permissions against every object and, similarly, be removed if they leave.
- AWX and Ansible Tower have the same concept of user grouping that you would find in most other RBAC systems. The only slight difference is that in the user interface, they are referred to as teams, rather than groups. However, you can create teams simply and easily and then add and remove users as you need to. Doing this through the user interface is very straightforward and you will find the process similar to the way that most RBAC systems handle user groups, so we won't go into any more specific details here.
- Once you have your teams set up, I recommend that you assign your permissions to teams, rather than through individual users, as this will make your management of AWX object permissions much easier as your organization grows. 
### Creating an organization
- Sometimes, you have multiple independent groups of people that you need to manage independent machines. 
- For those kinds of scenarios, the use of organizations can help you. 
- An organization is basically a tenant of AWX, with its own unique user accounts, teams, projects, inventories, and job templates—it's almost like having a separate instance of AWX! 
- After you create the organization, you can assign any kind of resource to an organization, such as projects, templates, inventories, users, and so on. 
- Organizations are a simple concept to grasp, but also powerful in terms of segregating roles and responsibilities in AWX. 
### Assigning permissions in AWX
- Individual users (or the teams that they belong to) can be granted permissions on a per-object basis. So, for example, you could have a team of database administrators who only have access to see and execute playbooks on an inventory of database servers, using job templates that are specific to their role. Linux system administrators could then have access to the inventories, projects, and job templates that are specific to their role. AWX hides objects that users don't have the privileges to, which means the database administrators never see the Linux system administrator objects and vice versa.
- There are a number of different privilege levels that you can award users (or teams) with, which include the following:
    - Admin: This is the organization-level equivalent of a system administrator.
    - Execute: This kind of user can only execute templates that are part of the organization.
    - Project admin: This kind of user can alter any project that is part of the organization.
    - Inventory admin: This kind of user can alter any inventory that is part of the organization.
    - Credential admin: This kind of user can alter any credential that is part of the organization.
    - Workflow admin: This kind of user can alter any workflow that is part of the organization.
    - Notification admin: This kind of user can alter any notification that is part of the organization.
    - Job template admin: This kind of user can alter any job template that is part of the organization.
    - Auditor: This is the organization-level equivalent to a system auditor.
    - Member: This is the organization-level equivalent of a normal user.
    - Read: This kind of user is able to view non-sensible objects that are part of the organization.
- AWX is a great addition to the power of Ansible in an enterprise setting and really helps ensure that your users can run Ansible playbooks in a manner that is well managed, secure, and auditable.
# Setting up Jenkins

```YAML
- name: installing jenkins in ubuntu 16.04
  hosts: "192.168.1.7"
  remote_user: ubuntu
  gather_facts: False
  become: True

tasks:
  - name: install python 2
    raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)

  - name: install curl and git
    apt: name={{ item }} state=present update_cache=yes
    with_items:
      - curl
      - git
    - name: adding jenkins gpg key
    apt_key:
      url: https://pkg.jenkins.io/debian/jenkins-ci.org.key
      state: present

  - name: jeknins repository to system
    apt_repository:
      repo: http://pkg.jenkins.io/debian-stable binary/
      state: present

  - name: installing jenkins
    apt:
      name: jenkins
      state: present
      update_cache: yes

  - name: adding jenkins to startup
    service:
      name: jenkins
      state: started
      enabled: yes

  - name: printing jenkins default administration password
    command: cat /var/lib/jenkins/secrets/initialAdminPassword
    register: jenkins_default_admin_password
  
  - debug:
      msg: "{{ jenkins_default_admin_password.stdout }}"
```
```BASH
# To set up Jenkins, run the following command. Where 192.168.1.7 is the server IP address where Jenkins will be installed:
ansible-playbook -i '192.168.1.7,' site.yml --ask-sudo-pass
# we have to navigate to the Jenkins dashboard by browsing to http://192.168.1.7:8080 and providing the auto-generated password. 
# If the playbook runs without any errors, it will display the password at the end of the play.
```
- Create the new user by filling in the details and confirming to log in to the Jenkins console.
- We can install custom plugins in Jenkins, navigate to the Manage Jenkins tab, select Manage Plugins, then navigate to the Available tab. 
- In the Filter: enter the plugin name as Ansible. Then select the checkbox and click Install without restart.
- Now we are ready to work with the Ansible plugin for Jenkins. 
- Create a new project in the main dashboard, give it a name, and select Freestyle project to proceed:
- We can configure the build options, this is where Jenkins will give us more flexibility to define our own triggers, build instructions, and post build scripts
- Once the build triggers based on an event, this can be sent to some artifact storage, it can also be available in the Jenkins build console output
- This is a really very powerful way to perform dynamic operations such as triggering automated server and stacks setup based on a code push to the repository, as well as scheduled scans and automated reporting.

# Security automation use cases
- Here is a list of tasks that will prepare you to build layers of automation for the stuff that is important to you:
    - Adding playbooks or connecting your source code management (SCM) tools, such as GitHub/GitLab/BitBucket
    - Authentication and data security
    - Logging output and managing reports for the automation jobs
    - Job scheduling
    - Alerting, notifications, and webhooks
## Ansible Tower configuration
- To add playbooks into Ansible Tower, we have to start by creating projects, then select the SCM TYPE as Manual
- We can choose the SCM TYPE set to Git and provide a github.com URL pointing to a playbook
- Git SCM to add playbooks into projects
    - We can also change the PROJECTS_ROOT under CONFIGURE TOWER to change this location.
- The added playbooks are executed by creating a job template. Then we can schedule these jobs (or) we can launch directly.
## Jenkins Ansible integration configuration
- Jenkins supports SCM to use playbooks and local directories for manual playbooks too. 
- This can be configured with the build options. 
- Jenkins supports both ad-hoc commands and playbooks to trigger as a build (or) post-build action.
- We can also specify credentials if we want to access private repositories
- We can add the Playbook path by specifying the location of the playbook and defining inventory and variables as required
## Authentication and  data security
- Some of the security features the tools offer include:
    - RBAC (authentication and authorization)
    - Web application over TLS/SSL (security for data in motion)
    - Encryption for storing secrets (security for data at rest)
### RBAC for Ansible Tower
- Ansible Tower supports RBAC to manage multiple users with different permissions and roles. 
- It also supports Lightweight Directory Access Protocol (LDAP) integration in the enterprise version to support Active Directory. 
- This feature allows us to create different levels of users for accessing Ansible Tower. 
- For example:
    - The operations team requires a system administrator role to perform playbook execution and other activities like monitoring
    - The security team requires a system auditor role to perform audit check for compliance standards such as Payment Card Industry Data Security Standard (PCI DSS) or even internal policy validation
    - Normal users, such as team members, might just want to see how things are going, in the form of status updates and failure (or) success of job status
### TLS/SSL for Ansible Tower
- By default, Ansible Tower uses HTTPS using self-signed certificates at /etc/tower/tower.cert and /etc/tower/tower.key.
### Encryption and data security for Ansible Tower
- Ansible Tower has been created with built-in security for handling encryption of credentials that includes passwords and keys. 
- It uses Ansible Vault to perform this operation. 
- It encrypts passwords and key information in the database.
### TLS/SSL for Jenkins
- By default, Jenkins runs as plain old HTTP. To enable HTTPS, we can use a reverse proxy, such as Nginx, in front of Jenkins to serve as HTTPS. 
- [Digital Ocean Reference for TLS](https://www.digitalocean.com/community/tutorials/how-to-configure-jenkins-with-ssl-using-an-nginx-reverse-proxy)
### Encryption and data security for Jenkins
- We are using Jenkins' default credential feature. This will store the keys and passwords in the local filesystem. 
## Output of the playbooks
-  We would like to know where can we see the output of the playbooks executing and if any other logs that get created. 
### Report management for Ansible Tower
- By default, Ansible Tower itself is a reporting platform for the status of the playbooks, job executions, and inventory collection. 
- The Ansible Tower dashboard gives an overview of the total projects, inventories, hosts, and status of the jobs. 
- The output can be consumed in the dashboard, standard out, or by using the REST API and we can get this via tower-cli command line tool as well, which is just a pre-built command line tool for interfacing with the REST API.
## Scheduling of jobs
- The scheduling of jobs is simple and straightforward in Ansible Tower. 
- For a job, you can specify a schedule and the options are mostly like cron. 
- For example, you can say that you have a daily scan template and would like it to be executed at 4 a.m. every day for the next three months. 
- This kind of schedule makes our meta automation very flexible and powerful. 
## Alerting, notifications, and webhooks
- Tower supports multiple ways of alerting and notifying users as per configuration. 
- This can even be configured to make an HTTP POST request to a URL of your choice using a webhook.
- Ansible Tower notification using slack webhook is a popular option.
# Setting Up a Hardened WordPress with Encrypted Automated Backups
- Automating our server's patches is the most obvious, and possibly popular, requirement. 
- We will apply security automation techniques and approaches to set up a hardened WordPress and enable encrypted backups. 
- Everyone would agree that setting up a secure website and keeping it secured is a fairly common security requirement. 
- And since it is so common, it would be useful for a lot of people who are tasked with building and managing websites to stay secure to look at that specific scenario. 
!!! Note "Note"
    Are you aware that, according to Wikipedia, 27.5% of the top 10 million websites use WordPress? According to another statistic, 58.7% of all websites with known software on the entire web run WordPress.
- For us, setting up a hardened WordPress with encrypted automated backups can be broken down into the following steps:
    - Setting up a Linux/Windows server with security measures in place.
    - Setting up a web server (Apache/Nginx on Linux and IIS on Windows).
    - Setting up a database server (MySQL) on the same host.
    - Setting up WordPress using a command-line utility called WP-CLI.
    - Setting up backup for the site files and the database which is incremental, encrypted, and most importantly, automated.
!!! Note "Note"
    We will assume that the server that we plan to deploy our WordPress website on is already up and running and we are able to connect to it. 
    We will store the backup in an already configured AWS S3 bucket, for which the access key and secret access key is already provisioned. 
- Refer the examples in Introduction to set this up.
## Secure automated the WordPress updates
- Run the backups and update WordPress core, themes, and plugins. This can be scheduled via an Ansible Tower job for every day
```YAML
- name: running backup using duply
  command: /etc/cron.hourly/duply-backup

- name: updating WordPress core
  command: wp core update
  register: wp_core_update_output
  ignore_errors: yes

- name: wp core update output
  debug:
    msg: "{{ wp_core_update_output.stdout }}"

- name: updating WordPress themes
  command: wp theme update --all
  register: wp_theme_update_output
  ignore_errors: yes

- name: wp themes update output
  debug:
    msg: "{{ wp_theme_update_output.stdout }}"

- name: updating WordPress plugins
  command: wp plugin update --all
  register: wp_plugin_update_output
  ignore_errors: yes

- name: wp plugins update output
  debug:
    msg: "{{ wp_plugin_update_output.stdout }}"
```
## Scheduling via Ansible Tower for daily updates
- Ansible Tower job scheduling for automated WordPress updates OR
- We can use the cron job template to perform this daily and add this template while deploying the WordPress setup
```BASH
#!/bin/bash

/etc/cron.hourly/duply-backup
wp core update
wp theme update --all
wp plugin update --all
```
## Setting up Apache2 web server
- Shows how we can use templating to perform configuration updates in the server
```YAML
- name: installing apache2 server
  apt:
    name: "apache2"
    update_cache: yes
    state: present

- name: updating customized templates for apache2 configuration
  template:
    src: "{{ item.src }}"
    dest: "{{ item.dst }}"
    mode: 0644
  
  with_tems:
    - { src: apache2.conf.j2, dst: /etc/apache2/conf.d/apache2.conf }
    - { src: 000-default.conf.j2, dst: /etc/apache2/sites-available/000-default.conf }
    - { src: default-ssl.conf.j2, dst: /etc/apache2/sites-available/default-ssl.conf }

- name: adding custom link for sites-enabled from sites-available
  file:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
    state: link
  
  with_items:
    - { src: '/etc/apache2/sites-available/000-default.conf', dest: '/etc/apache2/sites-enabled/000-default.conf' }
    - { src: '/etc/apache2/sites-available/default-ssl.conf', dest: '/etc/apache2/sites-enabled/default-ssl.conf' }

  notify:
    - start apache2
    - startup apache2
```
## Enabling TLS/SSL with Let's Encrypt
- We can use a command-line tool offered by Let's Encrypt to get free SSL/TLS certificates in an open, automated manner. 
- The tool is capable of reading and understanding an nginx virtual host file and generating the relevant certificates completely automatically, without any kind of manual intervention.
```YAML
- name: adding certbot ppa
  apt_repository:
    repo: "ppa:certbot/certbot"

- name: install certbot
  apt:
    name: "{{ item }}"
    update_cache: yes
    state: present

  with_items:
    - python-certbot-nginx

- name: check if we have generated a cert already
  stat:
    path: "/etc/letsencrypt/live/{{ website_domain_name }}/fullchain.pem"
  register: cert_stats

- name: run certbot to generate the certificates
  shell: "certbot certonly --standalone -d {{ website_domain_name }} --email {{ service_admin_email }} --non-interactive --agree-tos"
  when: cert_stats.stat.exists == False

- name: configuring site files
  template:
    src: website.conf
    dest: "/etc/nginx/sites-available/{{ website_domain_name }}"

- name: restart nginx
  service:
    name: nginx
    state: restarted
```
# Log Monitoring
- Log monitoring is the perfect place to think about security automation. 
- For monitoring to be effective, a few things need to happen. 
- We should be able to move logs from different devices to a central location. 
- We should be able to make sense of what a regular log entry is and what could possibly be an attack. 
- We should be able to store the logs, and also operate on them for things such as aggregation, normalization, and eventually, analysis.
- Traditional logging systems find it difficult to log for all applications, systems, and devices. 
- The variety of time formats, log output formats, and so on, makes the task pretty complicated.
- The biggest roadblock is finding a way to be able to centralize logs. 
- This gets in the way of being able to process log entries in real time, or near real time effectively.
- Some of the problematic points are as follows:
    - Access is often difficult
    - High expertise in mined data is required
    - Logs can be difficult to find
    - Log data is immense in size
## Introduction to Elastic Stack
- Elastic Stack is a group of open source products from the Elastic company. 
- It takes data from any type of source and in any format and searches, analyzes, and visualizes that data in real time. 
- It consists of four major components, as follows:
    - Elasticsearch
    - Logstash
    - Kibana
    - Beats
- It helps users/admins to collect, analyze, and visualize data in (near) real time. 
- Each module fits based on your use case and environment.
## Elasticsearch
- Elasticsearch is a distributed, RESTful search and analytics engine capable of solving a growing number of use cases. 
- As the heart of the Elastic Stack, it centrally stores your data so you can discover the expected and uncover the unexpected
- Main plus points of Elastic Stack:
    - Distributed and highly available search engine, written in Java, and uses Groovy
    - Built on top of Lucene
    - Multi-tenant, with multi types and a set of APIs
    - Document-oriented, providing (near) real-time search
## Logstash
- Logstash is an open source, server-side data processing pipeline that ingests data from a multitude of sources, simultaneously transforms it, and then sends it to your favorite stash.
- Centralized data processing of all types of logs
- Consists of the following three main components:
    - Input: Passing logs to process them into machine-understandable format
    - Filter: A set of conditions to perform a specific action on an event
    - Output: The decision maker for processed events/logs
## Kibana
- Kibana lets you visualize your Elasticsearch data and navigate the Elastic Stack, so you can do anything from learning why you're getting paged at 2:00 a.m. to understanding the impact rain might have on your quarterly numbers.
- Kibana's list of features:
    - Powerful frontend dashboard is written in JavaScript
    - Browser-based analytics and search dashboard for Elasticsearch
    - A flexible analytics and visualization platform
    - Provides data in the form of charts, graphs, counts, maps, and so on, in real time
## Beats
- Beats is the platform for single-purpose data shippers. They install as lightweight agents and send data from hundreds or thousands of machines to Logstash or Elasticsearch.
- Beats are:
    - Lightweight shippers for Elasticsearch and Logstash
    - Capture all sorts of operational data, like logs or network packet data
    - They can send logs to either Elasticsearch or Logstash
## ElastAlert
- ElastAlert is a Python tool which also bundles with the different types of integrations to support with alerting and notifications. 
- Some of them include Command, Email, JIRA, OpsGenie, AWS SNS, HipChat, Slack, Telegram, and so on. 
- It also provides a modular approach to creating our own integrations.

## Why should we use Elastic Stack for security monitoring and alerting?
- The Elastic Stack solves most of the problems that we have discussed before, such as:
    - Ability to store large amounts of data
    - Ability to understand and read a variety of log formats
    - Ability to ship the log information from a variety of devices in near real time to one central location
    - A visualization dashboard for log analysis
## Prerequisites for setting up Elastic Stack
```YAML
- name: install python 2
  raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)

- name: accepting oracle java license agreement
  debconf:
    name: 'oracle-java8-installer'
    question: 'shared/accepted-oracle-license-v1-1'
    value: 'true'
    vtype: 'select'

- name: adding ppa repo for oracle java by webupd8team
  apt_repository:
    repo: 'ppa:webupd8team/java'
    state: present
    update_cache: yes

- name: installing java nginx apache2-utils and git
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - python-software-properties
    - oracle-java8-installer
    - nginx
    - apache2-utils
    - python-pip
    - python-passlib
```
## Setting up the Elastic Stack
- The stack is a combination of:
    - The Elasticsearch service
    - The Logstash service
    - The Kibana service
    - The Beats service on all the devices 
- We are going to set up Elasticsearch, Logstash, and Kibana on a single machine.
- This is the main log collection machine:
    - It requires a minimum of 4 GB RAM, as we are using a single machine to serve three services (Elasticsearch, Logstash, and Kibana)
    - It requires a minimum of 20 GB disk space, and, based on your log size, you can add the disk space
## Installing Elasticsearch
- Install Elasticsearch from the repository with gpg key and add it to the startup programs
```YAML
- name: adding elastic gpg key for elasticsearch
  apt_key:
    url: "https://artifacts.elastic.co/GPG-KEY-elasticsearch"
    state: present

- name: adding the elastic repository
  apt_repository:
    repo: "deb https://artifacts.elastic.co/packages/5.x/apt stable main"
    state: present

- name: installing elasticsearch
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - elasticsearch

- name: adding elasticsearch to the startup programs
  service:
    name: elasticsearch
    enabled: yes
  
  notify:
    - start elasticsearch
```
- Configure the Elasticsearch cluster with the required settings.
- Also, set up the JVM options for the Elasticsearch cluster. 
- Also, create a backup directory for Elasticsearch cluster backups and snapshots
```YAML
- name: creating elasticsearch backup repo directory at {{ elasticsearch_backups_repo_path }}
  file:
    path: "{{ elasticsearch_backups_repo_path }}"
    state: directory
    mode: 0755
    owner: elasticsearch
    group: elasticsearch

- name: configuring elasticsearch.yml file
  template:
    src: "{{ item.src }}"
    dest: /etc/elasticsearch/"{{ item.dst }}"

  with_items:
    - { src: 'elasticsearch.yml.j2', dst: 'elasticsearch.yml' }
    - { src: 'jvm.options.j2', dst: 'jvm.options' }

  notify:
    - restart elasticsearch
```
- The notify part will trigger the restart elasticsearch handler and the handler file will look as follows.
```YAML
- name: start elasticsearch
  service:
    name: elasticsearch
    state: started

- name: restart elasticsearch
  service:
    name: elasticsearch
    state: restarted
```
## Installing Logstash
- Install Logstash from the repository with gpg key and add it to the startup programs
```YAML
- name: adding elastic gpg key for logstash
  apt_key:
    url: "https://artifacts.elastic.co/GPG-KEY-elasticsearch"
    state: present

- name: adding the elastic repository
  apt_repository:
    repo: "deb https://artifacts.elastic.co/packages/5.x/apt stable main"
    state: present

- name: installing logstash
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - logstash

- name: adding logstash to the startup programs
  service:
    name: logstash
    enabled: yes

  notify:
    - start logstash
```
- Configure the Logstash service with input, output, and filter settings. 
- This enables receiving logs, processing logs, and sending logs to the Elasticsearch cluster
```YAML
- name: logstash configuration files
  template:
    src: "{{ item.src }}"
    dest: /etc/logstash/conf.d/"{{ item.dst }}"
  
  with_items:
    - { src: '02-beats-input.conf.j2', dst: '02-beats-input.conf' }
    - { src: '10-sshlog-filter.conf.j2', dst: '10-sshlog-filter.conf' }
    - { src: '11-weblog-filter.conf.j2', dst: '11-weblog-filter.conf' }
    - { src: '30-elasticsearch-output.conf.j2', dst: '10-elasticsearch-output.conf' }

  notify:
    - restart logstash
```
## Logstash configuration
- To receive logs from different systems, we use the Beats service from Elastic. 
- The following configuration is to receive logs from different servers to the Logstash server. 
- Logstash runs on port 5044 and we can use SSL certificates to ensure logs are transferred via an encrypted channel.
```YAML
# 02-beats-input.conf.j2
input {
    beats {
        port => 5044
        ssl => true
        ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
        ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
    }
}
```
- The following configuration is to parse the system SSH service logs (auth.log) using grok filters. 
- It also applies filters like geoip, while providing additional information like country, location, longitude, latitude, and so on.
```YAML
#10-sshlog-filter.conf.j2
filter {
    if [type] == "sshlog" {
        grok {
            match => [ "message", "%{SYSLOGTIMESTAMP:syslog_date} %{SYSLOGHOST:syslog_host} %{DATA:syslog_program}(?:\[%{POSINT}\])?: %{WORD:login} password for %{USERNAME:username} from %{IP:ip} %{GREEDYDATA}",
            "message", "%{SYSLOGTIMESTAMP:syslog_date} %{SYSLOGHOST:syslog_host} %{DATA:syslog_program}(?:\[%{POSINT}\])?: message repeated 2 times: \[ %{WORD:login} password for %{USERNAME:username} from %{IP:ip} %{GREEDYDATA}",
            "message", "%{SYSLOGTIMESTAMP:syslog_date} %{SYSLOGHOST:syslog_host} %{DATA:syslog_program}(?:\[%{POSINT}\])?: %{WORD:login} password for invalid user %{USERNAME:username} from %{IP:ip} %{GREEDYDATA}",
            "message", "%{SYSLOGTIMESTAMP:syslog_date} %{SYSLOGHOST:syslog_host} %{DATA:syslog_program}(?:\[%{POSINT}\])?: %{WORD:login} %{WORD:auth_method} for %{USERNAME:username} from %{IP:ip} %{GREEDYDATA}" ]
        }
        
        date {
            match => [ "timestamp", "dd/MMM/YYYY:HH:mm:ss Z" ]
            locale => en
        }
        
        geoip {
            source => "ip"
        }
    }
}
```
- The following configuration is to parse web server logs (nginx, apache2).
- We will also apply filters for geoip and useragent. 
- The useragent filter allows us to get information about the agent, OS type, version information, and so on.
```YAML
#11-weblog-filter.conf.j2
filter {
    if [type] == "weblog" {
        grok {
        match => { "message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}' }
        }

        date {
        match => [ "timestamp", "dd/MMM/YYYY:HH:mm:ss Z" ]
        locale => en
        }

        geoip {
            source => "clientip"
        }
        
        useragent {
            source => "agent"
            target => "useragent"
        }
    }
}
```
- The following configuration will send the log output into the Elasticsearch cluster with daily index formats.
```YAML
#30-elasticsearch-output.conf.j2
output {
    elasticsearch {
        hosts => ["localhost:9200"]
        manage_template => false
        index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
        document_type => "%{[@metadata][type]}"
    }
}
```
## Installing Kibana
- By default we are not making any changes in Kibana, as it works out of the box with Elasticsearch.
```YAML
- name: adding elastic gpg key for kibana
  apt_key:
    url: "https://artifacts.elastic.co/GPG-KEY-elasticsearch"
    state: present

- name: adding the elastic repository
  apt_repository:
    repo: "deb https://artifacts.elastic.co/packages/5.x/apt stable main"
    state: present

- name: installing kibana
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - kibana

- name: adding kibana to the startup programs
  service:
    name: kibana
    enabled: yes

  notify:
    - start kibana
```
- By default Kibana doesn't have any authentication, X-Pack is the commercial plug-in by Elastic for RBAC (role-based access control) with security. Also, some open source options include https://readonlyrest.com/ and Search Guard (https://floragunn.com) to interact with Elasticsearch. 
- Using TLS/SSL and custom authentication and aauthorization is highly recommended. 
- Some of the open source options includes Oauth2 Proxy (https://github.com/bitly/oauth2_proxy) and Auth0, and so on.
## Setting up nginx reverse proxy
- The following configuration is to enable basic authentication for Kibana using nginx reverse proxy.
```YAML
server {
    listen 80;
    server_name localhost;
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;
    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
- Setting up and configuring the nginx service looks as follows.
```YAML
#command: htpasswd -c /etc/nginx/htpasswd.users
- name: htpasswd generation
  htpasswd:
    path: "/etc/nginx/htpasswd.users"
    name: "{{ basic_auth_username }}"
    password: "{{ basic_auth_password }}"
    owner: root
    group: root
    mode: 0644

- name: nginx virtualhost configuration
  template:
    src: "templates/nginxdefault.j2"
    dest: "/etc/nginx/sites-available/default"

  notify:
    - restart nginx
```
## Installing Beats to send logs to Elastic Stack
- We are going to install Filebeat to send SSH and web server logs to the Elastic Stack:
```YAML
- name: adding elastic gpg key for filebeat
  apt_key:
    url: "https://artifacts.elastic.co/GPG-KEY-elasticsearch"
    state: present

- name: adding the elastic repository
  apt_repository:
    repo: "deb https://artifacts.elastic.co/packages/5.x/apt stable main"
    state: present

- name: installing filebeat
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - apt-transport-https
    - filebeat

- name: adding filebeat to the startup programs
  service:
    name: filebeat
    enabled: yes

  notify:
    - start filebeat
```
- Configure the Filebeat to send both SSH and web server logs to Elastic Stack, to process and index in near real-time.
```YAML
filebeat:
  prospectors:
    -
      paths:
        - /var/log/auth.log
        # - /var/log/syslog
        # - /var/log/*.log
      document_type: sshlog
    -
      paths:
        - /var/log/nginx/access.log
      document_type: weblog

  registry_file: /var/lib/filebeat/registry

output:
 logstash:
   hosts: ["{{ logstash_server_ip }}:5044"]
   bulk_max_size: 1024
   ssl:
    certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]

logging:
 files:
   rotateeverybytes: 10485760 # = 10MB
```
## ElastAlert for alerting
- First, we need to install the prerequisites for setting up ElastAlert. 
```YAML
- name: installing pre requisuites for elastalert
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - python-pip
    - python-dev
    - libffi-dev
    - libssl-dev
    - python-setuptools
    - build-essential

- name: installing elastalert
  pip:
    name: elastalert

- name: creating elastalert directories
  file: 
    path: "{{ item }}"
    state: directory
    mode: 0755

  with_items:
    - /opt/elastalert/rules
    - /opt/elastalert/config

- name: creating elastalert configuration
  template:
    src: "{{ item.src }}"
    dest: "{{ item.dst }}"

  with_items:
    - { src: 'elastalert-config.j2', dst: '/opt/elastalert/config/config.yml' }
    - { src: 'elastalert-service.j2', dst: '/lib/systemd/system/elastalert.service' }
    - { src: 'elastalert-sshrule.j2', dst: '/opt/elastalert/rules/ssh-bruteforce.yml' }

- name: enable elastalert service
  service:
    name: elastalert
    state: started
    enabled: yes
```
- Creating a simple startup script so that ElastAlert will be used as a system service.
```BASH
[Unit]
Description=elastalert
After=multi-user.target

[Service]
Type=simple
WorkingDirectory=/opt/elastalert
ExecStart=/usr/local/bin/elastalert --config /opt/elastalert/config/config.yml

[Install]
WantedBy=multi-user.target
```
## Configuring the Let's Encrypt service
```YAML
- name: adding certbot ppa
  apt_repository:
    repo: "ppa:certbot/certbot"

- name: install certbot
  apt:
    name: "{{ item }}"
    update_cache: yes
    state: present

  with_items:
    - python-certbot-nginx

- name: check if we have generated a cert already
  stat:
    path: "/etc/letsencrypt/live/{{ website_domain_name }}/fullchain.pem"
    register: cert_stats

- name: run certbot to generate the certificates
  shell: "certbot certonly --standalone -d {{ website_domain_name }} --email {{ service_admin_email }} --non-interactive --agree-tos"
  when: cert_stats.stat.exists == False

- name: configuring site files
  template:
    src: website.conf
    dest: "/etc/nginx/sites-available/{{ website_domain_name }}"

- name: restart nginx
  service:
    name: nginx
    state: restarted
```
## ElastAlert rule configuration
- Assuming that you already have Elastic Stack installed and logging SSH logs, use the following ElastAlert rule to trigger SSH attack IP blacklisting.
```YAML
es_host: localhost
es_port: 9200
name: "SSH Bruteforce attack alert"
type: frequency
index: filebeat-*
num_events: 20
timeframe:
  minutes: 1
# For more info: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl.html

filter:
- query:
    query_string:
      query: '_type:sshlog AND login:failed AND (username: "ubuntu" OR username: "root")'

alert:
  - slack:
      slack_webhook_url: "https://hooks.slack.com/services/xxxxx"
      slack_username_override: "attack-bot"
      slack_emoji_override: "robot_face"
  - command: ["/usr/bin/curl", "https://xxxxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/zzzzzzzzzzzzzz/ip/inframonitor/%(ip)s"]

realert:
  minutes: 0
```
- For more references, visit https://elastalert.readthedocs.io/en/latest/running_elastalert.html.
# Serverless Automated Defense
- If we can get a notification for an attack, we can set up and do the following:
    - Call an AWS Lambda function
    - Send the attacker's IP address information to this AWS Lambda function endpoint
    - Use the code deployed in the Lambda function to call the VPC network access list API and block the attacker's IP address
- To ensure that we don't fill up the ACLs with attacker IPs, we can combine this approach with AWS DynamoDB to store this information for a short duration and remove it from the block list.
- As soon as an attack is detected, the alerter sends the IP to the blacklist lambda endpoint via an HTTPS request. 
- The IP is blocked using the network ACL and the record of it is maintained in DynamoDB. 
- If the IP is currently blocked already, then the expiry time for the rule will be extended in the DynamoDB.
- An expiry handler function is periodically triggered, which removes expired rules from DynamoDB and ACL accordingly.
## Setup
- The setup involves the following steps:
    - Obtain IAM credentials
    - Create a table in DynamoDB
    - Configure the lambda function based on requirement
    - Deploy code to AWS Lambda
    - Configure Cloudwatch to periodic invocation
- The entire setup is automated, except for obtaining the IAM credentials and configuring the function based on requirements.
## Configuration
- The following parameters are configurable before deployment:
    - region: AWS region to deploy in. This needs to be the same as the region where the VPC network resides.
    - accessToken: The accessToken that will be used to authenticate the requests to the blacklist endpoint.
    - aclLimit: The maximum number of rules an ACL can handle. The maximum limit in AWS is 20 by default.
    - ruleStartId: The starting ID for rules in the ACL.
    - aclID: The ACL ID of the network where the rules will be applied.
    - tableName: The unique table name in DynamoDB, created for each VPC to be defended.
    - ruleValidity: The duration for which a rule is valid, after which the IP will be unblocked.
```JS
// Configure the following in the config.js file
module.exports = {
    region: "us-east-1",                                        // AWS Region to deploy in
    accessToken: "YOUR_R4NDOM_S3CR3T_ACCESS_TOKEN_GOES_HERE",   // Accesstoken to make requests to blacklist
    aclLimit: 20,                                               // Maximum number of acl rules
    ruleStartId: 10,                                            // Starting id for acl entries
    aclId: "YOUR_ACL_ID",                                       // AclId that you want to be managed
    tableName: "blacklist_ip",                                  // DynamoDB table that will be created
    ruleValidity: 5                                             // Validity of Blacklist rule in minutes 
}
```
- Make sure to modify at least the aclId, accessToken, and region based on your setup. 
- To modify the lambda deployment configuration use the serverless.yml file
```YAML
...

functions:
  blacklist:
    handler: handler.blacklistip
    events:
     - http:
         path: blacklistip
         method: get

  handleexpiry:
    handler: handler.handleexpiry
    events:
     - schedule: rate(1 minute)

...
```
- For example, the rate at which the expiry function is triggered and the endpoint URL for the blacklist function can be modified using the YML file. But the defaults are already optimal.
```YAML
# The playbook looks as follows:
- name: installing node run time and npm
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes

  with_items:
    - nodejs
    - npm

- name: installing serverless package
  npm:
    name: "{{ item }}"
    global: yes
    state: present

  with_items:
    - serverless
    - aws-sdk

- name: copy the setup files
  template:
    src: "{{ item.src }}"
    dest: "{{ item.dst }}"

  with_items:
    - { src: 'config.js.j2', dst: '/opt/serverless/config.js' }
    - { src: 'handler.js.j2', dst: '/opt/serverless/handler.js' }
    - { src: 'iamRoleStatements.json.j2', dst: '/opt/serverless/iamRoleStatements.json' }
    - { src: 'initDb.js.j2', dst: '/opt/serverless/initDb.js' }
    - { src: 'serverless.yml.j2', dst: '/opt/serverless/serverless.yml' }
    - { src: 'aws-credentials.j2', dst: '~/.aws/credentials' }

- name: create dynamo db table
  command: node initDb.js
  args:
    chdir: /opt/serverless/

- name: deploy the serverless
  command: serverless deploy
  args:
    chdir: /opt/serverless/
```
- The current setup for AWS Lambda is to block the IP address against network ACL. This can be reused with other API endpoints, like a firewall dynamic block list and other security devices.
- The blacklist endpoint is responsible for blocking an IP address.
- The URL looks like the following: https://lambda_url/blacklistipaccessToken=ACCESS_TOKEN&ip=IP_ADDRESS
- The query parameters are as follows:
    - IP_ADDRESS: This is the IP address to be blocked
    - ACCESS_TOKEN: The accessToken to authenticate the request
## Automated defense lambda in action
- When the ElastAlert detects an SSH brute force attack, it will trigger a request to lambda endpoint by providing the attacker's IP address. Then our automated defense platform will trigger a network ACL blocklist rule. 
- This can be configurable to say for how much time it should be blocked.