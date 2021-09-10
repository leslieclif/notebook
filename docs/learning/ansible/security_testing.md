# Automating Web Application Security Testing Using OWASP ZAP
- The OWASP Zed Attack Proxy (commonly known as ZAP) is one of the most popular web application security testing tools. 
- It has many features that allow it to be used for manual security testing; it also fits nicely into continuous integration/continuous delivery (CI/CD) environments after some tweaking and configuration. 
- More details about the project can be found at https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project.
- Open Web Application Security Project (OWASP) is a worldwide not-for-profit charitable organization focused on improving the security of software. 
- OWASP ZAP includes many different tools and features in one package. 
- For a pentester tasked with doing the security testing of web applications, the following features are invaluable
- **Feature: Use case**
- Intercepting proxy: This allows us to intercept requests and responses in the browser
- Active scanner: Automatically run web security scans against targets
- Passive scanner: Glean information about security issues from pages that get downloaded using spider tools and so on
- Spiders: Before ZAP can attack an application, it creates a site map of the application by crawling all the possible web pages on it
- REST API: Allows ZAP to be run in headless mode and to be controlled for running automated scanner, spider, and get the results
- ZAP is a Java-based software. The typical way of using it will involve the following:
    - Java Runtime Environment (JRE) 7 or more recent installed in the operating system of your choice (macOS, Windows, Linux)
    - Install ZAP using package managers, installers from the official downloads page
- The best way to achieve that is to use OWASP ZAP as a container. In fact, this is the kind of setup Mozilla uses ZAP in a CI/CD pipeline to verify the baseline security controls at every release. 
## Installing OWASP ZAP
We are going to use OWASP ZAP as a container, which requires container runtime in the host operating system. The team behind OWASP ZAP releases ZAP Docker images on a weekly basis via Docker Hub. The approach of pulling Docker images based on tags is popular in modern DevOps environments and it makes sense that we talk about automation with respect to that.
## Installing Docker runtime
```YAML
# The following playbook will install Docker Community Edition software in Ubuntu 16.04
- name: installing docker on ubuntu
  hosts: zap
  remote_user: "{{ remote_user_name }}"
  gather_facts: no
  become: yes
  vars:
    remote_user_name: ubuntu
    apt_repo_data: "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
    apt_gpg_key: https://download.docker.com/linux/ubuntu/gpg

  tasks:
    - name: adding docker gpg key
      apt_key:
        url: "{{ apt_gpg_key }}"
        state: present
    
    - name: add docker repository
      apt_repository:
        repo: "{{ apt_repo_data }}"
        state: present
    
    - name: installing docker-ce
      apt:
        name: docker-ce
        state: present
        update_cache: yes
    - name: install python-pip
      apt:
        name: python-pip
        state: present
    - name: install docker-py
      pip:
        name: "{{ item }}"
        state: present

      with_items:
        - docker-py
```
## OWASP ZAP Docker container setup
- The two new modules to deal with Docker containers that we will be using here are docker_image and docker_container.
```YAML
# The following playbook will take some time to complete as it has to download about 1 GB of data from the internet
- name: setting up owasp zap container
  hosts: zap
  remote_user: "{{ remote_user_name }}"
  gather_facts: no
  become: yes
  vars:
    remote_user_name: ubuntu
    owasp_zap_image_name: owasp/zap2docker-weekly

  tasks:
    - name: pulling {{ owasp_zap_image_name }} container
      docker_image:
        name: "{{ owasp_zap_image_name }}"

    - name: running owasp zap container
      docker_container:
        name: owasp-zap
        image: "{{ owasp_zap_image_name }}"
        interactive: yes
        state: started
        user: zap
        command: zap.sh -daemon -host 0.0.0.0 -port 8090 -config api.disablekey=true -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true
        ports:
          - "8090:8090"
```
- You can access the ZAP API interface by navigating to http://ZAPSERVERIPADDRESS:8090
## A specialized tool for working with Containers - Ansible Container 
Currently, we are using Docker modules to perform container operations. A new tool, ansible-container, provides an Ansible-centric workflow for building, running, testing, and deploying containers.

This allows us to build, push, and run containers using existing playbooks. Dockerfiles are like writing shell scripts, therefore, ansible-container will allow us to codify those Dockerfiles and build them using existing playbooks rather writing complex scripts.

The ansible-container supports various orchestration tools, such as Kubernetes and OpenShift. It can also be used to push the build images to private registries such as Google Container Registry and Docker Hub. 
## Running an OWASP ZAP Baseline scan
- The following playbook runs the Docker Baseline scan against a given website URL. 
- It also stores the output of the Baseline's scan in the host system in HTML, Markdown, and XML formats.
```YAML
- name: Running OWASP ZAP Baseline Scan
  hosts: zap
  remote_user: "{{ remote_user_name }}"
  gather_facts: no
  become: yes
  vars:
    remote_user_name: ubuntu
    owasp_zap_image_name: owasp/zap2docker-weekly
    website_url: {{ website_url }}
    reports_location: /zapdata/
    scan_name: owasp-zap-base-line-scan-dvws

  tasks:
    - name: adding write permissions to reports directory
      file:
        path: "{{ reports_location }}"
        state: directory
        owner: root
        group: root
        recurse: yes
        mode: 0770

    - name: running owasp zap baseline scan container against "{{ website_url }}"
      docker_container:
        name: "{{ scan_name }}"
        image: "{{ owasp_zap_image_name }}"
        interactive: yes
        auto_remove: yes
        state: started
        volumes: "{{ reports_location }}:/zap/wrk:rw"
        command: "zap-baseline.py -t {{ website_url }} -r {{ scan_name }}_report.html"

    - name: getting raw output of the scan
      command: "docker logs -f {{ scan_name }}"
      register: scan_output

    - debug:
        msg: "{{ scan_output }}"
```
- Explore the parameters of the preceding playbook:
    - website_url is the domain (or) URL that you want to perform the Baseline scan, we can pass this via --extra-vars "website_url: http://192.168.33.111" from the ansible-playbook command
    - reports_location is the path to ZAP host machine where reports get stored
## Security testing against web applications and websites
- An active scan may cause the vulnerability to be exploited in the application.
- Also, this type of scan requires extra configuration, which includes authentication and sensitive functionalities.
- The following playbook will run the full scan against the DVWS application. 
- Now we can see that the playbook looks almost similar, except the flags sent to command:
```YAML
- name: Running OWASP ZAP Full Scan
  hosts: zap
  remote_user: "{{ remote_user_name }}"
  gather_facts: no
  become: yes
  vars:
    remote_user_name: ubuntu
    owasp_zap_image_name: owasp/zap2docker-weekly
    website_url: {{ website_url }}
    reports_location: /zapdata/
    scan_name: owasp-zap-full-scan-dvws

  tasks:
    - name: adding write permissions to reports directory
      file:
        path: "{{ reports_location }}"
        state: directory
        owner: root
        group: root
        recurse: yes
        mode: 0777

    - name: running owasp zap full scan container against "{{ website_url }}"
      docker_container:
        name: "{{ scan_name }}"
        image: "{{ owasp_zap_image_name }}"
        interactive: yes
        auto_remove: yes
        state: started
        volumes: "{{ reports_location }}:/zap/wrk:rw"
        command: "zap-full-scan.py -t {{ website_url }} -r {{ scan_name }}_report.html"

    - name: getting raw output of the scan
      raw: "docker logs -f {{ scan_name }}"
      register: scan_output

    - debug:
        msg: "{{ scan_output }}"
```
# Testing web APIs
- Similar to the ZAP Baseline scan, the fine folks behind ZAP provide a script as part of their live and weekly Docker images. 
- We can use it to run scans against API endpoints defined either by OpenAPI specification or Simple Object Access Protocol (SOAP).
- The script can understand the API specifications and import all the definitions. 
- Based on this, it runs an active scan against all the URLs found.
```YAML
- name: Running OWASP ZAP API Scan
  hosts: zap
  remote_user: "{{ remote_user_name }}"
  gather_facts: no
  become: yes
  vars:
    remote_user_name: ubuntu
    owasp_zap_image_name: owasp/zap2docker-weekly
    website_url: {{ website_url }}
    reports_location: /zapdata/
    scan_name: owasp-zap-api-scan-dvws
    api_type: openapi
  tasks:
    - name: adding write permissions to reports directory
      file:
        path: "{{ reports_location }}"
        state: directory
        owner: root
        group: root
        recurse: yes
        mode: 0777

    - name: running owasp zap api scan container against "{{ website_url }}"
      docker_container:
        name: "{{ scan_name }}"
        image: "{{ owasp_zap_image_name }}"
        interactive: yes
        auto_remove: yes
        state: started
        volumes: "{{ reports_location }}:/zap/wrk:rw"
        command: "zap-api-scan.py -t {{ website_url }} -f {{ api_type }} -r {{ scan_name }}_report.html"

    - name: getting raw output of the scan
      raw: "docker logs -f {{ scan_name }}"
      register: scan_output

    - debug:
        msg: "{{ scan_output }}"
```
# Vulnerability Scanning with Nessus
- Scanning for vulnerabilities is one of the best understood periodic activities security teams take up on their computers. 
- There are well-documented strategies and best practices for doing regular scanning for vulnerabilities in computers, networks, operating system software, and application software:
    - Basic network scans 
    - Credentials patch audit
    - Correlating system information with known vulnerabilities
- With networked systems, this type of scanning is usually executed from a connected host that has the right kind of permissions to scan for security issues. 
- One of the most popular vulnerability scanning tools is Nessus. Nessus started as a network vulnerability scanning tool, but now incorporates features such as the following: 
    - Port scanning
    - Network vulnerability scanning
    - Web application-specific scanning
    - Host-based vulnerability scanning
## Introduction to Nessus
The vulnerability database that Nessus has is its main advantage. While the techniques to understanding which service is running and what version of the software is running the service are known to us, answering the question, "Does this service have a known vulnerability" is the important one. Apart from a regularly updated vulnerability database, Nessus also has information on default credentials found in applications, default paths, and locations. All of this fine-tuned in an easy way to use CLI or web-based tool.

- We will try out the standard activities required for that and see what steps are needed to automate them using Ansible.
    - Installing Nessus using a playbook.
    - Configuring Nessus.
    - Running a scan.
    - Running a scan using AutoNessus. 
    - Installing the Nessus REST API Python client.
    - Downloading a report using the API.
## Installing Nessus for vulnerability assessments
```YAML
- name: installing nessus server
  hosts: nessus
  remote_user: "{{ remote_user_name }}"
  gather_facts: no
  vars:
    remote_user_name: ubuntu
    nessus_download_url: "http://downloads.nessus.org/nessus3dl.php?file=Nessus-6.11.2-ubuntu1110_amd64.deb&licence_accept=yes&t=84ed6ee87f926f3d17a218b2e52b61f0"

  tasks:
    - name: install python 2
      raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)

    - name: downloading the package and installing
      apt:
        deb: "{{ nessus_download_url }}"

    - name: start the nessus daemon
      service:
        name: "nessusd"
        enabled: yes
        state: started
```
## Configuring Nessus for vulnerability scanning
- Perform the following steps to configure Nessus for vulnerability scanning:
    - We have to navigate to https://NESSUSSERVERIP:8834 to confirm and start the service
- It returns with an SSL error and we need to accept the SSL error and confirm the security exception and continue with the installation
- Click on Confirm Security Exception and continue to proceed with the installation steps.
- Click on Continue and provide the details of the user, this user has full administrator access.
- Then finally, we have to provide the registration code (Activation Code), which can be obtained from registering at https://www.tenable.com/products/nessus-home
- Now it will install the required plugins. It will take a while to install, and once it is done we can log in to use the application.
- Now, we have successfully set up the Nessus vulnerability scanner.
## Basic network scanning
- Nessus has a wide variety of scans, some of them are free and some of them will be available only in a paid version. So, we can also customize the scanning if required.
- We can start with a basic network scan to see what's happening in the network. This scan will perform a basic full system scan for the given hosts.
- We have to mention the scan name and targets. Targets are just the hosts we want.
- Targets can be given in different formats, such as 192.168.33.1 for a single host, 192.168.33.1-10 for a range of hosts, and also we can upload the target file from our computer.
## Running a scan using AutoNessus
- With the AutoNessus script, we can do the following:
    - List scans
    - List scan policies
    - Do actions on scans such as start, stop, pause, and resume
- The best part of AutoNessus is that since this is a command-line tool, it can easily become part of scheduled tasks and other automation workflows.
## Setting up AutoNessus
- The following code is the Ansible playbook snippet to set up AutoNessus and configure it to use Nessus using credentials.
```YAML
- name: installing python-pip
  apt:
    name: python-pip
    update_cache: yes
    state: present

- name: install python requests
  pip:
    name: requests

- name: setting up autonessus
  get_url:
    url: "https://github.com/redteamsecurity/AutoNessus/raw/master/autoNessus.py"
    dest: /usr/bin/autoNessus
    mode: 0755
 
- name: updating the credentials
  replace:
    path: /usr/bin/autoNessus
    regexp: "{{ item.src }}"
    replace: "{{ item.dst }}"
    backup: yes
  no_log: True
 
  with_items:
    - { src: "token = ''", dst: "token = '{{ nessus_user_token }}'" }
    - { src: "url = 'https://localhost:8834'", dst: "url = '{{ nessus_url }}'" } 
    - { src: "username = 'xxxxx'", dst: "username = '{{ nessus_user_name }}'" }
    - { src: "password = 'xxxxx'", dst: "password = '{{ nessus_user_password }}'" }
```
- _no_log_: True will censor the output in the log console of Ansible output. It will be very useful when we are using secrets and keys inside playbooks.
- Before running the automated scans using AutoNessus, we have to create them in the Nessus portal with required customization, and we can use these automated playbooks to perform tasks on top of it.
### Listing current available scans and IDs
```YAML
- name: list current scans and IDs using autoNessus
  command: "autoNessus -l"
  register: list_scans_output

- debug:
    msg: "{{ list_scans_output.stdout_lines }}"
```
### Starting a specified scan using scan ID
```YAML
- name: starting nessus scan "{{ scan_id }}" using autoNessus
  command: "autoNessus -sS {{ scan_id }}"
  register: start_scan_output

- debug:
    msg: "{{ start_scan_output.stdout_lines }}"
```
- Similarly, we can perform pause, resume, stop, list policies, and so on. Using the AutoNessus program, these playbooks are available. This can be improved by advancing the Nessus API scripts.
### Storing results
- The entire report can be exported into multiple formats, such as HTML, CSV, and Nessus. This helps to give more a detailed structure of vulnerabilities found, solutions with risk rating, and other references
- The output report can be customized based on the audience, if it goes to the technical team, we can list all the vulnerabilities and remediation. For example, if management wants to get the report, we can only get the executive summary of the issues.
- Reports can be sent by email as well using notification options in Nessus configuration.
### Installing the Nessus REST API Python client
- Official API documentation can be obtained by connecting to your Nessus server under 8834/nessus6-api.html.
- To perform any operations using the Nessus REST API, we have to obtain the API keys from the portal. This can be found in user settings. Please make sure to save these keys
### Downloading reports using the Nessus REST API
```YAML
- name: working with nessus rest api
  connection: local
  hosts: localhost
  gather_facts: no
  vars:
    scan_id: 17
    nessus_access_key: 620fe4ffaed47e9fe429ed749207967ecd7a77471105d8
    nessus_secret_key: 295414e22dc9a56abc7a89dab713487bd397cf860751a2
    nessus_url: https://192.168.33.109:8834
    nessus_report_format: html

  tasks:
    - name: export the report for given scan "{{ scan_id }}"
      uri:
        url: "{{ nessus_url }}/scans/{{ scan_id }}/export"
        method: POST
        validate_certs: no
        headers:
            X-ApiKeys: "accessKey={{ nessus_access_key }}; secretKey={{ nessus_secret_key }}"
        body: "format={{ nessus_report_format }}&chapters=vuln_by_host;remediations"
      register: export_request

    - debug:
        msg: "File id is {{ export_request.json.file }} and scan id is {{ scan_id }}"

    - name: check the report status for "{{ export_request.json.file }}"
      uri:
        url: "{{ nessus_url }}/scans/{{ scan_id }}/export/{{ export_request.json.file }}/status"
        method: GET
        validate_certs: no
        headers:
            X-ApiKeys: "accessKey={{ nessus_access_key }}; secretKey={{ nessus_secret_key }}"
      register: report_status

    - debug:
        msg: "Report status is {{ report_status.json.status }}"

    - name: downloading the report locally
      uri:
        url: "{{ nessus_url }}/scans/{{ scan_id }}/export/{{ export_request.json.file }}/download"
        method: GET
        validate_certs: no
        headers:
                  X-ApiKeys: "accessKey={{ nessus_access_key }}; secretKey={{ nessus_secret_key }}"
        return_content: yes
        dest: "./{{ scan_id }}_{{ export_request.json.file }}.{{ nessus_report_format }}"
      register: report_output

    - debug:
      msg: "Report can be found at ./{{ scan_id }}_{{ export_request.json.file }}.{{ nessus_report_format }}"
```
## Nessus configuration
- Nessus allows us to create different users with role-based authentication to perform scans and review with different access levels.
### Summary
- Security teams and IT teams rely on tools for vulnerability scanning, management, remediation, and continuous security processes. 
- Nessus, by being one of the most popular and useful tools, was an automatic choice for the authors to try and automate.

# Writing an Ansible Module for Security Testing
- Ansible primarily works by pushing small bits of code to the nodes it connects to. 
- These codes/programs are what we know as Ansible modules. 
- Typically in the case of a Linux host these are copied over SSH, executed, and then removed from the node.
- We will look at the following:
    - How to set up the development environment
    -Writing an Ansible hello world module to understand the basics
    -Where to seek further help
    -Defining a security problem statement
    -Addressing that problem by writing a module of our own
- Along with that, we will try to understand and attempt to answer the following questions:
    - What are the good use cases for modules?
    - When does it make sense to use roles?
    - How do modules differ from plugins?
## Getting started with a hello world Ansible module
- We will pass one argument to our custom module and show if we have success or failure for the module executing based on that.
- Since all of this is new to us, we will look at the following things:
    - The source code of the hello world module
    - The output of that module for both success and failure
    - The command that we will use to invoke it
## Setting up the development environment
- The primary requirement for Ansible 2.4 is Python 2.6 or higher and Python 3.5 or higher. If you have either of them installed, we can follow the simple steps to get the development environment going.
- From the Ansible Developer Guide:
    - Clone the Ansible repository: $ git clone https://github.com/ansible/ansible.git
    - Change the directory into the repository root directory: $ cd ansible
    - Create a virtual environment: $ python3 -m venv venv (or for Python 2 $ virtualenv venv
    - Note, this requires you to install the virtualenv package: $ pip install virtualenv
    - Activate the virtual environment: $ . venv/bin/activate
    - Install the development requirements: $ pip install -r requirements.txt
    - Run the environment setup script for each new dev shell process: $ . hacking/env-setup
- This playbook will set up the developer environment by installing and setting up the virtual environment.
```YAML
- name: Setting Developer Environment
  hosts: dev
  remote_user: madhu
  become: yes
  vars:
    ansible_code_path: "/home/madhu/ansible-code"

  tasks:
    - name: installing prerequirements if not installed
      apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
    
      with_items:
        - git
        - virtualenv
        - python-pip
    
    - name: downloading ansible repo locally
      git:
        repo: https://github.com/ansible/ansible.git
        dest: "{{ ansible_code_path }}/venv"
    
    - name: creating virtual environment
      pip:
        virtualenv: "{{ ansible_code_path }}"
        virtualenv_command: virtualenv
        requirements: "{{ ansible_code_path }}/venv/requirements.txt"
```

