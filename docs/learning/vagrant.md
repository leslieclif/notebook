
!!! info "Vagrant is not able to run on Windows 10 + WLS2"
# Windows setup
* vagrant plugin install vagrant-vbguest
* Image should have guest additions or it will not share folder from windows inside the VM
# Internal Network
Go to VirtualBox --> File --> Host Network Manager --> Check the enabled network DHCP address

# Windows Features Turn On Off 
Disable "virtual machine platform" and "windows hypervisor platform
# Installation
Install same version of Vagrant in Windows and WSL
Verify `vagrant --version` in both to match
In windows try downloading a box and start
vagrant up --provider=virtualbox

# Vagrant
# Init with a image in vagrant cloud
vagrant init hashicorp/precise64
# Start the vm
vagrant up
# SSH into the vm
vagrant ssh
# Hibernate the vm
vagrant suspend
# Check the status of vagrant vm
vagrant status
# Stop the vm
vagrant halt
# Clean up the vm
vagrant destroy

3. Get Status of Vagrant Machines on host
``` shell
vagrant global-status
```

4. Get SSH Settings
``` shell
vagrant ssh-config
```

5. Reload Virtual Machine
``` shell
vagrant reload
```

!!! warning "Make sure the ssh key you created is stored parallel to your Vagrantfile before you execute the vagrant up command."

!!! info "Vagrant commands"

# Managing Vagrant boxes
# Download a box to a machine
vagrant box add ubuntu/trusty64
vagrant box add centos/8
# List boxes on machine
vagrant box list
# Update an existing box on a machine
vagrant box outdated
vagrant box update
# Run a downloaded box --> cd into a folder
vagrant init ubuntu/trusty64
vagrant up
# Remove a downloaded box  from a machine
vagrant box remove ubuntu/trusty64
# Finding boxes
vagrantboxes.es & vagrantcloud --> find a box and copy the url
vagrant box add <custom name> <copy box url>
vagrant init <custom name>
vagrant up

# Using Plugins
# List existing plugins
vagrant plugin list
# Install Plugins
vagrant plugin install vagrant-vbguest
# Update Plugin version
vagrant plugin update vagrant-vbguest
# Update all plugins
vagrant plugin update
# Remove Plugins
vagrant plugin uninstall vagrant-vbguest

# Adding services to startup boot
sudo chkconfig --add httpd
sudo chkconfig httpd on
sudo service httpd stop
## Create symbolic link which will serve file from local on vagrant machine, ensure index html file is there in local root
cd /var/www/html
cd .. && rm -rf html
sudo ln -s /vagrant /var/www/html
sudo service httpd start

# Packaging Vagrant after baking
# Imp that VM is running, check status
vagrant status
vagrant package --output <custom-name>.box
vagrant box add <custom name> <custom-name>.box
# Custom base box packaging after customization / hardening
vagrant package --base <vm name in Virtual box terminal>
# Switching of guest additions checks if the plugin is available in local
# Add line in config
config.vbguest.auto_update = false
# Adding a file from local machine not in the project folder to the vm
config.vm.provision "file",
    source: "~/vagrant/files/git-files",
    destination: "~/.gitconfig"
## If VM is running when above provisioning is done, it is not reflected
vagrant provision
# Adding software at provisioning
config.vm.provision "shell",
    inline: "yum install -y git nano"
# Adding custom scripts not in the project folder to the vm
config.vm.provision "shell",
    path: "~/vagrant/scripts/provision.sh"

# To restart vm
sudo shutdown -r now
# Restart service
sudo systemctl restart sshd.service

# Update centos kernal
sudo yum update kernel*
# Check and delete old kernels
rpm -qa kernel
sudo package-cleanup --old-kernels --count=2

# Debugging Vagrant
# During Vagrant Up your Windows system tries to connect to SSH. If you type on your command line:
set VAGRANT_LOG=INFO
# Debug SSH
set VAGRANT_PREFER_SYSTEM_BIN=0
vagrant ssh --debug

