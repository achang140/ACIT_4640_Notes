# Learning outcomes and topics

- Terraform state
	- Review of terraform state files
	- Update state file to handle changes made outside of your Terraform configurations
- Terraform modules
	- modules what and why
	- Breakup an existing terraform configuration to use several modules

# Terraform state

When we first looked at Terraform we looked at the related state files, and touched on some of the relevant commands and concepts. Today we are going to revisit Terraform state and why it matters so much to anyone working with Terraform

> Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.
>[ Terraform state](https://developer.hashicorp.com/terraform/language/state)

In other words, Terraform knows about the resources you have created by storing them in state. By default in a "terraform.tfstate" file that is stored in your root module. When you work in a team on a larger project you would store your state in a remote. We will come back to remote state in another class.

The terraform state file is a JSON document that contains information about your resources, like the ID of your VPC. Generally you don't directly interact with this file. You let Terraform manage it through commands.

Because Terraform state is just stored in plain text, it is also not a good idea to store state files in version control.

## state locking

Some Terraform backends provide state locking. When you are working in a team you don't want two or more people trying to update your resources at the same time. So it is possible to lock your state to prevent this.

## viewing your state file

You can view your projects state with `terraform show`.
You can list the contents of the state file with `terraform state list`
You can view the state data of a single resource with the command 
`terraform state show aws_instance.my-instance`

## Terraform replace and refresh

In addition to alternate [planning modes](https://developer.hashicorp.com/terraform/cli/commands/plan#planning-modes), there are several options that can modify planning behavior. These options are available for both `terraform plan` and [`terraform apply`](https://developer.hashicorp.com/terraform/cli/commands/apply).


>`-refresh=false` Disables the default behavior of synchronizing the Terraform state with remote objects before checking for configuration changes. This can make the planning operation faster by reducing the number of remote API requests. However, setting `refresh=false` causes Terraform to ignore external changes, which could result in an incomplete or incorrect plan. You cannot use `refresh=false` in refresh-only planning mode because it would effectively disable the entirety of the planning operation.


> `-replace=ADDRESS` Instructs Terraform to plan to replace the resource instance with the given address. This is helpful when one or more remote objects have become degraded, and you can use replacement objects with the same configuration to align with immutable infrastructure patterns. Terraform will use a "replace" action if the specified resource would normally cause an "update" action or no action at all. Include this option multiple times to replace several objects at once. You cannot use `-replace` with the `-destroy` option, and it is only available from Terraform v0.15.2 onwards. For earlier versions, use [`terraform taint`](https://developer.hashicorp.com/terraform/cli/commands/taint) to achieve a similar result.

**Reference:**

[Terraform plan docs](https://developer.hashicorp.com/terraform/cli/commands/plan)
## removing a resource from state

Individual resources can be removed from your Terraform state with the

```bash
terraform state rm
```

This can be useful if you change how a resource is managed, or sometimes long running projects just need a little clean up.

Assume that you have an s3 bucket

```hcl
resource "aws_s3_bucket" "main" {
  bucket = "the-main-bucket"
  acl    = "private"
}
```

You could remove that resources with the command

```bash
terraform state rm "aws_s3_bucket.main"
```

## Terraform import block

It is also possible to import existing resources into your terraform configuration using an import block.

```hcl
import {
  to = aws_instance.example
  id = "i-abcd1234"
}

resource "aws_instance" "example" {
  name = "hashi"
  # (other resource arguments...)
}
```

### Generate file with new resources blocks

After adding an import block this will create a new file with blocks that correspond to any resources imported with an import block.

```bash
terraform plan -generate-config-out=generated.tf
```

Reference:

[Terraform import block](https://developer.hashicorp.com/terraform/language/import)

[HashiCorp video on the import block](https://www.youtube.com/watch?v=y8_5Ud29W8o)

## state exercise

Using the starter Terraform configuration provided below. Remove one of the EC2 instances with the `state rm` command. After removing the EC2 instance try to destroy the rest of your infrastructure. What problems did you encounter?

After identifying the problem destroy your infrastructure. 

Comment out the "aws_instance" resource in main.tf file and recreate your infrastructure with a new `terraform apply`. When your infrastructure has been provisioned add a new EC2 instance with the AWS CLI. Get the values needed for this command using terraform commands. The `terraform console` command might be a good option.

Create the EC2 instance
```bash
aws ec2 run-instances \
--image-id <ami_id> \
--count 1 \
--instance-type <instance_type> \
--subnet-id <subnet_id> \
--security-group-ids <security_group_id> \
--key-name <key_name>
```

Add tags (replace i-0... with your "InstanceId" value)
```bash
aws ec2 create-tags \
    --resources i-01002d54eb81a9d0b \
    --tags Key=Name,Value=ubuntu-server
```

When your new EC2 instance has been created use an import block in the main.tf file to import this EC2 instance into your Terraform configuration. Make notes on the steps and configuration code that you used. Imagine this was a task on an exam and you were allowed to take your notes into the exam when you are creating them.

Clean up and destroy all of the resources that you just created.

==hint: You may want to watch the video linked above on the import block.==

You will need a local ssh key pair for the starter code below.

[Starter code for state lab](https://gitlab.com/cit_4640/4640_notes_w24/-/blob/main/starter_code/week06/main.tf?ref_type=heads)

Reference:

[Managing Terraform State – Best Practices & Examples](https://spacelift.io/blog/terraform-state)

[Managing resources in Terraform state](https://developer.hashicorp.com/terraform/tutorials/state/state-cli)

# Terraform modules

Technically any Terraform configuration is a module. 

> _Modules_ are containers for multiple resources that are used together. A module consists of a collection of `.tf` and/or `.tf.json` files kept together in a directory.
> - [Terraform docs](https://developer.hashicorp.com/terraform/language/modules)

Modules help to organise, encapsulate and make configuration easier to reuse. 

An individual module can, and usually does contain multiple .tf files.

Modules can be stored in a number of places. Local files, Git repos, S3 buckets...

## module exercise

Unzip the zip file in the exercise starter files below and use it to answer the following questions.

1. How is data passed into a module?
2. How is data passed out of a module?
3. Modify the `mod_demo` module to create a security group module for use in the mod_demo project?

[Starter code for modules lab](https://gitlab.com/cit_4640/4640_notes_w24/-/blob/main/starter_code/week06/mod_demo.zip)

**Reference:**

[What Are Terraform Modules and How to Use Them](https://spacelift.io/blog/what-are-terraform-modules-and-how-do-they-work)

[Terraform Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources)

# Flipped learning material

- [Write Terraform Tests](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- Watch Lesson 5: Working with variables from [Ansible: From Basic to Guru](https://learning.oreilly.com/course/ansible-from-basics/9780137894949/)
- Watch Lesson 6: Using Conditionals from [Ansible: From Basic to Guru](https://learning.oreilly.com/course/ansible-from-basics/9780137894949/)
# Todo

- [ ]  Complete and submit assignment 1
- [ ] Review flipped material above