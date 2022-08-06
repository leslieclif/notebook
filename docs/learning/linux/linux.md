# Introduction

- [Understanding Linux Filesystem](https://www.cyberciti.biz/tips/understanding-unixlinux-file-system-part-i.html)
- [Templates folder](https://askubuntu.com/questions/94734/what-is-the-templates-folder-in-the-home-directory-for)
- [CronTab Guru](https://crontab.guru/)

# Basic commands

???+ note "Important Commands"

    ??? summary "Terminal"
        ```BASH
        Ctrl+Alt+T          # Open the terminal
        Ctrl+D              # Close the terminal
        exit                # Close the terminal
        Ctrl + L	        # Clear the screen, but will keep the current command
        Ctrl + Shift +	    # Increases font size of the terminal
        ```
    ??? summary "Utility"
        ```BASH
        cal	                        # Calendar current month
        cal -3	                    # Current -1, Current , Current +1 month
        cal 5 1967	                # Format is (Month and Year). Gives May 1967 
        date	                    # Current date in BST (default)
        date -u                     # Current date in UTC
        date --date “30 days”	    # Gives current date + 30 days (future date)
        date --date “30 days ago”	# Gives current date – 30 days (past date)
        which echo                  # Shows where the command is stored in PATH
        hostname -I                 # Gives IP address
        echo $?                     # Gives the output 0/1 value stored after a command is run
        wc –l file1	                # Gives line count in file1
        wc file1	                # Give word count in file1
        ```
    ??? summary "History"
        ```BASH
        history	                    # List all the commands executed
        !!                          # Run the previous command
        !50                         # Run the command that is on line 50 of history output
        history –c; history –w;     # Clears history and writes back to the file
        Ctrl + r                    # reverse searches for your input. Press Esc to edit the matched command
        ```

    ??? summary "man"
        Using the Manual
        There are 8 sections in the manual. Important are 1, 5 and 8 sections
        ```BASH
        man -k <search term>	    # Search the manual for pages matching <search term>.
        man -k tmux                 # example of searching for tmux in the manual pages
        man -k "list directory contents" # Double quote seraches complete words 
        man 1 tmux                  # Opens section 1 of tmux manual page, 1 is default and can be ignored
        man ls                      # Shows section 1 of ls command
        help cd          	        # Shows the help pages if man pages are not present
        ```
    ??? summary "Redirection of Streams"
        ```BASH
        echo "Hello" 1> output.txt	    # Standard output is redirected to output.txt
        echo "Hello" > output.txt	    # Standard output is default
        echo "World" 1>> output.txt	    # Standard output is appended to output.txt
        echo "Error" 2> error.txt       # Standard error is redirected to error.txt
        cat -k bla 2>> error.txt        # Program error is redirected and appended to error.txt
        echo "Hello World" 1>> output.txt 2>> error.txt     # Use both std output and error
        cat 0< input.txt                # Standard input is read from a file and sent to cat command
        cat < input.txt                 # Standard input is default
        cat 0< input.txt 1>> output.txt 2>> error.txt       # Use all 3 data streams
        cat -k bla 1>> output.txt 2>&1  # Redirect Standard error to standard output stream and write to file
        ```
    ??? summary "Redirection to Terminals"
        ```BASH
        tty	                            # Current terminal connected to Linux, gives path
        cat < input.txt > /dev/pts/1    # In another terminal, Standard input is read from a file and sent to tty 1 terminal
        Ctrl + Alt + F1 / chvt 1	    # Goes to physical terminal with no graphics. Similarly you can change to 2 to 6 tty terminals.
        Ctrl + Alt + F7 / chvt 7	    # Comes back to Graphical terminal
        ```
    ??? summary "Piping"
        ```BASH
        date | cut --delimiter " " --fields 1   # Output of date is input to cut command
        ```
        - [Tee command](https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Tee.svg/400px-Tee.svg.png)
        - Used to store intermediate output in a file and then stream passed horizontally through the pipeline
        - tee command takes a snapshot of the standard output and then passes it along
        ```BASH
        date > date.txt | cut --delimiter " " --fields 1        
        # Output will not work and date will only be stored in file and not passed to cut command
        date | tee date.txt | cut --delimiter " " --fields 1    
        # Output of date is first stored in file, then passed to cut command for display to Standard Output
        date | tee date.txt | cut --delimiter " " --fields 1 | tee today.txt 
        cat file1.txt file2.txt | tee unsorted.txt | sort -r > reversed.txt
        # Output chaining and storing intermediate data in files
        ```
        - XARGS command (Powerful pipeline command)
        - Allows piped data into command line arguments
        - 
        ```BASH
        date | echo  
        # Output of date is passed to echo, but echo doesn't accept standard input, only commandline arguments
        date | xargs echo
        # xargs will convert standard output into command line arguments
        date | cut --delimiter " " --fields 1 | xargs echo  # Prints the day of the week
        ```
    ??? summary "Alias"
        - Used to store reusable scripts in `.bash_aliases` file
        - can be used in scripts 
        ```BASH
        alias	                # Shows all the alias setup for the user
        # Store an alias in the `.bash_aliases` file
        alias calmagic='xargs cal -A 1 -B 1 > /home/leslie/calOutput.txt'
        # In the terminal use if in a pipe command, STDOUT will be stored in a file
        echo "12 2021" | calmagic

        ``` 
    ??? summary "File System Navigation"
        ```BASH
        # File Listing
        pwd                     # Prints absolute path of current working directory(CWD)
        ls –l               	# Long list of CWD
        ls –a	                # Shows all files including hidden
        ls -F                   # Shows directories as ending with / along with other files
        stat <filename>         # Detailed file information
        file <filename>         # File type
        ls -ld                  # Detailed folder information
        # Change Directories
        cd -	                # Helps to switch directories. Like a Toggle (Alt + Tab) in windows
        cd  OR cd ~	            # User Home directory from anywhere
        cd ..                   # Back to parent directory of CWD
        ``` 
    ??? summary "Wildcards"
        [Wildcards](https://tldp.org/LDP/GNU-Linux-Tools-Summary/html/x11655.htm) and [How to use](http://www.linfo.org/wildcard.html)
        - The star wildcard has the broadest meaning of any of the wildcards, as it can represent zero characters, all single characters or any string.
        - The question mark (?) is used as a wildcard character in shell commands to represent exactly one character, which can be any single character.
        - The square wildcard can represent any of the characters enclosed in the brackets. 
        ```BASH
        ls *.txt                # Matches all txt files
        ls ???.txt              # Matches all 3 letter txt files
        ls file[123].txt        # Matches all files ending with 1 to 3 
        ls file[A-Z].txt        # Matches all files ending with A to Z
        ls file[0-9][A-Z].txt   # Matches all files ending with 0A to 9Z
        ``` 
    ??? summary "File and Folders"
        ```BASH
        # Create Operations
        touch file1                         # Creates a new file1
        echo "Hello" > hello.txt            # Creates and writes using redirection
        # -p is parent directory which is data and inside that 2 directories called sales & mkt is created
        mkdir –p /data/{sales,mkt}	     
        # Brace exapansion will allow to create folders. Sequence can be expressed as ..
        mkdir -p /tmp/{jan,feb,mar}_{2020..2023}
        # Brace expansion for files, it will create 10 files inside each folder
        touch {jan,feb,mar}_{2020..2023}/file{1..10}
        # Delete Operations
        rm file1                            # Deletes file1
        rm  *.txt                           # Deletes all txt files
        # Deletes all files and folders inside the main folder and the main folder as well
        # CAUTION: Use the recursive option with care
        rm -r /tmp/{jan,feb,mar}_{2020..2023}/   
        # Deletes only empty directories
        rmdir /tmp/                         # Skips folders which have files
        # Copy Operations
        cp /data/sales/file1 /data/mkt/file1
        cp /data/sales/* .                  # Copy all files to CWD
        cp -r /data/sales /data/backup      # Copy sales folder to backup folder
        # Move and Rename Operations
        mv file1 file2                      # Rename file in the same folder
        mv /data/mkt/ /data/hr              # Rename folder, Note the slash after first folder
        mv /data/sales/* /tmp/backup/       # Move files to new location
        mv /data/mkt/ /tmp/newFolder        # Move and rename the folder
        ``` 
    ??? summary "Nano - Editing"
        - M Key can be Alt or Cmd depending on keyboard layout
        - Enable spell checking on nano by editing `/etc/nanorc` and uncomment `set speller` in the file.
        ```BASH
        Ctrl + O                            # Write data out to file
        Ctrl + R                            # Copy contents of one file into another
        Ctrl + K                            # Cuts entire line, also used as a delete
        Alt + 6                             # Copy entire line
        Ctrl + U                            # Paste the line
        Ctrl + T                            # Spell check the file
        Alt + U                             # Undo changes
        Alt + E                             # Redo changes
        ``` 
        ```BASH
        # File operations in vi
        > filename                        	# Empties an existing file
        :x	                                # Saves file changes instead of :wq
        ```
    ??? summary "Search Files"
        ```BASH
        find ~/projects                     # Find matches of files and folders from projects and below
        find .                              # Find from CWD and below
        find . -maxdepth 1                  # Find from CWD and one level below
        find . -type f                      # Find files only
        find . -type d                      # Find folder only
        find . -maxdepth 1 -type d          # Find folder only and one level below
        find . -name "*.txt"                # Find files ending with matching patterns
        find . -maxdepth 3 -iname "*.TXT"   # Find files with case insensitive matching patterns
        find . -type f -size +100k          # Find files greater than 100 Kb
        # Find files greater than 100 Kb AND less than 5 Mb and count them
        find . -type f -size +100k -size -5M | wc -l
        # Find files less than 100 Kb OR greater than 5 Mb and count them
        find . -type f -size -100k -o -size +5M | wc -l
        ```
        - Find and Execute commands 
        ```BASH
        # Find and copy files to backup folder. `\;` denotes end of exec command
        find . -type f -size +100k -size +5M -exec cp {} ~/Desktop/backup \;
        ###
        # Find file called needle.txt inside haystack folder
        ###
        # Create 100 folders and inside each folder 100 files
        mkdir -p haystack/folder{1..100}
        touch haystack/folder{1..100}/file{1..100}
        # Create file in one random folder
        touch haystack/folder$(shuf -i 1-100 -n 1)/needle.txt
        ###
        # Finding the file using name
        find haystack/ -type f -name "needle.txt"
        # Move the file to haystack folder
        find haystack/ -type f -name "needle.txt" -exec mv {} ~/tmp/haystack \;
        ###
        ```
    ??? summary "View/Read File Contents"
        - cat
        ```BASH
        cat file1 file2 > file3             # Concatenate 2 files and write into file3
        cat –vet file3                      # displays special characters in the file e.g. EOL as $. Useful if sh files are created in windows
        ``` 
        - tac - Flips the file contents vertically
        ```BASH
        tac file3                           # Reads the file in reverse
        ```
        - rev - Reverses the contents of each line
        ```BASH
        rev file3                           # Reads the line in reverse
        ```
        - less - Allows to page through big files
        ```BASH
        less file3                          # Shows one page at a time. Use Arrow keys to scroll
        # Output of find piped to less command for scrolling
        find . -type f -name "*.txt" | less
        ```
        - head - Shows limited lines from top of output
        ```BASH
        cat file3 | head -n 3               # Shows first 3 lines
        ``` 
        - tail - Shows limited lines from bottom of output
        ```BASH
        cat file3 | tail -n 3               # Shows last 3 lines
        tail –f /var/log/messages           # follows the file and continuously shows the 10 lines 
        ``` 
    ??? summary "Sort"
        ```BASH
        sort words.txt > sorted.txt         # Sorts in Asc order and redirects to sorted.txt
        sort -r word.txt > reverse.txt      # Sorts in Des order
        sort -n numbers.txt                 # Sorts in Asc numeric order based on digit placement
        sort -nr numbers.txt                # Sorts in Des numeric order based on digit placement
        sort -u numbers0-9.txt              # Sorts and shows only unique values
        ``` 
        - Sorting data in tabular format
        ```BASH
        # Sort on the basis of file size (5th column and its numeric)
        ls -l /etc | head -n 20 | sort -k 5n    
        # Reverse (r) the output showing largest files first
        ls -l /etc | head -n 20 | sort -k 5nr
        # Sort on the basis of largest file size in human readable format
        ls -lh /etc | head -n 20 | sort -k 5hr  
        # Sort on the basis of month 
        ls -lh /etc | head -n 20 | sort -k 6M 
        ``` 
    ??? summary "Search data - grep"
        - grep is case-sensitive search command
        ```BASH
        # grep <search term> file-name
        grep e words.txt                    # Shows matching lines as STDOUT
        grep -c e words.txt                 # Counts the matching lines
        # Search in case insensitive manner
        grep -i gadsby gadsby_manuscript.txt
        # Search strings using quotes
        grep -ci "our boys" gadsby_manuscript.txt
        # Invert the search
        grep -v "our boys" gadsby_manuscript.txt
        # Searches for server and not servers. \b is the word boundary
        grep ‘\bserver\b’/etc/ntp.conf    
        # Searches for server beginning in the line. \b is the word boundary
        grep ‘^server\b’/etc/ntp.conf
        ``` 
        - Filter data using grep
        ```BASH
        ls -lF / | grep opt                 # Shows details for opt folder only
        ls -F /etc | grep -v /              # Shows only files in etc folder
        - Remove Commented and Blank Lines
        # Empty lines can be shown as ^$. –v reverses our search and –e allows more than one expression. O/p is sent to std o/p
        grep –ve ‘^#’ –ve’^$’ /etc/ntp.conf   
        # -v ^# says I don’t want to see lines starting with #. ^$ says I don’t want to see lines that begin with EOL marker
        ``` 
    ??? summary "Archival and Compression"
        - Two step process: Create the tar ball, then compress the tar
        - [Compression tool comparison](https://www.rootusers.com/gzip-vs-bzip2-vs-xz-performance-comparison/)
        ```BASH
        # Create the tar ball
        tar -cvf backup.tar file[1-3].txt   # Create, Verbose, Files to archive
        tar -tf backup.tar                  # Test for tar file without unzipping
        # Compress the tar ball
        ## 3 compression tools - gzip -> bzip2 -> xz (Compression and time increases from left to right)
        gzip backup.tar                     # Compresses the tar ball and adds .gz extension to tar ball
        gunzip backup.tar.gz                # Decompress the gzip
        ###
        bzip2 backup.tar                    # Smaller file size than gzip and adds .bz2 extension to tar ball
        bunzip2 backup.tar.bz2              # Decompress the bzip. Best used for larger file sizes
        # Open the tar ball contents
        tar -xvf backup.tar                 # Extract, Verbose, Files to unarchive
        ###
        Create tar and compress in single command
        # Adding the z option for gzip and renaming the tar as .gz
        tar -cvzf backup.tar.gz file[1-3].txt
        tar -xvzf backup.tar.gz 
        # Adding the j option for bzip2 and renaming the tar as .bz2
        tar -cvjf backup.tar.bz2 file[1-3].txt
        tar -xvjf backup.tar.bz2 
        ###
        ``` 
    ??? summary "BASH"
        ```BASH
        #!/bin/bash                         # First line in the script "SHEBANG" tells type of script
        ### 
        # To create an executable script, create a `bin` folder in your home.
        # Move all utility shell scripts to bin. Also remove .sh file extenstions
        # Make the file as executable `chmod +x data_backup`
        # Add the `~/bin` to the PATH variable
        # Edit `.bashrc` with PATH="$PATH:$HOME/bin"
        # Now all scripts in bin folder are executable from command line
        ###
        # Set and unset variables
        export $VARIABLE	        # Sets the variable
        unset VARIABLE	            # Removes the variable, NOTE – No $ in variable
        ``` 
    ??? summary "Cron Scheduling"
        ```BASH
        crontab -e <select editor>          # Opens the template crontab
        # Multiple options for each column of crontab using comma. 
        # SPACE is used to delimit the columns of crontab
        # */<value> can divide the time intervals
        ###
        # min hours "day of month" month "day of week (0-6)"
        ###
        * * * * * bash ~/data_backup.sh
        ``` 
    ??? summary "Package Management"
        ```BASH
        apt-cache search docx               # Searches apt for programs that can work with MS Word
        apt-cache show <package> | less     # Gives software information
        # Apt cache information resides in /var/lib/apt/lists
        sudo apt-get update                 # Updates the apt lists
        sudo apt-get upgrade                # Upgraded to the latest software versions from the list
        sudo apt-get install <pkg-name>     # Install package   
        sudo apt-get purge <pkg-name>       # Remove & uninstall package. Recommended approach
        sudo apt-get autoremove             # Removes any installed package dependecies
        # Package compressed archives are stored in `/var/cache/apt/archives`
        sudo apt-get clean                  # Removes all package compressed acrhives
        sudo apt-get autoclean              # Removes only package compressed acrhives that cannot be downloaded
        ``` 
        - [Source Code for apps](https://help.ubuntu.com/community/Repositories/CommandLine)
    ??? summary "OS"
        ```BASH
        uname                               # Shows kernal
        uname -o                            # Shows OS
        uname -m                            # Shows computer architecture x86_64 (64 bit), x86 (32 bit)
        lsb_release -a                      # Distro version
        ``` 
    ??? summary "Misc"
        ```BASH
        fdisk -l 	                    # Gives device wise memory details
        free / free -m	                # Gives amount of free memory
        lsblk	                        # Lists all partitions
        swapon –s	                    # List all swap files
        ps	                            # Process id of the current bash shell
        shutdown –h now / poweroff / init 0	    # Power downs the system
        restart / init 6 / reboot               # Restarts the system 
        shutdown –r + 1 “We are restarting”	    # Restarts the system give all logged in users 1 min to shut down all process
        su -	                        # Login to root
        id / id bob	                    # Shows the current user and group id
        sudo -i	                        # Interactive shell for password of the current user, to get elevated access
        ssh localhost	                # ssh connection to same server. Type exit or Ctrl + D to logout of ssh.
        who / w	                        # Gives the list of terminals that are connected and who has logged on to the server
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 
    ??? summary "Terminal"
        ```BASH
        ``` 


# Tips
- Alt + F2 Gives the run command terminal and then type gnome-system-monitor is like task Manger in windows. Gives graphical overview of the system and can kill processes.
- Putting & after any commands runs it in the background. Run jobs  to see all the background running jobs. Type fg to bring the background running jobs to the foreground. Ctrl + C to cancel the job then.
- `!<anycharacter>` will search for the last command in history starting with that character
- `!?etc` executes the last command that contains etc

# Filesystem

## Creating Partitions
fdisk or gdisk utility to partition. If Mountpoint is /, that is primary partition.
### Creating Filesystems
```BASH
mkfs.ext4 –b 4096 /dev/sdb1         # Creates 4MB block size file system
mkfs.xfs –b size=64k /dev/sdb2      # Creates 64k block size file system. Xfs is specialized filesystem
```
### Mounting Data
```BASH
mkdir –p /data/{sales,mkt}
mount /dev/sdb1 /data/sales         # Mounts device to data/sales directory
mount /dev/sdb2 /data/mkt
```
### Unmounting Data
```BASH
umount /dev/sdb1 or umount /dev/sdb{1,2}    # Unmounts both the devices
```

## Virtual Memory or Swap Filesystem
- They are temporary space requirements
- Virtual memory in Linux can be a Disk Partition or Swap file. 
- Use gdisk to create swap filesystem. Option L and then hex code 8200.
- To make the swap filesystem permanent, make an entry in `/etc/fstab` file, so changes are persistent even after system reboot.
```BASH
partprobe /dev/sdb                  # Sync saved partition in memory. Or it requires system reboot
mkswap /dev/sdb3                    # Select the right swap device to create the filesystem
swapon /dev/sdb3                    # Mount the filesystem
```
## Troubleshooting Linux filesystem
```BASH
df –hT                              # list all filesystem with space details
du –hs /etc                         # gives diskusage of etc directory with memory
dumpe2fs /dev/sdb1 | less           # human readable details for the device
dd if=/dev/sda of=/data/sales/file count=1 bs=512   # takes data backup of sda to sales/file of the first 512 bytes
dd if=/data/sales/file of=/dev/sda  # copies the data back in case of recovery
tar –cvf /data/sales/etc.tar /etc   # backs up etc directory by creating a tar file
umount /dev/sdb1                    # unmounts sales directory 
tune2fs –L “DATA” /dev/sdb1         # adding label to the file system
debugfs /dev/sdb1                   # enters debug of sdb1 directory. Type quit to exit
```

## File Permissions
```BASH
# Format for file permission :              User-Group-Others
# Symbolic Notation (Default permission)    RWX – RW  - R     
# Octal Notation                            7   - 6   - 4       
# So RWX is 111 i.e. 7, RW is 110 i.e. 6 and R is 100 i.e. 4
umask 2                         # sets default permission to all the files in the directory
chmod 777 file1                 # Changes permission for a file1
chmod u=rwx,g=rw,o=rw file 2    # Verbose way to set permissions
chmod +rx file3                 # Sets read & write for User, group and others
ls –ld /data                    # Shows permission for a single directory
chgrp users /data               # Adds users group to the directory
```
- Even if user does not have **write** access to a file, he has **delete / add** file access to a directory. 
- `chmod o+t /data` .Users can delete only their files and not other’s. Root will not be able to delete files in this directory.
- This permission is sent on the `/tmp` directory by default at installation. So only user’s own file can be deleted, not of others.

## Links (Hard and Soft Links)
- Soft links are also called as **Symbolic Links or symlinks**. Here one file will be a pointer to the other file.
- If file has more than one name, it’s called hard link.
- To find the number of sub directories , use `stat dirname`. 
- Links number -2 is the total number of sub directories. Each directory has a minimum of 2 links, hence subtract 2. 
```BASH
ln file2 file5                  #  Creates hard link between file2 and file5.
# Shows the inode number which is same i.e. the same metadata is present for both. Cat on both the files shows the same data content
ls –li file2 file5      
ln –s file3 file4               #  Creates a symlink between file 3 and file5. Cat on both the files shows the same data content
ls –li file3 file4              #  Shows the symlink, but they are different files. Inode number is different.
readlink file5                  # shows where the link is 
```
## Applying Quotas
- Quotas can be applied to Space/inodes, Group, User or File System.
```BASH
repquota –auv          # Give quota report per user space usage along with limits
quotaon /dev/sdb1      # Checks quota limit
# enable quotas and edit the hard and soft limits. Soft limit can be exceeded for 7 days, after which it is enforced.
edquota –u <username>  
# enables quota via command line. Soft limit is 21000 is 21MB, hard limit is 26MB
setquota –u <username> 21000 26000 0 0 /dev/sdb1  
```
## Directory Listing and Alias
```BASH
ls –F /dir1                   # shows directory with a / and symlink as @ at the end of the name 
ls –-color=auto /dir1         # shows the same file types in color
alias ls=’ls –-color=auto’    # creates an alias for ls with color
ls –lh file1                  # list in human readable format
ls –lt /etc                   # shows long listing with time modified in descending order
ls –ltr /etc | less           # shows reverse listing, q to quit
```
## Synchronize Directories
```BASH
mkdir /backup
rsync –av /home/ /backup/           # archive home dir to backup dir. / after home and backup is important
rsync –av --delete /home/ /backup/  # sync deletions of data as well, otherwise rsync ignores it by default
rsync –ave ssh                      # sync data between servers using e option
```
# Process Management

## Monitor Process
```BASH
which ps               # shows the installation directory for ps
uptime                 # shows the uptime of the system along with the load average in the range of 1 min, 5 mins and 15 mins
# Rule of Thumb for uptime --> Load average for single core value should be less than 1, for dual core less than 2 etc.
which uptime           # shows the installation directory for uptime
cat /proc/uptime       # shows uptime and idle time
cat /proc/loadavg      # shows load avg for 1,5 and 15 mins, active process running/total process, last process id that was issued
```
## Jobs
```BASH
sleep 180              # sleeps for 180 secs in foreground. Ctrl + Z to pause the job. Run bg to put the sleep command in background.
jobs                   # shows running jobs          
fg 1                   # puts the sleep command in foreground
```
## Managing Processes
- ps to display processes and kill to send signals. 
- **pgrep, pkill and killall** are great shortcuts. 
- The default kill signal is -15 which can also be written as **–term or –sigterm**.
- To really kill it is **-9, -kill or –sigkill**.
```BASH
echo $$                # Shows current process
ps –l                  # long listing with the process
ps –ef                 # shows all the processes for all users
ps –eaf | grep processname
pgrep nginx            # shows process ids for nginx
sleep 900&
pkill sleep            # searches for sleep process and kills it
killall sleep          # searches for all running sleep process and kills it
kill –l                # shows the multiple kill signals available
kill -9 <process id>   # forcefully terminates the process, also use kill –kill <process id> 
```
- top --> kill, renice, sort and display processes
- Running top, you can toggle between the information displayed at the top lines. l – on/off load, t – on/off tasks, m – on/off memory  
- Sorting of top is on %CPU, f – shows current fields being shown on output of top. Select the new field to sort and type s
- Type r for renice and put in the process id. Esc and Enter to quit the shell
- Type k for kill and put in the process id. Esc and Enter to quit the shell
- q to quit out of top
```BASH
top                    # shows all running processes, q to quit
top –n 1               # shows the running processes for 1 capture and quits
top –n 2 –d 3          # shows 2 captures with a delay of 3 seconds and quits
```
# Editors
## Vi
```BASH
:               # Last line mode
q, q!           # quit the file
x, wq, wq!      # save and exit the file
i, I            # insert from cursor position, I for inserting from start of the line
a, A            # append after the cursor, A for append from last character in the line
o, O            # insert line below the cursor, O for above the current cursor position
dd              # delete the line
u               # undo the changes
```
## Line Navigation
```BASH
<Linenumber>G                   # e.g. 7G, takes cursor to 7th line in the file
G                               # only G takes cursor to end of file
w , b                           # w takes cursor to next word, b takes cursor to one word before
^ , $                           # ^takes cursor to start of line, $ to end of the line
vi +127 /etc/file1              # opens the file and takes cursor to 127th line
vi +/Document /etc/file1.conf   # opens the file and takes cursor to first occurrence of “Document”
set number / set nonumber       # from last line mode, it will show and stop line number display
syntax on                       # highlighting on, e.g. xml highlighting etc.
```
## Read and Write
```BASH
r /etc/hosts           # Open an existing file, use : and then you can get content from hosts file into current file
w newfile              # :, it will copy entire file contents into newfile in the same directory
3,7w newfile           # it will copy line 3 to 7 into newfile
```
## Search and Replace
```BASH
%s/Hi/Hello            # Open an existing file, use : and you can search Hi and Replace with Hello. %s signifies entire document search
/Hello                 # searches for Hello in the document. Type n to get next occurrence, N will take cursor in reverse
1,20s/Hi/Hello         # searches for 1st 20 lines for Hi and replaces with Hello
14,20s/^/   /          # from 14th to 20th line, it will add 3 spaces from the start of the line, just like Tab
```
# BASH Scripting
## Understanding Variables
- Local variables --> accessible only to the current shell, `FRUIT=’apple’, echo $FRUIT`
- Global variables --> you need to set and then export it to make it global. `export FRUIT=’apple’`

## Simple Script
```BASH
vi hello.sh
#!/bin/bash                    # Path to the interpreter
echo “Hello World”
exit 0                         # return code, :wq
chmod +x hello.sh
hello.sh                       # execute the script as it’s in the home directory /user/bin
```
## Getting user input
```BASH
vi hello.sh
#!/bin/bash                    
echo –e “Enter your name: \c”   # -e is the escape sequence, -c is for the prompt
read INPUT_NAME                 # read the input data into a variable
echo “Hello $INPUT_NAME”
exit 0       
```
## User Input types
```BASH
$1 $2             # $1 is the 1st input parameter, 2nd Parameter and so on.
$0                # is the script name itself
$#                # count of input parameters
$*                # is collection of all the arguments
```
## Multiple inputs using positional parameters
```BASH
vi hello.sh
#!/bin/bash          
echo “Hello $1 $2”          # $1 is the 1st input parameter, $0 is the script name itself, $2 is the 2nd input parameter and so on
exit 0
```
## Code Snippets
- Gedit --> Gnome Editor --> Add the Snippet Plugin (Applications --> Accessories --> gedit.
- Preferences in gedit tab --> Plugins enable Snippet Plugin and restart gedit)
## Conditional Statement - IF
- if [[condition]]        --> testing for string condition
- if ((condition))        --> testing for numeric condition
- e.g. if (( $# < 1 ))    --> if count of input parameter 
```BASH
vi hello.sh
#!/bin/bash        
if (( $#  1 ))
   then
      echo “Usage: $0 <name>”
      exit 1
fi 
echo “Hello $1 $2”      
exit 0
```
## Case Statement
```BASH
vi hello.sh
#!/bin/bash        
if [[ ! –d $1 ]]            # if the 1st argument is not a directory
   then
      echo “Usage: $0 <directory>”
      exit 1
fi
case $2  in 
	“directory”)
		find $1 –maxdepth 1 –type d
		;;                  # break
	“link”)
		find $1 –maxdepth 1 –type l
		;;                  # break
	*)		                # default statement
		echo “Usage: $0 <directory> directory|link”
		;;
esac
exit 0 
```
## For
```BASH
vi hello.sh
#!/bin/bash        
for u in $*                             # $* is collection of arguments, u is temporary variable
  do                                    # do block
    useradd $u                          # access to temp variable is via $
    echo Password1 | passwd –stdin $u   # use the passwd command and get the user input from keyboard
    passwd –e $u                        # expire the password, so they can change it at first login
  done
echo “Finished”                         # at time of execution ./hello.sh fred mary john
```
```BASH
vi listsize.sh
#!/bin/bash        
for file in $(ls)                 # for each file, in the output of ls
  do
    [[! –f ]] && continue         # not a file then continue to next
    # use the stats to get statistics of the file, to get the last accessed date and then format the date
    LA=$(stat –c %x $file | cut –d “ ” –f1)    
    echo “$file is $(du –b $file) bytes  and was last accessed on $LA”  # use du to get file size
  done    
```
## While
```BASH
vi loop.sh
#!/bin/bash -x               # -x is for debug mode
COUNT=10
while (( COUNT > 0 )) 
  do
    echo –e “$COUNT \c”      # \c will suppress the line feed (enter)
    sleep 1
    (( COUNT -- ))           # round brackets to avoid using $ symbol
  done      
```
- Use the until when you want to stop the loop when the condition becomes true. 

# User Management
- Managing Users:  User Lifecycle ==> useradd, usermod, userdel
- Local databases ==> /etc/passwd, /etc/shadow (encrypted)
- passwd (to set the password)
- pwconv (move pass to encrypted)
- pwunconv (move back to unencrypted)
```BASH
# /etc/passwd file structure 
# It has 7 filed separated by :
Login Name, Optional encrypted password or “x”, Numerical UID, Numerical GID, Username or comment, User home directory, Optional command interpreter

# /etc/shadow file structure where the actual passwords are stored
# It has 8 filed separated by :
Login Name, encrypted password (if it begins with ! the account is locked), Date of last password change,
Minimum password age, Maximum password age, Password warning period, password inactivity, account expiry date

# /etc/login.defs
The password ageing defaults can be configured with this file
```
```BASH
useradd –D                     # shows the default settings for a user that is added
cat /etc/default/useradd       # shows where the defaults are set
useradd bob                    # only adds the user, no home directory is created. Once the user logs in, it will get created
tail -3 /etc/passwd            # shows that bob is added
useradd –m bob                 # also creates the home directory
tail -3 /etc/shadow            # shows the password for the user
passwd bob                     # add the password for bob
passwd –l bob                  # locks the account
passwd –u bob                  # unlocks the account
usermod bob –c “Bob Smith”     # adding additional details for the user
userdel –r bob                 # removes the user and home directory
```
## Group Management 
- Group Lifecycle --> groupadd, groupmod, groupdel
- Local databases --> /etc/group, /etc/gshadow (encrypted)
- gpasswd (to set password)
- newgrp (switch to new groups)
```BASH
# /etc/group structure
# It has 4 fields:
Group Name, Password, Numerical GID, User list that is comma separated

# /etc/gshadow structure
# It has 4 field:
Group Name, Encrypted password, Admin list that is comma separated, 
# this can be managed used –A cmd
# Members, this can be managed using the –M cmd
```
- Private groups are enabled by default. The user added is also added to the same group. If this is disabled, users will belong to the groups users.
- Use `useradd –N` to overwrite private groups. This can be enabled or disabled by setting USERGROUPS_ENAB in `/etc/login.defs`
```BASH

useradd –m –g users jim               # -g is Primary Group, -G is secondary groups. Secondary groups are more traditional groups
id jim
usermod –G sudo,adm jim               # added jim to secondary groups sudo, adm
useradd –N –m sally                   # adds sally to the default group
gpasswd –M jim,sally sudo             # adds 2 users to sudo group
groupadd sales
gpasswd sales                         # sets the new password for sales
newgrp sales                          # add the user to the sales group temporarily. If the user logs out, he is removed from the group
```
# Automate System Tasks
- Regular Tasks --> cron (more than once a day but misses job if turned off), anacron (run jobs missed on startup but jobs can run just once a day)
- Once Off --> at (runs at specified time and date), batch (runs when load average drops below 0.8)

## System Cron Jobs
```BASH
# /etc/crontab, /etc/cron.d           # cron files
# /etc/cron.<time>      # where time is hourly, daily, weekly and monthly, contains scripts that need to be executed
# Adding a system cron job
cd /etc/cron.d
vi daily-backup                    # add a new file
30 20 * * 1-5 root /root/back.sh   # run back.sh from Mon to Fri at 20:30 

# Adding a user cron job
crontab –e                         # edit the user crontab file
*/10 10 1 1 1 tail /etc/passwd     # Runs once on 1st day if it’s a Mon of Jan, at 10 am for every 10 mins

crontab –l                         # list all cron jobs
crontab –r                         # remove the cron job
```
```BASH
# anacron: /etc/anacrontab structure
# It has 4 fields
Period in days or macro (Daily, Monthly),
Delay ( minutes after system startup for job to run),
Job Identifier (used to name timestamp file indicating when job was last run)
Command (that needs to be executed)

@weekly 120 weekly-backup ls /etc          // weekly, 120 mins after startup it will run weekly-backup
```
## Batch
- at and batch commands
```BASH
at noon tomorrow                # Enter the command line, Ctrl + D to save
at> ls /etc                     # enter the command that needs to be executed

atq                             # shows the jobs queue
atrm                            # remove the job

batch                          # Enter the command line, Ctrl + D to save
at> ls /etc   > /root/file1    # redirect the o/p to file1. It will run if the system load avg is less than 0.8. 
```
## Security for Cron 
- Everyone is allowed to run their own cron and at jobs, unless you add entries to /etc/cron.allow or /etc/at.allow.
- No one is denied unless you add entries to /etc/cron.deny or /etc/at.deny

# Networking Fundamentals
## Network Time Protocol (NTP)
### Configuring Network Time Protocol (NTP)

```BASH
# vi /etc/ntp.conf
# prefixing i with date creates a backup of the original file. Removes commented and blank lines
sed –i.$(date +%F)  ‘/^#d;/^$/d’ /etc/ntp.conf               
```
### Implementing the configuration file changes
```BASH
vi /etc/ntp.conf              
# Add lines other can default just below the driftfile command
statsdir /var/log/ntpstats
# Delete one of the server 0 line and add the local server here
server 192.168.0.3 iburst prefer            # this will synchronize with the local server instead of on the internet debian servers
```
### Save the file and restart the service
```BASH
service ntp restart              # sudo if no access
# check if the ntpstats directory is accessible to the ntp service
# The user should be ntp and it should have write access
ls –ld /var/log/ntpstats/        
```
- Date --> Current system date and time. This is the time in memory.
- HwClock --> Hardware date and time set by the BIOS.
```BASH
hwclock –r                 # shows the hardware clock
hwclock –-systohc          # sets the hardware clock from system clock
Hwclock –-hctosys          # sets the system clock from hardware clock
```
### NTP Tools
- ntpdate (once off adjustment)
- ntpq (query the ntp server) `ntpq –p` (shows peers)
- ntpstat (Shows status but not on debian. Try ntpdc –c sysinfo)
- ntpq –c “associations”     --> shows associations

```BASH
# Configuring NTP on centos --> Install ntp
ntpdate 192.168.0.3                         # one off update with a local machine in the network
# vi /etc/ntp.conf              
# Delete one of the server 0 line and add the local server here
server 192.168.0.3 iburst prefer            # this will synchronize with the local server
systemctl start ntpd                        # save and restart
systemctl enable ntpd                       # enable to start at system startup
```
## Managing System Log Daemons
### Rocket-Fast System for Log Processing (rsyslogd)
```BASH
rsyslogd –v 
# vi /etc/rsyslog.conf
# Adding a simple log rule
# For any log event greater than or equal to info make a log entry in local5 log. Local5 could be a simple application
local5.info    /var/log/local5      
systemctl restart rsyslog.service       # restart the service
# to test this in working using command line
logger –p local5.info “Script started”  # p is priority, if you see /var/log/local5 file, the log would be present
```
### /var/log/ folder structure
- messages (Nearly everything is logged here)
- secure (su and sudo events amongst others)
- dmesg (kernel ring buffer messages)
### Logrotate
```BASH
ls /etc/cron.daily           # has the logrotate script which will rotate log files
cd /etc/logrotate.d/         # folder where all apps rotation policy is set
cp syslog local5             # copy existing app conf for local5 app
# vi local5                  # make edits to point to /var/log/local5 file
/var/log/local5 {
weekly                       # period for rotation
size +10                     # size of the file for rotation
compress                     # use compression for the rotated log file
rotate 4                     # keep 4 weeks of logs before overwriting
}
# manually running the rotate
logrotate /etc/logrotate.conf  # on execution, all files mentioned will be interrogated and log backup will be created
```
### Journalctl
- Responsible for viewing and log management. 
- Need to be a member of adm group to read this. 
- By default journal is memory resident i.e. it will be lost on restart
```BASH
journalctl                          # view the journal
journalctl –n 10                    # shows the last 10 entries
journalctl –n 10 –p err             # shows the last 10 entries with priority errors
mkdir /var/log/journal              # to make the journal data persistent
systemctl restart system-journald
systemctl status system-journald    # shows that the journal data is persistent
usermod –a –G adm username          # adding user to adm group, -a is append
chgrp –R adm /var/log/journal       # recursively give adm group access
jornalctl –-disk-usage              # shows disk usage
journalctl –-verify                 # verify the journal integrity
```
## SSH
### Remote access using SSH
- Server Configuration `/etc/ssh/sshd_config`
- The public key of the server is used to authenticate to the client.
- The public key of the server is stored in `/etc/ssh/ssh_host_rsa_key.pub`
- It is down to the client to check the public key using: `StrictHostkeyChecking`
- Server public keys are stored centrally in `/etc/ssh/ssh_known_host` or locally under `~/.ssh/known_hosts`
### SSH Server Configuration
```BASH
netstat –antl               # shows the open tcp ports of the server 
grep ssh /etc/services      # shows the services using ssh
lsof –i                     # Also shows open ports

# vi /etc/ssh/sshd_config
# Uncomment AddressFamily line and change as below
AddressFamily inet          # Now ssh will only listen on IPv6 

systemctl restart sshd

# vi /etc/ssh/sshd_config
# Uncomment below lines and modify
LoginGraceTime 1m           # To avoid denial of service attacks and freeing up your service quickly
PermitRootLogin no          # 2 level authentication, first as normal user and then root 
SyslogFacility AUTHPRIV  
ClientAliveInterval 300
ClientAliveCountMax 0
MaxSessions 10

systemctl restart sshd
```
### Client Configuration and Authentication
- Client Configuration `/etc/ssh/ssh_config` 
- Generate Private and Public keypair using ssh_keygen
- Use ssh-copy-id to copy to host we want to authenticate with.
- To provide Single Sign On using ssh-agent
- Client/User public keys are stored in `~/.ssh/authorized_keys` using ssh-copy-id.
### To connect to server using ssh
```BASH
cd                              # home directory
ls –a                           # to show all hidden files
ssh pi@192.168.0.97             # ssh using user and ip address. Add the password of the user to authenticate
cd .ssh
cat known_hosts                 # shows the client ip and public keys
exit or logout or Ctrl + D      # to end the ssh session
```
### To generate keypairs
```BASH
cd .ssh                 # On the client home directory
ssh-keygen –t rsa       # generate key pair. Private key is encrypted using a passphrase
# This will copy the generated public key to the target server. To which user’s directory at the server we will                               
# connect as. Give the password of the server’s account.
ssh-copy-id –i id_rsa.pub pi@192.168.0.97 
ssh pi@192.168.0.97     # now connect to the server using passphrase of the private key

# From another terminal say tty we can now add the private key once and don’t need to authenticate to the target server
ssh-agent bash          # fire up another bash terminal
ssh-add .ssh/id_rsa     # add the private key from the home directory. Enter the passphrase
ssh –l or ssh –L        # list all identities added
ssh pi@192.168.0.97
```
### SSH Tunnels
```BASH
ssh –f –N –L 80:localhost:80 user@s1.com    
# -f = execute in background, -N = We are not running any commands on remote host
# -L = listening on port 80, we are listening on localhost and forwarding to port 80 on the remote host
# On the remote host it has to listen on ssh called s1.com. We connect as user called user.

# Example
# Webservice on 192.168.0.3
# on a different machine, login as standard user 
cd .ssh
ssh –f –N –L 9000:localhost:80 andrew@192.168.0.3 
# we are listening on port 9000 on the localhost and forwarding traffic to port 80 om 192.168.0.3
netstat –antlp             
# we can see that localhost:9000 is listening on ssh
# On the client machine open the browser and type in http://127.0.0.1:9000 we will see the webservice data
kill <process id of ssh>   # shutdown the ssh tunneling process after finishing the work 
```
## Configuring Network Protocols in Linux
### /etc/services  
- Network services are identified by a port address
- Common services and associated port address is listed in /etc/services
- `netstat –alt` will list services listening via TCP this resolves address to name in `/etc/services`
```BASH
# To verify the above we can use strace to map the netstat data with the services that are running
strace netstat –alt 2>&1 | grep /etc/services
grep http /etc/services       # service and port mapping
```
### dig command
```BASH
which dig                   # get the path of dig
rpm –qf /usr/bin/dig        # dig is not installed by default. Hence needs to be installed.
dig –t AAAA ipv6.bbc.co.uk  # shows the IPv6 address
```
### Interface Configuration Files
```BASH
ifconfig                                                # shows ip address details
ifconfig eth0 192.168.0.99 netmask 255.255.255.0 up     # sets ip address for Ethernet card
ip address show                                         # same as ifconfig
# These settings are lost upon restart unless they are written to configuration files.
/etc/sysconfig/network-scripts/                         # centos
/etc/network/interfaces                                 # debian
```
### To make the IP address static
```BASH
cd /etc/sysconfig/network-scripts/     
vi ifcfg-ens32                   # open the config file
# Replace and add the lines
BOOTPROTO=”static”               # change from dhcp 
IPADDR=192.168.0.240             # select a static ip address
NETMASK=255.255.255.0            # add a class c subnet
GATEWAY=192.168.0.1              # add the gateway address
DNS1=8.8.8.8                     # add google as the DNS server
# Restart the services
systemctl restart network.service
```
## Networking Tools
### nmap
```BASH
nmap localhost          # shows all open ports used by localhost
nmap 192.168.0.3        # shows open ports at remote host
nmap –v 192.168.0.3     # verbose mode
nmap –iL ip.txt         # input file containing all ip address to be scanned
nmap -p 80,443 192.168.0.3 -P0  # Scan 2 ports without using ping. This is done if iptables is blocking ping
```
### netstat
```BASH
netstat –a              # shows all connections
netstat –at             # shows all tcp connections
netstat –alt            # shows all listening tcp connections
netstat –altpe          # shows all user and process ids and listening tcp connections
netstat –s              # statistics
netstat –i              # shows interfaces
netstat –g              # multicast groups
netstat –nr             # network route tables
```
### Show Sockets (ss)
```BASH
ss –t –a                                                    # shows all tcp connections
ss –o state established ‘( dport = :ssh or sport = :ssh )’  # shows all ssh connections
ss –x src /tmp/.X11-unix/*                                  # shows X11 connections using socket files
```
### lsof
```BASH
lsof –i -4             # list all ipv4 connections
lsof –i :23, 24        # list all port 22 and 23 connections
lsof –p 1385           # list process id 1385 connections
```
## Testing Network Connectivity
```BASH
ping www.centos.org                 # test network connectivity
ping –c3 www.centos.org             # sends only 3 pings
traceroute www.centos.org           # describes the route to destination from source
tracepath www.centos.org            # shows maximum transmission unit size
```
## Host Name Resolution Tools
```BASH
hostname                             # Confirms the hostname
cat /etc/hostname                    # shows the current host name
hostname myComputer                  # changes the hostname to myComputer. You need to login as root to change this
dig www.centos.org                   # resolves to ip address
dig –t MX centos.org                 # mail servers associated with centos 
```
## Managing Interfaces
```BASH
ip a s                               # Shows ip addresses
ip n s                               # Shows Neighbor shows looking at ARP cache
ip r s                               # Shows root table
ip ma s                              # Shows Multicast groups
ip l                                 # Shows network cards
ifdown eth0                          # Brings down interface
ifup eth0                            # Brings up interface
```
## Securing Access to your Server
```BASH
# Temporary disables logins for users other than root. Just the existence of this file will prevent user logins and is controlled via PAM(Pluggable Authentication Modules)
/etc/nologin 
# Create a blank file, but if the user tries to login via ssh username@localhost, the connection will be immediately closed. Only root can access the server then.
touch /etc/nologin                     
rm /etc/nologin                        # Now users can login. This can be used as a temporary measure
cd /etc/pam.d/                         # Config files for authentication modules
grep nologin *                         # Shows instances where nologin file exists
last                                   # shows last user activity present in /var/log/wtmp file.
lastlog                                # List the last login time for each user
lastlog | grep –v Never                # Reverse the grep search to check for all user logins
```
### ulimit 
- Puts restrictions on system resources
```BASH
ulimit –a                              # Shows system limitations that can be applied
ulimit –u 8000                         
# -u is for avoiding fork bombs and is defaulted to 4096. A std user can set a new value to 8000. 
# It will remain for his profile till system restart.
cd /etc/security                       # To set the limits which can be persisted even after restart
cat limits.conf                        # Shows soft (can be changed by processes) and hard (can’t be changed by processes) limits
cd limits.d/                           
# ls to see the files inside this directory. Edit the file and add an entry for the user account with soft or hard limits and save the file.
```
### Avoiding fork bombs 
- They are a potential Denial of Service Attack
```BASH
ulimit –u
##### Do not run on Production Machines. Test only in laptop #####
ps –u username | wc -l                 # Shows the number of processes running under the user and gives the count
# On the command line create a function called foo
foo(){
  echo hello
}
# Execute the function by just calling it and pressing enter
foo
# Similarly to execute a fork bomb, instead of foo, call it :
:(){
  :|:&                                # Here the function calls itself and pipes the output to itself
};:                                   # End the function with a semicolon and then call the function :
# BEWARE: Do this only at your own risk. Ensure ulimit is set to protect the resources on the server #
```
### xinetd 
- Called the super daemon as it can manage a lot of smaller services, secures access to your server
- /etc/xinetd.d  
- /etc/xinetd.conf      
- tftp server (Trivial file transfer protocol)
```BASH
# Sample configuration
service tftp {
  socket_type = dgram              # data gram
  protocol = udp
  wait = yes
  user = root
  server = /usr/sbin/in.tftpd
  server_args = -s /tftpboot       # root directory of the server
  disable =  no
}
```
### Implementing TFTP using xinetd.d service
```BASH
ls /etc/xinetd.d/                  # blank directory
yum install tftp-server tftp       # install client and server, also xinetd as it’s a dependency
vi /etc/xinetd.d/tftp              # after installation, delete disable line from the configuration to enable tftp
# if the server directory doent exist, create it
mkdir –p /var/lib/tftpboot
systemctl enable xinetd
systemctl start xinetd
netstat –aulpe | grep tftp         # shows the port
# As a root user, create a temp file inside var/lib/tftpboot directory with hello text
vi var/lib/tftpboot/file1
# Logout and login as standard user. Use TFTP to transfer the file to standard user
tftp 127.0.0.1                     # Press enter
get file1                          # Get the file1 created by root using tftp
quit
# At the same file location do a cat to see the contents of the file
cat file1
```
### TCP Wrappers 
- Alternative to firewalling on the server
```BASH
# To check if service supports TCP wrappers. Once we can determine this, we can use hosts.allow or hosts.deny 
ldd </path to service name> | grep libwrap     
# To set this up for a service, 2 entries are made
# This in /etc/hosts.allow file to allow access to 0.3 IP which is raspberry pi. tftpd is the name of the binary
in.tftpd : 192.168.0.3                         
# This in /etc/hosts.deny file to deny access to all other IP except for 0.3 IP
in.tftpd : ALL
# If the client appears in both files then allow takes precedence and access is granted
ldd /usr/sbin/xinetd | grep libwrap     
tftp 192.168.0.240                             
# login from raspberry pi and access the remote server, disable your firewall before trying this.
```
## Delegating Admin rights using sudoers
```BASH
id                         # check if the user is already an admin and part of wheel group in centos
cd /etc
grep wheel sudoers         # check the current setup
visudo                     # to edit sudoers file
%wheel ALL=(root)  ALL     # Uncomment the line for %wheel, change (ALL) to (root), so only root can change the sudoers. Save and exit
```
# Data Encryption
## Using GPG to encrypt data between users
```BASH
password=$(mkpassword –m sha-512 Password1)    # encrypt the password using sha and mkpassword and put in a variable
echo $password
for u in marta ivan ; do                       # take an input from marta and ivan for users
sudo useradd –m –p $password $u                # add the user and set the encrypted password
done                                           # Run the command and create 2 users ivan and marta
# Install GPG if not present
dkpg –S $(which gpg)
# Login as ivan and generate private and public keys for gpg encryption
su - ivan
gpg --gen-key                                   # Take the default settings
gpg --list-key                                  # List the keys
gpg --export –a <email from gpg gen-key step> > /tmp/ivankey  
# export the public key and place in tmp folder for marta to access
exit
su - marta
vi secret.txt                                   # create a plain txt file for encryption
chmod 400 secret.txt                            # make the file writeable by marta only
gpg --import /tmp/ivankey                       # import ivan public key
gpg –e –r <ivan mailid> secret.txt              # add the recipient and encrypt the file
mv secret.txt.gpg /tmp/                         # move the encrypted file to tmp and exit
su – ivan
gpg –d /tmp/secret.txt.gpg                      # decrypt the file and enter the passphrase for the private key
```
## Implementing LUKS for Full Disk Encryption 
- example Laptops, USB
```BASH
sudo apt-get install cryptsetup                 # Install LUKS tools
lsblk                                           # list the blocks
sudo fdisk /dev/sdb                             # partition the sdb drive and create a new partition called sdb1 
sudo cryptsetup –y luksFormat /dev/sdb1         # Allows to store encrypted data in this partition. Give a passphrase
sudo cryptsetup luksDump /dev/sdb1              # Shows details of the encrypted partition
sudo cryptsetup luksOpen /dev/sdb1 private_data # Assign a mapper called private_data
ls /dev/mapper                                  # Shows the new mapper setup and that is a device
sudo mkfs.ext4 /dev/mapper/private_data         # format the device as ext4
sudo mount /dev/mapper/private_data /mnt        # The device is mounted and any data that is stored will get encrypted
```
## EFS for data encryption
```BASH
sudo apt-get install ecryptfs-utils   # Install EFS tools
su – ivan                             # Login as std user
ecryptfs-setup-private                # Create a private key with passphrase. logout and login back as ivan
ls                                    # Private directory is created by EFS
echo hello > Private/data             # Write to private directory
cat Private/data                      # ivan can see the data
ecryptfs-umount-private               # unmount the private directory
ls                                    # Now ivan cannot see the data
cd /.Private/                         # Go to the ivan’s hidden Private folder with a dot
ls                                    # You can see the encrypted data file
ecryptfs-mount-private                # Mount the directory again
```

# Compiling software from source
- Install gcc compiler `sudo apt-get install gcc make`
```BASH
# go to gnu.org/software/Downloads -> coreutils -> file ending with .xz
# tar -xvJf coreutils-8.28.tar.xz   # J is for xz, j is for bzip2
# cd into src folder and select ls.c file
# Add a line in main function printf("Hello World\n"); 
# After changes, change directory one level up and run the configure script
bash configure
# This will check for any configuration changes to the src files and update the make file
# Excute the make command
make
# After binary code is compiled, it needs to be updated in OS
sudo make install
# Close the terminal and restart. New software is working ;)
```
