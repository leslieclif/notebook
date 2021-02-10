# Example using Docker images
```Terraform
// Main.tf
resource "docker_image" "nginx" {
    name = "nginx:latest"
    keep_locally = false
}

resource "docker_container" "nginx" {
    image = docker_image.nginx.latest
    name = "webserver"
    ports {
        internal = 80
        external = 8050
    }
}
```

# Infrastructure as Code
* IaC is an important **DevOps cornerstone** that enables you to define, automatically manage, and provision infrastructure through source code.
* Infrastructure is managed as a **software system**.
* IaC is frequently referred to as **Programmable Infrastructure**.
# Benefits of Iac
* In IaC,
+ A tool will monitor the **state of the infrastructure**.
+ A script will be sent **automatically to fix the issue**.
+ A script can be written to add new instances, and **it can be reused**.
+ **Faster process**, no/less human involvement.
# IaC Implemetation Approaches
##Declarative
+ Focuses on the **desired end state of infrastructure (Functional)**.
+ **Tools** perform the **necessary actions to reach that state**.
+ Automatically takes care of the **order and executes it**.
+ Examples are Terraform and CloudFormation.
## Imperative
+ Focuses on how to **achieve the desired state (Procedural)**.
+ Follows the **order of tasks and it executes in that order**.
+ Examples are Chef and Ansible.
# Configuration Management
* It is a **system that keeps the track** of organization's hardware, software, and other related information.
* It includes the software updates and versions present in the system.
* Configuration management is also called as **configuration control**.
* E.g.: Chef and Ansible
# Orchestration:
* It **automates the coordination, management, and configuration** of systems and hardware.
* E.g.: Terraform and Nomad
# Installing Terraform 
sudo apt-get install unzip
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
unzip terraform_0.11.11_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
# Terraform Lifecycle
* Terraform init - Initializes the working directory having Terraform configuration files.
* Terraform plan - Creates an execution plan and it mentions the changes it is going to make.
* Terraform apply - When you are not amazed by seeing the results of the terraform plan, you can go ahead and run terraform apply to apply the changes.
* The main difference between plan and apply is - apply asks for a prompt like Do you want to perform these actions? and then implement the changes, whereas, plan shows the possible end state of your infrastructure without actually implementing them.
* Terraform destroy - Destroys the created infrastructure.
# Terraform Configuration
* A set of files that describe the infrastructure in Terraform is called as Terraform Configuration.
* The entire configuration file is saved with **.tf** extension. Make sure to have all the configurations maintained in a single .tf file instead of many. Terraform loads all the .tf files present in the working directory.
# Creating Virtual Network
* create a virtual network without using the Azure portal and azure CLI commands.
```
resource "azurerm_virtual_network""myterraformnetwork"
  {
     name = "myvnet"
     address_space = ["10.0.0.0/16"]
     location="East US"
     resource_group_name="er-tyjy"
  }
```
* Resource blocks define the infrastructure (resource "azurerm_virtual_network" "myterraformnetwork"). It contains the two strings - type of the resource(azurerm_virtualnetwork) and name of the resource(myterraformnetwork).
* Terraform uses **plugin based architecture** to support the various services providers and infrastructure available.
* When you run Terraform init command, it downloads and installs provider binary for the corresponding providers. In this case, it is Azure.
* Now, you can run the terraform plan command. It shows all the changes it is going to make.
* If the output is as you expected and there are no errors, then you can run Terraform apply.
# Terraform Validate
* You can run this command whenever you like to check whether the code is correct. Once you run this command, if there is no output, it means that there are no errors in the code.
# Variables
* Terraform provides the following variable types:
+ Strings - The default data type is a **string**.
+ List - A list is like **simple arrays**
+ Map - A map value is nothing but a **lookup table for string keys** to get the string values. 


* In terraform, to **reduce the complexity of code and for easiness**, all the variables are created in the **variables.tf** file.
**variables.tf**
```
variable "rg"
{
default = "terraform-lab2"
}
variable "locations"
{ 
default = ["ap-southeast-1" , "ap-southeast-2"]
}
variable "tags"
{
  type = "map"
  default = 
        {
         environment = "training"
         source="citadel"
        }
 }
variable "images"
{
type = "map"
default = 
  {
   us-east-1 = "image-1234"
   us-east-2 = "image-4321"
  }
}
```
* For example, you have defined resource_group name in the variable.tf file. you can call them in main.tf file like this
```"${var.resource_group}"```
# Sensitive Parameters
* There may be sensitive parameters which should be shown only when running the terraform plan but not terraform apply.
```
output "sensitiveoutput" {
  sensitive = true
  value     = VALUE
}
```
* When you run terraform apply, the output is labeled as sensitive. If there is any sensitive information, then you can protect it by using a sensitive parameter.
# terraform.tfvars File
* In terraform.tfvars file, we mention the "key/value" pair.
* The main.tf file takes the input from a terraform. tfvars file. If it is not present, it gets the input from variables.tf file.
```
resource_group = "user-ybje"
location = "East US"
```
# terraform fmt
* It rewrites the confguration files to canonical style and format.
# State File - terraform.tfstate
* It is a **JSON file** that maps the real world resources to the configuration files. 
* In terraform, there are three states.
+ **Desired state** - Represents how the infrastructure to be present.
+ **Actual state** - Represents the current state of infrastructure.
+ **Known state** - To bridge desired state and actual state, there is a known state. You can get the details of known state from a tfstate file.
* When you run terraform **plan command**, terraform performs a quick refresh and lists the actions needed to achieve the desired state.
* When terraform **apply command** is run, it applies the changes and updates the actual state.
# Modules
* A module is like a reusable **blueprint of infrastructure**.
* A module is nothing but a folder of Terraform files.
* In terraform the modules are categorized into two types:
+ Root modules - The current directory of Terraform files on which you are running the commands.
+ Child modules - The modules sourced by the root module. To create a child module, add resources to it.
**Module syntax:**
```
module "child"
{
source = "../child"
}
```
* The difference between adding the resources and module is **for adding the resource** (Eg: resource "azurerm_virtual_network" 'test") you need type and name but for adding a module (Eg: module "child") only the name is enough.
* The name of the module should be **unique** within configurations because it is used as a reference to the module and outputs.

* main.tf file so that it creates three virtual networks at a time.
```
resource "azurerm_virtual_network""multiplevnets" {
   name = "multiplevnets-${count.index}"
   resource_group_name="${var.resource_group"}
   location="${var.location}"
   address_space=["10.0.0.0/16"]
   count = 3
}
```
# Updates
* **terraform get** - This command is used to download and install the modules for that configuration.
* **terraform get -update** - It checks the downloaded modules and checks for the recent versions if any.

# Module Outputs
If you need output from any module, you can get it by passing the required parameter.

For example, the output of virtual network location can be found by following the below syntax. You can add this syntax to **.tf file(main.tf or variables.tf)**.
```
output "virtual_network_id" {
value = "${azurerm_virtual_network.test.location}"
}  
```
Where virtual_network_id is a unique name and "${azurerm_virtual_network.test.location}" is the location of the virtual network using string interpolation.

# Benefits of Modules
* **Code reuse**: When there is a need to provision the group of resources on another resource at the same time, a module can be used instead of copying the same code. It helps in resolving the bugs easily. If you want to make changes, changing the code in one place is enough.
* **Abstraction layer**: It makes complex configurations easier to conceptualize.
For example, if you like to add vault(Another harshicop's tool for managing secrets) cluster to the environment, it requires dozens of components. Instead of worrying about individual components, it gives ready-to-use vault cluster.
* **Black box**: To create a vault, you only need some configuration parameters without worrying about the complexity. You don't need any knowledge on how to install vault, configuring vault cluster and working of the vault. You can create a working cluster in a few minutes.
* **Best practices in organization**: When a module is created, you can give it to the other teams. It helps in easily developing the infrastructure.
* **Versioned artifacts: They are immutable artifacts and can be promoted from one environment to others.

# Introduction to Meta Parameters
There are some difficulties with the declarative language. For example, since it is a declarative language, there is no concept of for loops. How do you repeat a piece of code without copy paste?
* Terraform provides primitives like meta parameter called as **count, life cycle blocks like create_before_destroy, ternary operator and a large number of interpolation functions**.
This helps in performing certain types of loops, if statements and zero downtime deployments.

# Count 
* Count - It defines how many parameters you like to create.

* Modify main.tf file so that it creates three virtual networks at a time.
```
resource "azurerm_virtual_network""multiplevnets" {
   name = "multiplevnets-${count.index}"
   resource_group_name="${var.resource_group"}
   location="${var.location}"
   address_space=["10.0.0.0/16"]
   count = 3
}
```
* To increase Vnets to 5, update **count = 5**.
* To decrease Vnets to 2, update **count = 2**, last 3 Vnets will get deleted.

# Elements
* Suppose you like to create the three virtual networks with names vnet-A, vnet-B and vnet-C, you can do this easily with the help of **list**.
* Mention how many vnets you are going to create with the help of list and define it in variables.tf file
```
variable "name" {
  type= "list"
  default = ["A","B","C"]
}
```
* You can call this variable in the main.tf file in the following way
+ **count = "${length(var.name)}"** - It returns number of elements present in the list. you should store it in meta parameter count.
+ **"${element(var.name,count.index)}"** - It acts as a loop, it takes the input from list and repeats until there are no elements in list.
**variables.tf **
```
variable "resource_group" {
 default = "user-nuqo"
  } 
 variable "location" { 
 default = "East US"
  }  
  variable "name" {
   type = "list"
   default = ["A","B","C"]
  }
```
**main.tf**
```
resource "azurerm_virtual_network""multiple" {
name = "vnet-${element(var.name,count.index)}"
resource_group_name = "${var.resource_group}"
location = "${var.location}"
address_space=["10.0.0.0/16"]
count="${length(var.name)}" 
}
```

# Conditions
For example, a vnet has to be created only, if the variable number of vnets is 3 or else no. You can do this by using the ternary operator.
**variables.tf**
``` 
variable "no_of_vnets" {
   default= 3
}
```
**main.tf**
``` 
count = "${var.no_of_vnets ==3 ?1  : 0}"
```
* First, it will execute the ternary operator. If it is true, it takes the output as 1 or else 0.
* Now, in the above case, the output is 1, the count becomes one, and the vnet is created.

# Inheriting Variables
* Inheriting the variables between modules keeps your Terraform code DRY.
* **Don't Repeat Yourself (DRY)**
+ It aims at **reducing repeating** patterns and code.
+ There is no need to write the **duplicate code** for each environment you are deploying.
+ You can write the **minimum code and achieve the goal** by having maximum re-usability.

# Module File Structure
* You will follow the **below file structure to inherit** the variables between modules.
```
 modules
         |
         |___mod
         |    |__mod.tf
         |
         |___vnet
              |__vnet.tf
              |__vars.tf
```                      
* There is one vnet and you can **configure the vnet** by passing the parameters from module.
* The variables in the vnet are **overriden** by the values provided in mod.tf file.
* Create a folder with name Modules
* Create two subfolders of names vnet and mod in the nested_modules folder.
* In the vnet folder, create a virtual network using Terraform configuration. Maintain two files one for **main configuration(vnet.tf) and other for declaring variables(vars.tf)**.
* Now, create main.tf file like this
```
resource "azurerm_virtual_network""vnet" {
name = "${var.name}"
address_space = ["10.0.0.0/16"]
resource_group_name = "${var.resourcegroup}"
location = "${var.location}"
}
```
* Now, vars.tf file looks like this
```
variable "name" {
description = "name of the vnet"
}

variable "resourcegroup" {
description = "name of the resource group"
}

variable "location" {
description ="name of the location"
}

variable "address" {
type ="list"
description = "specify the address"
}
```
* Create a folder with name mod in the modules directory. Create a file with name **mod.tf** and write the below code in it.
* We are passing the variables from the root module (mod) to the child module (vnet) using **source path**.
```
module "child" {
source = "../vnet"
name = "modvnet"
resourcegroup = "user-vcom"
location  = "eastus"
address = "10.0.1.0/16"
}
```
* Run terraform plan to visualize how the directories will be created. You can see the name of the vnet is taken from the module file instead of getting it from vars.tf

# Nested Modules

* For any module, root module should exist.
* Root module is basically a directory that holds the terraform configuration files for the desired infrastructure.
* They also provide the **entry point** to the nested modules you are going to utilize.
* For any module main.tf, vars.tf, and outputs.tf naming conventions are recommended.
* If you are using nested modules, create them under the **subdirectory with name modules**.
```
checking_modules
    |__modules
    |      |____main.tf
    |   
    |______virtual_network 
    |              |_main.tf
    |              |_vars.tf
    |
    |______storage_account
                      |_main.tf
                      |_vars.tf
```
* You will create three folders with names modules, virtual_network, and storage account.
* Make sure that you are following the terraform standards like writing the terraform configuration in the main file and defining the variables alone in the variables(vars.tf) file.
**stoacctmain.tf**
```
resource "azurerm_storage_account""storageacct" {
name = "${var.name}"
resource_group_name = "${var.rg}"
location = "${var.loc}"
account_replication_type = "${var.account_replication}"
account_tier = "${var.account_tier}"
}
```
**stoacctvars.tf**
```
variable "rg" {
	default = "user-wmle"
}
variable "loc" {
	default = "eastus"
}
variable "name" {
    default ="storagegh"
}
variable "account_replication" {  
	default = "LRS"
}
variable "account_tier" {
	default = "Basic"
}
```
**Root Module (main.tf) file under checking_modules**
```
module "vnet" {
source = "../virtual_network"
name = "mymodvnet"
}
module "stoacct" {
source = "../storage_account"
name = "mymodstorageaccount"
}
```
* Not only the parameters mentioned above, but you can also pass any parameter from root module to the child modules.
* You can pass the parameters from the module to avoid the duplicity between them.

# Remote Backends
* It is better to store the code in a **central repository**.
* However, is having some disadvantages of doing so:
+ You have to **maintain push, pull configurations**. If one pushes the wrong configuration and commits it, it becomes a problem.
+ State file consists of **sensitive information**. So state files are non-editable.
* Backend in terraform explains how the state file is loaded and operations are executed.
* Backend can get initialize only after running terraform init command. So, terraform init is required to be run every time
+ when backend is configured
+ when any changes made to the backend
+ when the backend configuration is removed completely
* Terraform **cannot perform auto-initialize** because it may require additional info from the user, to perform state migrations, etc..
* Below are the steps which you will be maintaining for creating **remote backend** in Azure.
+ Create a storage account
+ Create a storage container
+ Create a backend
+ Get the storage account access key and resource group name, give it as a parameter to the backend.
* Below is the complete file structure for sample backend. 
```
Backend
   |____stoacct.tf
   |____stocontainer.tf
   |____backend.tf
   |____vars.tf
   |____output.tf
```
* stoacct.tf
```
resource "azurerm_storage_account" "storageaccount" {
  name                     = "storageaccountname"
  resource_group_name      = "${var.resourcegroup}"
  location                 = "${var.location}"
  account_tier             = "${var.accounttier}"
  account_replication_type = "GRS"

  tags {
    environment = "staging"
  }
}
```
* stocontainer.tf
```
resource "azurerm_storage_container" "storagecontainer" {
  name                  = "vhds"
  resource_group_name   = "${var.resourcegroup}"
  storage_account_name  = "${azurerm_storage_account.storageaccount.name}"
  container_access_type = "private"
}
```
* vars.tf
```
variable "resourcegroup" {
default = "user-abcd"
}
variable "location" {
default = "eastus"
}
variable "accounttier" {
default = "Basic"
}
```
* output.tf
```
output "storageacctname" {
value = "${azurerm_storage_account.storageaccount.name}"
}

output "storageacctcontainer" {
value = "${azurerm_storage_account.storagecontainer.name}"
}

output "access_key" {
value = "${azurerm_storage_account.storageaccount.primary_access_key"
}
```
* Before creating backend, run the command to get the storage account keys list(**az storage account keys list --account-name storageacctname**) 
and copy one of the key somewhere. It is useful for configuring the backend.
* backend.tf
```
terraform{
	backend   "azurerm" {
	storage_account_name = "storageacct21"
	container_name = "mycontainer"
	key = "terraform.tfstate.change"
	resource_group_name = "user-okvt"
	access_key = "aJlf+XjZhxwRp4gsU4hkGrQJzO7xBzz7B9rSzMLB/ozwcM6k/1N.......==" 
	}
}
```
* where Parameters:
+ storage_account_name - name of the storage account.
+ container_name - name of the container.
+ key- name of the tfstate blob.
+ resource_group_name - name of the resource group.
+ access_key - Storage account access key(any one).
# Points to Remember
* You cannot use interpolation syntax to configure backends.
* After creating backend run terraform init, it will be in the locked state.
* By running terraform apply command automatically, the lease status is changed to locked.
* After it is applied, it will come to an unlocked state.
* This backend supports consistency checking and state locking using the native capabilities of the Azure storage account.

# Terragrunt
* Terragrunt is referred to as a thin wrapper for Terraform which provides extra tools to keep the terraform configurations DRY, 
manage remote state and to work with multiple terraform modules.
# Terragrunt Commands
* terragrunt get
* terragrunt plan
* terragrunt apply
* terragrunt output
* terragrunt destroy

* Terragrunt supports the following use cases:
+ Keeps terraform code DRY.
+ Remote state configuration DRY.
+ CLI flags DRY.
+ Executing terraform commands on multiple modules at a time.

* Advantages of using terragrunt:
+ Provides locking mechanism.
+ Allows you to use remote state always.

# Build-In Functions

# lookup
* This helps in performing a **dynamic lookup** into a map variable.

* The syntax for lookup variable is ```lookup(map,key, [default])```.
+ map: The map parameter is a variable like var.name.
+ key: The key parameter includes the key from where it should find the environment.
+ If the key doesn't exist in the map, interpolation will fail, if it doesn't find a third argument (default).

* The lookup will not work on nested lists or maps. It only works on flat maps.

# Local Values
* Local values help in **assigning names to the expressions**, which can be used multiple times within a module without rewriting it.
* Local values are defined in the local blocks.
* It is recommended to group the logically related local values together as a single block, if there is a dependency between them.
```
locals {
service_name = "Fresco"
owner = "Team"
}
```
* Example
```
locals {
  instance_ids = "${concat(aws_instance.blue.*.id, aws_instance.green.*.id)}"
}
```
* If a single value or a result is used in many places and it is likely to be changed in the future, then you can go with locals.
* It is recommended to **not use many local values** because it makes the read configurations hard to the future maintainers.

# Data Source
* Data source allows the data to be computed or fetched for use in Terraform configuration.
* Data sources allow the terraform configurations to build on the information defined outside the Terraform or by another Terraform configuration.
* Providers play a major role in implementing and defining data sources.
* Data source helps in two major ways:
+ It provides a **read-only** view for the pre-existing data.
+ It can **compute new values** on the fly.

* Every data source in the Terraform is mapped to the provider depending on the **longest-prefix-matching**.
```
data "azurerm_resource_group" "passed" {
  name = "${var.resource_group_name}"
}
```

# Concat and Contains
```concat(list1,list2)```
* It combines two or more lists into a single list.
```contains(list, element)```
* It returns true if the element is present in the list or else false.
E.g. ``` contains(var.list_of_strings, "an_element")```

# Workspaces
* Every terraform configurations has **associate backends** which defines how the operations are executed and where the persistent data like terraform state are stored.
* Persistent data stored in backend belongs to a workspace.
* Previously, the backend has only one workspace which is called as **default** and there will be only one state file associated with the configuration.
* Some of the backends support multiple workspaces, i.e. It allows multiple state files to be stored within a single configuration.
* The configuration is still having only one backend, and the multiple distinct instances can be deployed without configuring to a new backend or by changing authentication credentials.
* default workspace is special because you can't delete the default workspace.
* You cannot delete your active workspace (the workspace in which you are currently working).
* If you haven't created the workspace before, then you are working on the default workspace.

# Workspace Commands
* terraform workspace new <name> - It creates the workspace with specified name and switches to it.
* terraform workspace list - It lists the workspaces available.
* terraform workspace select <name> - It switches to the specified workspace.
* terraform workspace delete <name> - It deletes the mentioned workspace.

# Configuring Multiple Providers

* Below is the file structure that you will maintain for working with multiple providers.
```
      multiple_providers
       |
       |___awsmain.tf
       |
       |___azuremain.tf
       |
       |___vars.tf
       |
       |___out.tf
```
* Create an S3 bucket in Azure which helps in storing the file in AWS.
* awsmain.tf
```
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-21"
  acl    = "private"

  tags = {
    Name        = "My bucket test"
    Environment = "Dev"
  }
}
```
* Resource has two parameters: name(aws_s3_bucket) and type("b").
+ Name of the resource may vary from provider to provider. Type of the resource depends on the user.
+ Bucket indicates the name of the bucket. If it is not assigned, terraform assigns a random unique name.
+ acl (access control list) - It helps to manage access to the buckets and objects.
+ tag - It is a label which is assigned to the AWS resource by you or AWS.
+ Environment - On which environment do you like to deploy S3 bucket (Dev, Prod or Stage).     

* azuremain.tf
```
resource "azurerm_storage_account""storageacct" {
name = "storageacct21"
resource_group_name = "${var.rg}"
location = "${var.loc}"
account_replication_type = "LRS"
account_tier = "Standard"
}
```
* Parameters 
+ name - It indicates the name of the storage account.
+ resource_group_name and location- name of the resource group and location.
+ account_replication_type - Type of the account replication.
+ account_tier - Account tier type

* out.tf
```
output "account_tier" {
value = "azurerm_storage_Account.storagecct.account_tier"
}
```