output "vpc" {
  value = module.vpc_simple.vpc.id
}

output "sn" {
  value = module.vpc_simple.sn.id

}

output "gw" {
  value = module.vpc_simple.gw.id
}

output "rt" {
  value = module.vpc_simple.rt.id
}

output "public_sg" {
  value = module.public_sg.self
}

output "ec2_instances" {
  description = "Name indexed Map of EC2 instance information that includes id, public IP, private IP, DNS name, and availability zone"
  value = {
    for instance in aws_instance.main : 
        instance.tags.Name => {
          "id" = instance.id
          "ip" = instance.public_ip
          "priv_ip" = instance.private_ip
          "dns_name" = instance.public_dns
          "sg" = instance.security_groups
      }
  }
}

output "ssh_pub_key_file" {
  description = "Absolute path to the public key file"
  value = abspath(module.ssh_key.pub_key_file)
}

output "ssh_priv_key_file" {
  description = "Absolute path to the private key file"
  value = abspath(module.ssh_key.priv_key_file)
}

output "ansible_ssh_private_key_file"{
  value = "${abspath(module.ssh_key.priv_key_file)}"
  description = "The absolute path to the private key file"
}

output "ansible_user" {
  value = var.ec2_instance_user
  description = "The OS user used for to connect to the instance via ssh"
}

output "project_name" {
  value = var.project_name
  description = "value of the project name"
}
