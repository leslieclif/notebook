# Security Hardening for Applications and Networks
- Security hardening is the most obvious task for any security-conscious endeavor. 
- By doing the effort of securing systems, applications, and networks, one can achieve multiple security goals given as follows:
    - Ensuring that applications and networks are not compromised (sometimes)
    - Making it difficult for compromises to stay hidden for long
    - Securing by default ensures that compromises in one part of the network don't propagate further and more
- We will build playbooks that will allow us to do the following things:
    - Secure our master images so that as soon as the applications and systems are part of the network, they offer decent security
    - Execute audit processes so that we can verify and measure periodically if the applications, systems, and networks are in line with the security policies that are required by the organization
    - Security hardening with benchmarks such as Center for Internet Security (CIS), Security Technical Implementation Guides (STIG), and National Institute of Standards and Technology (NIST)
    - Automating security audit checks for networking devices using Ansible
    - Automating security audit checks for applications using Ansible
    - Automated patching approaches using Ansible
# Security hardening with benchmarks such as CIS, STIGs, and NIST
- Benchmarks provide a great way for anyone to gain assurance of their individual security efforts.
- Hardening for security mostly boils down to do the following: 
    - Agreeing on what is the minimal set of configuration that qualifies as secure configuration. This is usually defined as a hardening benchmark or framework.
    - Making changes to all the aspects of the system that are touched by such configuration.
    - Measuring periodically if the application and system are still in line with the configuration or if there is any deviation.
    - If any deviation is found, take corrective action to fix that. 
    - If no deviation is found, log that.
    - Since software is always getting upgraded, staying on top of the latest configuration guidelines and benchmarks is most important.
# Operating system hardening for baseline using an Ansible playbook
- We will see how we can use existing playbooks from the community (Ansible Galaxy).
- The following playbook provides multiple security configurations, standards, and ways to protect operating system against different attacks and security vulnerabilities.
- Some of the tasks it will perform include the following:
    - Configures package management, for example, allows only signed packages
    - Remove packages with known issues
    - Configures pam and pam_limits modules
    - Shadow password suite configuration
    - Configures system path permissions
    - Disable core dumps via soft limits
    - Restrict root logins to system console
    - Set SUIDs
    - Configures kernel parameters via sysctl
- Downloading and executing Ansible playbooks from galaxy is as simple as follows:
```BASH
ansible-galaxy install dev-sec.os-hardening
```
```YAML
- hosts: localhost
  become: yes
  roles:
    - dev-sec.os-hardening
```
- The preceding playbook will detect the operating system and perform hardening steps based on the different guidelines. This can be configured as required by updating the default variables values. Refer to https://github.com/dev-sec/ansible-os-hardening for more details about the playbook.
# STIGs Ansible role for automated security hardening for Linux hosts
- OpenStack has an awesome project named [ansible-hardening](https://github.com/openstack/ansible-hardening), which applies the security configuration changes as per the STIGs standards.
- It performs security hardening for the following domains:
    - accounts: User account security controls
    - aide: Advanced Intrusion Detection Environment
    - auditd: Audit daemon
    - auth: Authentication
    - file_perms: Filesystem permissions
    - graphical: Graphical login security controls
    - kernel: Kernel parameters
    - lsm: Linux Security Modules
    - misc: Miscellaneous security controls
    - packages: Package managers
    - sshd: SSH daemon
- Download the role from the GitHub repository itself using ansible-galaxy as follows:  
```BASH
ansible-galaxy install git+https://github.com/openstack/ansible-hardening
```
```YAML
- name: STIGs ansible-hardening for automated security hardening
  hosts: servers
  become: yes
  remote_user: "{{ remote_user_name }}"
  vars:
    remote_user_name: vagrant
    security_ntp_servers:
      - time.nist.gov
      - time.google.com

  roles:
    - ansible-hardening
```
# Continuous security scans and reports for OpenSCAP using Ansible Tower
- OpenSCAP is a set of security tools, policies, and standards to perform security compliance checks against the systems by following SCAP. SCAP is the U.S. standard maintained by NIST.
- OpenSCAP follows these steps to perform scanning on your system:
    - Install SCAP Workbench or OpenSCAP Base (for more information, visit https://www.open-scap.org)
    - Choose a policy
    - Adjust your settings
    - Evaluate the system 
- Check playbook reference at https://medium.com/@jackprice/ansible-openscap-for-compliance-automation-14200fe70663.
```YAML
- hosts: all
  become: yes
  vars:
    oscap_profile: xccdf_org.ssgproject.content_profile_pci-dss
    oscap_policy: ssg-rhel7-ds

  tasks:
  - name: install openscap scanner
    package:
      name: "{{ item }}"
      state: latest
    with_items:
    - openscap-scanner
    - scap-security-guide

  - block:
    - name: run openscap
      command: >
        oscap xccdf eval
        --profile {{ oscap_profile }}
        --results-arf /tmp/oscap-arf.xml
        --report /tmp/oscap-report.html
        --fetch-remote-resources
        /usr/share/xml/scap/ssg/content/{{ oscap_policy }}.xml

    always:
    - name: download report
      fetch:
        src: /tmp/oscap-report.html
        dest: ./{{ inventory_hostname }}.html
        flat: yes
```
- We can use this playbook to perform continuously automated checks using Ansible Tower
    - First, we need to create a directory in Ansible Tower server in order to store this playbook with the awx user permission to add the custom playbook.
    - Create a new project in Ansible Tower to perform the OpenSCAP setup and scan against the checks.
    - Then, we have to create a new job to execute the playbook. Here, we can include the list of hosts, credentials for login, and other details required to perform the execution.
    - This audit can be scheduled to perform frequently. 
    - We can also launch this job on demand when required. 
    - The output of the playbook will generate the OpenSCAP report, and it will be fetched to Ansible Tower. 
    - We can access this playbook at the /tmp/ location. Also, we can send this report to the other centralized reporting server if required.
    - We can also set up notifications based on playbook execution results. By doing this, we can send this notifications to respective channels, such as email, slack, and message.
# CIS Benchmarks
- CIS has benchmarks for different type OS, software, and services. The following are some high-level categories:
    - Desktops and web browsers
    - Mobile devices
    - Network devices
    - Security metrics
    - Servers – operating systems
    - Servers – other
    - Virtualization platforms, cloud, and other
- 
## Ubuntu CIS Benchmarks (server level)
- CIS Benchmarks Ubuntu provides prescriptive guidance to establish a secure configuration posture for Ubuntu Linux systems running on x86 and x64 platforms. 
- This benchmark is intended for system and application administrators, security specialists, auditors, help desk, and platform deployment personnel who plan to develop, deploy, assess, or secure solutions that incorporate Linux platform.
- Here are the high-level six domains that are part of CIS Ubuntu 16.04 LTS benchmarks:
    - Initial setup:
        - Filesystem configuration
        - Configure software updates
        - Filesystem integrity checking
        - Secure boot settings
        - Additional process hardening 
        - Mandatory access control
        - Warning banners
    - Services:
        - Inted Services
        - Special purpose services
        - Service clients
    - Network configuration:
        - Network parameters (host only)
        - Network parameters (host and router)
        - IPv6
        - TCP wrappers
        - Uncommon network protocols
    - Logging and auditing:
        - Configure system accounting (auditd)
        - Configure logging
    - Access, authentication, and authorization:
        - Configure cron
        - SSH server configuration
        - Configure PAM
        - User accounts and environment
    - System maintenance:
        - System file permissions
        - User and group settings
```BASH
# Playbooks
git clone https://github.com/oguya/cis-ubuntu-14-ansible.git
cd cis-ubuntu-14-ansible
```
- Then, update the variables and inventory and execute the playbook using the following command. 
- The variables are not required mostly, as this performs against different CIS checks unless, if we wanted to customize the benchmarks as per the organization.
```BASH
ansible-playbook -i inventory cis.yml
```
- The preceding playbook will execute the CIS security benchmark against an Ubuntu server and performs all the checks listed in the CIS guidelines.
## AWS benchmarks (cloud provider level)
- AWS CIS Benchmarks provides prescriptive guidance to configure security options for a subset of AWS with an emphasis on foundational, testable, and architecture agnostic settings. 
- Here are the high-level domains, which are part of AWS CIS Benchmarks:
    - Identity and access management
    - Logging
    - Monitoring
    - Networking
    - Extra 
- Currently, there is a tool named prowler (https://github.com/Alfresco/prowler) based on AWS-CLI commands for AWS account security assessment and hardening.
- Before running the playbook, we have to provide AWS API keys to perform security audit. 
- This can be created using IAM role in AWS service. If you have an already existing account with required privileges, these steps can be skipped.
- Create a new user in your AWS account with programmatic access.
- Apply the SecurityAudit policy for the user from existing policies in IAM console.
- Create the new user by following the steps. Make sure that you safely save the Access key ID and Secret access key for later use.
- The following playbook assume that you already have installed python and pip in your local system.
```YAML
- name: AWS CIS Benchmarks playbook
    hosts: localhost
    become: yes
    vars:
    aws_access_key: XXXXXXXX
    aws_secret_key: XXXXXXXX

    tasks:
    - name: installing aws cli and ansi2html
        pip:
        name: "{{ item }}"

    with_items:
        - awscli
        - ansi2html

    - name: downloading and setting up prowler
        get_url:
        url: https://raw.githubusercontent.com/Alfresco/prowler/master/prowler
        dest: /usr/bin/prowler
        mode: 0755

    - name: running prowler full scan
        shell: "prowler | ansi2html -la > ./aws-cis-report-{{ ansible_date_time.epoch }}.html"
        environment:
        AWS_ACCESS_KEY_ID: "{{ aws_access_key }}"
        AWS_SECRET_ACCESS_KEY: "{{ aws_secret_key }}"

    - name: AWS CIS Benchmarks report downloaded
        debug:
        msg: "Report can be found at ./aws-cis-report-{{ ansible_date_time.epoch }}.html"
```
- The playbook will trigger the setup and security audit scan for AWS CIS Benchmarks using the prowler tool.
- Prowler-generated HTML report can be downloaded in different formats as required and also scanning checks can be configured as required.
- More reference about the tool can be found at https://github.com/Alfresco/prowler.
# Automating security audit checks for networking devices using Ansible
- We can use this to do security audit checks for networking devices.
## Nmap scanning and NSE
- Network Mapper (Nmap) is a free open source software to perform network discovery, scanning, audit, and many others. It has a various amount of features such as OS detection, system fingerprinting, firewall detection, and many other features. 
- Nmap Scripting Engine (Nmap NSE) provides advanced capabilities like scanning for particular vulnerabilities and attacks. 
- We can also write and extend Nmap using our own custom script. 
- Nmap is a **swiss army knife** for pen testers (security testers) and network security teams. 
```YAML
- name: Basic NMAP Scan Playbook
  hosts: localhost
  gather_facts: false
  vars:
    top_ports: 1000
    network_hosts:
      - 192.168.1.1
      - scanme.nmap.org
      - 127.0.0.1
      - 192.168.11.0/24

  tasks:
    - name: check if nmap installed and install
      apt:
        name: nmap
        update_cache: yes
        state: present
      become: yes

    - name: top ports scan
      shell: "nmap --top-ports {{ top_ports }} -Pn -oA nmap-scan-%Y-%m-%d {{ network_hosts|join(' ') }}"
```
- {{ network_hosts|join(' ') }} is a Jinja2 feature named filter arguments to parse the given network_hosts by space delimited
network_hosts variable holds the list of IPs, network range (CIDR), hosts, and so on to perform scan using Nmap
- top_ports is the number that is ranging from 0 to 65535. Nmap by default picks commonly opened top ports
- -Pn specifies that scans the host if ping (ICMP) doesn't work also
- -oA gets the output in all formats, which includes gnmap (greppable  format), Nmap, and XML
## Nmap NSE scanning playbook
- This playbook will perform enumeration of directories used by popular web applications and servers using http-enum and finds options that are supported by an HTTP server using http-methods using Nmap scripts.
```YAML
- name: Advanced NMAP Scan using NSE
  hosts: localhost
  vars:
    ports:
      - 80
      - 443
    scan_host: scanme.nmap.org 

  tasks:
    - name: Running Nmap NSE scan
      shell: "nmap -Pn -p {{ ports|join(',') }} --script {{ item }} -oA nmap-{{ item }}-results-%Y-%m-%d {{ scan_host }}"

      with_items:
        - http-methods
        - http-enum
```
- The http-enum script runs additional tests against network ports where web servers are detected. 
- We can see that two folders were discovered by the script and additionally all HTTP methods that are supported got enumerated as well. 
# Automation security audit checks for applications using Ansible
- Modern applications can get pretty complex fairly quickly. 
- Having the ability to run automation to do security tasks is almost a mandatory requirement. 
- The different types of application security scanning we can do can range from the following:
    - Run CI/CD scanning against the source code (for example, RIPS and brakeman).
    - Dependency checking scanners (for example, OWASP dependency checker and snyk.io (https://snyk.io/)).
    - Once deployed then run the web application scanner (for example, Nikto, Arachni, and w3af).
    - Framework-specific security scanners (for example, WPScan and Droopscan) and many other.
## Source code analysis scanners
- This is one of the first and common way to minimize the security risk while applications going to production. 
- Source code analysis scanner also known as **Static Application Security Testing (SAST)** will help to find security issues by analyzing the source code of the application. 
- Source code analysis is kind of white box testing and looking through code. 
- This kind of testing methodology may not find 100% coverage of security vulnerabilities, and it requires manual testing as well. 
- For example, finding logical vulnerabilities requires some kind of user interactions such as dynamic functionalities.
- For example, if you are scanning PHP code, then [RIPS](http://rips-scanner.sourceforge.net/); if it's Ruby on Rails code, then it's [Brakeman](https://brakemanscanner.org/); and if it's python, then [Bandit](https://wiki.openstack.org/wiki/Security/Projects/Bandit)
## Dependency-checking scanners
- Most of the developers use third-party libraries while developing applications, and it's very common to see using open source plugins and modules inside their code.
- So dependency checks will allow us to find using components with known vulnerabilities (OWASP A9) issues in application code by scanning the libraries against the CVE and NIST vulnerability database.
- There are multiple projects out there in the market for performing these checks, and some of them includes the following:
    - OWASP Dependency-Check
    - Snyk.io (https://snyk.io/)
    - Retire.js
    - [:] SourceClear and many other
## Running web application security scanners
- This is the phase where the application went live to QA, stage, (or) Production. 
- Then, we wanted to perform security scans like an attacker (black box view). 
- At this stage, an application will have all the dynamic functionalities and server configurations applied.
- These scanner results tell us how good the server configured and any other application security issues before releasing the replica copy into the production.
- There are many tools in the market to do these jobs for you in both open source and commercial world.
    - Nikto
    - Arachni
    - w3af
    - Acunetix
## Framework-specific security scanners
- This kind of check and scanning is to perform against specific to framework, CMS, and platforms. 
- It allows to get more detailed results by validating against multiple security test cases and checks. 
    - Scanning against WordPress CMS using [WPScan](https://github.com/wpscanteam/wpscan)
    - Scanning against JavaScript libraries using [Retire.js](https://retirejs.github.io/retire.js)
    - Scanning against Drupal CMS using [Droopescan](https://github.com/droope/droopescan)
# Automated patching approaches using Ansible
- Patching and updating is a task that everyone who has to manage production systems has to deal with. 
- There are two approaches that we will look are as follows:
    - Rolling updates
    - BlueGreen deployments
## Rolling updates
- Imagine that we have five web servers behind a load balancer. 
- What we would like to do is a zero downtime upgrade of our web application. 
- We want to achieve the following: 
    - Tell the load balancer that web server node is down
    - Bring down the web server on that node
    - Copy the updated application files to that node
    - Bring up the web server on that node
- The first keyword for us to look at is serial. 
- This ensures that the execution of the playbook is done serially rather than in parallel. 
- We can choose to provide a percentage value or numeric value to serial.
- A great example for this way of doing updates is given in the following link
[Episode #47 - Zero-downtime Deployments with Ansible](https://sysadmincasts.com/episodes/47-zero-downtime-deployments-with-ansible-part-4-4)
## BlueGreen deployments
- The concept of BlueGreen is attributed to [Martin Fowler](http://martinfowler.com/bliki/BlueGreenDeployment.html).
- The idea is to consider our current live production workload as blue. Now what we want to do is upgrade the application. So a replica of blue is brought up behind the same load balancer. The replica of the infrastructure has the updated application.
- Once it is up and running, the load balancer configuration is switched from current blue to point to green. Blue keeps running in case there are any operational issues. Once we are happy with the progress, we can tear down the older host. 
### BlueGreen deployment setup playbook
- The following playbook will set up three nodes, which includes load balancer and two web server nodes. 
    - The first playbook brings up three hosts. Two web servers running nginx behind a load balancer
    - The second playbook switches what is live (blue) to green
```YAML
# inventory.yml
[proxyserver]
proxy ansible_host=192.168.100.100 ansible_user=ubuntu ansible_password=passwordgoeshere

[blue]
blueserver ansible_host=192.168.100.10 ansible_user=ubuntu ansible_password=passwordgoeshere

[green]
greenserver ansible_host=192.168.100.20 ansible_user=ubuntu ansible_password=passwordgoeshere

[webservers:children]
blue
green

[prod:children]
webservers
proxyserver
```
```YAML
# main.yml
- name: running common role
  hosts: prod
  gather_facts: false
  become: yes
  serial: 100%
  roles:
    - common

- name: running haproxy role
  hosts: proxyserver
  become: yes 
  roles:
    - haproxy

- name: running webserver role
  hosts: webservers
  become: yes 
  serial: 100% 
  roles:
    - nginx

- name: updating blue code
  hosts: blue
  become: yes 
  roles:
    - bluecode

- name: updating green code
  hosts: green
  become: yes 
  roles:
    - greencode
```
```YAML
# common role
- name: installing python if not installed
  raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)

- name: updating and installing git, curl
  apt:
    name: "{{ item }}"
    state: present
    update_cache: yes
  
  with_items:
    - git
    - curl

# Also we can include common any monitoring and security hardening tasks
```
```YAML
# haproxy role
- name: adding haproxy repo
  apt_repository:
    repo: ppa:vbernat/haproxy-1.7

- name: updating and installing haproxy
  apt:
    name: haproxy
    state: present
    update_cache: yes

- name: updating the haproxy configuration
  template:
    src: haproxy.cfg.j2
    dest: /etc/haproxy/haproxy.cfg

- name: starting the haproxy service
  service:
    name: haproxy
    state: started
    enabled: yes
```
```YAML
# haproxy.cfg.j2
global
  log /dev/log local0
  log /dev/log local1 notice
  chroot /var/lib/haproxy
  stats socket /run/haproxy/admin.sock mode 660 level admin
  stats timeout 30s
  user haproxy
  group haproxy
  daemon

  # Default SSL material locations
  ca-base /etc/ssl/certs
  crt-base /etc/ssl/private

  # Default ciphers to use on SSL-enabled listening sockets.
  # For more information, see ciphers(1SSL). This list is from:
  # https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
  # An alternative list with additional directives can be obtained from
  # https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
  ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
  ssl-default-bind-options no-sslv3

defaults
  log global
  mode http
  option httplog
  option dontlognull
        timeout connect 5000
        timeout client 50000
        timeout server 50000
  errorfile 400 /etc/haproxy/errors/400.http
  errorfile 403 /etc/haproxy/errors/403.http
  errorfile 408 /etc/haproxy/errors/408.http
  errorfile 500 /etc/haproxy/errors/500.http
  errorfile 502 /etc/haproxy/errors/502.http
  errorfile 503 /etc/haproxy/errors/503.http
  errorfile 504 /etc/haproxy/errors/504.http

frontend http_front
   bind *:80
   stats uri /haproxy?stats
   default_backend http_back

backend http_back
   balance roundrobin
   server {{ hostvars.blueserver.ansible_host }} {{ hostvars.blueserver.ansible_host }}:80 check
   #server {{ hostvars.greenserver.ansible_host }} {{ hostvars.greenserver.ansible_host }}:80 check
```
```YAML
# nginx role
- name: installing nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: starting the nginx service
  service:
    name: nginx
    state: started
    enabled: yes
```
```YAML
# Code snipet for blue
<html>
    <body bgcolor="blue">
       <h1 align="center">Welcome to Blue Deployment</h1>
    </body>
</html>

# Code snipet for green
<html>
    <body bgcolor="green">
        <h1 align="center">Welcome to Green Deployment</h1>
    </body>
</html>
```
- We want to deploy the new version of production site with green deployment.
- The playbook looks very simple as follows, it will update the configuration and reloads the haproxy service to serve the new production deployment.
```YAML
- name: Updating to GREEN deployment
  hosts: proxyserver
  become: yes 
  
  tasks:
    - name: updating proxy configuration
      template:
        src: haproxy.cfg.j2
        dest: /etc/haproxy/haproxy.cfg
    
    - name: updating the service
      service:
        name: haproxy
        state: reloaded

    - debug:
        msg: "GREEN deployment successful. Please check your server :)"
```
# Continuous Security Scanning for Docker Containers
- Docker containers are the new way developers package applications. 
- The best feature of containers is the fact that they contain the code, runtime, system libraries, and all the settings that are required for the application to work. 
- Due to the ease of use and deployment, more and more applications are getting deployed in containers for production use. 
- With so many moving parts, it becomes imperative that we have the capability to continuously scan Docker containers for security issues.
## Understanding continuous security concepts
- One of the key approaches to emerge out of DevOps is the idea of immutable infrastructure. 
- It means that every time there needs to be a **runtime change**, either in application code or configuration, the containers are built and deployed again and the existing running ones are torn down. 
- Since that allows for predictability, resilience, and simplifies deployment choices at runtime, it is no surprise that many operations teams are moving toward it. 
- With that comes the question of when these containers should be tested for security and compliance. 
- By embracing the process of continuous security scanning and monitoring, you can automate for a variety of workloads and workflows. 
## Automating vulnerability assessments of Docker containers using Ansible
- **Tool: Description**
- There are many different ways of evaluating the security of containers. 
- Docker Bench: A security shell script to perform checks based on CIS
- Clair: A tool to perform vulnerability analysis based on the CVE database
- Anchore: A tool to perform security evaluation and make runtime policy decisions
- vuls: An agent-less vulnerability scanner with CVE, OVAL database
- osquery: OS instrumentation framework for OS analytics to do HIDS-type activities
## Docker Bench for Security
- Docker Bench for Security is a shell script to perform multiple checks against the Docker container environment. 
- It will give a more detailed view of the security configuration based on CIS benchmarks. 
- This script supports most of the Unix operating systems as it was built based on the POSIX 2004 compliant.
- The following are the high-level areas of checks this script will perform:
    - Host configuration
    - Docker daemon configuration and files
    - Docker container images
    - Docker runtime
    - Docker security operations
    - Docker swarm configuration
```YAML
- name: Docker bench security playbook
  hosts: docker
  remote_user: ubuntu
  become: yes
  
  tasks:
    - name: make sure git installed
      apt:
        name: git
        state: present

    - name: download the docker bench security
      git:
        repo: https://github.com/docker/docker-bench-security.git
        dest: /opt/docker-bench-security
    
    - name: running docker-bench-security scan
      command: docker-bench-security.sh -l /tmp/output.log
      args:
        chdir: /opt/docker-bench-security/
    
    - name: downloading report locally
      fetch:
        src: /tmp/output.log
        dest: "{{ playbook_dir }}/{{ inventory_hostname }}-docker-report-{{ ansible_date_time.date }}.log"
        flat: yes

    - name: report location
      debug:
        msg: "Report can be found at {{ playbook_dir }}/{{ inventory_hostname }}-docker-report-{{ ansible_date_time.date }}.log"</mark>
```
- The output of the playbook will download and scan the containers based on the CIS benchmark and store the results in a log file
## Clair
- Clair allows us to perform static vulnerability analysis against containers by checking with the existing vulnerability database. 
- It allows us to perform vulnerability analysis checks against our Docker container images using the Clair database. 
- Setting up Clair itself is really difficult and scanning using the API with Docker images makes more difficult. 
- Here comes [clair-scanner](https://github.com/arminc/clair-scanner), it makes really simple to set up and perform scans using the REST API.
- Clair-scanner can trigger a simple scan against a container based on certain events, to check for existing vulnerabilities. 
- Furthermore, this report can be forwarded to perform the team responsible for fixes and so on.
```YAML
# It assumes that the target system has Docker and the required libraries installed
- name: Clair Scanner Server Setup
  hosts: docker
  remote_user: ubuntu
  become: yes
  
  tasks:
    - name: setting up clair-db
      docker_container:
        name: clair_db
        image: arminc/clair-db
        exposed_ports:
          - 5432

    - name: setting up clair-local-scan
      docker_container:
        name: clair
        image: arminc/clair-local-scan:v2.0.1
        ports:
          - "6060:6060"
        links:
          - "clair_db:postgres"
# Setting up clair-scanner with Docker containers using Ansible
# It will take a while to download and setup the CVE database after playbook execution.
```
- This playbook will be used to run clair-scanner to perform an analysis on the containers by making an API request to the server.
```YAML
- name: Scanning containers using clair-scanner
  hosts: docker
  remote_user: ubuntu
  become: yes
  vars:
    image_to_scan: "debian:sid"   # container to scan for vulnerabilities
    clair_server: "http://192.168.1.10:6060"    # clair server api endpoint
  
  tasks:
    - name: downloading and setting up clair-scanner binary
      get_url:
        url: https://github.com/arminc/clair-scanner/releases/download/v6/clair-scanner_linux_amd64
        dest: /usr/local/bin/clair-scanner
        mode: 0755
    
    - name: scanning {{ image_to_scan }} container for vulnerabilities
      command: clair-scanner -r /tmp/{{ image_to_scan }}-scan-report.json -c {{ clair_server }} --ip 0.0.0.0 {{ image_to_scan }}
      register: scan_output
      ignore_errors: yes
    
    - name: downloading the report locally
      fetch:
        src: /tmp/{{ image_to_scan }}-scan-report.json
        dest: {{ playbook_dir }}/{{ image_to_scan }}-scan-report.json
        flat: yes
```
## Scheduled scans using Ansible Tower for Docker security
- Continuous security processes are all about the **loop of planning, doing, measuring, and acting**
- By following standard checklists and benchmarks and using Ansible to execute them on containers, we can check for security issues and act on them. 
## Anchore – open container compliance platform 
- Anchore is one of the most popular tools and services to perform analysis, inspection, and certification of container images. 
- Anchore is an analysis and inspection platform for containers.
- It provides multiple services and platforms to set up, the most stable and powerful way is to set up the local service using Anchore Engine, which can be accessed via the REST API.
- High level operations Anchore can perform:
    - Policy evaluation operations
    - Image operations
    - Policy operations
    - Registry operations
    - Subscription operations
    - System operations
## Anchore Engine service setup
- This playbook will set up the Anchore Engine service, which contains the engine container as well as the postgres to store database information. 
- The admin_password variable is the admin user password to  access the REST API of Anchore.
```YAML
- name: anchore server setup
  hosts: anchore
  become: yes
  vars:
    db_password: changeme
    admin_password: secretpassword

  tasks:
    - name: creating volumes
      file:
        path: "{{ item }}"
        recurse: yes
        state: directory
      
      with_items:
        - /root/aevolume/db
        - /root/aevolume/config
      
    - name: copying anchore-engine configuration
      template:
        src: config.yaml.j2
        dest: /root/aevolume/config/config.yaml

    - name: starting anchore-db container
      docker_container:
        name: anchore-db
        image: postgres:9
        volumes:
          - "/root/aevolume/db/:/var/lib/postgresql/data/pgdata/"
        env:
          POSTGRES_PASSWORD: "{{ db_password }}"
          PGDATA: "/var/lib/postgresql/data/pgdata/"

    - name: starting anchore-engine container
      docker_container:
        name: anchore-engine
        image: anchore/anchore-engine
        ports:
          - 8228:8228
          - 8338:8338
        volumes:
          - "/root/aevolume/config/config.yaml:/config/config.yaml:ro"
          - "/var/run/docker.sock:/var/run/docker.sock:ro"
        links:
          - anchore-db:anchore-db
```
## Anchore CLI scanner
- Now that we have the Anchore Engine service REST API with access details, we can use this to perform the scanning of container images in any host. 
- The following steps are the Ansible Tower setup to perform continuous scanning of container images for vulnerabilities.
```YAML
- name: anchore-cli scan
  hosts: anchore
  become: yes
  vars:
    scan_image_name: "docker.io/library/ubuntu:latest"
    anchore_vars:
      ANCHORE_CLI_URL: http://localhost:8228/v1
      ANCHORE_CLI_USER: admin
      ANCHORE_CLI_PASS: secretpassword

  tasks:
    - name: installing anchore-cli
      pip:
        name: "{{ item }}"

      with_items:
        - anchorecli
        - pyyaml
    
    - name: downloading image
      docker_image: 
        name: "{{ scan_image_name }}"

    - name: adding image for analysis
      command: "anchore-cli image add {{ scan_image_name }}"
      environment: "{{anchore_vars}}"
    
    - name: wait for analysis to compelte
      command: "anchore-cli image content {{ scan_image_name }} os"
      register: analysis
      until: analysis.rc != 1
      retries: 10
      delay: 30
      ignore_errors: yes
      environment: "{{anchore_vars}}"

    - name: vulnerabilities results
      command: "anchore-cli image vuln {{ scan_image_name }} os"
      register: vuln_output
      environment: "{{anchore_vars}}"
    
    - name: "vulnerabilities in {{ scan_image_name }}"
      debug:
        msg: "{{ vuln_output.stdout_lines }}"
```
## Scheduled scans using Ansible Tower for operating systems and kernel security
- While most of the discussed tools can be used for scanning and maintaining a benchmark for security, we should think about the entire process of the incident response and threat detection workflow:
    - Preparation
    - Detection and analysis
    - Containment, eradication, and recovery
    - Post-incident activity
- Setting up all such scanners is our preparation. 
- Using the output of these scanners gives us the ability to detect and analyze. 
- Both containment and recovery are beyond the scope of such tools. 
- For the process of recovery and post-incident activity, you may want to consider playbooks that can trash the current infrastructure and recreate it as it is. 
- As part of our preparation, it may be useful to get familiar with the following terms as you will see them being used repeatedly in the world of vulnerability scanners and vulnerability management tools:
- **Term: Full form (if any): Description of the term**
- CVE: Common Vulnerabilities and Exposures: It is a list of cybersecurity vulnerability identifiers. Usage typically includes CVE IDs.
- OVAL: Open Vulnerability and Assessment Language: A language for finding out and naming vulnerabilities and configuration issues in computer systems.
- CWE: Common Weakness Enumeration: A common list of software security weaknesses.
- NVD: National Vulnerability Database: A US government vulnerability management database available for public use in XML format.
## Vuls – vulnerability scanner
- Vuls is an agent-less scanner written in golang. 
- It supports a different variety of Linux operating systems.
- It performs the complete end-to-end security system administrative tasks such as scanning for security vulnerabilities and security software updates. 
- It analyzes the system for required security vulnerabilities, performs security risk analysis based on the CVE score, sends notifications via Slack and email, and also provides a simple web report with historical data.
- The playbook has mainly two roles for setting up vuls using Docker containers.
    - vuls_containers_download
    - vuls_database_download
```YAML
- name: setting up vuls using docker containers
  hosts: vuls
  become: yes

  roles:
    - vuls_containers_download
    - vuls_database_download
```
```YAML
# Pulling the Docker containers locally using the docker_image module:
- name: pulling containers locally
  docker_image:
    name: "{{ item }}"
    pull: yes
  
  with_items:
    - vuls/go-cve-dictionary
    - vuls/goval-dictionary
    - vuls/vuls

# Then downloading the CVE and OVAL databases for the required operating systems and distributions versions
- name: fetching NVD database locally
  docker_container:
    name: "cve-{{ item }}"
    image: vuls/go-cve-dictionary
    auto_remove: yes
    interactive: yes
    state: started
    command: fetchnvd -years "{{ item }}"
    volumes:
      - "{{ vuls_data_directory }}:/vuls"
      - "{{ vuls_data_directory }}/go-cve-dictionary-log:/var/log/vuls"
  with_sequence: start=2002 end="{{ nvd_database_years }}"

- name: fetching redhat oval data
  docker_container:
    name: "redhat-oval-{{ item }}"
    image: vuls/goval-dictionary
    auto_remove: yes
    interactive: yes
    state: started
    command: fetch-redhat "{{ item }}"
    volumes:
      - "{{ vuls_data_directory }}:/vuls"
      - "{{ vuls_data_directory }}/goval-dictionary-log:/var/log/vuls"
  with_items: "{{ redhat_oval_versions }}"

- name: fetching ubuntu oval data
  docker_container:
    name: "ubuntu-oval-{{ item }}"
    image: vuls/goval-dictionary
    auto_remove: yes
    interactive: yes
    state: started
    command: "fetch-ubuntu {{ item }}"
    volumes:
      - "{{ vuls_data_directory }}:/vuls"
      - "{{ vuls_data_directory }}/goval-dictionary-log:/var/log/vuls"
  with_items: "{{ ubuntu_oval_versions }}"
```
- The global variables file looks as follows. We can add more redhat_oval_versions, such as 5. The nvd_database_years will download the CVE database up until the end of 2017:
```YAML
vuls_data_directory: "/vuls_data"
nvd_database_years: 2017
redhat_oval_versions:
  - 6
  - 7
ubuntu_oval_versions:
  - 12
  - 14
  - 16
```
- Now, it's time to perform the scanning and reporting using the vuls Docker containers. 
- The following playbook contains simple steps to perform the vuls scan against virtual machines and containers, and send the report to slack and web:
```YAML
- name: scanning and reporting using vuls
  hosts: vuls
  become: yes
  vars:
    vuls_data_directory: "/vuls_data"
    slack_web_hook_url: https://hooks.slack.com/services/XXXXXXX/XXXXXXXXXXXXXXXXXXXXX
    slack_channel: "#vuls"
    slack_emoji: ":ghost:"
    server_to_scan: 192.168.33.80
    server_username: vagrant
    server_key_file_name: 192-168-33-80

  tasks:
    - name: copying configuraiton file and ssh keys
      template:
        src: "{{ item.src }}"
        dest: "{{ item.dst }}"
        mode: 0400
      
      with_items:
         - { src: 'config.toml', dst: '/root/config.toml' }
         - { src: '192-168-33-80', dst: '/root/.ssh/192-168-33-80' } 

    - name: running config test
      docker_container:
        name: configtest
        image: vuls/vuls
        auto_remove: yes
        interactive: yes
        state: started
        command: configtest -config=/root/config.toml
        volumes:
          - "/root/.ssh:/root/.ssh:ro"
          - "{{ vuls_data_directory }}:/vuls"
          - "{{ vuls_data_directory }}/vuls-log:/var/log/vuls"
          - "/root/config.toml:/root/config.toml:ro"
    
    - name: running vuls scanner
      docker_container:
        name: vulsscan
        image: vuls/vuls
        auto_remove: yes
        interactive: yes
        state: started
        command: scan -config=/root/config.toml
        volumes:
          - "/root/.ssh:/root/.ssh:ro"
          - "{{ vuls_data_directory }}:/vuls"
          - "{{ vuls_data_directory }}/vuls-log:/var/log/vuls"
          - "/root/config.toml:/root/config.toml:ro"
          - "/etc/localtime:/etc/localtime:ro"
        env:
          TZ: "Asia/Kolkata"

    - name: sending slack report
      docker_container:
        name: vulsreport
        image: vuls/vuls
        auto_remove: yes
        interactive: yes
        state: started
        command: report -cvedb-path=/vuls/cve.sqlite3 -ovaldb-path=/vuls/oval.sqlite3 --to-slack -config=/root/config.toml
        volumes:
          - "/root/.ssh:/root/.ssh:ro"
          - "{{ vuls_data_directory }}:/vuls"
          - "{{ vuls_data_directory }}/vuls-log:/var/log/vuls"
          - "/root/config.toml:/root/config.toml:ro"
          - "/etc/localtime:/etc/localtime:ro"

    - name: vuls webui report
      docker_container:
        name: vulswebui
        image: vuls/vulsrepo
        interactive: yes
        volumes:
          - "{{ vuls_data_directory }}:/vuls"
        ports:
          - "80:5111"
```
- The following file is the configuration file for vuls to perform the scanning. This holds the configuration for slack alerting and also the server to perform scanning. This can be configured very effectively as required using vuls documentation:
```YAML
[slack]
hookURL = "{{ slack_web_hook_url}}"
channel = "{{ slack_channel }}"
iconEmoji = "{{ slack_emoji }}"

[servers]

[servers.{{ server_key_file_name }}]
host = "{{ server_to_scan }}"
user = "{{ server_username }}"
keyPath = "/root/.ssh/{{ server_key_file_name }}"
```
- We can also visit the web UI interface of the vuls server IP address to see the detailed results in tabular and portable format. This is very useful to manage large amount of servers and patches at scale.
- This can be part of the CI/CD life cycle as an infrastructure code and then we can run this as a scheduled scan using Ansible Tower or Jenkins.
## Scheduled scans for file integrity checks, host-level monitoring using Ansible for various compliance initiatives
- One of the many advantages of being able to execute commands on the host using Ansible is the ability to get internal system information, such as:
    - File hashes
    - Network connections
    - List of running processes
- It can act as a lightweight Host-Based Intrusion Detection System (HIDS). 
- While this may not eliminate the case for a purpose-built HIDS in many cases, we can execute the same kind of security tasks using a tool such as Facebook's osquery along with Ansible. 
## osquery
- osquery is an operating system instrumentation framework by Facebook and written in C++, that supports Windows, Linux, OS X (macOS), and other operating systems. 
- It provides an interface to query an operating system using an SQL like syntax. 
- By using this, we can perform low-level activities such as running processes, kernel configurations, network connections, and file integrity checks. Overall it's like a host-based intrusion detection system (HIDS) endpoint security. 
- It provides osquery as a service, system interactive shell, and so on. 
- Hence we can use this to perform centralized monitoring and security management solutions. 
- This playbook is to set up and configure the osquery agent in your Linux servers to monitor and look for vulnerabilities, file integrity monitoring, and many other compliance activities, and then log them for sending to a centralized logging monitoring system.
- The reference tutorial can be followed at [DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-monitor-your-system-security-with-osquery-on-ubuntu-16-04).
```YAML
- name: setting up osquery
  hosts: linuxservers
  become: yes

  tasks:
    - name: installing osquery
      apt:
        deb: https://pkg.osquery.io/deb/osquery_2.10.2_1.linux.amd64.deb
        update_cache: yes
    
    - name: adding osquery configuration
      template:
        src: "{{ item.src }}"
        dest: "{{ item.dst }}"
      
      with_items:
        - { src: fim.conf, dst: /usr/share/osquery/packs/fim.conf }
        - { src: osquery.conf, dst: /etc/osquery/osquery.conf }
    
    - name: starting and enabling osquery service
      service:
        name: osqueryd
        state: started
        enabled: yes
```
- The following `fim.conf` code snippet is the pack for file integrity monitoring and it monitors for file events in the /home, /etc, and /tmp directories every 300 seconds. It uses Secure Hash Algorithm (SHA) checksum to validate the changes. This can be used to find out whether attackers add their own SSH keys or audit log changes against system configuration changes for compliance and other activities.
```JSON
{
  "queries": {
    "file_events": {
      "query": "select * from file_events;",
      "removed": false,
      "interval": 300
    }
  },
  "file_paths": {
    "homes": [
      "/root/.ssh/%%",
      "/home/%/.ssh/%%"
    ],
      "etc": [
      "/etc/%%"
    ],
      "home": [
      "/home/%%"
    ],
      "tmp": [
      "/tmp/%%"
    ]
  }
}
```
- The following code snippet is the osquery service configuration. This can be modified as required to monitor and log by osquery service.
```JSON
{
  "options": {
    "config_plugin": "filesystem",
    "logger_plugin": "filesystem",
    "logger_path": "/var/log/osquery",
    "disable_logging": "false",
    "log_result_events": "true",
    "schedule_splay_percent": "10",
    "pidfile": "/var/osquery/osquery.pidfile",
    "events_expiry": "3600",
    "database_path": "/var/osquery/osquery.db",
    "verbose": "false",
    "worker_threads": "2",
    "enable_monitor": "true",
    "disable_events": "false",
    "disable_audit": "false",
    "audit_allow_config": "true",
    "host_identifier": "hostname",
    "enable_syslog": "true",
    "audit_allow_sockets": "true",
    "schedule_default_interval": "3600" 
  },
  "schedule": {
    "crontab": {
      "query": "SELECT * FROM crontab;",
      "interval": 300
    },
    "system_profile": {
      "query": "SELECT * FROM osquery_schedule;"
    }, 
    "system_info": {
      "query": "SELECT hostname, cpu_brand, physical_memory FROM system_info;",
      "interval": 3600
    }
  },
  "decorators": {
    "load": [
      "SELECT uuid AS host_uuid FROM system_info;",
      "SELECT user AS username FROM logged_in_users ORDER BY time DESC LIMIT 1;"
    ]
  },
  "packs": {
     "fim": "/usr/share/osquery/packs/fim.conf",
     "osquery-monitoring": "/usr/share/osquery/packs/osquery-monitoring.conf",
     "incident-response": "/usr/share/osquery/packs/incident-response.conf",
     "it-compliance": "/usr/share/osquery/packs/it-compliance.conf",
     "vuln-management": "/usr/share/osquery/packs/vuln-management.conf"
  }
}
```
- The goal is not just setting up osquery, we can use the logs to build a centralized real-time monitoring system using our Elastic stack. 
- We can use the Filebeat agent to forward these logs to our Elastic stack and we can view them and build a centralized dashboard for alerting and monitoring.
- This idea can be extended for building some automated defences by taking actions against attacks by using automated Ansible playbooks for known actions.
- The world is moving toward containers and this kind of monitoring gives us a look at low-level things such as kernel security checks, and file integrity checks on host level. 
- When attackers try to bypass containers and get access to hosts to escalate privileges, we can detect and defend them using this kind of setup.
## Summary 
- Containers are rapidly changing the world of developers and operations teams. 
- The rate of change is accelerating, and in this new world, security automation gets to play a front and center role. 
- By leveraging our knowledge of using Ansible for scripting play-by-play commands along with excellent tools such as **Anchore and osquery**, we can measure, analyze, and benchmark our containers for security. 
- This allows us to build end-to-end automatic processes of securing, scanning and remediating containers. 

# Automating Lab Setups for Forensics Collection and Malware Analysis
- Malware is one of the biggest challenges faced by the security community. 
- It impacts everyone who gets to interact with information systems. 
- While there is a massive effort required in keeping computers safe from malware for operational systems, a big chunk of work in malware defenses is about understanding where they come from and what they are capable of.
-  Another important aspect of malware analysis is the ability to collaborate and share threats using the Malware Information Sharing Platform (MISP). 
- One of the initial phases of malware analysis is identification and classification. 
- The most popular source is using VirusTotal to scan and get the results of the malware samples, domain information, and so on. 
- It has a very rich API and a lot of people have written custom apps that leverage the API to perform the automated scans using the API key for identifying the malware type.  
- It generally checks using more than 60 antivirus scanners and tools and provides detailed information.
## VirusTotal  API tool set up
- The following playbook will set up the [VirusTotal API tool](https://github.com/doomedraven/VirusTotalApi)
```YAML
- name: setting up VirusTotal
  hosts: malware
  remote_user: ubuntu
  become: yes
  
  tasks:
    - name: installing pip
      apt:
        name: "{{ item }}"
        
      with_items:
        - python-pip
        - unzip
    
    - name: checking if vt already exists
      stat:
        path: /usr/local/bin/vt
      register: vt_status

    - name: downloading VirusTotal api tool repo
      unarchive:
        src: "https://github.com/doomedraven/VirusTotalApi/archive/master.zip"
        dest: /tmp/
        remote_src: yes
      when: vt_status.stat.exists == False 

    - name: installing the dependencies
      pip:
        requirements: /tmp/VirusTotalApi-master/requirements.txt
      when: vt_status.stat.exists == False 
    
    - name: installing vt
      command: python /tmp/VirusTotalApi-master/setup.py install
      when: vt_status.stat.exists == False
```
- The playbook execution will download the repository and set up the VirusTotal API tool.
- The following playbook will find and copy the local malware samples to a remote system and scan them recursively and return the results. 
- Once the scan has been completed, it will remove the samples from the remote system.
```YAML
- name: scanning file in VirusTotal
  hosts: malware
  remote_user: ubuntu
  vars:
    vt_api_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #use Ansible-vault
    vt_api_type: public # public/private
    vt_intelligence_access: False # True/False
    files_in_local_system: /tmp/samples/
    files_in_remote_system: /tmp/sample-file/

  tasks:
    - name: creating samples directory
      file:
        path: "{{ files_in_remote_system }}"
        state: directory

    - name: copying file to remote system
      copy:
        src: "{{ files_in_local_system }}"
        dest: "{{ files_in_remote_system }}"
        directory_mode: yes
    
    - name: copying configuration
      template:
        src: config.j2
        dest: "{{ files_in_remote_system }}/.vtapi"

    - name: running VirusTotal scan
      command: "vt -fr {{ files_in_remote_system }}"
      args:
        chdir: "{{ files_in_remote_system }}"
      register: vt_scan
    
    - name: removing the samples
      file:
        path: "{{ files_in_remote_system }}"
        state: absent

    - name: VirusTotal scan results
      debug:
        msg: "{{ vt_scan.stdout_lines }}"
```
## Creating Ansible playbooks for collection and storage with secure backup of forensic artifacts
- Ansible is an apt replacement for all kinds of bash scripts. Typically, for most activities that require analysis, we follow a set pattern:
    - Collect logs from running processes into files with a path we already know
    - Copy the content from these log files periodically to a secure storage locally or accessible remotely over SSH or a network file share
    - Once copied successfully, rotate the logs
- Since there is a bit of network activity involved, our bash scripts are usually written to be fault tolerant with regard to network connections and become complex very soon. 
- Ansible playbooks can be used to do all of that while being simple to read for everyone. 
## Collecting log artifacts for incident response
- The key phase in incident response is log analysis. 
- This playbook will collect the logs from all the hosts and store it locally.
- This allows responders to perform the further analysis.
```YAML
# Reference https://www.Ansible.com/security-automation-with-Ansible

- name: Gather log files
  hosts: servers
  become: yes

  tasks:
    - name: List files to grab
      find:
        paths:
          - /var/log
        patterns:
          - '*.log*'
        recurse: yes
      register: log_files

    - name: Grab files
      fetch:
        src: "{{ item.path }}"
        dest: "/tmp/LOGS_{{ Ansible_fqdn }}/"
      with_items: "{{ log_files.files }}"
```
- This playbook execution will collect a list of logs in specified locations in remote hosts using Ansible modules and store them in the local system.
## Secure backups for data collection
- When collecting multiple sets of data from servers, it's important to store them securely with encrypted backups. 
- This can be achieved by backing up the data to storage services such as S3.
This Ansible playbook allows us to install and copy the collected data to the AWS S3 service with encryption enabled.
```YAML
- name: backing up the log data
  hosts: localhost
  gather_facts: false
  become: yes
  vars:
    s3_access_key: XXXXXXX # Use Ansible-vault to encrypt
    s3_access_secret: XXXXXXX # Use Ansible-vault to encrypt
    localfolder: /tmp/LOGS/ # Trailing slash is important
    remotebucket: secretforensicsdatausingAnsible # This should be unique in s3

  tasks:
    - name: installing s3cmd if not installed
      apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
      
      with_items:
        - python-magic
        - python-dateutil
        - s3cmd
    
    - name: create s3cmd config file
      template:
        src: s3cmd.j2
        dest: /root/.s3cfg
        owner: root
        group: root
        mode: 0640
    
    - name: make sure "{{ remotebucket }}" is avilable
      command: "s3cmd mb s3://{{ remotebucket }}/ -c /root/.s3cfg"

    - name: running the s3 backup to "{{ remotebucket }}"
      command: "s3cmd sync {{ localfolder }} --preserve s3://{{ remotebucket }}/ -c /root/.s3cfg"
```
- The Ansible playbook installing s3cmd, creating the new bucket called secretforensicsdatausingAnsible, and copying the local log data to the remote S3 bucket.
- The configuration file looks like the following for the s3cmd configuration
```YAML
[default]
access_key = {{ s3_access_key }}
secret_key = {{ s3_access_secret }}
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com
website_endpoint = http://%(bucket)s.s3-website-%(location)s.amazonaws.com/
use_https = True
signature_v2 = True
```
- We can see that the logs are successfully uploaded into the secretforensicsdatausingAnsible S3 bucket in AWS S3.
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