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
function vpc_setup() {
  project="${1:-acit4640_l2}" 

  # Get the directory of this script
  script_dir=$(dirname "${BASH_SOURCE[0]}")
  # If no infrastructure file, default to one in the script directory
  output_file="${2:-"${script_dir}/infrastructure_data"}"

  # Variables
  region="us-west-2"
  vpc_cidr="10.0.0.0/16"
  subnet_cidr="10.0.1.0/24"

  # Verify VPC with the same name doesn't already exist
  # get ID of existing VPC if exists - will be blank if not
  existing_vpc=$(aws ec2 describe-vpcs \
                --filters Name=tag:Name,Values="${project}_vpc"\
                --query 'Vpcs[0].VpcId' --output text)
  

  if [[ "${existing_vpc}" == "None" ]]; then
    # VPC with name does not exist

    # Create VPC
    vpc_id=$(aws ec2 create-vpc \
      --cidr-block $vpc_cidr \
      --query 'Vpc.VpcId' \
      --output text --region $region)

    aws ec2 create-tags --resources "${vpc_id}" \
      --tags Key=Name,Value="${project}_vpc" Key=Project,Value="${project}" \
      --region $region

    # Enable DNS hostnames for EC2 instances in VPC
    aws ec2 modify-vpc-attribute \
      --vpc-id "${vpc_id}" \
      --enable-dns-hostnames Value=true

    # Create public subnet
    subnet_id=$(aws ec2 create-subnet --vpc-id "${vpc_id}" \
      --cidr-block "${subnet_cidr}" \
      --availability-zone "${region}a" \
      --query 'Subnet.SubnetId' \
      --output text \
      --region "${region}")

    aws ec2 create-tags --resources "${subnet_id}" \
      --tags Key=Name,Value="${project}_subnet" Key=Project,Value="${project}" \
      --region $region

    # Give each ec2 instance a public IP address
    aws ec2 modify-subnet-attribute \
      --subnet-id "${subnet_id}" \
      --map-public-ip-on-launch

    # Create internet gateway
    igw_id=$(aws ec2 create-internet-gateway \
      --query 'InternetGateway.InternetGatewayId' \
      --output text --region $region)

    aws ec2 create-tags --resources "${igw_id}" \
      --tags Key=Name,Value="${project}_igw" Key=Project,Value="${project}" \
      --region $region

    aws ec2 attach-internet-gateway --vpc-id "${vpc_id}" \
      --internet-gateway-id "${igw_id}" \
      --region "${region}"

    # Create route table
    route_table_id=$(aws ec2 create-route-table --vpc-id "${vpc_id}" \
      --query 'RouteTable.RouteTableId' \
      --region "${region}" \
      --output text)

    aws ec2 create-tags --resources "${route_table_id}" \
      --tags Key=Name,Value="${project}_route_table" Key=Project,Value="${project}" \
      --region $region

    # Associate route table with public subnet
    aws ec2 associate-route-table --subnet-id "${subnet_id}" \
      --route-table-id "${route_table_id}" --region "${region}"

    # Create route to the internet via the internet gateway
    aws ec2 create-route --route-table-id "${route_table_id}" \
      --destination-cidr-block 0.0.0.0/0 \
      --gateway-id "${igw_id}" \
      --region "${region}"

    # Write infrastructure data to a file
    echo "vpc_id=\"${vpc_id}\"" >>"${output_file}"
    echo "subnet_id=\"${subnet_id}\"" >>"${output_file}"
    
    # echo new vpc_id
    echo "${vpc_id}"
  else
    echo "${existing_vpc}"
  fi 
}

# If this script is run directly, create a VPC
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

  # Get the directory of this script
  script_dir=$(dirname "${BASH_SOURCE[0]}")

  # Use an infrastructure file in the script directory if none is specified 
  infrastructure_file="${1:-"${script_dir}/infrastructure_data"}"

  # Load the ssh_key_name and project from the infrastructure_data file
  source "${infrastructure_file}"

  vpc_setup "${project}" "${infrastructure_file}"
fi