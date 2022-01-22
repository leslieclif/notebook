- [Developer Skills Roadmap](https://github.com/kamranahmedse/developer-roadmap#introduction)
- [Devops Skills Roadmap](https://github.com/kamranahmedse/developer-roadmap#devops-roadmap)
- [Devops Skillset](https://github.com/BretFisher/ama/issues/7)
- !!! info  "Search for Autopilot and Technology to find for automation scripts or patterns"

# A DevOps Engineer 
> A DevOps Engineer works on automating the various processes and operations. Some of the responsibilities include 1) automating software code build, testing, and deployment 2) handle IT infrastructure, automate provisioning, upgrades, manage environments 3) monitor application and system performances.
- It's not really a job role, but more of a mindset of how dev's and sysadmin's come together to solve problems.
DevOps to me is like saying "We Do Agile". It speaks more to how you approach work and the team then your actual job tasking.
> Most DevOps job descriptions really just mean "We need you to take the dev team's code, and create/manage an automated path of tools that test the code, build the runtime environments (servers and containers) and get the code onto them in a reliable and consistent way."
>> **So here's a longer job description**: "We need someone who understands code and dev tools, but can also get that code setup in CI/CD, knows git, and also knows how to manage and troubleshoot servers. They know AWS/Azure and how to start from zero and build out a whole stack of services, and then back it up, monitor it for health and performance, set up logging and alerting, and maybe knows some security like TLS, SSH, certificates and key generation, IP/Sec, VPN's, Firewall basics."
- You must be a self-starter that is good at break/fix, problem analysis, and "systems thinking".
- The **three core qualities** I think that set the best of any IT role so far in front of others are:
1. Empathy, the ability to hear what others are saying and put yourself in their shoes to better understand the problem or desired outcome.
1. The drive to help others, to even put them first.
1. A deep curiosity for understanding how things work. Code, servers, or networks. Always be learning.

## Journey
- Take Linux courses. Take AWS courses. Learn a ton about networking, the OSI Layers, how TCP packets are made up, how firewalls and NAT really work.
- Learn common sysadmin CLI tools like SSH, Bash, package managers, and how drivers and system services are configured. 
- Force yourself to use network storage (NFS, iSCSI), load balancers, and do backups and restores of databases.
- Automate everything you can. Pick a system automation tool like Ansible or SaltStack or Puppet and start using it to control servers rather than manual SSH commands. 
- Pick a monitoring and logging tool and get confident in them. Use them for even your smallest personal projects.
- Learn the basics of these things, then over time, go deeper in the areas you gravitate to.
1. GitHub and Git Flow.
1. Learn AWS basics. Not just the how, but also the why and when to use each tool. Skip 75% of their products and focus on the core tools everyone uses: 1. EC2, VPC's, Security Groups, Elastic IP's, ELB's, Route 53 2.**Storage**. EBS, EFS, S3 3. Lambda, CloudWatch, CodeDeploy 4. CloudFormation ← key to AWS infrastructure automation and "infrastructure as code" but you need to know the services above first and why they exist before automating their creation.
1. Learn TCP/IP networking, NAT firewalls, and the 7 OSI layer basics.
1. Learn Jenkins and the CI/CD workflow.
1. Learn Docker, and then how to use it in Jenkins to build, test, and deploy containers to servers.
1. Learn K8s for creating a container cluster to deploy containers on many servers as easy as one.
1. Learn Linux. Take an admin course online. Pick one distribution to know better than the others.
1. Learn Ansible for automating sysadmin tasks across many servers as easy as one.
1. Learn Terraform for creating servers in any cloud via "infrastructure as code".
1. Learn Nginx or HAProxy for HTTP Reverse Proxy.
1. cAdvisor, Prometheus, and Grafana for Monitoring.
1. Use something like "swarmprom" to learn how the above tools work together to give you graphs and alerting of your apps and cluster.
1. REX-Ray, used shared network storage to store your persistent data (databases).

- Common points to consider for application deployment
1. Does the ecosystem for that language prefer file-based configs or can it also do envvar based (the best way for containers)? How should it be built for containers? Inside a language, there can be config standards that are specific to a toolkit, so there might be multiple ways depending on what the dev team is doing.
1. What are the sysadmin-concerns about that language? Does it have memory management settings that usually need to be changed (Java)? Is it single threaded so that you'll need to manage solutions for multi-core servers (Node.js)? Does it have common caching or temp dir settings and permission issues (PHP)? Does it require special ways of installing on a server that are different then developers are used to locally (lots of them, but Ruby can be the worst)?
1. Often you'll get a code repo from a developer that you need to change the way it deploys for testing and production, which means you need to understand how to install the language build/runtime environment, envvars, and dependencies. Usually, doing this on a server is different than how the developer did it on their computer.

# Devops Daily Routine
1. Create a very basic hello world app in a language of their choice.
1. Use git to commit that code to a remote git repository. Understand modern CVS workflows like pull-requests, bug tracking systems, code commits, code merges, etc.
1. Create documentation a simple way for other devs to download that repo and get started coding on it as well. (working in a team and having empathy for others is important, remember)
1. Use their choice of CI to test that app in basic ways. CI should run on every code commit.
1. Provision cloud servers, storage, networking, firewalls, and load balancers for the app.
1. Use CD to automate the deployment of code after successful CI to the servers.
1. Do this for a test and prod set of servers. Store the configs of those two environments in a way that's easily manageable and has change tracking.
1. Deploy basic backups, monitoring, alerting, and log collection. Leave the fancy stuff for Ops-focused people.
1. Do all of this "infrastructure as code" style where they use configuration files to store the settings of all these systems.

If they can do that all with the tools of their choice, then it shows they understand the full lifecycle of applications and how all the parts fit together. Understanding both the Dev and Ops roles in these basic ways helps you fully support both teams and bridge the gap.