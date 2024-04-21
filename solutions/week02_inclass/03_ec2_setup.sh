#!/usr/bin/env bash
set -eu

#####################################################################
# Creates a new VPC with a public subnet and internet gateway
# Arugments:
#   project: The name of the project to create, this is also the prefix for each
#        of the resource names
#   output_dir: The directory to save the infrastructure data to
# Outputs:
#   - A file named infrastructure_data containing the following variables:
#     - vpc_id: The ID of the VPC
#     - subnet_id: The ID of the public subnet
#     - project: The name of the project
# Returns:
#   - The ID of the VPC
#####################################################################
create_ec2_instance() {
  project="${1:-default}"
  vpc_id="${2}"
  subnet_id="${3}"
  ssh_key_name="${4}"
  infrastructure_file="${5}"

  # Variables
  region="us-west-2"

  # Verify VPC with the same name doesn't already exist
  # get ID of existing VPC if exists - will be blank if not
  existing_instance=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=\"${project}_ec2\"" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].VpcId" \
    --output text)

  if [[ "${existing_instance}" == "None" ]]; then
    # VPC with name does not exist
    # Get Ubuntu 23.04 image id owned by amazon
    ubuntu_ami=$(aws ec2 describe-images \
      --region $region \
      --owners amazon \
      --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server* \
      --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

    # Create security group allowing SSH and HTTP from anywhere
    security_group_id=$(aws ec2 create-security-group \
      --group-name "${project}_sg"\
      --description "Allow SSH and HTTP" \
      --vpc-id "${vpc_id}" \
      --query 'GroupId' \
      --region $region \
      --output text)

    aws ec2 create-tags \
      --resources "${security_group_id}" \
      --tags Key=Name,Value="${project}_sg" Key=Project,Value="${project}"

    # Add ingress rules to security group allowing inbound SSH
    aws ec2 authorize-security-group-ingress \
      --group-id "${security_group_id}" \
      --protocol tcp \
      --port 22 \
      --cidr "0.0.0.0/0" \
      --region "${region}"

    # Add ingress rules to security group allowing inbound HTTP
    aws ec2 authorize-security-group-ingress \
      --group-id "${security_group_id}" \
      --protocol tcp \
      --port 80 \
      --cidr "0.0.0.0/0" \
      --region "${region}"

    # egress rule group allowing outbound traffic to anywhere using any protocol exists by default
    # aws ec2 authorize-security-group-egress \
    #   --group-id "${security_group_id}" \
    #   --protocol "-1"\
    #   --cidr "0.0.0.0/0"

    # Launch an EC2 instance in the public subnet
    instance_id=$(aws ec2 run-instances \
      --image-id "${ubuntu_ami}" \
      --count 1 \
      --instance-type "t2.micro" \
      --key-name "${ssh_key_name}" \
      --security-group-ids "${security_group_id}" \
      --subnet-id "${subnet_id}" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=\"${project}_ec2\"},{Key=Project,Value=\"{project}\"}]" \
      --output text \
      --query 'Instances[*].InstanceId')

    # Name and Tag the instance
    aws ec2 create-tags --resources "${instance_id}" \
      --tags Key=Name,Value="${project}_ec2" Key=Project,Value="${project}" \
      --region $region

    # wait for ec2 instance to be running
    aws ec2 wait instance-running --instance-ids "${instance_id}"

    # Get the public IP address of the EC2 instance
    public_ip=$(aws ec2 describe-instances \
      --instance-ids "${instance_id}" \
      --query 'Reservations[*].Instances[*].PublicIpAddress' \
      --output text)

    # Write instance data to a file
    echo "ec2_public_ip=\"${public_ip}\"" >>"${infrastructure_file}"
    echo "ec2_id=\"${instance_id}\"" >>"${infrastructure_file}"

    # Print the EC2 Instance Id
    echo "${instance_id}"
  else
    # If an EC2 instance with name already exists, print the instance ID
    echo "${existing_instance}"
  fi


}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Script is not being sourced

  script_dir=$(dirname "${BASH_SOURCE[0]}")

  # If no infrastructure file, default to infrastructure_data in the script directory
  infrastructure_file="${1:-"${script_dir}/infrastructure_data"}"

  # Get vpc_id, subnet_id, key_name from infrastructure file 
  source "${infrastructure_file}"

  # Check if the required variables are set
  if [[ -v vpc_id && -v subnet_id && -v ssh_key_name ]]; then
    # Call the function and pass all the arguments to it
    create_ec2_instance "${project}" "${vpc_id}" "${subnet_id}" "${ssh_key_name}" "${infrastructure_file}"
  else
    echo "Error: infrastructure_data file does not exist or is missing variables"
    exit 1
  fi

fi
