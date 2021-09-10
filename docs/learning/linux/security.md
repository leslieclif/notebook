# Introduction
- [Linux Security Confernce Videos](http://www.LinuxTrainingAcademy.com/security-videos/)
- Hardening Guides from CIS, DISA, Ubuntu
- Add Ubuntu mailing list for security updates
## Linux is only as secure as you make it!
- Nothing is perfectly secure.
- Security is a series of trade-offs.
- convenience vs security
```BASH
# No passwords = easy to use, not secure.
# System powered off = secure, not usable.
```
- Examples:
- Linux can be configured to be unsecure.
- Users may employ lax file permissions.
- System administration mistakes.
- Users could use easy to guess passwords.
- Data transmitted in the clear.
- Malicious software installed on the system.
- Lack of training or security awareness.
## Continous Improvement
- Just because you are using Linux, doesn’t mean you are “secure.”
- Security is an ongoing process.
- Stay vigilant!
## Risk Assessment
- What is the severity of the risk?
- What is the probability of the risk occurring?
- What is the cost to mitigate the risk?
- What is the effectiveness of the countermeasure?
## Multiuser System
- Linux is a multiuser system.
- The superuser is the root account.
- **root** is all powerful.
- Required to install system-wide software, configure networking, manager users, etc.
- All other accounts are **“normal”** accounts.
- Can be used by people or applications (services).
## Advantages to a Multiuser System.
### File permissions
- Every file has an owner.
- Permissions can be granted to other accounts and users as needed.
- Breaking into one account does not necessarily compromise the entire system.
### Process permissions.
- Every process has an owner.
- Each account can manage their processes.
- Exception to above rule: **root can do anything**
- Breaking into one account does not necessarily compromise the entire system.

# Security Guidelines
- Principle of Least Privilege
- Use encryption
- Shared accounts (Yes, root can be a shared account!)
- Multifactor authentication
- Firewall
- Monitoring logs
## Minimize Software and Services
- If you don’t need a piece of software, don’t install it.
- If you don’t need a service, don’t start it.
- If you no longer need the software or service, stop and uninstall it.
## Run Services on Separate Systems
- Minimizes the risk of one compromised service leading to other compromised services.
## Encrypt Data Transmissions
- Protect against eavesdropping and man-in-the middle attacks.
- Examples:
- Protocol --> Replace with
- FTP --> SFTP
- telnet --> SSH
- SNMP v1/v2 --> SNMP v3
- HTTP --> HTTPS
## Avoid Shared Accounts
- Each person should have their own account.
- Each service should have its own account.
- Shared accounts make security auditing difficult.
- Lack of accountability with shared accounts.
## Avoid Direct root Logins
- Do not allow direct login of shared accounts.
- Users must login to their personal accounts and then switch to the shared account.
- Control and monitor access with sudo.
## Maintain Accounts
- Create and use a process for removing access.
## Use Multifactor Authentication
- Something you know (password) + something you have (phone) or something you are(fingerprints).
- Examples:
- account password + phone to receive the one time password (OTP).
- account password + fingerprint
## The Principle of Least Privilege
- AKA, the Principle of Least Authority.
- Examples:
- Only use root privileges when required.
- Avoid running services as the root user.
- Use restrictive permissions that allow people and services enough access to do their jobs.
## Monitor System Activity
- Routinely review logs.
- Send logs to a central logging system.
## Use a Firewall
- Linux has a built-in firewall. Netfilters + iptables.
- Only allow network connections from desired sources.
## Encrypt Your Data
- Encryption protects your data while it is “at rest” (on disk).

# Physical Security
## Physical Security Is Linux Security
- Physical access poses a great security threat to your Linux system!
- Single user mode - Allows unrestricted access.
- Only allow physical access when necessary.
## Systems Not Under Your Control
- Data centers / colos - Like “banks” of data.
- Possible targets for attackers
- Needs processes, procedures, and controls in place toprotect your valuable data.
## Cloud
- At some point the cloud is real equipment.
- Physical security is still important.
- Your data is on their storage systems.
- The provider has access to your virtual disks.
- If encryption is available, use it.
## Protecting Linux Against Physical Attacks
- Gaining Access to a Linux System: Single User Mode & Power Resets
- Changing the shell command from sushell to sulogin will prompt for root password when entrering into single user mode
```BASH
# Securing Single User Mode and blank passwords by having root password at logins
# Login to root and gain access to shell
echo $$             # Shows the current process id i.e shell
ps -fp <pid>        
# Shows detailed information about shell process including command executed at login
cd /lib/systemd/system
grep sulogin emergency.target       # No output should be visible
grep sulogin emergency.service      # Should have sulogin in ExecStart command
head -1 /etc/shadow                 # Shows id root password is set or not. If not set (!) is present in output 2nd column   
passwd                              # Set root password
```
## Securing the Boot Loader
-  To prevent a person who as physical access from passing arguments to the Linux kernel at boot time, you should password protect the boot loader.
- Check examples how to secure this.
## Disk Encryption
### dm-crypt 
- device mapper crypt
- Provides transparent disk encryption.
- Creates a new device in /dev/mapper.
- Use like any other block device.
- Manage with `cryptsetup`
### LUKS
- Linux Unified Key Setup.
- Front-end for dm-crypt.
- Multiple passphrase support.
- Portable as LUKS stores setup information in the partition header.
- Great for removable media, too.
### Encrypt During Install
- PRO: easy, with sane defaults.
- CON: you give up some control.
### Setting up LUKS on a New Device
- Use this process for any block device presented to your system that you want to encrypt.
- Following this procedure will remove all data on the partition (device) that you are encrypting!
### Implementing LUKS for Full Disk Encryption 
- example Laptops, USB
```BASH
sudo apt-get install cryptsetup                 # Install LUKS tools
lsblk                                           # list the blocks
sudo shread -v -n 1 /dev/sdb                    # Writes random data to he device sdb
sudo fdisk /dev/sdb                             # partition the sdb drive and create a new partition called sdb1 
sudo cryptsetup –y luksFormat /dev/sdb1         # Allows to store encrypted data in this partition. Give a passphrase
sudo cryptsetup luksDump /dev/sdb1              # Shows details of the encrypted partition
sudo cryptsetup luksOpen /dev/sdb1 private_data # Assign a mapper called private_data and opens the device
ls /dev/mapper                                  # Shows the new mapper setup and that is a device
ls -arlt /dev/mapper | tail                     # Shows the virtual block devices private_data
sudo mkfs.ext4 /dev/mapper/private_data         # format the device as ext4
sudo mount /dev/mapper/private_data /mnt        # The device is mounted and any data that is stored will get encrypted
# Make an entry in the /etc/fstab to mount private_data to /mnt on each boot
# Make an entry in /etc/crypttab to mount private_data at boot time

# To close the encrypted device
sudo cryptsetup luksClose private_data
```
### Encrypting device in Cloud
- Sometimes cloud providers do not give block level access to volumes.
- For such cases, we will encrypt the files like we do for volumes
```BASH
sudo mkdir /data
sudo fallocate -l 100M /data/private_data        # Creates a non sparse file
sudo strings /data/private_data                  # Shows any string data in the file. It mostly is blank
# Write random data, if=input, of=output, bs=byte size<1 Mb>, count=<size of file i.e 100Mb>
sudo dd if=/dev/urandom of=/data_private_data bs=1M count=100
sudo strings /data/private_data 
sudo cryptsetup –y luksFormat /data/private_data # Allows to store encrypted data in this file. Give a passphrase
sudo cryptsetup luksOpen /data/private_data private_data # Assign a mapper called private_data and opens the device
ls /dev/mapper                                  # Shows the new mapper setup and that is a device
ls -arlt /dev/mapper | tail                     # Shows the virtual block devices private_data
sudo mkfs.ext4 /dev/mapper/private_data         # format the device as ext4
sudo mount /dev/mapper/private_data /mnt        # The device is mounted and any data that is stored will get encrypted
sudo df -h /mnt                                 # Shows the size
# Make an entry in the /etc/fstab to mount private_data to /mnt on each boot
# Make an entry in /etc/crypttab to mount private_data at boot time
```
### Converting an Existing Device to LUKS
```BASH
# Backup the data.
/home lives on /dev/sda3        # for example.
# Wipe the device.
# use shred or dd if=/dev/urandom of=/dev/sda3
# Setup LUKS.
cryptsetup luksFormat /dev/sda3
cryptsetup luksOpen /dev/sda3 home
mkfs -t ext4 /dev/mapper/home
mount /dev/mapper/home /home
# & restore from backup
```
## Disabling Ctrl+Alt+Del (Systemd)
- Attackers can gain access to the virtual terminal and send command `ctrl+alt+delete` to reboot the system.
```BASH
# Disabling reboot using ctrl-alt-delete command over remote connection
systemctl mask ctrl-alt-del.target
systemctl daemon-reload
```
# Account Security
- It's easier to attack a system from the inside.
- Privilege escalation attacks are a threat.
## Mitigation
- Keep unwanted users out.
- Secure accounts.
## PAM
- Pluggable Authentication Modules
- Used to delegate / abstract authentication of services / programs like login or sshd
## PAM Configuration files
- Location: `/etc/pam.d`
-  Configuration file for login is `/etc/pam.d/login`
-  Configuration file for sshd is `/etc/pam.d/sshd`
- Format: `module_interface control_flag module_name module_args`
## PAM Module Interfaces
- auth - Authenticates users.
- account - Verifies if access is permitted.
- password - Changes a user’s password.
- session - Manages user’s sessions.
## PAM Control Flags
- required - Module result must be successful to continue.
- requisite - Like required, but no other modules are invoked.
- sufficient - Authenticates user if no required modules have failed, otherwise ignored.
- optional - Only used when no other modules reference the interface.
- include - Includes configuration from another file.
- complex control flags - attribute=value
## PAM Configuration Example
- The directives listed in the PAM module are executed in sequential order
- *.so extension stands for shared objects
```BASH
#%PAM-1.0                                       # Comment
auth required pam_securetty.so                  # 3 auth modules which need to pass
auth required pam_unix.so nullok
auth required pam_nologin.so
account required pam_unix.so                    # Checks if the user account is valid
password required pam_pwquality.so retry=3      # Checks for password quality if acount has expired and gives 3 tries to set password
password required pam_unix.so shadow \          # Allows to use shadow file
                    nullok use_authtok
session required pam_unix.so                    # Logs when user logs in and out of the system
```
## PAM Documentation
- Configuration:
-    `account required pam_nologin.so`
-    `session required pam_unix.so`

- Getting help, drop the `.so` extension and use the man page to get additional help:
- `man pam_nologin`
- `man pam_unix`
## Linux Account Types
### root, the superuser
- Root can do anything.
- Always has the UID of 0.
### System accounts
- UIDs < 1,000
- Configured in /etc/login.defs
- `useradd -r system_account_name`
### Normal User Accounts
- UIDs >= 1,000
- Intended for human (interactive) use
## Password Security
- Enforce, not hope for, strong passwords.
- Use pam_pwquality, based on pam_cracklib.
- Configuration File: `/etc/security/pwquality.conf`
- PAM Usage: `password requisite pam_pwquality.so`
- Module attributes: `man pam_pwquality`
```BASH
# /etc/login.defs format
# PASS_MAX_DAYS 99999
# PASS_MIN_DAYS 0
# PASS_MIN_LEN 5
# PASS_WARN_AGE 7
```
## Use Shadow Passwords
- /etc/passwd unencrypted: `root:$6$L3ZSmlM1H5:0:0:root:/root:/bin/bash`
- /etc/passwd with shadow passwords: `root:x:0:0:root:/root:/bin/bash`
- /etc/shadow: `root:$6$L3ZSmlM1H5::0:99999:7:::`
## Converting Passwords
- pwconv - convert to shadow passwords.
- pwunconv - convert from shadow passwords.
## /etc/shadow format
- Username
- Hashed password
- Days since epoch of last password change
- Days until change allowed
- Days before change required
- Days warning for expiration
- Days before account inactive
- Days since epoch when account expires
- Reserved
## Display user account expiry info with chage
```BASH
chage -l <account-name>     # Show account aging info.

$ chage -l jason
# Last password change : Apr 01, 2016
# Password expires : never
# Password inactive : never
# Account expires : never
# Minimum number of days between password change : 0
# Maximum number of days between password change : 99999
# Number of days of warning before password expires : 7
```
## Change user account expiry info with chage
- -M MAX_DAYS - Set the maximum number of days during which a password is valid.
- -E EXPIRE_DATE - Date on which the user’s account will no longer be accessible.
- -d LAST_DAY - Set the last day the password was changed.
## Demo to change normal account to root
```BASH
head -n 1 /etc/passwd               # Shows the root entry, UID is 3rd field delimited by :
sudo useradd jim                    # Create normal account
sudo passwd jim                     # Change password
su - jim                            # Login to account
whoami                              # Show logged in user details
exit
sudo vi /etc/passwd                 # Edit the UID of jim to 0
su - jim
id
whoami                              # Now jim account shows root
# Show how many users have UID of 0
awk -F: '($3 == '0')' {print}       # Delimit Field by :, take the 3rd field and check if its 0 and print the line
# This will show 2 entries, one for root and other for jim
# Undo the change by editing `/etc/passwd` and updating jim's UID to original
```
## Controlling Account Access
### Locking and Unlocking accounts
```BASH
passwd -l account
passwd -u account
```
### Disabling logins for system and root accounts
- Locking with nologin as the Shell
```BASH
# Example /etc/passwd entries: for apache and www-data system accounts
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
# Using chsh :
chsh -s SHELL ACCOUNT
chsh -s /sbin/nologin jason             # Does not allow jason user to login using password
```
### Centralized Authentication
- Easy to manage users system-wide - lock account everywhere
- Example authentication systems: freeIPA, LDAP (openLDAP)
- Has drawbacks too.
### Disable Logins
- pam_nologin module
- Looks for `/etc/nologin or /var/run/nologin`
- Disables logins and displays contents of nologin file.
### Monitoring Authentication Logs
```BASH
last                # All login data
lastb               # Failed authentication
lastlog             # Last logins
# Depends on syslog configuration, logs are stored in following files:
/var/log/messages
/var/log/syslog
/var/log/secure
/var/log/auth.log
```
### Intrusion Prevention with fail2ban
- Monitors log files.
- Blocks IP address of attacker.
- Automatic unban.
- Not just for Linux logins.
### Multifactor Authentication
- Google Authenticator PAM module
- DuoSecurity’s pam_duo module
- RSA SecurID PAM module
## Security by Account Type
### Account Security - root
- Use a normal account for normal activities.
- Avoid logging in as root.
- Use sudo instead of su.
- Avoid using the same root password.
- Ensure only the root account has UID 0 - `awk -F: '($3 == "0") {print}' /etc/passwd`
### Disabling root Logins
- `/etc/securetty` - Controls root logins using terminals.
- Normal user logins don't use this file 
```BASH
# pam_securetty module - /etc/pam.d/login
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so    # Shows pam_securetty module is used
w                               # Shows the current terminal, assume tty1
vi /etc/securetty               # Remove tty1 entry from this file and save
# login to system as root and it fails as tty1 (first terminal) has been removed from logging
# Alt+Ctrl+F2  (This will use tty2 to login to the system instead of tty1 as that is no longer valid)
# Similarly F3 for tty3, F4 for tty4 and so on
# Now login as root and it works as tty2 is present in /etc/securetty file

# Empty the securetty file of all entries and save it.
# Now there is no way root can login to this system.

# Login using a normal account and that will work
```
### System / Application Accounts
- Use one account per service - web service (httpd), web service account (apache)
- Don’t activate the account.
- Don’t allow direct logins from the account - sshd_config: DenyUsers account1 accountN
- Use sudo for all access.
```BASH
sudo -u apache apachectl configtest
```
### User Accounts
- One account per person.
### Deleting Accounts
- Determine the UID - `id ACCOUNT`
- Delete their account and home directory - `userdel -r`
- Find other files that belong to them on the system.
```BASH
find / -user UID
find / -nouser
```
## Using and Configuring Sudo
### sudo vs su
- “SuperUser Do” or “Substitute User Do”
- Use instead of the su command.
- Complete shell access with su.
- With su you need to know the password of the other account.
- Breaks the Principle of Least Privilege.
- Vague audit trail with su.
### Sudo (Super User Do)
- **Elevation of Privileges** - Giving users temporary root priviledges
- Fine grain controls.
- No need to share passwords.
- Clear audit trail.
### Sudoers Format
- User Specification Format: `user host=(run_as) command`
```BASH
# Examples:
jason webdev01=(root) /sbin/apachectl
%web web*=(root) /sbin/apachectl
%wheel ALL=(ALL) ALL
```
### Sudo Authentication
- Sudo requires a user to authenticate.
- Default 5 minute grace period (timeout).
- You may not want to use a password.
```BASH
apache web*=(root) NOPASSWD:/sbin/backup-web,                # No password required to run backup-web
                   PASSWD:/sbin/apachectl                    # Password required for apache
```
### Sudo Aliases
- User_Alias
- Runas_Alias
- Host_Alias
- Cmnd_Alias
- Format: `Alias_Type NAME = item1, item2, ...`
```BASH
# Add normal users to group webteam
User_Alias WEBTEAM = jason, bob
# Give permission to group 
WEBTEAM web*=(root) /sbin/apachectl
WEBTEAM web*=(apache) /sbin/apachebackup
# Run permissions to system accounts
Runas_Alias WEBUSERS = apache, httpd
WEBTEAM web*=(WEBUSERS) /sbin/apachectl
# Host permissions to user accounts
Host_Alias WEBHOSTS = web*, prodweb01
WEBTEAM WEBHOSTS=(WEBUSERS) /sbin/apachectl
# Command permissions
Cmnd_Alias WEBCMNDS = /sbin/apachectl
WEBTEAM WEBHOSTS=(WEBUSERS) WEBCMNDS
```
```BASH
# Optimized sudoers configuration
User_Alias WEBTEAM = jason, bob
Runas_Alias WEBUSERS = apache, httpd
Host_Alias WEBHOSTS = web*, prodweb01
Cmnd_Alias WEBCMNDS = /sbin/apachectl

WEBTEAM WEBHOSTS=(root) /sbin/apachebackup
WEBTEAM WEBHOSTS=(WEBUSERS) WEBCMNDS
```
### Displaying the Sudo Configuration
- List commands you are allowed to run: `sudo -l`
- Verbose listing of commands: `sudo -ll`
- List commands another USER is allowed: `sudo -l -U user`
```BASH
# Sudo configuration
export EDITOR=nano
visudo
# Give Bob the rights to run yum command at the end of the sudoers file
bob ALL=(root) /usr/bin/yum             # save and exit
sudo -l -U bob                          # List sudo permissions for bob
sudo -ll -U bob                         # More verbose output
su - bob                                # Login as bob
sudo -l                                 # Shows current permissions
sudo yum install dstat -y               # It will work without password
exit
su -
visudo -f /etc/sudoers.d/bob            # Creates a new file inside sudoers.d
bob ALL=(ALL) /usr/bin/whoami           # Give permission to run whoami. save and exit
su - bob
whoami                                  # Gives bob as output
sudo -u jason whoami                    # Pass user as jason who runs whoami and it works as well.
# As one user can give another user access to run a command and this is dangerous.
# All sudo operations are logged inside /var/log/secure

# Allow the “bob” account to run the “reboot” command only as the “root” user on the “linuxsvr1” system
bob linuxsvr1=(root) /sbin/reboot  
```

# Network Security
## Network Services
- Called -Network services, daemons, servers.
- Listen on network ports.
- Constantly running in the background.
- Output recorded in log files.
- Designed to perform a single task.
## Securing Network Services
- Use a dedicated user for each service.
- Take advantage of privilege separation. Ports below 1024 are privileged.
- Use root to open them, then drop privileges. Configuration controlled by each service.
- Stop and uninstall unused services.
- Avoid unsecure services. Use SSH instead of telnet, rlogin, rsh, and FTP
- Stay up to date with patches. Install services provided by your distro.
- Only listen on the required interfaces and addresses.
- Information Leakage: Avoid revealing information where possible.
- Examples: Web server banners or information in `/etc/motd /etc/issue /etc/issue.net`
- Stop and Disable Services
```BASH
systemctl stop SERVICE
systemctl disable SERVICE
# Example:
systemctl stop httpd
systemctl disable httpd
```
- List Listening Programs with netstat: `netstat -nutlp`
- Port Scanning: `nmap HOSTNAME_OR_IP` or `lsof -i`
```BASH
nmap localhost
nmap 10.11.12.13
```
- Testing a Specific Port: `telnet HOST_OR_ADDRESS PORT` or `nc -v HOST_OR_ADDRESS PORT`
- Xinetd Controlled Services `/etc/xinetd.d/SERVICE`
```BASH
# To disable service:
disable = yes
# To disable xinetd:
systemctl stop xinetd
systemctl disable xinetd
```
## Securing SSH
- SSH = Secure SHell.
- Allows for key based authentication.
- Configuration: `/etc/ssh/sshd_config`
```BASH
# vi /etc/ssh/sshd_config
PubkeyAuthentication yes
PasswordAuthentication no           # Force Key Authentication
PermitRootLogin no                  # To disable root logins
PermitRootLogin without-password    # To only allow root to login with a key
AllowUsers user1 user2 userN        # Only Allow Certain Users SSH Access
AllowGroups group1 group2 groupN    # Only Allow Certain Groups SSH Access
DenyUsers user1 user2 userN         # Deny Certain Users SSH Access
DenyGroups group1 group2 groupN     # Deny Certain Groups SSH Access
AllowTcpForwarding no               # Disable TCP Port Forwarding
GatewayPorts no
Protocol 2                          # Use SSHv2 instead of SSHv1
ListenAddress host_or_address1      # Bind SSH to a Specific Address
ListenAddress host_or_addressN      # Allow individual IP to connect to SSH, separate line for each IP
Port 2222                           # Change the Default Port. This masks port scanners
Banner none                         # Disable the Banner, or update the banner in `/etc/issue.net` to remove identifiable data like versions

# Reload the SSH Configuration
systemctl reload sshd
# Add the New Port to SELinux after changing ssh port number
semanage port -a -t ssh_port_t -p tcp PORT
semanage port -l | grep ssh

# Additional information
man ssh
man sshd
man sshd_config
```
## SSH Port Forwarding
- Expose service (database) to a client not in same network
- Forward traffic from client to a service running in remote
```BASH
# Client (Different network) ---> (SSH session on port 3306) ---> Server1 ---> (SSH session on port 22) ---> (Database on 127.0.0.0 and port 3306)
ssh -L 3306:127.0.0.1:3306 server1      # -L = forwarding
# Similarly another application can connect to Client on port 3306 and access database on server 1
# Avoid this by having firewall block connections to client

# Client (Different network) ---> (SSH session on port 8080) ---> Server1 ---> (SSH session on port 22) ---> Google.com (service on port 80)
ssh -L 8080:google.com:80 server1      # -L = forwarding
# In this case google.com will understand that traffic is originating from server1 instead of client
```
## Dynamic Port Forwarding / SOCKS
```BASH
# Client (Different network) ---> (SSH session on port 8080) ---> Server1 ---> (SSH session on port 22) ---> (Internal Network)
ssh -D 8080 server1                    # -D = Dynamic forwarding
# This allows users to connect to company network
```
## Reverse Port Forwarding
- Use a proxy to direct traffic to internal network
- Connect to a desktop inside corporate network to work from home
```BASH
# (Internal Network) (SSH session on port 22) <--- (Desktop having shell program) <--- (SSH session on port 22) (Port 2222 is open to internet) <--- Server1 <--- Client (Different network)
ssh -R 2222:127.0.0.0:22               # -R = Reverse forwarding
```
# Linux Firewall Fundamentals
- Firewalls control network access.
- Linux firewall = Netfilter + IPTables
- Netfilter is a kernel framework.
- IPTables is a packet selection system.
- Use the `iptables` command to control the firewall.
## Default Tables
- Filter - Most commonly used table.
- NAT - Network Address Translation.
- Mangle - Alter packets.
- Raw - Used to disable connection tracking.
- Security - Used by SELinux.
## Default Chains
- INPUT
- OUTPUT
- FORWARD
- PREROUTING
- POSTROUTING
## Rules
- Rules = Match + Target
- Match on: Protocol, Source/Dest IP or network, Source/Dest Port, Network Interface
- Example: `protocol: TCP, source IP: 1.2.3.4, dest port: 80`
## Targets
- Built-in targets:
- ACCEPT
- DROP
- REJECT
- LOG
- RETURN
## iptables / ip6tables
- Command line interface to IPTables/netfilter.
## List / View iptables
```BASH
iptables -L                     # Display the filter table.
iptables -t nat -L              # Display the nat table.
iptables -nL                    # Display using numeric output.
iptables -vL                    # Display using verbose output.
iptables --line-numbers -L      # Use line nums.
```
## Chain Policy / Default Target
- Set the default TARGET for CHAIN: `iptables -P CHAIN TARGET`
- Example: `iptables -P INPUT DROP`
```BASH
# Appending Rules
iptables -A CHAIN RULE-SPECIFICATION
iptables [-t TABLE] -A CHAIN RULE-SPECIFICATION
# Inserting Rules
iptables -I CHAIN [RULENUM] RULE-SPECIFICATION
# Deleting Rules
iptables -D CHAIN RULE-SPECIFICATION
iptables -D CHAIN RULENUM
# Flushing rules or deleting tables
iptables [-t table] -F [chain]
```
## Rule Specification Options
```BASH
-s 10.11.12.13                          # Source IP, network, or name
-d 216.58.192.0/19                      # Destination IP, network, or name
-p tcp / udp / icmp                     # Protocol
-p tcp --dport 80                       # Destination Port
-p tcp --sport 8080                     # Source Port
-p icmp --icmp-type echo-reply          # ICMP packet type, gives pong response
-p icmp --icmp-type echo-request        # Gives ping response
# Rating limiting
-m limit --limit rate[/second/minute/hour/day] # Match until a limit is reached.
-m limit --limit-burst                  # --limit default is 3/hour and --limit-burst default is 5
-m limit --limit 5/m --limit-burst 10   # /s = second, /m = minutes
-m limit ! --limit 5/s                  # ! = invert the match
```
## Target / Jump
- To specify a jump point or target: `-j TARGET_OR_CHAIN`
```BASH
-j ACCEPT               # Built-in target.
-j DROP                 # Built-in target.
-j LOGNDROP             # Custom chain.
```
## Rule Specification Example
```BASH
# To drop all traffic from given source ip
iptables -A INPUT -s 216.58.219.174 -j DROP
# List the filter table, as the above rule didnt specify table name
iptables -nL
# Chain INPUT (policy ACCEPT)
# target prot opt source         destination
# DROP   all  --  216.58.219.174 0.0.0.0/0

# Accept SSH connection from only one network, drop all other SSH connections
iptables -A INPUT -s 10.0.0.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# DOS protection by implementing Rate limiting
iptables -I INPUT -p tcp --dport 80 \
-m limit --limit 50/min --limit-burst 200 -j REJECT
# Apply the below rate limit rule only for new connections and ignore for established connections
iptables -I INPUT -p tcp --dport 80 \
-m limit --limit 50/min --limit-burst 200 \
-m state --state NEW -j REJECT
```
## Creating and Deleting a Chain
- Create CHAIN: iptables [-t table] -N CHAIN
- Delete CHAIN: iptables [-t table] -X CHAIN
## Saving Rules
```BASH
# Debian / Ubuntu:
apt-get install iptables-persistent
netfilter-persistent save
```
## Netfilter/iptable Front-Ends
- Uses iptables command on the back-end
- Firewalld - CentOS/RHEL
- UFW - Uncomplicated FireWall (Ubuntu)
- GUFW - Graphical interface to UFW
- system-configure-firewall - CentOS/RHEL
## IP Tables Examples
```BASH
# Allow anyone to connect to webserver, but only internal ips to connect via SSH
# Block all other traffic
iptables -L                             # List the existing rules, no rules
# Accept all incoming TCP traffic on port 80
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -nL                            # List the current new rule
# Accept all incoming SSH traffic on port 22 originating from the internal network
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -j ACCEPT
# Drop all packets which dont match above 2 rules
iptables -A INPUT  -j DROP

# Testing the filters
nc -v 10.0.0.8 80                       # Net cat using an internal IP on port 80
nc -v 10.0.0.8 22                       # Test the SSH connection

# Deleting existing rule
iptables -D INPUT 1                     # Deletes the Web server traffic on port 80

nc -w 2 -v 10.0.0.8 80                  # -w specifies timeout of 2 seconds

# Reject the packets instead of dropping them
iptables -D INPUT 2                     # Deletes the drop rule
iptables -A INPUT -J REJECT             # Now rejects the packets
nc -w 2 -v 10.0.0.8 80                  # Connection refused

# Flush all existing rules
iptables -F

iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -j ACCEPT
# Create a new custom table
iptables -N LOGNDROP
# Create a rule to log all incoming traffic other than internal network SSH connection 
iptables -A LOGNDROP -p tcp -m limit --limit 5/min -j LOG --log-prefix "iptables BLOCK "
iptables -A INPUT -j LOGNDROP           # Accept and log before dropping the connection other than internal network

# In another terminal, tail the syslog file
tail -f /var/log/syslog

# Other terminal
nc -w 2 -v 10.0.0.8 80                  # This will log and drop the connection

# Persist the iptables changes after reboot
netfilter- persistent save
```
## TCP Wrappers
- Host-based networking ACL system.
- Controls access to “wrapped” services.
- A wrapped service is compiled with `libwrap` support.
- Check if a service supports wrappers use `ldd`.
```BASH
ldd /usr/sbin/sshd | grep libwrap           # Prints required shared libraries.
```
- Can control access by IP address / networks.
- Can control access by hostname.
- Transparent to the client and service.
- Used with xinetd which is a super daemon as it can manage a lot of smaller services, secures access to your server.
- Centralized management for multiple network services.
- Runtime configuration
### Configuring TCP Wrappers
- `/etc/hosts.allow` is checked first. If a match is found, **access is granted**.
- `/etc/hosts.deny` is checked next. If a match is found, **access is denied**.
### Access Rules
- The rule format for `hosts.allow` and `hosts.deny` are the same.
- One rule per line
- Format: `SERVICE(S) : CLIENT(S) [: ACTION(S) ]`
```BASH
# Deny All configuration
# /etc/hosts.deny:
ALL : ALL                                       # Deny all connections
# /etc/hosts.allow:
# Explicitly list allowed connections here.
sshd : 10.11.12.13                              # Allow only ssh connection from this ip

# Additional configuration possibilities
sshd, imapd : 10.11.12.13                       # Multiple services allowed
ALL : 10.11.12.13                               # Wild Card configuration
sshd : 10.11.12.13, 10.5.6.7                    # Multiple IPs
sshd : jumpbox.example.com                      # Domain name
sshd : .admin.example.com                       # Subdomain - server2.admin.example.com or webdev.admin.example.com
sshd : jumpbox*.example.com                     # jumpbox4admins.example.com
sshd : jumpbox0?.example.com                    # jumpbox03.example.com
sshd : 10.11.12.                                # Subnet range
sshd : 10.                                      
sshd : 10.11.0.0/255.255.0.0
sshd : /etc/hosts.sshd                          # Allow all hosts in this file
imapd : ALL                                     # Wildcard in clients
sshd : ALL EXCEPT .hackers.net                  # Conditions, except IP in hacker.net domains
sshd : 10.11.12.13 : severity emerg             # Actions - Log emergency messages for that ssh connection coming from IP
sshd : 10.11.12.13 : severity local0.alert      # Raise local alert
# Raise custom message
# /etc/hosts.deny:
sshd : .hackers.net : spawn /usr/bin/wall “Attack in progress.”
# Use expressions in message, %a logs client ip
sshd : .hackers.net : spawn /usr/bin/wall “Attack from %a.”

## Possible expression expansions
# %a (%A) The client (server) host address.
# %c      Client information.
# %d      The daemon process name.
# %h (%H) The client (server) host name or address.
# %n (%N) The client (server) host name.
# %p      The daemon process id.
# %s      Server information.
# %u      The client user name (or "unknown").
# %%      Expands to a single `% ́ character.
```
# File Security

## File Permissions
- first letter in `ls -l` output
- Regular file: -
- Directory: d
- Symbolic link: l
- Read: r
- Write: w
- Execute: x
## Files vs Directory
- r - Allows a file to be read. Allows file names in a directory to be read
- w - Allows a file to be modified. Allows entries to be modified within the directory
- x - Allows a file to be executed. Allows access to the contents and metdadata for entries
## Groups
- Every user in linux is in atleast one group
- Users can belong to many groups
- `group` command shows a user's group. Can also use `id -Gn`
```BASH
# Changing file permissions
ls -l sales.data                # Long list file permissions
chmod g+w sales.data            # Add Write permission to group
chmod g-w sales.data            # Remove Write permission to group
chmod u+rwx,g-x sales.data      # Add user all permissions and remove execute permission for group
chmod a=r sales.data            # Give all groups read permissions
chmod o= sales.data             # removes all permissions for others
```
## Directory permissions
- Permissions on a directory can affect the files in the directory
- If the file permissions look correct, start checking the directory permissions
- Work your way up to the root
- Use `chgrp` to change group of a file
```BASH
# Changing directory permissions
ls -l sales.data                # Long list to show current group membership
groups                          # Shows current user's groups (one is user and other is sales group)
chgrp sales sales.data          # Change file ownership from user to sales group
chmod g+w sales.data            # Give other members in sales group write access
mkdir -p /usr/local/sales       # Create a common directory for sales group
mv sales.data /usr/local/sales  # Now file and directory have the same permissions

# Verify directory permissions
mkdir -p my-cat                 # Create new directory
touch my-cat/cat                # Create new file
chmod 755 my-cat                # Modify permissions
ls -ld my-cat                   # Shows permissions
chmod 400 my-cat                # Give only read permissions
ls -ld my-cat                   # Gives permission error
chmod 500 my-cat                # Give write permission as well
ls -ld my-cat                   # Gives output
cat my-cat/cat                  # Shows file output
```
## File Creation Mask
- File creation mask are set by the admins
- This can be changed by per user basis
- File creation mask determines default permissions.
- If no mask were to be specified: deafault permissions would be **777 for directories and 666 for files**
## umask command
- Sets the file creation mask to mode, if given
- Use `-S` for symbolic notation
- Format: `umask [-S] [mode]`
- mode of umask is opposite to chmod
- chmod - adds permissions. `chmod 660` will give read and write permissions to file 
- umask - subtracts permissions. `umask 007` will give read an write permissions to file
- Common umask modes: 002, 022, 077, 007
```BASH
# Test umask
mkdir testumask
cd testumask
umask                           # Shows creation umask 0022
umask -S                        # Shows umask in symbolic mode
mkdir newdir
touch newfile
ls -l                           # Shows dir permissions = 0755 and file permissions = 0644
rm newfile
rmdir newdir
umask 007                       # Set new umask
mkdir newdir
touch newfile
ls -l                           # Shows dir permissions = 0770 and file permissions = 0660
```
## Special Modes
### Setuid
- When a process is started, it runs using the starting user's UID and GID.
- setuid = Set User ID upon execution.
- Examples of binaries running with root and setuid
```BASH
-rwsr-xr-x 1 root root /usr/bin/passwd      # Requires root permissions to modify passwd file
ping
chsh
```
- setuid files are an attack surface.
- Not honored on shell scripts.
- Octal Permissions: setuid=4, setgid=2 and sticky=1
```BASH
# Adding the Setuid Attribute
chmod u+s /path/to/file
chmod 4755 /path/to/file
# Removing the Setuid Attribute
chmod u-s /path/to/file
chmod 0755 /path/to/file
# Finding Setuid Files
find / -perm /4000 -ls              # ls also lists files
# Only the Owner Should Edit Setuid Files
Good:           Symbolic          Octal
                -rwsr-xr-x        4755
Really bad:     -rwsrwxrwx        4777
```
### Setgid
- setgid = Set Group ID upon execution.
```BASH
-rwxr-sr-x 1 root tty /usr/bin/wall     # s - set in group field
crw--w---- 1 bob tty /dev/pts/0
# Adding the Setgid Attribute
chmod g+s /path/to/file
chmod 2755 /path/to/file
# Adding the Setuid & Setgid Attributes
chmod ug+s /path/to/file
chmod 6755 /path/to/file
# Removing the Setgid Attribute
chmod g-s /path/to/file
chmod 0755 /path/to/file
# Finding Setgid Files
find / -perm /2000 -ls
```
### Setgid on Directories
- setgid on a directory causes new files to inherit the group of the directory.
- setgid causes directories to inherit the setgid bit.
- Is not retroactive. Does not apply on existing files, but new files in directories.
- Great for working with groups.
### Use an Integrity Checker
- Other options to `find`.
- Tripwire
- AIDE (Advanced Intrusion Detection
- Environment)
- OSSEC
- Samhain
- Package managers
### Sticky Bit
- Use on a directory to only allow the owner of the file/directory to delete it.
- Required on files or directories whcih are shared with multiple users or programs
```BASH
# Used on /tmp:
drwxrwxrwt 10 root root 4096 Feb 1 09:47 /tmp
# Adding the Sticky Bit
chmod o+s /path/to/directory
chmod 1777 /path/to/directory
# Removing the Sticky Bit
chmod o-t /path/to/directory
chmod 0777 /path/to/directory
```
### Reading ls Output
- A capitalized special permission means the underlying normal permission is not set.
- A lowercase special permission means the underlying normal permission set.
```BASH
# execute permission is not set for user
-rwSr--r-- 1 root root 0 Feb 14 11:21 test
# execute permission is set for the user
-rwsr--r-- 1 root root 0 Feb 14 
# execute permission is not set for group
-rwxrwSr-- 1 root root 0 Feb 14 11:21 test
# execute permission is not set for others
drwxr-xr-T 2 root root 0 Feb 14 11:30 testd
```
## File Attributes
- xattr: Supported by many file systems. ext2, ext3, ext4, XFS
### Attribute: i immutable
The file cannot be: modified, deleted, renamed, hard linked to
Unset the attribute in order to delete it.
### Attribute: a append
- Append only.
- Existing contents cannot be modified.
- Cannot be deleted while attribute is set.
- Use this attribute on log files.
- Safeguard the audit trail.
### Other Attributes
- Not every attribute is supported.
- man ext4, man xfs, man brtfs, etc.
- Example: s secure deletion
### Modifying Attributes
- Use the chattr command.
- + adds attributes.
- - removes attributes.
- = sets the exact attributes.
```BASH
# Making the hosts file immutable
lsattr /etc/hosts           # No attributes present
chattr +i /etc/hosts        # Add immutable attribute
vi /etc/hosts               # Not able to write and save
rm /etc/hosts               # Not able to delete the file
chattr -i /etc/hosts        # Remove immutable attribute  
lsattr /etc/hosts           # No attributes present
vi /etc/hosts               # Now able to write and save
chattr +i /etc/hosts        # Add immutable attribute back again

# Making the apache logs files append only
cd /var/log/httpd
chattr =a *                 # Adding append attribute to all the files inside
lsattr
echo test >> access_log     # Data will be appended
cat access_log
vi access_log               # Not able to write and save
```
## Access Control Lists
- ACL = Access Control List
- Provides additional control
- Example: Give one user access to a file.
- Traditional solution is to create another group.
- Increases management overhead of groups.
- Ensure file system mounted with ACL support
- XFS supports this by default
```BASH
# Mount files with ACL support to get this feature
mount -o acl /path/to/dev /path/to/mount
tune2fs -o acl /path/to/dev
tune2fs -l /path/to/dev | grep options      # Verify ACL
```
### Types of ACLs
- **Access** - Control access to a specific file or directory.
- **Default**- Used on directories only.
- Files without access rules use the default ACL rules.
- Not retroactive.
- Optional.
### ACLs Can Be Configured:
- Per user
- Per group
- For users not in the file’s group
- Via the effective rights mask
### Creating ACLs
- Use the setfacl command.
- May need to install the ACL tools.
- Modify or add ACLs: `setfacl -m ACL FILE_OR_DIRECTORY`
- Detecting Files with ACLs: `+` at the end of `ls -l` permissions output
```BASH
# User ACLs / Rules
# u:uid:perms               Set the access ACL for a user.
setfacl -m u:jason:rwx start.sh
setfacl -m u:sam:xr start.sh
# Group ACLs / Rules
# g:gid:perms               Sets the access ACL for a group.
setfacl -m g:sales:rw sales.txt
# Mask ACLs / Rules
# m:perms                   Sets the effective rights mask.
setfacl -m m:rx sales.txt
# Other ACLs / Rules
# o:perms                   Sets the access ACL for others.
setfacl -m o:r sales.txt
# Creating Multiple ACLs at Once
setfacl -m u:bob:r,g:sales:rw sales.txt
# Default ACLs
# d:[ugo]:perms             Sets the default ACL.
setfacl -m d:g:sales:rw sales
# Setting ACLs Recursively (-R)
setfacl -R -m g:sales:rw sales
# Removing ACLs for particular group or user
setfacl -x ACL FILE_OR_DIRECTORY
setfacl -x u:jason sales.txt        # Note: Not supposed to give permissions when deleting ACL
setfacl -x g:sales sales.txt
# Removing All ACLs
setfacl -b FILE_OR_DIRECTORY
setfacl -b sales.txt
# Viewing ACLs
getfacl sales.txt
```

```BASH
# ACL for a shared project directory
# Logged in as root user
mkdir /usr/local/project
cd /usr/local
chgrp project project/                  
chmod 775 project/                      # Give the project members access to the directory
ls -ld project/                         # Directory owned by root and project members have access
su - sam                                # Switch user
groups                                  # same is in project group
cd usr/local/project
echo stuff > notes.txt
ls -l notes.txt                         # sam is the owner of this file
# Give bob who is not a member of project group access to this file
setfacl -m u:bob:rw notes.txt           # Modify access by sam to give read and write access
getfacl notes.txt                       # List the permisions for bob
su -bob                                 # Switch user
vi notes.txt                            # bob is able to write
su -sam                                 # Switch user
setfacl -x u:bob notes.txt              # Remove the rw permissions
getfacl notes.txt                       # No permissions visble for bob

su -                                    # Switch to root
cd project
touch root-was-here                     # Create a new file owned by root in shared directory
ls -l                                   # No ACL is applied even though its in shared directory
su sam                                  # Switch to group user
echo >> root-was-here                   # Permission denied
su -                                    # Switch to root
cd /usr/local/project
setfacl -m d:g:project:rw .             # Set default ACL to project directory 
ls -ld .                                # Default ACL are added to directory denoted by +
getfacl                                 # Default ACL are added
touch test                              # Create new file
getfacl
su sam
vi test                                 # Edit is possible
setfacl -R -m g:project:rw .            # Add recursively permissions to root-was-here file as well
```
## Rootkits
- Software used to gain root access and remain undetected.
- They attempt to hide from system administrators and antivirus software.
- User space rootkits replace common commands such as ls, ps, find, netstat, etc
- Kernel space rootkits add or replace parts of the core operating system.
### Rootkit Detection
- Use a file integrity checker for user space rootkits. (AIDE, tripwire, OSSEC, etc.)
- Identify inconsistent behavior of a system.
- High CPU utilization without corresponding processes.
- High network load or unusual connections.
- Kernel mode rootkits have to be running in order to hide themselves.
- Halt the system and examine the storage.
- Use a known good operating system to do the investigation.
- Use bootable media, for example.
### Rootkit Hunter / RKHunter
- Shell script that searches for rootkits.
```BASH
rkhunter --update               # Update database
rkhunter --propupd              # Update RKHunter configurations
rkhunter -c                     # Interactive Check Mode 
cat /var/log/rkhunter.log       # Log file location
rkhunter -c --rwo               # Report only warnings
rkhunter --cronjob              # Run as cronjob

# After a fresh installation of OS
# Install RK Hunter and then update the properties and database
# Configure it to run everyday and report any issues by configuring it to log all output in a central place
# Configure Cronjob
crontab -e                      # Create a new cronjob
# At the end run at modnight everyday 
# Redirect the output to single file
0 0 * * * /usr/local/bin/rkhunter --cronjob --update > /var/tmp/rkhunter.cronlog 2>&1 
```
### [OSSEC](http://ossec.github.io/)
- Host Intrusion Detection System (HIDS)
- More than just rookit detection: log analysis, file integrity checking, alerting.
- Syscheck module - user mode rootkit detection.
- Rootcheck module - both user mode and kernel mode rootkit detection.
### Rootkit Removal
- Keep a copy of the data if possible.
- Learn how to keep it from happening again.
- Reinstall core OS components and start investigating. Not recommended. Easy to make a mistake.
- Safest is to reinstall the OS from trusted media.
### Rootkit Prevention
- Use good security practices: Physical, Account Network
- Use file integrity monitoring: AIDE,Tripware, OSSEC
- Keep your systems patched.
```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```

```BASH

```