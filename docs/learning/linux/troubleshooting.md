# Troubleshooting

???+ note "Scenarios"
    
    ??? summary "OS Debugging"
        ```BASH
        uname                               # Shows kernal
        uname -o                            # Shows OS
        uname -m                            # Shows computer architecture x86_64 (64 bit), x86 (32 bit)
        lsb_release -a                      # Distro version
        # kernel logs will be shown in dmesg command that are in memory. Will be lost at server restart.
        tail -f /var/log/kern.log           # Shows the kernel logs that are persisted even after restart.
        /usr/include/linux/capabilities.h   # Shows the Linux capabilities that are enabled
        ```

    ??? summary "Server Not reachable"
        ```BASH
        # Check server connectivity with outside world
        ping google.com             # check for a connection
        nslookup google.com         # Identify IP if DNS resolution is not working
        ping 172.10.1.2             # IP address of google
        # Check DNS resolution issues of the server
        cat /etc/hosts              # IP to DNS mapping
        ping localhost              # Check connection to itself
        cat /etc/resolv.conf        # Local DNS server details. Mostly router
        cat /etc/nsswitch.conf      # Controls the flow of traffic 
        # `hosts: files dns myhostname
        # This entry in `nsswitch.conf`, tells the first check in hosts file
        # If IP entry is not found, go to DNS Resolver i.e resolv.conf
        # Check if server has an IP address
        ifcongfig                   # Shows the Network configurations
        # Ping Gateway to check local connectivity
        netstat -rnv                # Shows Gateway address  
        # Netstat also shows the routing to the outside world.
        # This should show the destination 0.0.0.0 route to outside world
        route -n                    # Shows the path taken by the server to reach destination
        # Trace the route taken by the server, this needs additional traceroute package
        traceroute google.com       # Shows the network path taken to reach the server
        # The router should have IPV4 routing enabled to forward packets to the next destination
        cat /etc/sysctl.conf | grep -i ipv4   # ipv4.forward should be 1 and not 0 on the router
        echo 1 > /proc/sys/net/ipv4/ip_forward # Enable routing
        ```
    ??? summary "Application / Webserver Not reachable"
        ```BASH
        # Server is reachable but application is not
        curl <IP>:<Port>            # If no response, start the service
        # Login to the server and start the service
        ps -eaf | grep ntp          # Shows if ntp process is running
        ps -eaf | grep -i network   # Check if Network manager is running
        ps -eaf | grep httpd        # If apache is down start it
        ```
    ??? summary "SSH Login Errors for root or normal users"
        ```BASH
        # Login to the server
        # Check Root can login using password. This would be off and should also be.
        # If Login is allowed, check if the password is wrong or account is locked
        # Check /var/log/secure
        more /var/log/secure        # Check the error messages
        # Check if User does not exist or has nologin shell
        id bob                      # Shows user exists
        # Check sudo permissions
        sudo -l
        vi /etc/passwd              # Shows nologin is set or not `/sbin/nologin`
        # Check if user acoount is disabled
        vi /etc/passwd              # User information is not found or is commented
        # Check if ssh service is running
        ps -eaf | grep ssh
        systemctl restart sshd
        ```
    ??? summary "Firewall"
        ```BASH
        # Connection Refused errors
        service iptables status     # Check if firewall service is running
        ps -eaf | grep iptables     # Double check if service is up
        systemctl status ufw        # Firewall service
        systemctl stop ufw          # Temporray stop firewall to check connectivity
        find /var/log -type f -mmin -1       # This will show any log file modified in the last 1 min
        ```
    ??? summary "cd"
        ```BASH
        chmod o+x secret/
        # Executable permission is required to cd into a directory for any group
        su - sam            # sam is in others group and has execute permission on dir
        cd secret           # No error
        chmod o-x secret/
        cd secret           # Will fail
        # Read allows one to see the contents.
        ls -ltr             # Will fail if read permission is not there for sam
        su -                # Login to root
        chmod a+x /root     # Give everyone permission to cd into root home directory
        su -sam
        cd /root            # Allowed
        ls -ltr             # Denied
        ```
    ??? summary "Read file or Execute a script Errors"
        ```BASH
        # Read permission is required to read a file
        chmod o-r README.md
        su - sam
        cat README.md       # This will give permission denied
        # Reading directory will aslo throw an error

        chmod a+x script
        # Executable permission is required to execute a script for any group
        # 2 ways to execute this script
        # Give absolute path
        pwd
        /home/sam/script        # This will execute
        # Give the current folder using dot notation
        ./script                # This will execute
        # Error: If none of the above is done, "Command not found" error will be thrown as its not in path
        ```
    ??? summary "Finding Files or Directories Errors"
        ```BASH
        su -                        # Login as root
        find / -name "hello.txt"    # Search for a file in the entire file system
        # Throws a permission denied error for /run/user filesystem which can be ignored
        ```
    ??? summary "Create Links Errors"
        ```BASH
        # Format: ln -s <source> <destination>
        # Important: source and directory has to be ABSOLUTE path
        ln -s hello.txt /tmp/greetings.txt  # Link will get created
        cat /tmp/greetings.txt      # No such file or directory. Why? Full path for hello.txt not given
        rm /tmp/greetings.txt       # Remove the link

        pwd
        ln -s /home/sam/hello.txt /tmp/greetings.txt  # Link will get created
        cat /tmp/greetings.txt      # No Error and file is read

        # If you switch the destination and source position, it will throw an error
        ln -s /tmp/greetings.txt /home/sam/hello.txt    # Error: File already exists

        # Source file should have read permissions
        # Owner of the source file can only create symbolic links
        # Destination where the file will land should also have read permissions for the group or others
        ```

    ??? summary "sudo"
        ```BASH
        grep sudo /etc/group            # Shows users in the sudo group at account setup
        ```

    ??? summary "nmap"
        ```BASH
        # Always output the data into a file
        nmap 10.211.55.6 -O                         # Server's operating system
        nmap 10.211.55.6 -p-                        # Scans all 65535 TCP ports, helpful for finding services listening on weird, high ports like 12380 in this case.
        nmap 10.211.55.6 -sC -o /tmp/output.txt     # Runs a set list of default scripts against your target.
        nmap 10.211.55.6 -sU –top-ports 250         # scan the 250 most common UDP ports
        ```
    ??? summary "Docker"
        ```BASH
        # Find running process
        ps faux | grep 'agent'
        # For a matched process, look at the environment variables
        xargs -0 -L1 -a /proc/1099/environ      #1099 is the process id

        # Find sensitive files
        find / -name authorized_keys 2> /dev/null
        find / -name id_rsa 2> /dev/null
        find / -type f -path '*.kube/*' -name 'config' 2> /dev/null
        find / -type f -path '*.docker/*' -name 'config.json' 2> /dev/null
        find / -name kubeconfig 2> /dev/null
        find / -name .gitconfig 2> /dev/null

        # Docker logs on the machine
        sudo find /var/lib/docker/containers/ -name *.log
        # CAP_SYS_MODULE
        # If this capabilitcy is available for user, it can easily load a new module and setup a reverse shell.
        capsh --print       # shows if enabled
        # More details on this can be found in https://greencashew.dev/posts/how-to-add-reverseshell-to-host-from-privileged-container

        # Docker or not?
        # Check /proc/1/group. Inside container it will be /docker/ 
        cat /proc/1/cgroup
        cat /proc/self/cgroup

        # Logging agent configuration
        cat /etc/ryslog.d/<any conf file>   # Check this later
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    ??? summary "Utility"
        ```BASH
        ```
    