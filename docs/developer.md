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
[Adding SSH Keys to servers](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
[SSH Client Config](https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client)

Edit setings on the new terminal to make Ubuntu as the default terminal. Also set the fontFace and 
https://www.the-digital-life.com/en/awesome-wsl-wsl2-terminal/


# Inspirational dotfile repos
https://www.freecodecamp.org/news/how-to-set-up-a-fresh-ubuntu-desktop-using-only-dotfiles-and-bash-scripts/
https://github.com/victoriadrake/dotfiles/tree/ubuntu-19.10

https://github.com/jieverson/dotfiles-win/blob/master/install.sh

# Bashrc Automation
https://victoria.dev/blog/how-to-do-twice-as-much-with-half-the-keystrokes-using-.bashrc/
https://victoria.dev/blog/how-to-write-bash-one-liners-for-cloning-and-managing-github-and-gitlab-repositories/

# Vagrant setup
https://www.techdrabble.com/ansible/36-install-ansible-molecule-vagrant-on-windows-wsl