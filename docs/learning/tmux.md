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

# Workflow Recommendations

* Use a single client — Although it is possible to run multiple tmux clients by opening multiple terminal tabs or windows, I find it better to focus on one client in a single terminal window. This provides a single high-level abstraction, which is easier to reason about and interact with.
* One project per session — I will open each project, roughly mapping to a git repository in its own session. Typically I will have Vim in the first window along with a pane for running tests and any background processes like the rails server running in additional windows.
* One Vim instance per session — In order to avoid conflicts with temp files and buffers getting out of sync, I will only use a single Vim instance per tmux session. Since each session maps to a specific project, this tends to keep me safe from conflicting edits and similar complications.