# Troubleshooting 
- It's also important to remember that, due to its nature, in Ansible code, we describe the **desired state** rather than stating a sequence of steps to obtain the desired state.
- This difference means that the system is less prone to logical errors.
- Nevertheless, a bug in a Playbook could mean a potential misconfiguration on all of your machines. This should be taken very seriously. 
- It is even more critical when critical parts of the system are changed, such as SSH daemon or sudo configuration, since the risk is you locking yourself out of the system.
## Digging into playbook execution problems
- There are cases where an Ansible execution will interrupt. Many things can cause these situations.
- The single most frequent cause of problems I've found while executing Ansible playbooks is the network. 
- Since the machine that is issuing the commands and the one that is performing them are usually linked through the network, a problem in the network will immediately show itself as an Ansible execution problem.
- For instance, if you run the /bin/false command, it will always return 1. To execute this in a playbook so that you can avoid it blocking there, you can write something like the following:
```YAML
- name: Run a command that will return 1
  command: /bin/false
  ignore_errors: yes
```
-  Be aware that this is a particular case, and often, the best approach is to fix your application so that you're following UNIX standards and return 0 if the application runs appropriately, instead of putting a workaround in your Playbooks.
## Using host facts to diagnose failures
- Some execution failures derive from the state of the target machine. 
- The most common problem of this kind is the case where Ansible expects a file or variable to be present, but it's not.
- Sometimes, it can be enough to print the machine facts to find the problem.
```YAML
- hosts: target_host
  tasks:
    - name: Display all variables/facts known for a host
      debug:
        var: hostvars[inventory_hostname]
```
- This technique will give you a lot of information about the state of the target machine during Ansible execution.
## Testing with a playbook
- One of the most complex things in the IT field is not creating software and systems, but debugging them when they have problems. Ansible is not an exception.
- No matter how good you are at creating Ansible playbooks, sooner or later, you'll find yourself debugging a playbook that is not behaving as you thought it would.
- The simplest way of performing basic tests is to print out the values of variables during execution. 
```YAML
- hosts: localhost
  tasks:
    - shell: /usr/bin/uptime
      register: result
    - debug:
        var: result
```
- The debug module is the module that allows you to print the value of a variable (by using the var option) or a fixed string (by using the msg option) during Ansible's execution.
- The debug module also provides the verbosity option. 
```YAML
- hosts: localhost
  tasks:
    - shell: /usr/bin/uptime
      register: result
    - debug:
       var: result
       verbosity: 2
```
- We set the minimum required verbosity to 2, and by default, Ansible runs with a verbosity of 0.
- To see the result of using the debug module with this new playbook
```BASH
ansible-playbook debug2.yaml -vv
```
- By putting two -v options in the command line, we will be running Ansible with verbosity of 2. 
- This will not only affect this specific module but all the modules (or Ansible itself) that are set to behave differently at different debug levels.
## Using check mode
- Although you might be confident in the code you have written, it still pays to test it before running it for real in a production environment. 
- In such cases, it is a good idea to be able to run your code, but with a safety net in place. This is what check mode is for.
```YAML
- hosts: localhost
  tasks:
    - name: Touch a file
      file:
        path: /tmp/myfile
        state: touch
```
```BASH
ansible-playbook check-mode.yaml --check
```
- Ansible check mode is usually called a dry run. The idea is that the run won't change the state of the machine and will only highlight the differences between the current status and the status declared in the playbook.
- Not all modules support check mode, but all major modules do, and more and more modules are being added at every release. In particular, note that the command and shell modules do not support it because it is impossible for the module to tell what commands will result in a change, and what won't. Therefore, these modules will always return changed when they're run outside of check mode because they assume a change has been made. 
- A similar feature to check mode is the --diff flag. What this flag allows us to do is track what exactly changed during an Ansible execution.
```BASH
ansible-playbook check-mode.yaml --diff
```
- The output says changed, which means that something was changed (more specifically, the file was created), and in the output, we can see a diff-like output that tells us that the state moved from absent to touch, which means the file was created. mtime and atime also changed, but this is probably due to how files are created and checked.
## Solving host connection issues
- Ansible is often used to manage remote hosts or systems. To do this, Ansible will need to be able to connect to the remote host, and only after that will it be able to issue commands. 
- Sometimes, the problem is that Ansible is unable to connect to the remote host. A typical example of this is when you try to manage a machine that hasn't booted yet. Being able to quickly recognize these kinds of problems and fix them promptly will help you save a lot of time.
```YAML
- hosts: all
  tasks:
    - name: Touch a file
      file:
        path: /tmp/myfile
        state: touch
```
- We can try to run the remote.yaml playbook against a non-existent FQDN
```BASH
ansible-playbook -i host.example.com, remote.yaml
```
- The output will clearly inform us that the SSH service did not reply in time.
- SSH connections usually fail for one of two reasons:
    - The SSH client is unable to establish a connection with the SSH server
    - The SSH server refuses the credentials provided by the SSH client
- It's very probable that the IP address or the port is wrong, so the TCP connection isn't feasible. 
- Usually, double-checking the IP and the hostname (if it's a DNS, check that it resolves to the right IP) solves the problem.
- To investigate this further, you can try performing an SSH connection from the same machine to check if there are problems.
```BASH
ssh host.example.com -vvv
```
- The second problem might be a little bit more complex to debug since it can happen for multiple reasons. 
- One of those is that you are trying to connect to the wrong host and you don't have the credentials for that machine. 
- Another common case is that the username is wrong. To debug it, you can take the user@host address that is shown in the error (in my case, fale@host.example.com) and use the same command you used previously.
```BASH
ssh fale@host.example.com -vvv
```
- This should raise the same error that Ansible reported to you, but with much more details.
## Passing working variables via the CLI
- One thing that can help during debugging, and definitely helps for code reusability, is passing variables to playbooks via the command line.
- Every time your application – either an Ansible playbook or any kind of application – receives an input from a third party (a human, in this case), it should ensure that the value is reasonable. 
- An example of this would be to check that the variable has been set and therefore is not an empty string. 
- **This is a security golden rule, but should also be applied when the user is trusted since the user might mistype the variable name**. 
- The application should identify this and protect the whole system by protecting itself. 
```YAML
- hosts: localhost
  tasks:
    - debug:
       var: variable
```
- Now that we have an Ansible playbook that allows us to see if a variable has been set to what we were expecting, let's run it with variable declared in the execution statement.
```BASH
ansible-playbook printvar.yaml --extra-vars='{"variable": "Hello, World!"}'
```
- Ansible allows variables to be set in various modes and with different priorities. More specifically, you can set them with the following.
    - Command-line values (lowest priority)
    - Role defaults
    - Inventory files or script group vars
    - Inventory group_vars/all
    - Playbook group_vars/all
    - Inventory group_vars/*
    - Playbook group_vars/*
    - Inventory files or script host vars
    - Inventory host_vars/*
    - Playbook host_vars/*
    - Host facts/cached set_facts
    - Play vars
    - Play vars_prompt
    - Play vars_files
    - Role vars (defined in role/vars/main.yml)
    - Block vars (only for tasks in block)
    - Task vars (only for the task)
    - include_vars
    - set_facts/registered vars
    - Role (and include_role) params
    - include params
    - Extra vars (highest priority)
## Limiting the host's execution
- While testing a playbook, it might make sense to test on a restricted number of machines; for instance, just one. 
```YAML
- hosts: all
  tasks:
    - debug:
        msg: "Hello, World!"
```
```YAML
[hosts]
host1.example.com
host2.example.com
host3.example.com
```
- If we just want to run it against host3.example.com, we will need to specify this on the command line.
```BASH
ansible-playbook -i inventory helloworld.yaml --limit=host3.example.com
```
- By using the --limit keyword, we can force Ansible to ignore all the hosts that are outside what is specified in the limit parameter.
- It's possible to specify multiple hosts as a list or with patterns, so both of the following commands will execute the playbook against host2.example.com and host3.example.com
```BASH
ansible-playbook -i inventory helloworld.yaml --limit=host2.example.com,host3.example.com

ansible-playbook -i inventory helloworld.yaml --limit=host[2-3].example.com
```
## Flushing the code cache
- Everywhere in IT, caches are used to speed up operations, and Ansible is not an exception.
- Usually, caches are good, and for this reason, they are heavily used ubiquitously. 
- However, they might create some problems if they cache a value they should not have cached or if they are not flushed, even if the value has changed.
- Flushing caches in Ansible is very straightforward, and it's enough to run ansible-playbook, which we are already running, with the addition of the --flush-cache option
```BASH
ansible-playbook -i inventory helloworld.yaml --flush-cache
```
- Ansible uses Redis to save host variables, as well as execution variables. Sometimes, those variables might be left behind and influence the following executions. When Ansible finds a variable that should be set in the step it just started, Ansible might assume that the step has already been completed, and therefore pick up that old variable as if it has just been created. 
- By using the --flush-cache option, we can avoid this since it will ensure that Ansible flushes the Redis cache during its execution.
## Checking for bad syntax
- Defining whether a file has the right syntax or not is fairly easy for a machine, but might be more complex for humans. 
- This does not mean that machines are able to fix the code for you, but they can quickly identify whether a problem is present or not. 
- To use Ansible's built-in syntax checker, we need a playbook with a syntax error.
```YAML
- hosts: all
  tasks:
    - debug:
      msg: "Hello, World!"
```
- We can use the --syntax-check command
```BASH
ansible-playbook syntaxcheck.yaml --syntax-check
```
- Since Ansible knows all the supported options in all the supported modules, it can quickly read your code and validate whether the YAML you provided contains all the required fields and that it does not contain any unsupported fields.

