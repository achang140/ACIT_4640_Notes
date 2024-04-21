variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  default     = "192.168.1.0/24"
}

variable "default_route"{
  description = "Default route"
  default     = "0.0.0.0/0"
}

variable "home_net" {
  description = "Home network"
  default     = "75.157.0.0/16"
}

variable "bcit_net" {
  description = "BCIT network"
  default     = "142.232.0.0/16"
  
}

variable "instance_type" {
  description = "EC2 instance type used for the instances"
  type        = string
  default     = "t2.micro"
}

variable "ec2_instance_user" {
  description = "The linux user used to connect to EC2 instances via ssh"
  type        = string
  default     = "ubuntu"
}