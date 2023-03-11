# Updating hosts file
Update IP addresses of VM which can then be accessed by Ansible
`/etc/ansible/hosts`
# Creating Base Box
Create base machine using centos. Keep the VM in running state, then run the below commands
```BASH
vagrant package --output centos8-server.box
vagrant box add leslie/centos8 centos8-server.box
```
Update `Vagrantfile` to use the new box

# Running the test.yml
```YAML
ansible-playbook test.yml --connection=local
```

# OPTION 3: Run Ansible from a remote machine
# NOTE: Before running Ansible, complete the following on the 
#   remote machine:
#
#   - Copy the playbook.yml, index.html, and vhost.tpl:
#       scp playbook.yml index.html vhost.tpl <user>@<host>:<location>
#
#   - Copy the private key used for the vagrant user:
#       KEY=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
#       scp "${KEY}" <user>@<host>:<location>
#
#   - Create a host inventory file:
#       ssh <user>@<host>
#       sudo vim /etc/ansible/hosts
#       # insert the following:
#           <hostname> ansible_host=<ip-address> ansible_port=2222 ansible_user=vagrant ansible_private_key_file=<key-copied-from-earlier>
#
#   - Verify you can ping:
#       ansible all -m ping
#           # <hostname> | SUCCESS => {
#           #     "changed": false, 
#           #     "ping": "pong"
#           # }
#
#   - Run the Ansible Playbook:
#       cd <location-of-playbook>
#       ansible-playbook playbook.yml
#
#   NOTE: If you destroy and rebuild the vagrant box you will want to
#       remove the old entry in the remote machine's ~/.ssh/known_hosts
#       file, otherwise you will get an error when trying to ping or 
#       run the playbook.

```RUBY
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "centos/8"
    config.vbguest.installer_options = { allow_kernel_upgrade: true }
    config.ssh.insert_key = false
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
   config.vm.define "server" do |machine|
    machine.vm.network "private_network", ip: "192.168.99.100"
   end
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # Commenting the below line for testing in WSL
  # config.vm.synced_folder ".", "/vagrant"
    config.vm.synced_folder "/mnt/c/Users/Leslie/testprojects/vagrant", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
     vb.gui = false
  #
  #   # Customize the amount of memory on the VM:
     vb.memory = "512"
     vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
   end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo yum update -y
  #   yum install python3 python3-pip -y
  #   pip3 install --upgrade pip
  #   pip3 install ansible --user
  # SHELL
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "test.yml"
    ansible.inventory_path = "inventory"
    ansible.verbose        = true
    #ansible.install        = true
    ansible.limit = "all"
  end
end

#######################
 #servers=[
  #  {
  #    :hostname => "server",
  #    :box => "centos/8",
     # :box => "leslie/centos8",
  #    :ip => "192.168.99.100"
    #},
    #{
    #  :hostname => "node1",
    #  :box => "leslie/centos8",
    #  :ip => "192.168.99.101"
  #  }
  #]

servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      # Below 2 statements are complementary. To update guest additions enable first statement
      node.vbguest.installer_options = { allow_kernel_upgrade: true }
      #node.vm.box_check_update = false
      node.ssh.insert_key = false
      # node.vm.network "forwarded_port", guest: 80, host: 8080
      node.vm.hostname = machine[:hostname]
      node.vm.network :private_network, ip: machine[:ip]
      # node.vm.synced_folder ".", "/vagrant"
      node.vm.synced_folder "/mnt/c/Users/Leslie/testprojects/vagrant", "/vagrant", disabled: true
      # node.vm.provision "file", source: "./copiedfile.txt", destination: "/home/vagrant/copiedfile.txt"

      node.vm.provider :virtualbox do |vb|
        vb.gui = false
        # vb.name = "centos8_vagrant_base"
        vb.memory = "512"
        vb.cpus = 1
        vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
      end
      #serverCount += 1
      # Only execute once the Ansible provisioner,
      # when all the machines are up and ready.
      #if serverCount == 2
      #  config.vm.provision "ansible" do |ansible|
      #    ansible.playbook = "test.yml"
      #    ansible.inventory_path = "inventory"
      #    ansible.verbose        = true
          #ansible.install        = true
          # Disable default limit to connect to all the machines
      #    ansible.limit = "all"
      #  end
      #end  
    end
  end
#######################

```