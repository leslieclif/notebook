# Converting Android Device Into Linux Server

## Centos
---
1. Pre-requisites
    
    * Identify an Android mobile phone
    * Factory reset to remove any unwanted apps and data
    * Remove any apps or services from the device to free up space and memory
    * Install Termux and AnLinux from Playstore

1. Installation
    
    * Start AnLinux and search for the distro. Select Centos
    * Copy the installation command
    * Open Termux terminal and paste the command
    * Begin installation

1. Access Mobile
    * Configure Static Ip to [Mobile](https://service.uoregon.edu/TDClient/KB/ArticleDet?ID=33742)
    * Add Ip address and remote-hostname to Laptop's hosts file.
    * Install SSH on Termux ```apt install openssh```
    * Start the ssh server ```sshd```. This will also generate the private and public keys.
    * Test the service locally ```ssh localhost -p 8022```. Accept the public key.
    * **ssh-copy-id** copies the local-host’s public key to the remote-host’s authorized_keys file. 
        ``ssh-copy-id -i ~/.ssh/id_rsa.pub <remote-hostname> -p 8022``. Enter remote user password to complete transaction.
    * Login from Laptop ```ssh <hostname> -p 8022```. Enter the passphrase.
    * Install Python
    
    
1. Configuring Centos
    
    * Update Centos with latest patches
    ```yum install update -y && yum install upgrade -y```
    * Verify the OS Version
    ```cat /etc/os-releases```
    * **net-tools** package provides the ifconfig command
    ```yum install net-tools -y```
    * Init Centos ```yum -y install initscripts``` & ```yum clean all```
    * Change Root Password ```passwd root```
    * Install Sudo ```yum install sudo -y```
    * The difference between **wheel** and **sudo**.
    
      In CentOS, a user belonging to the wheel group can execute su and directly ascend to root. Meanwhile, a sudo user would have use the sudo su first. Essentially, there is no real difference except for the syntax used to become root, and users belonging to both groups can use the sudo command.
    * 
    
    [Adding Non Root User](https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-centos-quickstart)

     * bmmnb
       
    [Add and Delete Users](https://www.digitalocean.com/community/tutorials/how-to-add-and-delete-users-on-a-centos-7-server)

1. Securing Server
    
    Security based on articles mentioned [here](https://medium.com/viithiisys/10-steps-to-secure-linux-server-for-production-environment-a135109a57c5) or [here](https://www.cyberciti.biz/tips/linux-security.html) or [DigitalOcean](https://www.digitalocean.com/community/tutorials/an-introduction-to-securing-your-linux-vps)
    
    Configures a Hostname
    Reconfigures the Timezone
    Updates the entire System
    Creates a New Admin user so you can manage your server safely without the need of doing remote connections with root.
    Helps user Generate Secure RSA Keys, so that remote access to your server is done exclusive from your local pc and no Conventional password
    Configures, Optimize and secures the SSH Server (Some Settings Following CIS Benchmark)
    Configures IPTABLES Rules to protect the server from common attacks
    Disables unused FileSystems and Network protocols
    Protects the server against Brute Force attacks by installing a configuring fail2ban
    Installs and Configure Artillery as a Honeypot, Monitoring, Blocking and Alerting tool
    Installs PortSentry
    Installs RootKit Hunter
    Secures Root Home and Grub Configuration Files
    Installs Unhide to help Detect Malicious Hidden Processes
    Installs Tiger, A Security Auditing and Intrusion Prevention system
    Restrict Access to Apache Config Files
    Disables Compilers
    Creates Daily Cron job for System Updates
    Kernel Hardening via sysctl configuration File (Tweaked)
    /tmp Directory Hardening
    PSAD IDS installation
    Enables Process Accounting
    Enables Unattended Upgrades
    MOTD and Banners for Unauthorized access
    Disables USB Support for Improved Security (Optional)
    Configures a Restrictive Default UMASK
    Configures and enables Auditd
    Configures Auditd rules following CIS Benchmark
    Sysstat install
    ArpWatch install
    Additional Hardening steps following CIS Benchmark
    Secures Cron
    Automates the process of setting a GRUB Bootloader Password
    Secures Boot Settings
    Sets Secure File Permissions for Critical System Files

