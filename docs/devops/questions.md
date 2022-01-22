# Personal
1. Tell us about your roles and responsibilties
1. Any key learnings which you are proud off
# Devops
1. How will you plan a new Devops process for a Microservices Architecture?
1. What are the different phases in a Devops process and design it?
1. How will you convince a customer and teams to onboard to Devops practise?
1. What are Devops metrics?
1. Plan and Design a CI process and how will you include Secops in it to make it Devsecops?
1. Difference between CI and CD and explain that with a help of Gitflow strategy? Explain which branch is used in which process?
1. Suppose a bug comes in PR, how is the branching strategy affected? How will you sync branches which are in Testing phases with the Bugfix?
1. What are deployment strategies? (Answer Blue-Green, Canary, Rolling) What are the drawbacks and how to select an appropriate strategy in a microservices architecture?
1. Difference between git fetch and git pull
# Linux
1. How does TLS authentication happen between a client and a server?
1. How does DNS resolution happen?
1. Troubleshoot a Linux Server by checking various metrics?
1. Trobleshoot an application that is running as a service?
1. How will you find a file in the filesystem with a text "Hello" when location or filename is not known?
1. Significance of EXIT command? How will catch EXIT in a shell script (hint Trap)
# Pipelines
1. How is a pipeline triggered and describe the automation process?
1. Jenkinsfile and how is a shared library used?
1. Maven and build process plugins tht you have worked with?
1. What are steps present in a CI pipeline?
1. What base images did you use? How are various images for tooling maintained using pipelines?
1. Central pipeline libraries and how will you trigger them from code repos which have the calling function?
1. How will you build and deploy images that have been modified in a pipeline?
1. Image maintenance and the way to update them in an automated manner if the base image is modified?
# Docker
1. Dockerfile structure and its main components?
1. Explian entire process of building and deploying a image to Dockerhub or a private registry?
1. Difference between CMD and RUN?
1. Difference between CMD and ENTRYPOINT?
1. Remove unused docker containers from a machine without removing the volumes?
1. How will you exec into a running container?
# Kubernetes
1. Describe Kubernetes components?
1. Describe K8s Networking viz Container to Container communication, Pod to Pod communication and Node to Node communication?
1. Describe a Deployment resource structure and how is a service defined / mapped within it?
1. How will you scale an appliciation managed by a Deployment object without modifying the YAML? 
1. Describe an Ingress resource structure?
1. How to link a Ingress resource to a correct Ingress controller in a multi-controller environment?
1. Troubleshoot an application in a given environment, describe each step from identifying the cluster to navigating to the namespace?
1. Troubleshoot master plane when kubectl access is not present?
# Helm
1. Basic Structure of a Helmchart and explain?
1. What will happen when you deploy a helmchart and the resources already exists
1. How will you sync resources in an environment which have been modified outside the helm upgrade process?
1. How will you pass multiple values using files in command line?
# Terraform
1. What are terraform modules?
1. What are terraform providers?
1. Terraform variables and how are they used?
1. How will you override a value during execution (Hint: using tfvars)?
1. Variables defined in vars.tf and inside TFE? Which one will be picked up? How will you override them during execution?
1. How are different environments mapped in a single terraform modules