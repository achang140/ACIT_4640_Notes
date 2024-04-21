## Learning objectives

In this assignment students will extended their understanding of Terraform configuration by using modules  to make their configuration more portable.
Students will also demonstrate an understanding of using Ansible to mange servers by creating a user and setting up an application. Through this hands-on approach, students will develop practical skills in cloud architecture and Infrastructure as Code (IaC) techniques.

**Key Learning Goals:**

-  Understand and apply Infrastructure as Code (IaC) principles using Ansible and Terraform.
- Demonstrate proficiency in creating and configuring VPCs, subnets, and EC2 instances on AWS.
- Demonstrate understanding of using Ansible to manage creation of a user and deployment of an application on a remote server.
- Develop effective documentation skills to articulate infrastructure design, decisions, and configurations.

## Instructions

### Terraform

Your terraform configuration should create 2 public ec2 instances, each instance in a different availability zone. ec2 instances should run Ubuntu 23.04
Create the necessary networking so that your ec2 instances are publicly accessible via SSH and HTTP.

Create a separate module for:
- Your ec2 instances
	- Use variables with defaults to define the following: 
		- a count with a default
		- type (ie t2.micro)
		- availability zone
		- name tag (use the same name for both instances)
		- You will have more variables, but you should have defaults for these

### Ansible

Start by cloning the [application repository](https://gitlab.com/cit_4640/4640-assignment-app-files) to your local development environment(WSL, your Linux VM...).
The repository contains all of the code needed for your application as well as a service file to start your application and a Caddyfile to act as a reverse proxy.

You will need to install the bun runtime and Caddy web server on both of your ec2 instances, see the links below for details on installing each.

- [Bun](https://bun.sh/)
- [Caddy](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)

Create a new regular user "bun" on your ec2 instances to run your app. In practice you would probably make a system user for this. But in this case it is a little easier to create a regular user and install bun using that regular user, without sacrificing too much in regards to this otherwise very secure application.

Transfer application files, the service file and the Caddyfile to the required locations: 
- You can figure out where the application code should go by looking at the service file. 
- Replace the default Caddyfile with the included one. The default file is in the location where system wide configuration files are stored.
- See the [Arch Wiki](https://wiki.archlinux.org/title/Systemd) if you have forgotten where the service file should go.

Enable and start services. Restart or reload services only when needed.

### Documentation

Create a short video (5-10 minutes) in which you run and describe your **Terraform module**, **Ansible configuration** and **Ansible commands** .

Submit your video as a link to a hosted video that can be played without creating an account. If you don't already have a video service that you prefer, [Loom](https://www.loom.com/) is a good choice(free education account) . Include the link to the your video in the README.md file.

## Grading

**Terraform 5 points**
- Terraform configuration is complete
- Code is properly formatted
- Code includes meaningful comments

**Ansible 5 points**
- Ansible configuration is complete
- Ansible configuration is idempotent where possible
- Ansible configuration includes logical plays (1 play is one task)

**Video 5 points**
- Video demonstrates required Terraform and Ansible commands
- Video demonstrates understanding of Terraform module
- Video demonstrates understanding of Ansible configuration

**Total 15 points**

## Due date

Assignment is Due Sunday March 17

## Breakdown of what you are submitting

Submit a "your_name_as2.zip" that contains:
- A "README.md" that contains
	- a link to your hosted video
	- The steps need to run your configuration
		- Terraform and Ansible commands as well as any additional commands/steps required, like creating ssh keys...
- A "terraform" directory that contains your Terraform configuration files
- An "ansible" directory that contains your Ansible configuration files