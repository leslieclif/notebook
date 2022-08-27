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

```