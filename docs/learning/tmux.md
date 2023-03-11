[Config Setup](https://thevaluable.dev/tmux-config-mouseless/#:~:text=With%20tmux%2C%20you%20can%20create,powerful%2C%20and%20easier%20to%20config.)
[Tmux Config Doc](https://caleb89taylor.medium.com/coding-like-a-hacker-in-the-terminal-79e22954968e)
[Example Tmux and Neovim](https://github.com/ctaylo21/jarvis)
```BASH
tmux ls                             # List all sessions
tmux attach -t 0                    # -t #n indicates the session number from ls output
tmux new -s work                    # Create a new session with a name
tmux rename-session -t 0 work       # Rename existing session
tmux attach -t work                 # Attach to existing session after login
tmux switch -t session_name         # Switches to an existing session named session_name
tmux list-sessions                  # Lists existing tmux sessions 
tmux detach                         # (prefix + d) detach the currently attached session
```
```BASH
# PREFIX CTRL + SPACE

# reload ~/.tmux.conf using PREFIX r

# New Window => PREFIX w

# Rename Window  => PREFIX n

# Split window vertically => PREFIX | 

# Split window horizontally => PREFIX -

# Toggle Window ALT j (previous), ALT k (next)

# Toggle Panes => PREFIX h(Left),j(Down),k(Up),l(Right)

# Synchronize-panes => PREFIX CTRL+y

# Kill Pane => PREFIX x

# Kill Window => PREFIX X
```

# Benefit
1. Connect to your remote server via SSH.
1. Launch tmux on the remote server.
1. Run a script which takes hours.
1. Close the SSH connection. The script will still run on the remote server, thanks to tmux!
1. Switch off your computer and go home.

# Workflow Recommendations

* Use a single client — Although it is possible to run multiple tmux clients by opening multiple terminal tabs or windows, I find it better to focus on one client in a single terminal window. This provides a single high-level abstraction, which is easier to reason about and interact with.
* One project per session — I will open each project, roughly mapping to a git repository in its own session. Typically I will have Vim in the first window along with a pane for running tests and any background processes like the rails server running in additional windows.
* One Vim instance per session — In order to avoid conflicts with temp files and buffers getting out of sync, I will only use a single Vim instance per tmux session. Since each session maps to a specific project, this tends to keep me safe from conflicting edits and similar complications.