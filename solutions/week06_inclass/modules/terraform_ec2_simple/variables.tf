variable "project_name" {
  description = "Project name"

}
variable "type" {
  description = "Instance type"
  default     = "t2.micro"
  
}

variable "aws_region" {
  description = "AWS region"
}

variable "ami_id" {
  description = "AMI ID"
}

variable "subnet_id" {
  description = "The subnet to launch the instance on"
}

variable "security_group_id" {
  description = "The security group to launch the instance in"
}

variable "ssh_key_name" {
  description = "AWS SSH key name"
  default     = "acit_4640_202410"
}

