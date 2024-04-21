#!/usr/evn/bash

# set the web server hostname, this is from the ansible inventory file 
declare -r WEBHOST="web01"

# Display the kernel version of the "db" servers
ansible db -m ansible.builtin.command -a "/usr/bin/uname -a"

# install nginx on the web servers
ansible web \
  --module-name ansible.builtin.package \
  --args "name=nginx state=present update_cache=yes" \
  --become

# copy your local 'index.html' to the `/var/www/html` directory the web servers
ansible web \
  --module-name ansible.builtin.copy \
  --args "src=./files/index.html dest=/var/www/html/index.html mode=u=rw,g=r,o=r" \
  --become

# restart and enable the nginx service on the web servers
ansible web \
  --module-name ansible.builtin.service --args "name=nginx enabled=true state=restarted" \
  --become

# get the FQDN of the web01 server
# get the ansible_host variable from the hostvars dictionary
# grep the output for line with the ansible_host variable
# and use awk to print the second column, ie. the value of the ansible_host
host_fqdn=$(ansible "${WEBHOST}" \
  -m ansible.builtin.debug \
  -a "var=hostvars.${WEBHOST}.ansible_host" |
  grep "ansible_host" |
  awk '{print $2}')

# Remove the double quotes from the output
host_fqdn="${host_fqdn//\"/}"

# Display the content of the index.html file served by the web server
curl "http://${host_fqdn}/index.html"

# What does "Idempotent" mean? 
#   Idempotent means that the result of an operation is the same regardless of how
#   many times the operation is performed.

# What does this mean in the context of an Ansible ad hoc command?
#   It means that ansible operation can be executed many times without worrying
#   about the state of the system. The operation will always produce the same
#   result.

