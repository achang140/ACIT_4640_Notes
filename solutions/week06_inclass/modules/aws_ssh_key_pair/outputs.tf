output "public_key" {
  value = data.local_file.ssh_pub_key.content
  description = "The public key data"
}

output "priv_key_file" {
  value = "${path.root}/${var.key_name}.pem"
  description = "The path of the private key"
}

output "pub_key_file" {
  value = "${path.root}/${var.key_name}.pem.pub"
  description = "The path of the public key"
}