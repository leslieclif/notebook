# Installation

## Centos
---
1. Identifying Version

    Download the latest version of Centos from [centos.org](https://www.centos.org/download/)

1.  Creating Live USB

    * Format a USB as NTFS.
    * Download Fedora LiveUSB Creator or read the supported software for Centos in the downloads page.
    * See the instructions to write the ISO into the USB
    
1. Setting Up PC
  
    * Format the HDD (optional)
    * Ensure - Advanced Option, Legacy USB Support is Enabled
    * In Boot priority, USB is the first drive
    * Ensure the Boot option has Boot from USB selected above HDD
    
1. Configuring Centos

    * [Full Installation Steps](https://linoxide.com/how-tos/centos-7-step-by-step-screenshots/)
    * Create Custom partitions for /boot, /, /var, /tmp, /home
    * [Initial Server Setup](https://www.tecmint.com/initial-server-setup-with-centos-rhel-8/)
    
    * Update Centos with latest patches
    ```yum update -y && yum upgrade -y```
    ```yum clean all``` # To clean downloaded packages in /var/cache/yum
    
    * Verify the OS Version
        ```cat /etc/os-releases```
    
    * **net-tools** package provides the ifconfig command
        ```yum install net-tools -y``` 
        
    * [Adding Non Root User](https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-centos-quickstart)
    
    * [Add and Delete Users](https://www.digitalocean.com/community/tutorials/how-to-add-and-delete-users-on-a-centos-7-server)

    * [Creating Volume Groups](volume-groups.md)
    
1. Securing Server
    
    Security based on articles mentioned [here](https://medium.com/viithiisys/10-steps-to-secure-linux-server-for-production-environment-a135109a57c5) or [here](https://www.cyberciti.biz/tips/linux-security.html) or [DigitalOcean](https://www.digitalocean.com/community/tutorials/an-introduction-to-securing-your-linux-vps)
    
    * `-keygen -t rsa -b 4096` It will create two files: id_rsa and id_rsa.pub in the ~/.ssh directory.
    * When you add a passphrase to your SSH key, it encrypts the private key using 128-bit AES so that the private key is useless without the passphrase to decrypt it.
    * `cat ~/.ssh/id_rsa.pub`
    * For example, if we had a Linux VM named myserver with a user azureuser, we could use the following command to install the public key file and authorize the user with the key:
    `ssh-copy-id -i ~/.ssh/id_rsa.pub azureuser@myserver`
    * Connect with SSH `ssh jim@137.117.101.249`
    * Try executing a few Linux commands
    ```
    ls -la / to show the root of the disk
    ps -l to show all the running processes
    dmesg to list all the kernel messages
    lsblk to list all the block devices - here you will see your drives
    ```
1. Initialize data disks
    * Any additional drives you create from scratch need to be initialized and formatted. 
    * `dmesg | grep SCSI`  - list all the messages from the kernel for SCSI devices.
    * Use `fdisk` to initialize the drive
    * We can use the following command to create a new primary partition: `(echo n; echo p; echo 1; echo ; echo ; echo w) | sudo fdisk /dev/sdc`
    * We need to write a file system to the partition with the mkfs command. `sudo mkfs -t ext4 /dev/sdc1`
    * We need to mount the drive to the file system. `sudo mkdir /data & sudo mount /dev/sdc1 /data`
    * Always make sure to lock down ports used for administrative access. 
    An even better approach is to create a VPN to link the virtual network to your private network and only allow RDP or SSH requests from that address range. You can also change the port used by SSH to be something other than the default. 
    Keep in mind that changing ports is not sufficient to stop attacks. 
    It simply makes it a little harder to discover. 