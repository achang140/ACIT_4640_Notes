# Week 02 In-CLass Activity Solution

The solution to week 2 in class activity involved the following tasks:

1. Creating an S3 bucket
1. Creating an SSH key pair to access the remote EC2 instance
1. Create a VPC including:
   1. Internet Gateway
   1. Public Subnet
   1. Internet Gateway
   1. Route Table
1. Create an EC2 instance and protect it with a security group.

The solutions scripts for each of these tasks are provided in this directory.

1. [00_s3_setup.sh](00_s3_setup.sh) / [00_s3_cleanup.sh](00_s3_cleanup.sh)
1. [01_ssh_key_setup.sh](01_ssh_key_setup.sh)
1. [02_vpc_setup.sh](02_vpc_setup.sh)
1. [03_ec2_setup.sh](03_ec2_setup.sh)

The last three scripts are designed to be run in order.

The first script creates the SSH key pair and saves the private and public keys
to the local machine, and creates an infrastructure_data file in the same
directory as the script. The script can be run as follows:

```bash
bash ./vpc_setup_01_ssh_key.sh key_name project_name
```

The second script creates the VPC and saves the VPC ID and Subnet ID to the
infrastructure_data file. If the first script has been run, and the
infrastructure_data file exists, the script can simply be run as follows:

```bash
bash ./vpc_setup_02_vpc.sh
```

The third script creates the EC2 instance and saves the instance ID and Public
IP to the infrastructure_data file. If the first two scripts have successfully
been run, it can be run as follows:

```bash
bash  ./vpc_setup_03_ec2.sh
```

Once the scripts have been run, the infrastructure_data file should look
something like (example only):

```bash
ssh_key_name="acit4640_wk_02_key"
project="acit4640_wk_02"
vpc_id="vpc-01a779ddc02129287"
subnet_id="subnet-06946fbda669dd258"
ec2_public_ip="54.244.71.74"
ec2_id="i-062fc51ddc0973e47"
```

By `sourcing` the infrastructure_data file, in your shell you should be able to
connect to the EC2 instance using the following command:

```bash
source ./infrastructure_data
ssh -i ${ssh_key_name}.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${ec2_public_ip}
```

By using the utility script
[del_tagged_resources.sh](../../utiltiy/tagged_cleanup/del_tagged_resources.sh),
you can delete all of the resources created by the scripts by running the
following command:

```bash
bash del_tagged_resources.sh Project acit4640_week_02
```

Where `acit4640_week_02` is the name you specified for the 'project' when
running the setup scripts. You will need to run the script twice to cleanup the
VPC as there is a time delay between deleting some resources and being able to
delete the containing VPC.
