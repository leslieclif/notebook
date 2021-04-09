* Test for tar file without unzipping
```BASH
tar -tf <tar name>
```
# Open the Terminal

```CONSOLE

```
# Basic commands

???+ note "Important Commands"

    ??? summary "Terminal"
        ```BASH
        Ctrl+Alt+T      # Open the terminal
        Ctrl+D          # Close the terminal
        exit            # Close the terminal
        Ctrl + L	    # Clear the screen, but will keep the current command
        Ctrl + Shift +	# Increases font size of the terminal
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
        ```
    ??? summary "History"
        ```BASH
        history	                    # List all the commands executed
        !!                          # Run the previous command
        !50                         # Run the command that is on line 50 of history output
        history –c; history –w;     # Clears history and writes back to the file
        ```
    ??? summary "cat"
        ```BASH
        Ctrl + L	    # Clear the screen, but will keep the current command
        Ctrl + Shift +	# Increases font size of the terminal
        ```
    ??? summary "man"
        Using the Manual
        ```BASH
        man –k <search term>	    # Search the manual for pages matching <search term>.
        man 5 <system.conf>         # Shows 5 pages where system.conf was found
        man 5 ntp.conf / 	Shows the help pages for going through configuration options

        ```
    ??? summary "Terminal"
        ```BASH
        Ctrl + L	    # Clear the screen, but will keep the current command
        Ctrl + Shift +	# Increases font size of the terminal
        ```
    ??? summary "Terminal"
        ```BASH
        Ctrl + L	    # Clear the screen, but will keep the current command
        Ctrl + Shift +	# Increases font size of the terminal
        ```
    ??? summary "Terminal"
        ```BASH
        Ctrl + L	    # Clear the screen, but will keep the current command
        Ctrl + Shift +	# Increases font size of the terminal
        ```
    ??? summary "Terminal"
        ```BASH
        Ctrl + L	    # Clear the screen, but will keep the current command
        Ctrl + Shift +	# Increases font size of the terminal
        ``` 

cd -	Helps to switch directories. Like a Toggle (Alt + Tab) in windows
cd	User Home directory from anywhere

tty	Current terminal connected to Linux
Ctrl + Alt + F1 / chvt 1	Goes to physical terminal with no graphics. Similarly you can change to 2 to 6 tty terminals.
Ctrl + Alt + F7 / chvt 7	Comes back to Graphical terminal
ssh localhost	Ssh connection to same server. Type exit or Ctrl + D to logout of ssh.
who / w	Gives the list of terminals that are connected and who has logged on to the server
fdisk -l 	Gives device wise memory details
free / free -m	Gives amount of free memory
ls –l or stat filename	Long list
ls –a	Shows all files including hidden
ps	Process id of the current bash shell
shutdown –h now / poweroff / init 0	Power downs the system
restart / init 6 / shutdown –r + 1 “We are restarting”	Restarts the machine
su -	Login to root
export $VARIABLE	Sets the variable
unset VARIABLE	Removes the variable, NOTE – No $ in variable
> filename	Empties an existing file
mkdir –p /data/{sales,mkt}	-p is parent directory which is data and inside that 2 directories called sales & mkt is created
:x	Saves file changes instead of :wq
lsblk	Lists all partitions
swapon –s	List all swap files

wc –l file1	Gives line count in file1
wc file1	Give word count in file1
alias	Shows all the alias setup for the user
id / id bob	Shows the current user and group id
sudo -i	Interactive shell for password of the current user, to get elevated access



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
```BASH
```
```BASH
```