module "vpc_simple" {
  source       = "./modules/terraform_vpc_simple"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
  aws_region   = var.aws_region
}

module "public_sg" {
  source = "./modules/terraform_security_group"
  sg_name = "${var.project_name}_public_sg"
  sg_description = "Allows ssh, web, ingress access and all egress"
  project_name = var.project_name
  vpc_id = module.vpc_simple.vpc.id
  ingress_rules = [
    {
      description = "ssh access from home"
      ip_protocol = "tcp"
      from_port = 22
      to_port = 22
      cidr_ipv4 = var.home_net
      rule_name = "${var.project_name}_public_ssh_access_home"
    },
    {
      description = "ssh access from bcit"
      ip_protocol = "tcp"
      from_port = 22
      to_port = 22
      cidr_ipv4 = var.bcit_net
      rule_name = "${var.project_name}_public_ssh_access_bcit"
    },
    {
      description = "web access from home"
      ip_protocol = "tcp"
      from_port = 80
      to_port = 80
      cidr_ipv4 = var.home_net
      rule_name = "${var.project_name}_public_web_access_home"
    },
    {
      description = "web access from bcit"
      ip_protocol = "tcp"
      from_port = 80
      to_port = 80
      cidr_ipv4 = var.bcit_net
      rule_name = "${var.project_name}_public_web_access_bcit"
    },
    {
      description = "intra vpc access"
      ip_protocol = "-1"
      from_port = null
      to_port = null
      cidr_ipv4 = module.vpc_simple.vpc.cidr_block
      rule_name = "${var.project_name}_public_intra_vpc_access"
    }

   ]
  egress_rules = [ 
    {
      description = "allow all egress traffic"
      ip_protocol = "-1"
      from_port = null
      to_port = null
      cidr_ipv4 = "0.0.0.0/0"
      rule_name = "${var.project_name}_public_allow_all_egress"
    }
   ]
}

## ----------------------------------------------------------------------------
## SETUP SSH KEY PAIR: LOCAL FILE AND AWS KEY PAIR
## ----------------------------------------------------------------------------

module "ssh_key" {
  source = "./modules/aws_ssh_key_pair"
  key_name = var.project_name
}

# Get the most recent Ubuntu 23.04 image ID
data "aws_ami" "ubuntu" {
  most_recent = true

  # this is the owner id for Canonical - the publisher of Ubuntu
  owners = ["099720109477"]

  filter {
    name = "name"
    # this is a glob expression - the * is a wildcard - that matches  the most
    # recent ubuntu 23.04 image x86 64-bit server image
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

locals {
  security_groups = [module.public_sg.self.id]
  server_roles = ["web", "db", "app"]
}

## ----------------------------------------------------------------------------
## SETUP EC2 INSTANCES: one for each server role
## ----------------------------------------------------------------------------

# Create two ec2 isntances, one per security group
resource "aws_instance" "main" {
  
  count           = length(local.server_roles) 
  ami             = data.aws_ami.ubuntu.id

  instance_type   = var.instance_type
  key_name        = module.ssh_key.key_name

  subnet_id       = module.vpc_simple.sn.id
  security_groups = local.security_groups

  tags = {
    # use - as separator in name so it can be used as hostname in linux
    Name    = "${local.server_roles[count.index]}"
    Project = var.project_name
    Server_Role = "${local.server_roles[count.index]}"
  }

  lifecycle {
    # prevent terraform from deleting and recreating the instance when managed by ansible
    ignore_changes = all
  }
}

## ----------------------------------------------------------------------------
## CONFIGURE ANSIBLE
## Create Ansible variable file to specify the ssh key and user for connecting
## to the ec2 instances 
## ----------------------------------------------------------------------------

resource "local_file" "all_vars" {
  content = <<-EOF
  ansible_ssh_private_key_file: "${abspath(module.ssh_key.priv_key_file)}"
  ansible_user: ${var.ec2_instance_user}
  project_name: "${var.project_name}"
  EOF
  filename = abspath("${path.root}/../../ansible/group_vars/all.yml")
}

## ----------------------------------------------------------------------------
## CONFIGURE ANSIBLE
## Create bash variables file to help when connecting via ssh 
## to the ec2 instances 
## example: invocation
## source ../../connect_vars.sh
## ssh -i ${private_key_file} -o StrictHostKeyChecking=No -o UserKnownHostsFile=/dev/null ${ansible_user}@${web}
## ----------------------------------------------------------------------------

resource "local_file" "connect_vars" {
  content = <<-EOF
  private_key_file="${abspath(module.ssh_key.priv_key_file)}"
  ansible_user=${var.ec2_instance_user}
  %{for instance in aws_instance.main~}
${split("-",instance.tags.Name)[0]}="${instance.public_dns}"
  %{endfor~}
  EOF
  filename = abspath("${path.root}/../../connect_vars.sh")
}

