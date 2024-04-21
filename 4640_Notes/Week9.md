# Learning outcomes and topics

- Overview of Spacelift
	- IaC management tool
	- Remote backend
		- Remote state management
	- GitOps
- Assignment 2

# First look at spacelift

Spacelift advertises itself as a IaC management platform. It is a service that provides CI functionality for working with several popular IaC tools, including Ansible and Terraform.

## Stacks

Spacelift uses Stacks to manage a single infrastructure state. So one Terraform configuration state to one Spacelift stack. Spacelift stacks can be triggered by Git actions, merge, pull-request, or using manual actions.

**Reference:**
- [Spacelift, how it works](https://spacelift.io/how-it-works)
## Using a remote backend

We have talked about managing state in Terraform in several classes now. One of the recurring themes is that it can be tricky to manage when working in a team. Using a service like Spacelift or Terraform cloud is one way to solve this problem. 

Any remote backend solution needs to have two features:
- Some way of storing your state.
- Some way of locking state so that any operation that changes state prevents a simultaneous state changing operation from running.

Spacelift is a nice solution as a remote backend because it includes both of the features above, and it makes it pretty easy to go from pushing code to a Git repository to provisioning infrastructure on a cloud service provider.
## GitOps

GitOps is a little like DevOps in that isn't a tool or framework that you can add to your projects.

"GitOps uses a Git repository as the single source of truth for infrastructure definitions." - GitLab docs

Code that defines your infrastructure is pushed to a Git repository. From there merge or pull requests are used to trigger a CI/CD pipeline that will provision your infrastructure. Your CI/CD pipeline could be a service like Spacelift, or GitHub actions... The tools you use often depends on your needs and personal preferences of your development team. 

Automating some of these components allow teams to deploy updates faster and experiment with new features. In theory when you have a working pipeline it is relatively easy to create a new branch that would allow you to try out a new feature in an isolated environment.

**References:**
- [What is GitOps, GitLab](https://about.gitlab.com/topics/gitops/)
# Class time to work on assignment 2
# Flipped learning material

Review the material below before the first class after spring break

- [Core components of Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html)
- [Manage AWS DynamoDB scale](https://developer.hashicorp.com/terraform/tutorials/aws/aws-dynamodb-scale)