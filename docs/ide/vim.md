## Vim 
- Achieving comfort with the editor helps you focus on solving the K8s exam challenges
- [VIM Tutorial](https://www.openvim.com/)
```BASH
# Vim config to be set in the exam terminal
echo "set ts=2 sts=2 sw=2 et number ai" >> ~/.vimrc

source ~/.vimrc

################
# These stand for:
# 
# ts - tabstop to indent using 2 spaces on pressing tab key
# sts - softtabstop to move 2 cursor spaces on pressing tab key
# sw - shiftwidth to shift by 2 spaces on pressing tab key
# et - expandtab to insert space character instead of tab on pressing tab key
# number for line numbers while editing
# There is one additional useful config - ai to allow autoindent on pressing return key (but this messes when # copy pasting text)
```
## Shortcuts
```BASH
<linenumber>G               # Go to line number
:set paste                  # Tells vim to shutdown autoindent and makes it ready for paste

# Say you copy paste in wrong position and want to tab all the lines
shift + v + arrow up or down # selects all the lines for movement
<number of places to indent>+> # 2> will indent by 2 places all the selected lines
# Similarly to unindent 2<
# OR
Shift + > 
# OR
Shift + .
# Say when copying from html you also copy hidden Tab characters
:set list                   # Shows all hidden Tab characters. ^I is for Tab
:retab                      # Fix this issue by replacing ^I with spaces
# Handle multiline values like certificate data which spans multiple lines in YAML without leaving the editor
# Open the file and go to the line where you want to add this data.
# Add a | character to tell YAML this is a multi line value like request: | and Press enter
:read !base64 certificate.pem   # This will invoke base64 command on data from .pem file and read it into the next line.
# After the data is copied, indent 2> after selecting the entire contents. 
```