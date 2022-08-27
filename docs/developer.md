# Windows

1. Update WSL2 first (by default WLS1 is enabled)
1. Install Ubuntu from Microsoft Stores
1. Install Visual Studio Code
1. Update Linux packages
```BASH
sudo apt update
sudo apt -y upgrade
```
1. To find the home directory in Ubuntu
```BASH
explorer.exe .
```
1. Install Windows Terminal for Miscrosoft Store

1. Install Menlo font (from Powerlevel10k site)

1. To test the terminal color output, run this code in the terminal
```BASH
for code in {30..37}; do \
echo -en "\e[${code}m"'\\e['"$code"'m'"\e[0m"; \
echo -en "  \e[$code;1m"'\\e['"$code"';1m'"\e[0m"; \
echo -en "  \e[$code;3m"'\\e['"$code"';3m'"\e[0m"; \
echo -en "  \e[$code;4m"'\\e['"$code"';4m'"\e[0m"; \
echo -e "  \e[$((code+60))m"'\\e['"$((code+60))"'m'"\e[0m"; \
done
```
1. Generate SSH keys
```BASH
ssh-keygen -t rsa  -b 4096 -f ~/.ssh/raddit-user -C raddit-user
```
- `-C` is the comment, you can also write `-C 'keys generated on 20th Oct 2022'`
`ssh-keygen -t rsa  -b 4096 -f ~/.ssh/ansible-user -C ansible-user`

1. Using the .ssh config files (~/.ssh/config)
```BASH
# 1. Generate public & private ssh keys:
          `ssh-keygen -t rsa`
# Type in a name which will be put in `~/.ssh` directory

# 2. To bypass password prompt, you should add the `foo.pub` file to the `authorized_keys` file on the
# server's `~/.ssh` directory. You can do a pipe via ssh:
    
    `cat mykey.pub | ssh myuser@mysite.com -p 123 'cat >> .ssh/authorized_keys' `

# 3. Add the publickey name to the `~/.ssh/config` file like this:

        Host bitbucket.org
          IdentityFile ~/.ssh/myprivatekeyfile # the leading spaces are important!
          Port 123

# 4. Verify and then SSH into the remote server. To check if your config is right type: `ssh -T git@github.com`
      
        ssh root@mysite.com
        or
        ssh mysite.com # if you setup the User setting in config
```
1. Copy ssh keys to an existing server
`ssh-copy-id root@192.168.0.10` - This will copy default public key `id_rsa.pub` to server 192.168.0.10 in `.ssh/authorized_key` file under root user.
# Ubuntu
1. Use bootable USB created using ventoy
1. Press F12 at startup and select the bootable USB, select Ubuntu is image to begin installation
1. [Configure linux partitions as encrypted](https://www.youtube.com/watch?v=gvYM6hqTkQo)
1. Add swap partion instead of efi as we will dual boot into same system. [Part 2](https://askubuntu.com/questions/1033497/dual-boot-windows-10-and-linux-ubuntu-on-separate-ssd)
1. Change root password. `sudo passwd root`
1. Move Windows above Ubuntu in boot menu. Use Grub Customizer [Part 3](https://askubuntu.com/questions/1033497/dual-boot-windows-10-and-linux-ubuntu-on-separate-ssd)
1. Backup and restore data using rsync. Install programs using dotfiles.

- [Adding SSH Keys to servers](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
- [SSH Client Config](https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client)
- [Test SSH connections](https://www.cyberciti.biz/faq/how-to-set-up-ssh-keys-on-linux-unix/)
Edit setings on the new terminal to make Ubuntu as the default terminal. Also set the fontFace and 
https://www.the-digital-life.com/en/awesome-wsl-wsl2-terminal/
- [Create Sudo User](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-sudo-enabled-user-on-ubuntu-20-04-quickstart)
- [Securing Sudoers](https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file)
```BASH
#sudo visudo /etc/sudoers.d/leslie
leslie  ALL=(ALL:ALL) NOPASSWD: /usr/bin/docker, /usr/sbin/reboot, /usr/sbin/shutdown, /usr/bin/apt-get, /usr/local/bin/docker-compose
```
# Switching remote URLs from HTTPS to SSH
List your existing remotes in order to get the name of the remote you want to change.
```BASH
$ git remote -v
> origin  https://github.com/USERNAME/REPOSITORY.git (fetch)
> origin  https://github.com/USERNAME/REPOSITORY.git (push)
```
Change your remote's URL from HTTPS to SSH with the git remote set-url command.
```BASH
$ git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
```
git remote set-url origin git@github.com:leslieclif/notebook.git
# Inspirational dotfile repos
https://www.freecodecamp.org/news/how-to-set-up-a-fresh-ubuntu-desktop-using-only-dotfiles-and-bash-scripts/
[Dotfiles Intial Automation](https://github.com/victoriadrake/dotfiles/tree/ubuntu-19.10)
[Tmux and Otherconfig](https://github.com/georgijd/dotfiles)
https://github.com/nickjj/dotfiles

https://github.com/jieverson/dotfiles-win/blob/master/install.sh

# Bashrc Automation
https://victoria.dev/blog/how-to-do-twice-as-much-with-half-the-keystrokes-using-.bashrc/
https://victoria.dev/blog/how-to-write-bash-one-liners-for-cloning-and-managing-github-and-gitlab-repositories/

# Vagrant setup
https://www.techdrabble.com/ansible/36-install-ansible-molecule-vagrant-on-windows-wsl

# Tmux
## Every Hacker should have a great terminal | TMUX - Medium
[Tmux Basics](https://medium.com/@lanycrost/every-hacker-should-have-a-great-terminal-tmux-part-1-introduction-82b8f4fa5e79)
[Tmux Config](https://medium.com/@lanycrost/every-hacker-should-have-a-great-terminal-tmux-part-2-configuration-abe57a8c082d)

# VSCode
[Key Shortcuts](https://github.com/microsoft/vscode-tips-and-tricks)
[Mastering Terminal](https://www.growingwiththeweb.com/2017/03/mastering-vscodes-terminal.html)

# Examples
[TLS Certificate - Manual](https://github.com/justmeandopensource/docker/blob/master/docker-compose-files/docker-registry/docs/Generate%20certificates%20for%20TLS%20registry.md)

# PI
- [TFTP Boot](https://netboot.xyz/docs/booting/tftp/)
- [Boot Methods](https://williamlam.com/2020/07/two-methods-to-network-boot-raspberry-pi-4.html)
- [Network Boot from Ubuntu](https://blockdev.io/network-booting-a-raspberry-pi-3/)
- [K3s Cluster with Netboot](https://blog.alexellis.io/state-of-netbooting-raspberry-pi-in-2021/s)
- [DHCP, TFTP and NFS](https://thenewstack.io/bare-metal-in-a-cloud-native-world/)
- []()