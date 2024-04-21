# 4640 Assignment 1

## Learning objectives

In this assignment, students will gain practical experience in setting up AWS infrastructure using Terraform and AWS CLI. The focus is on designing and implementing functional infrastructure that includes a Virtual Private Cloud (VPC) containing a public and private subnet, each hosting an EC2 instance. Additionally, students will extend the infrastructure by installing Nginx on the public subnet using Terraform user data. The emphasis lies on providing clear documentation and creating a visual representation of the configured infrastructure. Through this hands-on approach, students will develop practical skills in cloud architecture and Infrastructure as Code (IaC) techniques.

**Key Learning Goals:**

-  Understand and apply Infrastructure as Code (IaC) principles using Terraform.
- Demonstrate proficiency in creating and configuring VPCs, subnets, and EC2 instances on AWS.
- Utilize AWS CLI commands for validation and retrieval of information.
- Extend infrastructure provisioning to include software installation using user data in your Terraform configuration.
- Develop effective documentation skills to articulate infrastructure design, decisions, and configurations.

## Instructions

### Terraform

Using Terraform create a VPC that contains two subnets, one public and one private. Each subnet should contain an EC2 instance.
The public EC2 instance should be accessible via SSH and HTTP from anywhere. 
The private EC2 instance should be accessible via SSH and HTTP from within the VPC only.

You will need an SSH key to connect to the EC2 instances when they have been provisioned. Your public key should be added to both EC2 instances.

In addition to the infrastructure above use the data block provided in a previous lab to get the most recent Ubuntu AMI.

Finally use "user_data" when writing your public ec2 instance resource to install nginx on the public ec2 instance.

### AWS

Using the AWS CLI write an individual command that will describe the following components in your infrastructure.
- VPCs
- routing tables
- internet gateways
- security groups
- ec2 instances

AWS CLI includes a 'describe-$resource' sub-command for most resources, for example to show information about any subnets you have created you could use:

```
aws ec2 describe-subnets --output yaml
```

These AWS CLI one liners can be helpful in quickly getting a overview of your infrastructure to help diagnose problems.

Include your AWS CLI commands in a 'README.md' along with your submission.
### Documentation and Diagram

Create a diagram of your infrastructure. You don't need to use a professional tool for this or AWS specific icons. Your diagram should be complete and should adequately describe your infrastructure. 

Finally create a short video (approximately 5 minutes) in which you you run and describe your Terraform configuration.

Submit your video as a link to a hosted video that can be played without creating an account. If you don't already have a video service that you prefer, [Loom](https://www.loom.com/) is a good choice(free education account) . Include the link to the your video in the README.md file.

In your video presentation, it's essential to communicate your thought process, decisions made during the configuration, and any challenges faced. This will help us understand your approach and problem-solving skills. Follow these guidelines to create an informative and engaging video:

1. **Introduction:**
    - Begin with a brief introduction, stating the objectives of your Terraform project and the key components you are setting up.

2. **Articulate Steps:**
    - Clearly articulate each step you take while configuring the AWS infrastructure using Terraform. Explain why you are making specific choices and how they contribute to the overall design.

3. **Thought Process:**
    - Share your thought process behind the architecture decisions. Discuss considerations such as security, scalability, and efficiency. This helps us evaluate the depth of your understanding.

4. **Key Terraform Commands:**
    - As you execute Terraform commands, capture and include the command-line output in your video. This provides evidence of the successful deployment and ensures transparency in your process. Focus on commands related to initialization, planning, and applying.

5. **Conclusion:**
    - Summarize the key aspects of your infrastructure, highlighting its functionality and any additional features implemented.

6. **Duration:**
    - Keep your video concise, aiming for a duration of approximately 5 minutes. Focus on delivering relevant information.
## Grading

**Terraform 5 points**
- Terraform configuration is complete
- Code is properly formatted
- Code includes meaningful comments

**AWS Commands and README 2 points**
- AWS commands are complete

**Diagram and Documentation 5 points**
- Diagram is clear and complete
- Video demonstrates required commands
- Video demonstrates understanding of Terraform configuration

**Total 12 points**

## Due date

Assignment is Due Friday February 16

## Breakdown of what you are submitting

Submit a 'your_name_as1.zip' that contains:
- A 'README.md' that contains 
	- a link to your hosted video
	- your AWS CLI commands
	- and any other necessary information.
- a 'main.tf' file in a 'terraform' directory
- a 'diagram.pdf'
- All three documents should include your name