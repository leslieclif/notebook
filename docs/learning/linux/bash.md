## Important 
- Use Lowercase for user variables. UPPERCASE reserved for env variables set by the OS or Shell startup variables
- Run `man test` to find all testing conditions. For example to test if input is a file (-f) or a directory (-d)
- Use `[[ test ]]` as it is a best practise while testing conditions
- Arithmatic operations have to be enclosed by `(())`
- Example: `a=5,b=6,c=$((a+b))`
- `kill -l` shows all kill signals that are available
## BASH
```BASH
echo $0                 # Shows the default shell that is configured
cat /etc/shells         # Shows all the configured shells for the user
cat /etc/passwd         # Shows the configured default shell for the user

# Script execution
echo $PATH              # Shows all the paths where the shell will look for executables
mkdir -p scripts        # Create a custom script directory to store common task scripts
export PATH='${PATH}:${HOME}/scripts' # Appends custom scripts directory to PATH variable
```
## SHEBANG
- Shebang tells the shell which **interpretor** to use.
- Shebang is **NOT** a comment. `#!` tells shell its a shebang
- For python, it would be python interpretor, for shell scripts it would be bash. 
```BASH
which bash              # Shows the path where bash is installed for the user
which -a bash           # Shows all the paths for bash. Its a link
ls -li /bin/bash /usr/bin/bash      # Output shows the same INODE number, so it verfies that its the same bash file that is linked
# Inside the script file scripts/my_first_script.sh
#!/bin/bash             # path of bash found from `which -a bash`      
# For Python
#!/usr/bin/python       # path of which python

# Execution 
# 1. Execute the script using full path
# 2. Execute the script from inside the directory
# 3. Execute the script using bash even if 'x' permission is not present on the file
chmod -x my_first_script.sh
# Example: bash my_first_script.sh
# This way you can override the 'Permission denied' error that comes from Shebang directive
# Give executable permission
chmod +x my_first_script.sh

# source command
# Scripts can be executed using .  or source notation.
# When . is used, the script is executed in a sub-shell
# When source is used, the script is executed in the same or current shell
./my_first_script.sh        # 1st Method of execution
. my_first_script.sh        # 2nd Method of execution
source my_first_script.sh   # 3rd Method of execution
```
## Variables
```BASH
# Create Variables
# 1. Direct assignment
os=Linux                # Without any spaces between =
distro="MX Linux"       # String variable 
# No floating point variable can be defined in bash, only integers
# No special characters in variable names or starting name with number
# Display Variables
echo $os                # Display only var value
echo "I'm learning $distro" # Display inside string using ""
echo 'Im learning $distro'  # Using single quotes will print $distro as is and not expand the variable value
echo "Im learning \$os using $distro" # Using a single \ will escape the special character $ and print as string

# Display all variables in the env
set                     # Shows all set variables
env                     # Shows all env variables
printenv                # Shows all env variables
# Remove variables
unset os                # Remember there is no $

# Read-Only Variables (constant)
# Use declare syntax with -r option
declare -r logdir="/var/log"
ls $logdir
logdir=abc              # It will throw error "readonly variable"
unset logdir            # It will throw error "readonly variable"
```
## User Input
```BASH
read name               # It will wait for user to input name and press enter
echo $name              # Will show the value input by user
# Show helpful message
read -p "Enter IP Address: " ip     # This will display the message and wait for user input
# Hide the input user value
read -s -p "Enter password: " pass  # -s will not echo the input value that is typed
```
## Special Variables and Positional Arguments
```BASH
# Example
./script.sh ﬁlename1 dir1 10.0.0.1
# Where
$0 is the name of the script itself (script.sh).
$1 is the ﬁrst positional argument (ﬁlename1)
$2 is the second positional argument (dir1)
$3 is the last argument of the script (10.0.0.1)

$# is the number of the positional arguments (i.e total arguments passed)
"$*" is a string representation of all positional arguments: $1, $2, $3 ....
$? is the most recent foreground command exit status
```
## If, Elif and Else Statements
```BASH
# Structure
if [[ some_condition_is_true ]]
then
//execute this code
elif [[ some_other_condition_is_true ]]
then
//execute_this_code
else
//execute_this_code
ﬁ

### TESTING CONDITIONS => man test ###
 
### For numbers (integers) ###
# -eq   equal to
# -ne   not equal to
# -lt   less than
# -le   less than or equal to
# -gt   greater than
# -ge   greater than or equal to
 
# For files:
# -s    file exists and is not empty
# -f    file exists and is not a directory
# -d    directory exists
# -x    file is executable by the user
# -w    file is writable by the user
# -r    file is readable by the user
 
# For Strings
# =     the equality operator for strings if using single square brackets [ ]
# ==    the equality operator for strings if using double square brackets [[ ]]
# !=    the inequality operator for strings
# -n $str   str is nonzero length
# -z $str   str is zero length
 
# &&  => the logical and operator
# ||  => the logical or operator
```
## Command Substitution
- Run the shell command and store the output in a variable.
- 2 Ways to perform command substitution
1. Using `command` within back-ticks.
2. Using $(command) 
```BASH
now="`date`"          # Output of date command is stored in variable now
# Note: as output of date is a string, better to enclose the command inside double quotes
echo $now             # Shows the value
users="$(who)"        # Enclosing who command inside double quotes as its output is string
echo $users

# Piping multiple commands
output="$(ps -ef | grep bash)"
echo $output

# Getting Current Date and Time
man date                # Check the current formatting options
now=$(date +%F_%H%M)    # DD/MM/YY_HHMM
# To use this in a backup scenario
sudo tar -cvzf etc-$(date +%F_%H%M).tar.gz /etc/    # Adds current date and time to backup file
```
## Short form Comparison
```BASH
# Check for regular file
[[  -f "/tmp/text.txt" ]] && echo "file found" || echo "file not found"

# Check for file exists
[[  -e "/tmp/text.txt" ]] && echo "file exists" || echo "file not found"
```
## String Comparison
- Use single `=` when using `[]`
- Use double `==` when using `[[]]`
- Remember to use `""` to enclose the variables to avoid String spilts
```BASH
# Substring comparison
str1="Hello, Linux is a wonderful OS"
if [[ "$str1" == *"Linux"* ]]
then
    echo "Found"
fi

# String Length comparison
str1="Hello, Linux is a wonderful OS"
if [[ -z "$str1" ]]
then
    echo "String length is zero"
fi

if [[ -n "$str1" ]]
then
    echo "String length is non zero"
fi

# Elseif
i=10
if [[ $i -lt 10 ]]
then
   echo "i is less than 10."
elif [[ $i -eq 10 ]]
then
   echo "i is 10"
else
   echo "i is greater than or equal to 10."
fi
```
 ## For Loop
 - The list can be a series of strings separated by spaces, a range of numbers, output of a
command, an array, and so on.
```BASH
# Structure
for item in LIST
do
    COMMANDS
done
```
```BASH
# Example with strings list
for os in Ubuntu Kali CentOS Slackware "Mx Linux"
do
    echo "os is $os"
done

# Range
for num in {3..7}
do
    echo "num is $num"
done

# Using Step increment in range
for num in {10..100..5}             # This will start the seq from 10 and increment counter by 5 till 100
do
    echo "num is $num"
done

# Iterating over files in current directory and displaying contents
for item in ./*         # . is current dir and * is all files
do
    echo "Displaying contents of $item"
    sleep 1
    echo "cat $item"
    echo "########"
done
```
## While Loop
- The set of commands are executed as long as the given condition evaluates to true.
```BASH
# Structure
while CONDITION
do
    COMMANDS
done
```
```BASH
# Increment 
i=0
while [[ $i -lt 10 ]]
do
    echo "$i"
    let i=i+1       # OR this can also be written as ((i++))
done

# Infinite loop
while true
do
    echo "Hello"
done

# Process monitoring using Infinite Loop
while :             # This is another way to represent true
do
    output="$(pgrep -l $1)" # If process is not running, output will be 0
    if [[ -n "$output" ]]
    then
        echo "Process \"$1\" is running"
    else
        echo "Process \"$1\" is NOT running"
    fi
    sleep 3
done
```
## Case Statements
```BASH
# Structure
case EXPRESSION in
    PATTERN_1)
        STATEMENTS
        ;;
    PATTERN_2)
        STATEMENTS
        ;;
    PATTERN_N)
        STATEMENTS
        ;;
    *)
        STATEMENTS
        ;;
esac
```
```BASH
# Sample case wih different combinations
#!/bin/bash
echo -n "Enter your favorite pet: "
read PET

case $PET in
    dog)
        echo "Your favorite pet is a dog"
        ;;
    cat|Cat)
        echo "You like cats"
        ;;
    fish|"African Turtle")
        echo "Fish or Turtles are great"
        ;;
    *)
        echo "Your pets are unknown"
        ;;
esac
```
```BASH
# Another example
#!/bin/bash
if [[ $# -ne 2 ]]
then
    echo "Run the script with 2 args: SIGNAL and PID."
    exit
fi

case $1 in
    1)
        echo "Sending the SIGHUP signal to $2"
        kill -SIGHUP $2
        ;;
    2)
        echo "Sending the SIGINT signal to $2"
        kill -SIGINT $2
        ;;
    15)
        echo "Sending the SIGTERM signal to $2"
        kill -SIGTERM $2
        ;;
    *)
        echo "Signal number $1 will not be delivered"
        ;;
esac
# Now start the sleep process in the background
sleep 1000 &
pgrep sleep     # Check the PID for sleep
./signal.sh 1501 1  # Send SIGHUP to sleep process
```
## Functions
```BASH
function print_something () {
    echo "I'm a simple function"
}
# 2nd type of declaring function without the keyword
display_something () {
    echo "Print here!"
}
# Calling the functions
print_something
display_something
```
- Processing arguments is done using $1, $2 and so on. Its not done using the paranthesis.
- Here $1 is the frst argument of the function and not the script.
```BASH
# Passing Arguments and processing return code
create_files () {
    echo "Creating file $1"
    touch $1
    chmod 400 $1
    echo "Creating file $2"
    touch $2
    chmod 400 $2
    return 10
}
create_files aa.txt bb.txt
echo $?     # Prints the return code sent by the function
```
```BASH
# Processing return values
function lines_in_files () {
    grep -c "$1" "$2" 
}
# Calling function
n=$(lines_in_files "usb" "/var/log/dmesg")
echo $n
```
## Variable scopes
- Variable scope is global and is visible inside the functions
- Varibales if changed inside the function, change is done globally
- Use `local` variables inside function which is only inside function body
```BASH
#!/bin/bash
var1="AA"
var2="BB"

function funct1 () {
    echo "Inside funct1, var1=$var1 var2=$var2"
}
funct1
```
```BASH
# Using Global and Local functions
#!/bin/bash
var1="AA"
var2="BB"

function funct1 () {
    var1="XX"
    local var2="YY"
    echo "Inside funct1, var1=$var1 var2=$var2"
}
funct1
echo "After calling funct1, var1=$var1 var2=$var2"
```
## Menus in Bash
- **ITEM** is a user deﬁned variable and the **LIST** is a series of strings, numbers or output of
commands.
- **REPLY** is the number that is selected by the user.
- Menus is repeated till break command is executed or `Ctrl+C` is pressed.
- Default Prompt is `#?` and can be changed by overriding `PS3` prompt variable
```BASH
# Structure
select ITEM in LIST
do
    COMMANDS
done
```
```BASH
# Override Prompt
PS3="Choose your country: "
select COUNTRY in Germany France USA "United Kingdom"
do
    echo "COUNTRY is $COUNTRY"
    echo "REPLY is $REPLY"
done
```
```BASH
# Adding case to select
PS3="Choose your country: "
select COUNTRY in Germany France USA "United Kingdom" Quit
do
    case $REPLY in 
        1) 
            echo "You speak French"
            ;;
        2) 
            echo "You speak German"
            ;;
        3) 
            echo "You speak American English"
            ;;
        4) 
            echo "You speak UK English"
            ;;
        5) 
            echo "Quitting!!"
            break
            ;;
        *) 
            echo "Invalid Option $REPLY"
            ;;
    esac

done
```
