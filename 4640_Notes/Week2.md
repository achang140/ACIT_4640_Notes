# Learning outcomes and topics

- Review Linux and bash scripting
  - Use `systemctl` to manage services
  - declare variables in bash
  - write a heredoc in bash
  - use command substitution in bash
- Create an AWS IAM user for the AWS CLI
- Install the AWS CLI in your Linux environment
- Review AWS CLI commands
  - Create AWS resources
  - Query AWS resources

# Additional shell scripting resources can be found here

[cit_bash_resources](https://gitlab.com/cit_bash/cit_bash_resources)

# Managing systemd services

## Unit files

A unit file is an ini style plain text file that defines a systemd unit
(generally a service).

This file specifies things like dependencies, what to do if the service crash,
when to start a service and of course starts the service it self. The service
can be a script or binary.

Service files (and other unit files) are found in several locations. We are
going to be creating service files in `/etc/systemd/system`. This directory
takes precedence over `/usr/lib/systemd/system`, which is where unit files
distributed with packages are generally found. This allows us to overwrite parts
of a unit file that was installed with a package.

> [!note] A unit file is composed of "Sections" that contain "Directives".
> Sections are denoted by square brackets. Directives are key value pairs.

A unit file that defines a service ends in a ".service" suffix and contains
`[Unit]`, `[Service]` and an optional `[Install]` sections

```
[Unit]
Description=Some HTTP server
After=remote-fs.target sqldb.service
Requires=sqldb.service
AssertPathExists=/srv/webserver

[Service]
Type=notify
ExecStart=/usr/sbin/some-fancy-httpd-server

[Install]
WantedBy=multi-user.target
```

## `systemctl` commands

| Action                                                                        | Command                                   | Note                                                                                  |
| ----------------------------------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------- |
| Analyzing the system state                                                    |                                           |                                                                                       |
| **Show system status**                                                        | `systemctl status`                        |                                                                                       |
| **List running** units                                                        | `systemctl` or <br>`systemctl list-units` |                                                                                       |
| **List failed** units                                                         | `systemctl --failed`                      |                                                                                       |
| **List installed** unit files1                                                | `systemctl list-unit-files`               |                                                                                       |
| **Show process status** for a PID                                             | `systemctl status _pid_`                  | [cgroup slice](https://wiki.archlinux.org/title/Cgroups "Cgroups"), memory and parent |
| Checking the unit status                                                      |                                           |                                                                                       |
| **Show a manual page** associated with a unit                                 | `systemctl help _unit_`                   | as supported by the unit                                                              |
| **Status** of a unit                                                          | `systemctl status _unit_`                 | including whether it is running or not                                                |
| **Check** whether a unit is enabled                                           | `systemctl is-enabled _unit_`             |                                                                                       |
| Starting, restarting, reloading a unit                                        |                                           |                                                                                       |
| **Start** a unit immediately                                                  | `systemctl start _unit_` as root          |                                                                                       |
| **Stop** a unit immediately                                                   | `systemctl stop _unit_` as root           |                                                                                       |
| **Restart** a unit                                                            | `systemctl restart _unit_` as root        |                                                                                       |
| **Reload** a unit and its configuration                                       | `systemctl reload _unit_` as root         |                                                                                       |
| **Reload systemd manager** configuration2                                     | `systemctl daemon-reload` as root         | scan for new or changed units                                                         |
| Enabling a unit                                                               |                                           |                                                                                       |
| **Enable** a unit to start automatically at boot                              | `systemctl enable _unit_` as root         |                                                                                       |
| **Enable** a unit to start automatically at boot and **start** it immediately | `systemctl enable --now _unit_` as root   |                                                                                       |
| **Disable** a unit to no longer start at boot                                 | `systemctl disable _unit_` as root        |                                                                                       |
| **Reenable** a unit3                                                          | `systemctl reenable _unit_` as root       | i.e. disable and enable anew                                                          |
| Masking a unit                                                                |                                           |                                                                                       |
| **Mask** a unit to make it impossible to start                                | `systemctl mask _unit_` as root           |                                                                                       |
| **Unmask** a unit                                                             | `systemctl unmask _unit_` as root         |                                                                                       |

Reference:

- [Understanding systemd Units and Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
- [Arch wiki, systemd](https://wiki.archlinux.org/title/Systemd)

# Bash scripting

## Variables and environment variables

bash variables are only available in the shell environment in which they are
created.

### Environments in the shell

> When a program is invoked it is given an array of strings called the
> _environment_. This is a list of name-value pairs, of the form `name=value`.
>
> - [Bash manual ](https://www.gnu.org/software/bash/manual/html_node/Environment.html)

Environment variables are accessible in shells and other programs (other
environments) started from the shell in which they are created. This is useful
for sharing sensitive information with a script, and for sharing values between
programs.

Most Linux distros have several existing environment variables. Generally these
are in all caps, by convention, not necessity. examples of environment variables
that likely exist: PAGER, EDITOR and HOME. You generally want to avoid
overwriting existing environment variables. You can use the `printenv` command
to test if an environment variable exists.

```bash
printenv HOME # This should return your users home path
printenv PICARD # This should return nothing, and if you check the exit status, 1
```

An environment variable can be created with the `export` builtin (it is part of
bash and not a separate command). You can export an existing variable:

```bash
NAME="Worf"
export NAME
```

or export a variable when you define it.

```bash
export NAME="Tasha"
```

The `declare` builtin can be used to create a read-only variable.

```bash
declare -r NAME="Reginald"
```

This can come in handy if you don't want to accidentally overwrite a value.

## heredocs (here documents)

A bash heredoc can be used to store files in scripts, or to pass multi-line
commands to a running program.

The syntax of a heredoc is:

```bash
command <<[-]delimiter
	contents of heredoc
delimiter
```

For example:

```bash
cat <<- EOF
	This is line one
	This is line two
EOF
```

heredocs can be used with redirects

```bash
cat <<- EOF > out-file
	This is line one
	This is line two
	Your current directory is $PWD
EOF
```

Example of using a heredoc to run commands on server using ssh

```bash
ssh -Tv user@host << EOF
	apt install nginx
EOF
```

## Command substitution

Command substitution allows you to store the output of a command in a variable.

```bash
now=$(date)
```

When working with AWS resources you often need the ID of one resource to
associate it with another resource. For example a subnet in a vpc.

# AWS CLI

> The AWS Command Line Interface (AWS CLI) is an open source tool that enables
> you to interact with AWS services using commands in your command-line shell.
> With minimal configuration, the AWS CLI enables you to start running commands
> that implement functionality equivalent to that provided by the browser-based
> AWS Management Console from the command prompt in your terminal program:
>
> - [AWS What is the AWS Command Line Interface?](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

> [!note] Most of you probably already have the AWS CLI installed and configured
> in a WSL instance from last term. If not, there are instructions in the
> In-class activity below. If you do have the AWS CLI installed and configured
> you should still update your IAM credentials and the AWS CLI.

**Reference**:

- [AWS Docs Install and Update](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS Docs Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [AWS IAM](https://aws.amazon.com/iam/)

## Working with the AWS CLI

The AWS CLI can perform all of the operations that you can perform in the AWS
web console. You can create and destroy resources and query information on
resources.

The general structure of an AWS CLI command is:

`aws [options] <command> <subcommand> [parameters]`

for example:

```bash
aws ec2 describe-key-pairs --key-name MyKeyPair
```

# In-class activity

Complete the exercise below in a group of 2-3. Everyone should create new IAM
credentials and install or update the AWS CLI

## Part 1, AWS CLI installation and configuration.

Create a new IAM user with credentials. These credentials will be used in your
Linux environment for the AWS CLI and Terraform.

Do this even if you already have credentials that you created from last term.

1. It is good practice
2. You should periodically remove and create new long term credentials, just
   like you should regularly create new passwords.

Install the AWS CLI (or update the AWS CLI if you have it installed in a Linux
instance that you have from last term)

> [!example] Install or Update the AWS CLI

Install

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Update

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
```

> [!example] Configure the AWS CLI

```
aws configure
```

This will prompt you for the following

```
AWS Access Key ID
AWS Secret Access Key
Default Region name
Default output format
```

I recommend using `us-west-2` for the region. We are only going to work in one
region this term.

Running `aws configure` will create a `~/.aws` directory that contains a
"credentials" file and a "config" file. You can specify additional profiles in
your configuration if for example you want to use different credentials for
different projects.

## Part two

Use the AWS CLI to create a new ssh key of type "ed25519" and save the key
locally as a .pem file.

Edit the script below so that instead of printing "Bucket $bucket_name does not
exist" the script will create the bucket using the provided name.

> [!note] Remember that bucket names must be globally unique Try something like
> "your-name-4640-bucket"

```bash
#!/usr/bin/env bash

# Check if the number of command-line arguments is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

# pass the bucket name as a positional parameter
bucket_name=$1

# Check if the bucket exists
if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
    echo "Bucket $bucket_name already exists."
else
  # change the line below
  echo "Bucket $bucket_name does not exist"
fi
```

Can you think of a way that this script could be improved?

You can delete your bucket with the command below. replace "your-bucket-name"
with the name of your bucket.

```bash
aws s3api delete-bucket --bucket your-bucket-name --region us-east-1
```

**Reference:**

- [AWS CLI S3 Docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3api/index.html)
- [AWS CLI ec2 docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/index.html)
  The command you want for creating keys is in here

## Part three

Copy the two scripts below into your Linux environment and complete the second
script.

The first script below will provision and configure the following:

- A VPC
- A public subnet
- An internet gateway
- A route table

This script also writes two variables to an 'infrastructure_data' file

```bash
#!/usr/bin/env bash
set -eu

# Variables
region="us-west-2"
vpc_cidr="10.0.0.0/16"
subnet_cidr="10.0.1.0/24"
key_name="your-key" #change this to the name of your key

# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query 'Vpc.VpcId' --output text --region $region)
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=MyVPC --region $region

# enable dns hostname
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames Value=true

# Create public subnet
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id \
  --cidr-block $subnet_cidr \
  --availability-zone ${region}a \
  --query 'Subnet.SubnetId' \
  --output text --region $region)

aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=PublicSubnet --region $region

# Create internet gateway
igw_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' \
  --output text --region $region)

aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id --region $region

# Create route table
route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id \
  --query 'RouteTable.RouteTableId' \
  --region $region \
  --output text)

# Associate route table with public subnet
aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $route_table_id --region $region

# Create route to the internet via the internet gateway
aws ec2 create-route --route-table-id $route_table_id \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id --region $region

# Write infrastructure data to a file
echo "vpc_id=${vpc_id}" > infrastructure_data
echo "subnet_id=${subnet_id}" >> infrastructure_data
```

Complete the script below so that it will use the infrastructure_data file to
create an EC2 instance inside of the public subnet created in the script above.
Your script should:

- use the AMI provided by the "ubuntu_ami" variable
- use the security group provided by the "security_group_id" variable.
- use the key pair you created in part 2 (above)
- write the public IP address of your EC2 instance to a new "instance_data"
  file.

```bash
#!/usr/bin/env bash

set -eu

region="us-west-2"
key_name="your-key" #change this to the name of your key


# Get Ubuntu 23.04 image id owned by amazon
ubuntu_ami=$(aws ec2 describe-images --region $region \
 --owners amazon \
 --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server* \
 --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)


# Create security group allowing SSH and HTTP from anywhere
security_group_id=$(aws ec2 create-security-group --group-name MySecurityGroup \
 --description "Allow SSH and HTTP" --vpc-id $vpc_id --query 'GroupId' \
 --region $region \
 --output text)

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region

# Launch an EC2 instance in the public subnet
# COMPLETE THIS PART
instance_id=

# wait for ec2 instance to be running
aws ec2 wait instance-running --instance-ids $instance_id

# Get the public IP address of the EC2 instance
# COMPLETE THIS PART
public_ip=

# Write instance data to a file
# COMPLETE THIS PART
echo "Public IP: $public_ip"

```

After you have provisioned your infrastructure with these scripts test that you
can connect to your EC2 instance via ssh using the key you created in part 2.

Provide links to any resources that you used.

Submit any material your team generated for all parts in a 'lab-two.zip' on D2L.
Your submission should include the scripts, and a document that includes any
resources you used, your team members names and any other relevant information.

**Reference:**

- [AWS CLI run-instance docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html)
- [AWS CLI describe-instances docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instances.html)

# Flipped learning material

- [Chapter 1. Why Terraform, Terraform: Up and Running 3rd](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch01.html)
- [Lesson 1: Terraform Fundamentals, Essential Terraform in AWS](https://learning.oreilly.com/course/essential-terraform-in/9780138312244/)
- [Lesson 2: First Terraform Configuration with AWS, Essential Terraform in AWS](https://learning.oreilly.com/course/essential-terraform-in/9780138312244/)

## Flipped material objectives

- What is IaC? What problems does IaC address?
- What is idempotence?
- What is the difference between "configuration management" and "provisioning"?
- What does it mean to say that Terraform is "declarative"?
- Who made and maintains Terraform?
- What language are Terraform configuration files written in?
- Overview of Terraform commands.
  - `init`
  - `plan`
  - `apply`
  - `destroy`
- What is a Terraform "provider"?
- What is a Terraform "block"?

# Todo

- Review flipped material
