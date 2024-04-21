#!/usr/bin/env bash
#
# Creates a new SSH key pair using AWS CLI and saves the private and public
# keys to a files in the script directory
# Arguments:
#   key_name: The name of the key pair to create, this is also the stem of the output file
#   project: The name of a project to tag the key pair with

# Exit immediately and exit on undefined variables
set -eu

#####################################################################
# Creates a new SSH key pair using the AWS CLI and saves the private
#  key to a file.
# Arugments:
#   key_name: The name of the key pair to create, this is also the
#     stem of the output file
#   project: The name of the project, this is used to tag the key
#   output_dir: The directory to save the key files to
# Outputs:
#   - A file named ${key_name}.pem containing the private key
#   - A file named ${key_name}.pem.pub containing the public key
#####################################################################
create_ssh_key_pair() {
  key_name="${1:-key_file}"
  project="${2:-defualt_project}"

  # Get the directory of this script
  script_dir=$(dirname "${BASH_SOURCE[0]}")
  # If no output directory, default to the script directory
  output_dir="${3:-${script_dir}}"

  # Store full path to output files
  private_key_file="${output_dir}/${key_name}.pem"
  public_key_file="${output_dir}/${key_name}.pem.pub"

  # Check if the key pair already exists supressing any error messages
  existing_key_pair=$(aws ec2 describe-key-pairs \
    --key-name "${key_name}" \
    --include-public-key \
    --query "KeyPairs[0].KeyName" \
    --output text 2>/dev/null)

  # Check if the key pair doesn't exist
  if [[ -z "${existing_key_pair}" ]]; then
    # Key pair does not exist
    # Create the key pair and save the private key to a file
    aws ec2 create-key-pair \
      --key-name "${key_name}" \
      --key-type ed25519 \
      --key-format pem \
      --tag-specifications "ResourceType=key-pair,Tags=[{Key=Project,Value=\"${project}\"}, {Key=Name,Value=\"${key_name}\"}]" \
      --output text \
      --query "KeyMaterial" >"${private_key_file}"

    # remove non-user permissions on the private key file
    chmod go= "${private_key_file}"

    # Get the public key from AWS and save it to a file
    aws ec2 describe-key-pairs \
      --key-name "${key_name}" \
      --include-public-key \
      --query "KeyPairs[0].PublicKey" \
      --output text >"${public_key_file}"
    
    # Get Key Pair Name
    aws ec2 describe-key-pairs \
      --key-name "${key_name}" \
      --include-public-key \
      --query "KeyPairs[0].KeyName" \
      --output text 
  else
    # If the key pair already exists, print the key pair name 
    echo "${existing_key_pair}"
  fi
  
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Script is not being sourced
  key="${1:-new_key}"
  project="${2:-default_project}"
  script_dir=$(dirname "${BASH_SOURCE[0]}")

  output_file="${script_dir}/infrastructure_data"

  key_name=$(create_ssh_key_pair "${key}" "${project}" "${script_dir}")

  # Print the key name and project as bash variable assignment
  # redirect to infrastructure_data file
  echo "ssh_key_name=\"${key_name}\"">>"${output_file}"
  echo "project=\"${project}\"">>"${output_file}"
fi
