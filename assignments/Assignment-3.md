## Learning objectives

In this assignment students will extended their understanding of Terraform and Ansible configuration by using a remote backend in their Terraform configuration and Ansible roles in their Ansible configuration.
Through this hands-on approach, students will develop practical skills in cloud architecture and Infrastructure as Code (IaC) techniques.

**Key Learning Goals:**

-  Understand and apply Infrastructure as Code (IaC) principles using Ansible and Terraform.
- Demonstrate proficiency in creating and configuring AWS resources in Terraform.
- Demonstrate understanding of using Ansible to manage the deployment of an application on a remote server.
- Develop effective documentation skills to articulate infrastructure design, decisions, and configurations.

## Instructions

### Terraform

Your terraform configuration should create: 
- 1 public ec2 instance(your frontend)
- 1 "almost private" ec2 instance(your backend) 
	- ec2 instances should run Ubuntu 23.04

Create the necessary networking for your ec2 instances so that: 
- your public ec2 instance is publicly accessible via SSH and HTTP.
- your "almost private" ec2 instance is publicly available via ssh but is only accessible via http from within your VPC

Create a remote backend to handle your configuration state using an s3 bucket to store your state file and a DynamoDB table to lock your state file.

Create a module for your security groups.

### Ansible

Start by cloning the [application repository](https://gitlab.com/cit_4640/as3-files-4640-w24) to your local development environment(WSL, your Linux VM...).
The repository contains:
- a backend (this is a compiled binary)
- a frontend(index.html) file
- a service file for your backend 
- and two web server configuration files
	- Caddy for your backend
	- Nginx for your frontend

Setup your servers in Ansible roles. 1 role for the frontend and one role for the backend.

Use Ansible Handlers and Tags where appropriate.

### Documentation

Create a short video (5-10 minutes) in which you run and describe your **Terraform module**, **Ansible configuration** and **Ansible commands** .

Submit your video as a link to a hosted video that can be played without creating an account. If you don't already have a video service that you prefer, [Loom](https://www.loom.com/) is a good choice(free education account) . Include the link to the your video in the README.md file.

## Grading

**Terraform 5 points**
- Terraform configuration is complete and meets requirements above
- Code is properly formatted
- Code includes meaningful comments

**Ansible 5 points**
- Ansible configuration is complete and meets requirements above
- Ansible configuration is idempotent where possible
- Ansible 

**Video 5 points**
- Video demonstrates required Terraform and Ansible commands
- Video demonstrates understanding of Terraform module
- Video demonstrates understanding of Ansible configuration

**Total 15 points**

## Due date

Assignment is Due Friday April 12 

## Breakdown of what you are submitting

Submit a "your_name_as3.zip" that contains:
- A "README.md" that contains
	- a link to your hosted video
	- The steps need to run your configuration
		- Terraform and Ansible commands as well as any additional commands/steps required, like creating ssh keys...
- A "terraform" directory that contains your Terraform configuration files
- An "ansible" directory that contains your Ansible configuration