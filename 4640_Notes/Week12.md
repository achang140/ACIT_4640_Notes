# Week 10 4640 fall 2023

# Learning outcomes and topics

- Ansible roles
	- Create Ansible roles to breakup a playbook
- Ansible tags
	- Use tags to run specific tasks in a playbook
- Manage Terraform state with S3 and DynamoDB
- Assignment 3

## Quiz update

Because next Monday is a holiday the quiz has been pushed back to week 14. It will also make for good review material. Serendipity 
# Intro to Ansible roles

> In Ansible, the _role_ is the primary mechanism for breaking a playbook into multiple files. This simplifies writing complex playbooks, and it makes them easier to reuse.
> - Ansible in Action 3rd

## Where should roles go in your project

Ansible roles have a defined directory structure. Ansible will look for roles in the following locations:

- in collections, if you are using them
- ==in a directory called `roles/`, relative to the playbook file (This is the solution that we are going to use)==
- in the configured [roles_path](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-roles-path). The default search path is `~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles`.
- in the directory where the playbook file is located

## Organising the roles directory

Inside of the roles directory individual directories are created for each role, for example a database role

```
ansible.cfg
roles/
	database/
```

Inside of each role, ie the database role directory ansible uses any of eight standard directories. If you don't need to include a directory you don't have to.

- Tasks
	The _tasks_ directory has a _main.yml_ file that serves as an entry point for the actions a role does.

- Files
	Holds files and scripts to be uploaded to hosts.

- Templates
	Holds Jinja2 template files to be uploaded to hosts.

- Handlers
	The _handlers_ directory has a _main.yml_ file that has the actions that respond to change notifications.

- Vars
	Variables that shouldn’t generally be overridden.

- Defaults
	Default variables that can be overridden.

- Meta
	Information about the role.

- Library
	modules, which may be used within this role (see [Embedding modules and plugins in roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#embedding-modules-and-plugins-in-roles) for more information).

So the database example might look like this:

```
ansible.cfg
roles/
	database/
		tasks/
			main.yml
		vars/
			main.yml
```


**Resources:**

[Ansible Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)

# Creating Ansible roles

Because roles are just directories and files, you don't need any special tools for creating roles on your local machine.

You can also use existing roles, hosted on Ansible Galaxy. Because of this there is the `ansible-galaxy` command. 

Today we are just going to focus on creating our own roles, and using them from local ansible configuration files. But the `ansible-galaxy` command can still help with this. 

Try running the command below in a directory containing an empty 'roles' directory.

```bash
ansible-galaxy init --init-path roles db-role
```

This command will create the scaffolding for a 'db-role' inside of the roles directory. Which will create something like this:

```
.
└── roles
    └── db-role
        ├── defaults
        │   └── main.yml
        ├── files
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── README.md
        ├── tasks
        │   └── main.yml
        ├── templates
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml

11 directories, 8 files
```

**Resources:**

- [Ansible Docs](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html)
- [Ansible Galaxy](https://galaxy.ansible.com/ui/)

# Using a role in an Ansible playbook

If your project includes a 'web.yml' playbook, and roles directory that contains a 'db-role' role, you can use that role from your playbook like so:

```yml
# web.yml
---
- name: Roles for the database servers
  hosts: database
  become: true
  roles:
    - db-role
```


**Resources:**
- [Ansible examples](https://github.com/ansible/ansible-examples/tree/master/lamp_simple)
- [Ansible roles tutorial on spacelift](https://spacelift.io/blog/ansible-roles)

# Ansible tags

Ansible tags allow you to "tag" tasks in a playbook so that you can run only certain tasks instead of running the entire playbook.

## Adding a tag to a task and running only tasks with those tags

If the tasks defined below are in a playbook file `site.yml`
```yml
tasks:
- name: Install the servers
  ansible.builtin.yum:
    name:
    - httpd
    - memcached
    state: present
  tags:
  - packages
  - webservers

- name: Configure the service
  ansible.builtin.template:
    src: templates/src.j2
    dest: /etc/foo.conf
  tags:
  - configuration
```

If you only wanted to install the servers you could run the command  
`ansible-playbook site.yml --tags "webserver"`  

If you want to run multiple tags use a comma separated list   
`--tags "webserver,configuration"`

If you would like to run all tags **except** the "webserver" tag use `--skip-tags`  
`ansible-playbook site.yml --skip-tags "webserver"`

An individual tag can be associated with multiple tasks.

An individual task can have multiple tags.

**Resources:**
- [Ansible Docs: tags](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_tags.html)
# Terraform backend with DynamoDB and S3

## Terraform State

Previously we looked at [Spacelift](https://spacelift.io/), a service for working with a variety of IaC tools in teams. One of the reasons that a team using Terraform might use a service like Spacelift is managing Terraform state. 

>[!Question]
>Why is managing state so important when working in teams?
>What are some important aspects of managing state?

Another option for managing Terraform state is to use a more DIY approach. We are going to use AWS for this But you could use the resources of most cloud service providers to accomplish the same thing.
### Reading

1. [How to Manage Terraform State](https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch03.html)

### Tutorials
1. [Managing Terraform State – Best Practices & Examples](https://spacelift.io/blog/terraform-state)
1. [How to Manage Terraform S3 Backend – Best Practices](https://spacelift.io/blog/terraform-s3-backend)

### Documentation
1. [Terraform State Backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
1. [Terraform State Backend: Local](https://developer.hashicorp.com/terraform/language/settings/backends/local)
1. [Terraform State Backend: S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
1. [Terraform State Cheatsheet](../resources/terraform_state_cheat-sheet.pdf)

### S3 Bucket Management and DynomoDB Locking
1. [Tutorial Configuring Terraform backend with AWS S3 and DynamoDB state locking](https://dev.to/bhusein/configuring-terraform-backend-with-aws-s3-and-dynamodb-state-locking-96l)
1. [Terraform S3 Bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
1. [Terraform DynamoDB Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)

# In class exercise

We are going to complete last weeks in class exercise, and add a remote backend with AWS S3 and DynamoDB.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Create student-info-table, "studentID" attribute as hash key
resource "aws_dynamodb_table" "student-table" {
  name           = "student-info-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "studentID"

  attribute {
    name = "studentID"
    type = "S"
  }

  tags = {
    Name        = "student-table-ddb"
    Environment = "test"
  }
}

```

# Flipped learning material

No new flipped material this week. This might be a good time to do some review for the exam. 