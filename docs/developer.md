Update VS Code in Windows

from dotfiles/programs - run ./vsc.sh. update chmod +x to make it executable in windows using Git Bash
This will install vscode extensions

Update WSL2 first (by default WLS1 is enabled)
Install Ubuntu from Microsoft Stores
Install Visual Studio Code
# Update Linux packages
sudo apt update
sudo apt -y upgrade

# To find the home directory in Ubuntu
explorer.exe .

Install Windows Terminal for Miscrosoft Store

Install Menlo font (from Powerlevel10k site)

To test the terminal color output, run this code in the terminal
```BASH
for code in {30..37}; do \
echo -en "\e[${code}m"'\\e['"$code"'m'"\e[0m"; \
echo -en "  \e[$code;1m"'\\e['"$code"';1m'"\e[0m"; \
echo -en "  \e[$code;3m"'\\e['"$code"';3m'"\e[0m"; \
echo -en "  \e[$code;4m"'\\e['"$code"';4m'"\e[0m"; \
echo -e "  \e[$((code+60))m"'\\e['"$((code+60))"'m'"\e[0m"; \
done
```
```BASH
ssh-keygen -t rsa  -b 4096 -f ~/.ssh/raddit-user -C raddit-user
```
--------------------------------------------
Using the .ssh config files (~/.ssh/config)
--------------------------
1. Generate public & private ssh keys:
          `ssh-keygen -t rsa`
    Type in a name which will be put in `~/.ssh` directory

2. To bypass password prompt, you should add the `foo.pub` file to the `authorized_keys` file on the
server's `~/.ssh` directory. You can do a pipe via ssh:
    
    `cat mykey.pub | ssh myuser@mysite.com -p 123 'cat >> .ssh/authorized_keys' `

3. Add the publickey name to the `~/.ssh/config` file like this:

        Host bitbucket.org
          IdentityFile ~/.ssh/myprivatekeyfile # the leading spaces are important!
          Port 123

4. Verify and then SSH into the remote server. To check if your config is right type: `ssh -T git@github.com`
      
        ssh root@mysite.com
        or
        ssh mysite.com # if you setup the User setting in config
--------------------------------------------

[Adding SSH Keys to servers](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
[SSH Client Config](https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client)

Edit setings on the new terminal to make Ubuntu as the default terminal. Also set the fontFace and 
https://www.the-digital-life.com/en/awesome-wsl-wsl2-terminal/

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

# Inspirational dotfile repos
https://www.freecodecamp.org/news/how-to-set-up-a-fresh-ubuntu-desktop-using-only-dotfiles-and-bash-scripts/
https://github.com/victoriadrake/dotfiles/tree/ubuntu-19.10
https://github.com/georgijd/dotfiles

https://github.com/jieverson/dotfiles-win/blob/master/install.sh

# Bashrc Automation
https://victoria.dev/blog/how-to-do-twice-as-much-with-half-the-keystrokes-using-.bashrc/
https://victoria.dev/blog/how-to-write-bash-one-liners-for-cloning-and-managing-github-and-gitlab-repositories/

# Vagrant setup
https://www.techdrabble.com/ansible/36-install-ansible-molecule-vagrant-on-windows-wsl