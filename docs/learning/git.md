# Create a new repository on the command line
git init
git add README.md
git commit -m "first commit"
git branch -M master
git remote add origin https://github.com/leslieclif/dotfiles.git
git push -u origin master

# Git Commands
cd into git folder --> ls -la --> cd .git --> ls -la
# Git help
git help <command>
# To quit help --> q	
# Best practise: Always do a pull before a push to merge changes from remote
git pull origin master
# To git add and git commit for tracked files in a single comand use -a
git commit -am "Commit message"
# Amend Commit message
git commit --amend "New commit message"
# Check for tracked files in git
git ls-files
# Back out changes that have been commited, but not pushed to remote. Once unstaged, you can remove the changes using checkout
git reset HEAD <file-name> 
git checkout -- <file-name>
# Rename file-name. It also automatically stages the changes, so need to do git add
git mv level3--file.txt level3.txt
# If file is renamed outside git, it will delete and add the files in git history and is not staged. To add new file and stage the renamed files use -A
git add -A
# Moving files and staging the changes
git mv level2.txt new-folder
# If file is moved outside git, it will delete and add the files in git history and is not staged. To add new file and stage the renamed files use -A
mv level2.txt ..
git add -A
# file renamed in OS. But say, git has identifed unwanted files during git status and you dont want to add those files, then don't use -A, use -u
# Individually add the new renamed file first then update git
git add level1.txt
git add -u
# Delete files tracked by git
git rm doomed.txt
# If file is delete outside git, it will delete and is not staged. To add and stage the deleted file  use -A
git add -A
# Git History
git log
# To quit help --> q
# Git history in one line
git log --oneline --graph --decorate
# Git history using duration
git log --since="3 days ago"
# Show all user actions
git reflog
# Show commit history --> do git log get commit id
git show <full commit id>
#TODO: Get a git diff tool
# Show git config
git config --global --list
# Compare with staging and current changes
git diff
# Compare between current changes and remote last commit
git diff HEAD
# Compare between staging and remote last commit
git diff --staged HEAD
# Compare file changes with staging and current changes
git diff -- <path to file+filename>
# Compare between commits (do git log to get commits)
git diff <commit 1> <commit 2 or HEAD>
# Compare local and remote branches
git diff master origin/master
# Compare local branches
git diff master test-branch
# Branching
# List local and remote branches
git branch -a
# Create new branch
git branch <new branch name>
# Rename local branch
git branch -m <old branch name> <new branch name>
# Delete a branch. Note: You have to be on another bracnh before you can delete the target branch
git branch -d <branch name>
# Create new branch and switch to it in single command
git checkout -b <branch name>
# Fash forward Merges  --> First switch to the target branches, do a git diff to review the changes.
git merge <source branch>
# Disable fast forward merge --> Give tracing of merge by giving a custom merge message and also the commit history of the branch
git merge <source branch> --no-ff
# Automatic merge
git merge <source branch> -m "<commit message>"
# Merge Conflict and Resolution
# Inside the merging workspace incase of conflict, open the conflicting file in editor or the merge-diff tool. Resolve conflict and close the file.
# Rebase feature branch from master
git checkout feature-branch
git rebase master
# Abort rebase
git rebase --abort
# Rebase conflict resolution --> Use merging tool to fix conflict, save and quit. Add file to git staging, then continue rebase
git rebase --continue
# Pull with Rebase (Rebase local master with remote master)
git fetch origin master (non destructive merge which only updates references)
git pull --rebase origin master
# Stash
git stash
# Stash + saving untracked files of git as well
git stash -u
# Get the stash back to local
git stash apply
# List the stash
git stash list
# Drop the stash
git stash drop
# Combination of apply and drop in one command. Brings the last saved state
git stash pop
# Multiple Stashes
git stash save "<commit message to identify stash>"
# Show any arbitary stash changes whithout popping. Do stash list first to get the stash ID
git stash show stash@{1}
# Apply any arbitary stash changes. Do stash list first to get the stash ID
git stash apply stash@{1}
# Drop any arbitary stash changes that was applied or not needed.
git stash drop stash@{1}
# Stashing changes into a new branch. First see if you have any untracked files that also needs to be saved
git stash -u 
git stash branch newbranchName
# Tagging
# Create Lightweight tag
git tag mytag
# List existing tags
git tag --list
# Delete tag
git tag --delete mytag
# Create Annotated tags (It has additional information like release notes)
git tag -a v1.0.0 -m "Release 1.0.0"
# Comparing tags
git diff v1.0.0 v1.0.1
# Tagging a specific commit ID
git tag -a v0.0.9 <commit id> -m "Release 0.0.9"
# Updating an existing tag with new commit id
git tag -a v0.0.9 -f <new commit id> -m "Correct Release 0.0.9"
# Pushing tags to remote
git push origin v1.0.0
# Pushing all local tags to remote
git push origin master --tags
# Deleting tags in remote (puting :before tag name will delete it from remote). Does not delete tag from local
git push origin :v0.0.9
# Reset HEAD position
git reset <commit id>
# Using Stash and Branch combination
# First stash the changes (WIP) in one brabch, then checkout a new test branch and then pop the changes into this test branch
git stash
git checkout -b test
git stash pop
# Cherry Pick (Hot Fix scenario)
git cherry-pick <commit-id>