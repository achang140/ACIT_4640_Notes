# Learning outcomes and topics
- Review week 3 Terraform Lab
- Instance user_data in Terraform configuration
- AWS CLI 'describe' sub-commands
- Testing and troubleshooting Terraform
	- Terraform console command
	- TF_LOG Logging and environment variables
- Assignment 1

# Next week will be first quiz.

The quiz will be online(d2l), closed book and 20 minutes. 

The quiz will be on material from weeks 1-4. 

Good luck everyone.
# Week 3 exercise review

We will look at the simplest solution in class and talk about a few common errors that were encountered.

# user data when creating an ec2 instance

AWS (and most other cloud service providers) provide cloud-init or user-data features which allow you to run additional configuration when creating a new EC2 instance.  

When you create an EC2 instance in the web console there is an option to add a bash script. This feature is also available when you create an EC2 instance with Terraform. In fact there are a few methods that you can use with Terraform. All of them should really only be used for small changes, if at all. Generally you would create a container, or image with a tool like packer, or configure your server with a tool like Ansible. 

All of that said, sometimes it is handy to run a simple script on a server.

you can do that that by adding `user_data` to your aws_instance resource block.

user_data can contain a file or heredoc. The example below uses a heredoc to write the word "hello" to a file named " hello-file".

```hcl
resource "aws_instance" "ubuntu" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id
  user_data     = <<-EOF
    #!/bin/bash
    echo "hello" > hello-file
  EOF
}
```

Something important to note about user_data is that it is run as root. The example above will write the file in the root users home directory, not the Ubuntu users home directory. 

# AWS CLI *describe* sub-commands

When we introduced the AWS CLI we were primarily interested in getting everything installed, and creating resources. Because creating stuff is just more fun.

A common use for the AWS CLI is to "describe" your existing resources. This can be useful in troubleshooting situations where you may have valid Terraform code that is creating the infrastructure you want, but perhaps you can't connect to an EC2 instance via ssh and you aren't sure why.

For example if I want to show info about all of the subnets I have created I can do that with the command below. Remember that your profile configures a specific region, so unless you override that this will display subnets in that region only.

```
aws ec2 describe-subnets --output yaml
```

In the example above I used the `--output` option with `yaml` another useful formatting style is `table`. 

```
aws ec2 describe-subnets --output table
```

That information can be filtered

```
aws ec2 describe-subnets \
    --filters Name=vpc-id,Values="$dubnet-id" \
    --output yaml
```

Or you can use a query to look for specific information

```
aws ec2 describe-subnets \
    --filters "Name=tag:CostCenter,Values=123" \
    --query "Subnets[*].SubnetId" \
    --output text
```

The describe sub-command isn't limited to subnets. If you visit the link to the docs [here](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/index.html#cli-aws-ec2), and scroll down to describe, you will find describe sub-commands that cover all of the infrastructure you will use in assignment 1.

**Reference:**

[aws-cli describe-subnets docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-subnets.html)

# Testing and troubleshooting Terraform

In general testing and troubleshooting Terraform configuration has been a weakness of Terraform. 

Tools like [TFLint](https://github.com/terraform-linters/tflint) and the included `fmt` and `validate` commands are helpful in catching some common coding errors. Third party tools like [Terratest](https://terratest.gruntwork.io/) and [Kitchen-Terraform](https://newcontext-oss.github.io/kitchen-terraform/) were created to help with testing. And just recently Terraform introduced the `test` command to[ validate module configuration](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test).  But Terraform is still a little more difficult to test than a general purpose programming language.

To be fair, one of the things that makes it difficult to test Terraform configuration is one of Terraform's greatest strengths. You can write configuration for just about anything. 

Sometimes this means adopting an awkward testing solution that involves different tools. The AWS CLI is quite useful for helping to test AWS resources.

Today we are going to look at three included tools that can be used to help test and troubleshoot your Terraform code.

## TF_LOG

Terraform provides a standard logging mechanism that prints to stderr. You can enable logging by setting a logging level using the TF_LOG environment variable.

```bash
export TF_LOG="DEBUG"
```

TF_LOG can be set to a log level of `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR` or `JSON`
`JSON` writes logs at the `TRACE` level and uses a JSON encoded formatting.

setting the log file path

We can also set the location where the log file will be stored. Depending on your project you may want to store the log file in your project root, or a central log location.

```bash
export TF_LOG_PATH="$HOME/terraform/project/debug.log"
```

After setting both environment variables the next Terraform command that you run will create the log file and include logging up to the specified log level 

**Reference:**

[Debugging Terraform](https://developer.hashicorp.com/terraform/internals/debugging)

## terraform show and terraform state show

The `terraform show` command can be used to inspect either the Terraform state file or the a Terraform plan file.

`terraform show [options] [file]`

Similarly the Terraform state command can be used to show information about resources in your state file.

For example to see the details of an aws_instance named "my_ec2" you could use the command.

```
terraform state show aws_instance.my_ec2
```

**Reference:**

[Command: show](https://developer.hashicorp.com/terraform/cli/commands/show)

[State Command](https://developer.hashicorp.com/terraform/cli/commands/state)
## Terraform console command

The Terraform console command can be used in a similar fashion, to learn about your existing infrastructure. 

To start the console run the command `terraform console` use `exit` to return to your prompt. Entering the console starts a new interactive CLI. 

From this interface you could for example show information about an ec2 instance by entering `aws_instance.my_ec2`

Where the Terraform console is more useful is in testing out functions, and logic. For example if you want to test that a Terraform function will return the expected results.

```hcl
# The below command will merge list elements into a string, separating them with commas.
> join(",",["foo","bar"])
"foo,bar"
```

**Reference:**

[Command: console](https://developer.hashicorp.com/terraform/cli/commands/console)

[Troubleshoot terraform](https://developer.hashicorp.com/terraform/tutorials/configuration-language/troubleshooting-workflow)

# Flipped learning material
- Ch 1. Introduction, Ansible Up and Running 3rd
- Ch 3. Playbooks: A beginning, Ansible Up and Running 3rd

# Todo
- [ ] Study for quiz next week
- [ ] Work on assignment 1