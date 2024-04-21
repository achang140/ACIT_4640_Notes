variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project Name"
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
