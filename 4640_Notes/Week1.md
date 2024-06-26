# Learning outcomes and topics

- overview of course
- high level look at course tools
- Setup a Linux development environment
- Cloud resources review exercise.
	- Plan infrastructure resources for a calendar application

# Course outline

## office hours

Please schedule appointments at least 48 hours in advance via Discord or email.

Nathan
- Monday 08:30-10:30 location tbd
- Tuesday 11:30-12:30 location tbd
- Thursday 08:30-10:30 location tbd

Tom
- Tuesday 12:00 - 13:00 Room 533

## Evaluation Criteria
  
| Criteria | % | Notes |
| ---- | ---- | ---- |
| Quizzes | 10 | 2 In-class quizzes (5% each) |
| Final Exam | 30 |  |
| Assignment 1 | 20 |  |
| Assignment 2 | 20 |  |
| Assignment 3 | 20 |  |

## Course notes

Course note are provided as markdown documents via GitLab. You can incorporate these notes into your own notes (recommended) or just view them on GitLab. 

## Flipped learning material

Each week material will be provided in these notes. Please complete this material before the following weeks class. 

The complete course outline is available [here](https://www.bcit.ca/programs/computer-information-technology-diploma-full-time-5540dipma/#courses).

# Course tools overview

## Amazon Web Services(AWS)

- AWS is still the largest cloud service provider
- You have previous experience with AWS

## Terraform/OpenTofu

[Terraform](https://www.terraform.io/) is a tool used for automation to provision and manage resources in any cloud or data center. 

On August 10th 2023 HashiCorp changed the license of some of their products from MPL 2.0 to BSL v1.1. As students learning this technology this won't impact you. It does however impact organisation using Terraform, particularly third party service providers.  

[OpenTofu](https://opentofu.org/) Was forked from Terraform because of this license change and is currently a drop-in replacement for Terraform. This will likely change as the two projects continue to develop.

There is an LSP server for Terraform (also works with OpenTofu) [Terraform-ls](https://github.com/hashicorp/terraform-ls). There are integrations for numerous editors that support this LSP.
### Other alternatives

AWS has [CloudFormation](https://docs.aws.amazon.com/cloudformation/) and [CDK](https://aws.amazon.com/cdk/) These are both AWS specific solutions. Most of the teams I have worked on have used more than one cloud service provider as well as on-premise infrastructure. Using one tool to manage multiple cloud service providers and your own infrastructure makes things easier. 

[Pulumi](https://www.pulumi.com/) is a tool similar to Terraform in that it is cloud agnostic, but instead of using a DSL, Pulumi configuration is written in one of a handful of popular programming languages. 

## Ansible

The tools above are used to provision your infrastructure. [Ansible](https://www.ansible.com/) is used to manage some of that infrastructure. Ansible can be used to perform actions such as installing software or copying files to a server. Ansible is also often used in conjunction with [Packer](https://www.packer.io/), to build images that already contain application resources.

## Terraform cloud/Spacelift

[Terraform Cloud](https://www.hashicorp.com/products/terraform) and [Spacelift](https://spacelift.io/) are cloud services that offer several features that support team work with tools like Terraform (Spacelift also supports OpenTofu, Pulumi and Ansible). One of the main features that we are going to look at this term is state management in teams. 

## Git and GitHub

The primary advantage of IaC is that you are working with plain text files that can be easily shared. The way that developers share these files is through version control. [Git](https://git-scm.com/) is currently the most popular version control system. All of you have previous experience with Git and [GitHub](https://github.com/).

Git is an essential component in a GitOps workflow. Git is an important component in most modern infrastructure provisioning and maintenance. 

# Important terminology

## Infrastructure

Infrastructure is the components that make up a system used to deploy and maintain applications and services. This includes things like:
- Virtual Machines
- Load Balancers
- Networks

## Provisioning

> Provisioning is the process of creating and setting up IT infrastructure, and includes the steps required to manage user and system access to various resources. Provisioning is an early stage in the deployment of servers, applications, network components, storage, edge devices, and more.
> - [RedHat What is Provisioning](https://www.redhat.com/en/topics/automation/what-is-provisioning)

## Management

> Configuration management is a process for maintaining computer systems, servers, applications, network devices, and other IT components in a desired state. It’s a way to help ensure that a system performs as expected, even after many changes are made over time.
> - [RedHat What is configuration management](https://www.redhat.com/en/topics/automation/what-is-configuration-management)

## Infrastructure as Code (IaC)

IaC is Infrastructure management provision using code instead of a manual process. Plain text files contain instructions to provision and manage infrastructure that can be share with a team using version control systems.

IaC has some of the following bennefits:
- Reproducible
- Easier to scale.
- Easier to maintain

IaC tools generally use one of two approaches:
- Declarative
- Imperative

>A declarative approach defines the desired state of the system, including what resources you need and any properties they should have, and an IaC tool will configure it for you.
>
>An imperative approach instead defines the specific commands needed to achieve the desired configuration, and those commands then need to be executed in the correct order.
>- [RedHat What is Infrastructure as Code (IaC)?](https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac)

**Reference:**

- [IBM What is Infrastructure as Code (IaC)](https://www.ibm.com/topics/infrastructure-as-code)

## DevOps

![DevOps pipeline](attachments/DevOps_feedback-diagram.ff668bfc299abada00b2dcbdc9ce2389bd3dce3f.png)

DevOps is practice of using a developer mindset and developer workflow to perform operations tasks. DevOps allows an operations team to perform tasks faster and to make those tasks more reproducible. DevOps also allows a team to experiment and perform more tests.

**Reference:**

- [AWS What is DevOps](https://aws.amazon.com/devops/what-is-devops/)
- [IBM What is DevOps](https://www.ibm.com/topics/devops)

## GitOps

> GitOps is an operational framework that takes DevOps best practices used for application development such as version control, collaboration, compliance, and CI/CD, and applies them to infrastructure automation.
> - [GitLab What is GitOps?](https://about.gitlab.com/topics/gitops/)

GitOps is a common component in a DevOps workflow. 

> GitOps takes the philosophies and approaches promised to those investing in a DevOps culture and provides a framework to start realizing the results. 
> - [RedHat What is GitOps](https://www.redhat.com/en/topics/devops/what-is-gitops)

# Linux development environment

Some of the tools that we are using this term are not fully supported in Windows and MacOS. For best results everyone is required to create and maintain a Linux development environment.

How you create your Linux development environment is up to you.

For Windows users the easiest solution is probably [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)

For MacOS users with a recent Mx chip the easiest solution is likely an online development environment or a local container using a tool such as docker.

[GitHub Codespaces](https://github.com/features/codespaces) might be an option that you want to explore. 

Or you can create your own using a cloud service provider.

Use a recent Linux distro. Ubuntu 23.04/23.10, Fedora 39, openSuse  tumbleweed are all good choices. 

Optional [WSL Setup Supplement](4640_Notes/Week1_wsl_supplement.md)

**Reference:**

- [WSL docs](https://learn.microsoft.com/en-us/windows/wsl/)
- [WSL install docs](https://learn.microsoft.com/en-us/windows/wsl/install)
- [WSL file storage and performance](https://learn.microsoft.com/en-us/windows/wsl/filesystems#file-storage-and-performance-across-file-systems)
- [WSL and systemd](https://ubuntu.com/blog/ubuntu-wsl-enable-systemd)
- [VSCode and WSL](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-vscode)

# In-class activity 

Split up into groups of 2-3.

## Part 1

In your groups imagine that you are part of a team responsible for provisioning and maintaining the infrastructure used for a calendar/productivity app (something like [Morgen](https://www.morgen.so/) or [Akiflow](https://akiflow.com/) ). Your team has decided to use AWS. 

- What are some of the AWS services you would use?
	- Why would you use these services?
	- What do they do that would help to make deployment of the app successful?
	- Where do you think you would encounter difficulty?
		- Try to think of what you might be missing. This can include resources that you don't feel you entirely understand.
		- Where might you want to evaluate several tools as a team to help you pick the most suitable tool? Why?
- Map out and diagram parts of your application infrastructure.
	- These diagrams can be very rudimentary (pen and paper is fine)
	- These diagrams serve 2 purposes for today:
		- In the context of this-is-a-school-exercise they help to demonstrate your understanding of the material
		- In the context of the exercise itself they can help your team understand the infrastructure you are creating. They can also help identify missing components and short comings.
- Be prepared to do a short (5 min), informal presentation (you don't need slides...)

## Part 2

In your group define each of the following computing execution environments:

1. Bare Metal
2. Virtual Machine
3. Container
4. IaaS
5. PaaS
6. SaaS
7. Serverless Functions (i.e. AWS Lambda)

Provide links to any resources that you used.

Submit any material your team generated for both parts in a 'lab-one.zip' on D2L. Include a note on who is in your team.

# Flipped learning material

Next week we are going to review some Linux basics as well as the setup and an overview of the AWS CLI v2. The material below is intended to help you fill in the gaps, or remind you of some material you may have forgotten from terms 2 and 3.

- [Bash variables, environment variables and command substitution](https://docs.rockylinux.org/books/learning_bash/02-using-variables/)
- [Bash Heredoc](https://linuxize.com/post/bash-heredoc/)
- [`systemctl` commands](https://www.linode.com/docs/guides/introduction-to-systemctl/)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

# Todo

- [ ] Create a Linux development environment
- [ ] Review flipped learning material
