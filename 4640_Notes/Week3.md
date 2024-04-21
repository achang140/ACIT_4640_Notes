# Learning outcomes and topics

- Review SSH key authentication
- Install Terraform
- Configure development environment to work in Terraform
- Review some important terms related to Terraform
- Use Terraform commands
- Write Terraform configuration to provision AWS infrastructure

# SSH review

## generating keys

You can create new keys on your host machine with the ssh-keygen utility. 

>[!note] Create your new keys in your Linux environment.
>If your prompt looks like `/mnt/....` cd into your Linux environment with `cd`
>In general it is preferable to work in your Linux file path in WSL. You can still open files in the file explorer and use all of the other tools you are used to working with.

-t = type
-f = filename
-C = comment Comments help identify public keys, a common approach is to use your email address. 

```bash
ssh-keygen -t ed25519 -f ~/.ssh/key-name -C "comment"
```

This will create two new files in the `~/.ssh` directory `key-name` and `key-name.pub` The .pub key is your public key, you put a copy of this key on your server or service.

How you add the public key depends on where it is going. A service like [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) probably has a menu item in the web console that you can use. (GitHub does have this and adding new SSH keys to GitHub is really easy)

When you add a public key to a server (a new EC2 instance). You generally first add your public key to AWS. AWS can store a number of keys for you in different regions. You can also create a key directly in the aws web console, or add a key using a tool like AWS CLI or Terraform. 

When you create the EC2 instance the key you specify is added to your server using a tool like [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html). Cloud init can be used to setup a new server with additional settings. You can create user, install software, run ad-hoc commands... This is also the tool used when you add "user data" to a new EC2 instance. In regards to SSH keys cloud-init adds the public key to the `/home/user-name/.ssh/authorized_keys` file on your server. You can add more than one key using this method if multiple users need to access the server.

### The known_hosts file

On your local machine there is another file that we want to look at today,`~/.ssh/known_hosts`.

The first time you use ssh to connect to a new server there is a message that informs you that "The authenticity of host 'your ip' can't be established...." 
When you type "yes" at the prompt that appears with this message, ssh adds the host to your known_hosts file. This is useful for services that you connect to often as it will notify you if a host has changed.

However, when you are creating and destroying servers often you don't necessarily want to fill your known_hosts file with all of these servers. We will look at some options for avoiding this the next section.
## connecting to a server using ssh

-i = identity file, the private key file to use.

If your key is not in a standard location, or you do not have a key manager configured you will have to specify the private key(the identity file) you want to use when you connect to a server.

```bash
ssh -i mykey.pem user@host
ssh -i ~/.ssh/mykey user@host
```

-o = option, This can be used to specify additional settings when you make an ssh connection. 

```bash
ssh -o "StrictHostKeyChecking=no" user@host
```

StrictHostKeyChecking=no will skip the step where you are asked if you want to permanently add a host to the known hosts file. But the host will still be added to your known_hosts file. 

If you know the IP or hostname you can remove a host from the known_hosts file with the command

```bash
ssh-keygen -R IP
```

But this is sort of a pain to type in often.

To prevent new hosts from being added to your known_hosts file you also want to use the option 'UserKnownHostsFile=/dev/null' and 'GlobalKnownHostsFile=/dev/null'. This sets the known_hosts file to the null file, which doesn't store new data written to it.

The command that we need to type every time we make an ssh connection is getting pretty long.

```bash
ssh -i key-path -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null user@server
```

You could create an alias in your bashrc file for this.

```bash
alias ssho="ssh -i key-path -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null"
```

then you could use the alias like so:

```bash
ssho user@ip-address
```

Later, when we start working with Ansible, we will also use these ssh options in part of our Ansible setup.

**Reference:**

[ssh man page](https://www.man7.org/linux/man-pages/man1/ssh.1.html)

[DigitalOcean SSH Essentials: Working with SSH servers, Clients and Keys](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys)

# Intro to Terraform

>[!question] What is Terraform?

>[!question] What problems does Terraform aim to solve?

>[!question] Is Terraform agentless?

>[!question]  What language is Terraform written in?
>

# Installing Terraform

Depending on the Linux distro that you are using Terraform may be in the package repository. If it is check that it is a recent version. 1.7.0 is the most recent version as of Jan 17

Terraform is written in [Go](https://go.dev/) and distributed as a single binary. So you can download the binary and put it in your path.

The Terraform site also includes documentation on installing Terraform for several popular Linux distros as well as several other OSs. The instructions for Ubuntu/Debian are provided below.

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform
```

Reference:

[Terraform Install docs](https://developer.hashicorp.com/terraform/install#Linux)

# Setting up a Terraform environment

Below are two optional tools that you may want to consider installing to create a minimal Terraform development environment.

To confirm that you have Terraform installed check the version. 

```bash
terraform -version
```

You can install the autocomplete package. This gives you minimal command line auto-completion.

```bash
terraform -install-autocomplete
source ~/.bashrc
```

Terraform also has a language server [terraform-ls](https://github.com/hashicorp/terraform-ls). In VSCode you can install this with the [HashiCorp Terraform extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform). 

# Terraform commands

>[!note] Note on capitalisation
>Terraform uppercase is the name of the tool
>The `terraform` utility that you installed is lowercase.

After installing Terraform you should have a `terraform` utility in your Linux path. If you just run the command `terraform` An outline of available commands will be printed, along with basic usage of the Terraform utility.

```
Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  metadata      Metadata related commands
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.
```

Today we are going to look at the commands in the "Main commands" list and *fmt*.

## init

```
terraform init
```

The `terraform init` command performs Backend Initialisation, Child Module Installation, and Plugin Installation. Code for providers is stored in a `.terraform` directory in your projects root. This directory is created when you run the command `terraform init`. Generally you don't have to touch files in the `.terraform` directory, Terraform will manage these files.

We will revisit this when we look at modules.
## plan

```
terraform plan
terraform plan -out=<path>
```

Generates an execution plan. This will show you what changes will be applied when you run the apply command. Using the `-out` option will save the output of your plan command to a file that can be used when you apply changes.
## apply

```
terraform apply
```

`terraform apply` will actually apply any changes in your configuration files to your infrastructure. By default this will ask you to approve changes. If you use a plan output file `terraform apply <plan-file-path>`, Terraform will apply changes in the plan file. You will not be asked to confirm if you use a plan file.

You can also pass additional environment variables and variable files here.
## destroy

```
terraform destroy
```

This will destroy infrastructure managed by your Terraform configuration. You can combine this with the `-target` option to destroy specific infrastructure specified in a module.
## validate and fmt

```
terraform fmt
```

Format your Terraform configuration files. This tries to format your code to HCL standards.

This is also part of the terraform-ls language server and depending on how your editor is configured is likely run when you save a file.

```
terraform validate
```

Validate your configuration files. This does not access your remote state or services.

**Reference:**

[Terraform Commands Cheat Sheet](https://spacelift.io/blog/terraform-commands-cheat-sheet)
# HashiCorp Configuration Language(HCL) 

Terraform configuration is written in HashiCorp Configuration Language, or JSON.

You can also write Terraform configuration in a handful of general purpose programming languages using CDKTF

**Reference:**

[CDK for Terraform](https://developer.hashicorp.com/terraform/cdktf)

## Arguments and blocks

Terraform configuration is described in *Blocks* that contain *Arguments.*

### Arguments

An argument assigns a value to a name.

```hcl
cidr_block = "10.0.0.0/16"
```

The context where an argument is used determines validity of the argument. Resource types have a schema, a definition of types of arguments that they can accept. For example when you create an EC2 instance the schema for that resource contains an ami argument.

### Blocks

A block is a container for the definition of data associated with a type. A *resource* type block for example. The type specifies how many *labels* must follow the type keyword. For example the resource block below has two labels. The first specifies the type of resource we are creating the second provides a name for that resource. This name can be used to refer to that resource later in your code.

A block is enclosed in {} 

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

Resources correspond to infrastructure objects (like an s3 bucket). 

A data block reads from an existing resource.

```hcl
# get the most recent ami for Ubuntu 23.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}
```

A variable block is used to define a variable

```hcl
variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-2a"]
}
```

An output block defines output that can be used to display information about your infrastructure, like an ip address.

```hcl
output "instance_ip_addr" {
  value = aws_instance.server.private_ip
}
```

Types of Blocks in Terraform: (We won't look at all of these today)
1. Terraform Block
2. Provider Block
3. Data Block
4. Resource Block
5. Module Block
6. Variable Block
7. Output Block
8. Locals Block.
### Comments

Comments can be written using the following syntax

- [`#`](https://developer.hashicorp.com/terraform/language/syntax/configuration#) begins a single-line comment, ending at the end of the line.
- [`//`](https://developer.hashicorp.com/terraform/language/syntax/configuration#-1) also begins a single-line comment, as an alternative to `#`.
- [`/*`](https://developer.hashicorp.com/terraform/language/syntax/configuration#-2) and `*/` are start and end delimiters for a comment that might span over multiple lines.

The `#` single-line comment style is the default comment style and should be used in most cases. Automatic configuration formatting tools may automatically transform `//` comments into `#` comments, since the double-slash style is not idiomatic.

**Reference:**

[Arguments and Blocks](https://developer.hashicorp.com/terraform/language/syntax/configuration)

[Resources](https://developer.hashicorp.com/terraform/language/resources)

# Terraform providers

> A provider in Terraform is a plugin that enables interaction with an API. This includes Cloud providers and Software-as-a-service providers. The providers are specified in the Terraform configuration code. They tell Terraform which services it needs to interact with.
> - [spacelift blog](https://spacelift.io/blog/terraform-providers)

There are hundreds of Terraform providers! Probably all of the cloud service providers that you can name as well as Git service providers, containers...

Providers are developed independently of Terraform. Some are maintained by third parties (not HashiCorp).

Providers are referenced in a terraform block. When you run `terraform init` the code needed for a provider is downloaded and stored in the `.terraform` directory

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Reference:**

[Terraform Providers Overview and How to Use Them](https://spacelift.io/blog/terraform-providers)
# Terraform credentials for AWS

Terraform will use the same `~/.aws` config and credentials that the AWS CLI uses.

If no named profile is specified the default profile will be used. If you are using a named profile for your AWS credentials you can set that in the provider block.

```hcl
provider "aws" {
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "your-profile"
  region                   = "us-west-2"
}
```
# Getting started

Create a new `week3` directory in your Linux file path.

Go to the [HashiCorp AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest). The first Terraform configuration that we are going to run is copied directly from the docs. The only change is the region.

Create a new `main.tf` file in the `week3` directory and copy the code below into it.

Try running through the Terraform commands just creating the vpc in the example below before moving on to the in class exercise.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}
```

# In class exercise

Create a new local(in your Linux environment)  SSH key pair.

Complete the terraform configuration below so that you have a public EC2 instance that you can connect to via ssh and http. Use the local ssh key that you created above.

Look for the COMPLETE ME! comments.

Once you have your ec2 instance up, connect to it via ssh and install nginx. Once you have nginx installed you can visit your public ip address to see the default nginx page.

Try to do this only using the documentation, link below.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "base_cidr_block" {
  description = "default cidr block for vpc"
  default     = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-ipg"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-route"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# security group for instances COMPLETE ME!
resource "aws_security_group" "main" {
}

# security group egress rules COMPLETE ME!
resource "aws_vpc_security_group_egress_rule" "main" {
# make this open to everything from everywhere
}

# security group ingress rules COMPLETE ME!
resource "aws_vpc_security_group_ingress_rule" "main" {
# ssh and http in from everywhere
}

# get the most recent ami for Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# key pair from local key COMPLETE ME!
resource "aws_key_pair" "local_key" {
  key_name   = "4640-Key"
  public_key = file()
}

# ec2 instance COMPLETE ME!
resource "aws_instance" "ubuntu" {
  instance_type = "t2.micro"
  ami           = data.
  
  tags = {
    Name = "ubuntu-server"
  }

  key_name               =
  vpc_security_group_ids = 
  subnet_id              = aws_subnet.main.id

  root_block_device {
    volume_size = 10
  }
}

# output public ip address of the 2 instances
output "instance_public_ips" {
  value = aws_instance.ubuntu.public_ip
}


```

Submit a .zip that contains your completed main.tf and a screenshot that shows the default nginx page and your ip address in the browser.

**Reference:**

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

https://developer.hashicorp.com/terraform/language/functions/file
# Flipped learning material

- No new flipped material this week, although if you want more the textbook in last weeks notes would be a good place to look

