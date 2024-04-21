This playbook creates a vpc with 1 subnet and 3 instances.

The configuration for the infrastructure is done in the
`host_vars/localhost.yml` file as the local host runs terraform.

The playbook uses the terraform configuration in `../terraform/backend` and `../terraform/infrastructure` to create the infrastructure.
This is done via the `terraform_be_infra` role.