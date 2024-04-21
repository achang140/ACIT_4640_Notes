#! /usr/bin/env bash
# This script is used to clean terraform infrastructure and remove all 
# init, state, and lock files. This allows a clean run of terraform init
# during ansible provisioning

script_dir=$(dirname "${BASH_SOURCE[0]}")

project_dir="${1:- "${script_dir}/terraform"}"

# array of terraform init, state, and lock files
declare -a tf_files=( \
    ".terraform" \
    ".terraform.lock.hcl" \
    "terraform.tfstate" \
    "terraform.tfstate.backup" \
)

# order is important destroy the infrastructure first before the backend
declare -a tf_files_dir=( \
    "./infrastructure" \
    "./backend" \
)

# perform terraform destroy for all terraform configuration directories
for dir in "${tf_files_dir[@]}"; do
    pushd "${project_dir:?}/${script_dir}/${dir}" || exit
    terraform destroy -auto-approve
    popd || exit
done

# Remove all terraform state, lock, and init files
remove terraform files
for dir in "${tf_files_dir[@]}"; do
    for file in "${tf_files[@]}"; do
            rm -vr "${project_dir:?}/${dir}/${file}"
    done
done

