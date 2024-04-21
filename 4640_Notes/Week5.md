# Learning outcomes and topics

- Quiz 1
- Install Ansible
- Ansible configuration
- Ansible inventory
- Ansible ad hoc commands
- Ansible playbooks

# Ansible Notes

# Installing Ansible

Depending on the Linux distro you are using a recent version of Ansible may be
in the package repositories. If you are looking for the package note that
Ansible is distribute as Ansible-core and Ansible. You want Ansible, **not**
Ansible-Core.

In Ubuntu/Debian and distros forked from Ubuntu or Debian you can use a PPA to
install Ansible.

If you are using Ubuntu or Debian you can use this script below. This will also
install a few nice-to-haves including a VSCode extension.

```bash
#!/user/bin/env bash

# Install Ansible
sudo apt -y update
sudo apt install -y software-properties-common python3-pip python3-boto3
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt -y update
sudo apt install -y ansible ansible-lint python3-argcomplete

# Install CLI completion
sudo activate-global-python-argcomplete3

# Install VSCode extension
code --install-extension redhat.ansible
```

You can also install Ansible with pipx.

# Configure Ansible

By default Ansible will use configuration in `/etc/ansible`. It is far more
convenient to have configuration files per-project in your project root. So
throughout the class we will be making use of a per-project `ansible.cfg` file.

To get started copy the main.tf starter file
[here](https://gitlab.com/cit_4640/4640_notes_w24/-/tree/main/starter_code) into
a new main.tf file in new directory in your development environment.

This Terraform configuration includes two blocks that will create the two files
that we need for our Ansible configuration.

- ansible.cfg
- hosts.yml (our static inventory file)

The main.tf file will also create the infrastructure that we need to get started
with Ansible.

After applying the Terraform configuration we will take a look at the two
configuration files created. We want to look at how Ansible is connecting
servers. We also want to look at how servers can be grouped so that we can run
commands on a group of servers instead of all of the servers.

With Ansible installed and our infrastructure provisioned we can check that
everything works with the following command

```
ansible-inventory --graph
```

# In-class exercise

The Ansible ad hoc commands and playbook sections contain tasks. These tasks
make up your in class exercise for today.

Just like previous labs, please do these in small groups 2-3.

For this one the easiest way to submit these is in a markdown document that
contains your ad hoc commands and playbooks in code blocks. You can write a code
block in markdown by starting and ending your code block with three backticks.

submit a "lab-week5.md" file. Include the names of everyone you worked with.


# Ansible ad hoc commands

## Ansible modules

> [!note]
>
> > In Ansible 2.10 and later, we recommend you use the fully-qualified
> > collection name in your playbooks to ensure the correct module is selected,
> > because multiple collections can contain modules with the same name (for
> > example, `user`).
> > [Ansible docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html#playbook-execution)

To see a list of available modules

```bash
ansible-doc -t module -l
```

This will display module names and a brief description in a pager(less).
Pressing the 'h' key brings up the less help menu.

You can also look at the documentation for a specific module with the command

```bash
ansible-doc module-name
```

The documentation for most modules contains examples, which are really helpful.

## Ad hoc commands

"An Ansible ad hoc command uses the ansible command-line tool to automate a
single task on one or more managed nodes."

An ad hoc command can be used to perform numerous one-off-commands. If you just
want to restart a service on a couple of servers it is often easier to use an ad
hoc command than to write a new playbook.

Ad hoc commands are also a good introduction some key Ansible concepts (such as
modules) and some of the cool things that you can do with Ansible.

The general syntax of an Ansible ad hoc command is as follows:

```bash
ansible [pattern] -m [module] -a "[module options]"
```

pattern is the servers that we want to target. 'all' will target all of your
servers.

```bash
ansible all -m ansible.builtin.ping
```

You can also run standard commands using any utilities installed on your
servers.

```bash
ansible web -a "ls -a"
```

Keep in mind that running commands using the `command` or `shell` module are not
necessarily idempotent.

## tasks

Big hint, look at the Ansible docs on ad hoc commands linked below!

- Write an ad hoc command that will display the kernel version of the "db"
  servers. (hint `uname`).
- Write an ad hoc command that will install nginx on the web servers. (hint
  Ansible has a number of package modules, including an apt module)
- Create a 'file' directory and add the HTML document below as 'index.html'.
  Then write an ad hoc command that will copy your local 'index.html' to the
  `/var/www/html` directory on your web servers. (hint copy module)
- write an ad hoc command that will restart the nginx service. (hint service
  module)
- Finally visit one of your web servers in the browser to confirm that you are
  serving HTML document below instead of the default nginx page.
- What does "Idempotent" mean? What does this mean in the context of an Ansible
  ad hoc command?

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>4640-Document</title>
  </head>
  <body>
    <h1>Not the default nginx Document</h1>
  </body>
</html>
```

**Reference:**

[Ansible ad hoc commands](https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html)

# Ansible playbooks

While ad hoc commands are incredibly useful, sometimes you need to run several
tasks on a server. Ansible playbooks allow you to store a series of tasks in a
YAML file. Just like ad hoc commands you can target specific servers or groups
of servers.

Ansible playbooks can also include variables and conditional statements. We will
look at those later.

Below is an example playbook that will install and start the apache server in
Ubuntu.

```yaml
---
- name: install and enable httpd
  hosts: web
  become: true
  tasks:
    - name: install apache2 package
      ansible.builtin.package:
        name: apache2
        state: latest
    - name: start and enable apache2 service
      ansible.builtin.service:
        name: apache2
        state: started
        enabled: yes
```

Playbooks often start with `---`. A single YAML file can contain multiple
documents separated by `---` document start and `...` document end.

To run a playbook use the command

```bash
ansible-playbook playbook-name.yaml
```

To see more verbose output use the -v option. The -v options has levels of
verbosity. -v to -vvvvvv

```bash
ansible-playbook -vv playbook-name.yaml
```

## tasks

Start by destroying your infrastructure and re-creating it (or have another team
member run commands on their laptop.)

Write a playbook that performs the following tasks:

On your web servers

- install nginx
- copy the example HTML document above to the `/var/www/html` directory
- restart the nginx service

On your db server

- install mysql-server

On your backend servers

- install bun
  - Install bun as the ubuntu user. After installation a .bun directory should
    be in the ubuntu users home directory and the ubuntu user should be able to
    run the bun command.

[bun installation docs](https://bun.sh/docs/installation)

Reference:

[Ansible playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)

[Some example playbooks](https://www.middlewareinventory.com/blog/ansible-playbook-example/)

# Resources

[YAML syntax](https://yaml.org/)

[Ansible docs](https://docs.ansible.com/index.html)

[Jinja2](https://jinja.palletsprojects.com/en/2.10.x/)

# Flipped learning material

Watch
[Lesson 2: Terraform Modules, Terraform Core Functionality](https://learning.oreilly.com/course/terraform-core-functionality/9780138312701/)

# Todo

- [ ] Continue working on Assignment 1
- [ ] Watch the videos above in the flipped learning material section
