# Learning outcomes and topics

- Test terraform modules
	- Terraform test framework
- Use Ansible variables and facts
- Use Ansible conditionals
	- handlers
	- when
	- loop

# Terraform test framework

> Terraform tests let you validate your module configuration without impacting your existing state file or resources. Testing is a separate operation that is not part of a plan or apply workflow, but instead builds ephemeral infrastructure and tests your assertions against in-memory state for those short-lived resources. This lets you safely verify changes to your module without affecting your infrastructure.
> - [Terraform docs](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)


Terraform tests consist of two parts:

1. Test files that end with the `.tftest.hcl` file extension
2. Optional helper modules, which you can use to create test-specific resources and data sources outside of your main configuration

By default when you run the `terraform test` command, Terraform looks for `.tftest.hcl` files in both the root directory and in the `tests` directory.

## The run block

Terraform tests introduces a new block, `run`. The `run` block has the following fields and blocks.

| Field or Block Name                                                               | Description                                                                                                              | Default Value |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `command`                                                                         | An optional attribute, which is either `apply` or `plan`.                                                                | `apply`       |
| `plan_options.mode`                                                               | An optional attribute, which is either `normal` or `refresh-only`.                                                       | `normal`      |
| `plan_options.refresh`                                                            | An optional boolean attribute.                                                                                           | `true`        |
| `plan_options.replace`                                                            | An optional attribute containing a list of resource addresses referencing resources within the configuration under test. |               |
| `plan_options.target`                                                             | An optional attribute containing a list of resource addresses referencing resources within the configuration under test. |               |
| [`variables`](https://developer.hashicorp.com/terraform/language/tests#variables) | An optional `variables` block.                                                                                           |               |
| [`module`](https://developer.hashicorp.com/terraform/language/tests#modules)      | An optional `module` block.                                                                                              |               |
| [`providers`](https://developer.hashicorp.com/terraform/language/tests#providers) | An optional `providers` attribute.                                                                                       |               |
| [`assert`](https://developer.hashicorp.com/terraform/language/tests#assertions)   | Optional `assert` blocks.                                                                                                |               |
| `expect_failures`                                                                 | An optional attribute.                                                                                                   |               |


```hcl
run "file_contents_should_be_valid_json" {
  command = plan

  assert {
    condition     = try(jsondecode(local_file.config.content), null) != null
    error_message = "The file is not valid JSON"
  }
}
```

**Reference:**
- [Terraform testing framework](https://developer.hashicorp.com/terraform/language/tests)
- [HashiConf 2023 presentation of Terraform test framework](https://www.youtube.com/watch?v=m5lKVKqk2qc)

# Ansible variables

The example below defines a variable in the playbook header and references the variable in a play.

```yaml
- name: create a new user
  hosts: rocky
  vars:
    user: lisa
  tasks:
    - name: create a new user {{ user }} on host {{ ansible_hostname }}
      ansible.builtin.user:
	    name: "{{ user }}"
```

If a variable is the first or only element in the line it must be wrapped in quotation marks.

## defining variables in lists and dictionaries

```yaml
vars:
	port_nums: [21,22,23,25,80,443]
vars:
    users:
      bob:
        username: bob
        uid: 1122
        shell: /bin/bash
      lisa:
        username: lisa
        uid: 2233
        shell: /bin/sh
```
## where can Ansible variables be defined

> You can define variables in a variety of places, such as in inventory, in playbooks, in reusable files, in roles, and at the command line. Ansible loads every possible variable it finds, then chooses the variable to apply based on [variable precedence rules](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#ansible-variable-precedence).
> - Ansible docs

Using vars_files to load variables stored in a separate file:

```yaml
- name: using a variable include file
  hosts: rocky
  gather_facts: no
  vars_files: myvars.yaml
  tasks:
    - name: install package {{ mypackage }}
      ansible.plugin.yum:
        name: "{{ mypackage }}"
        state: latest
```

`myvars.yaml`
```yaml
mypackage: nmap
var_two: value
```

Prompt the user to enter a variable with `vars_prompt`. This can be useful for sensitive data like passwords.

```yaml
---
- hosts: all
  vars_prompt:

    - name: username
      prompt: What is your username?
      private: false

    - name: password
      prompt: What is your password?

  tasks:

    - name: Print a message
      ansible.builtin.debug:
        msg: 'Logging in as {{ username }}'
```

override variables with command line arguments

Variables can be passed to a playbook as command line arguments when you run a playbook. These have a higher priority than variables declared in your playbook, so they will override those variables

```
ansible-playbook playbook.yaml -e user=bob
```

## variable scope

- Global: this is set by config, environment variables and the command line
- Play: each play and contained structures, vars entries (vars; vars_files; vars_prompt), role defaults and vars.
- Host: variables directly associated to a host, like inventory, include_vars, facts or registered task outputs

## Ansible facts

"Ansible facts are data related to your remote systems, including operating systems, IP addresses, attached filesystems, and more." - Ansible docs

Ansible uses the "setup" module to gather facts.  To see information about your hosts and the available facts run the command:

```bash
ansible <hostname> -m ansible.builtin.setup
```

Or in a playbook using the `debug` module:

```yaml
- name: Print all available facts
  ansible.builtin.debug:
    var: ansible_facts
```

Facts are returned in JSON, so they can be accessed as Objects using square brackets and single quotes.

```yaml
{{ ansible_facts['os_family'] }}
```

## magic variables

> You can access information about Ansible operations, including the Python version being used, the hosts and groups in inventory, and the directories for playbooks and roles, using “magic” variables. Like connection variables, magic variables are [Special Variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#special-variables). Magic variable names are reserved - do not set variables with these names.
> - Ansible docs [Information about Ansible: magic variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html#information-about-ansible-magic-variables)

The most commonly used magic variables are `hostvars`, `groups`, `group_names`, and `inventory_hostname`. 

## Capturing output with registers

Some tasks will not show any output when running your playbook. You can use register to capture the output of a task and store it in a variable

```yaml
--- 
- name: Register Playbook
  hosts: proxy
  tasks:
    - name: Run a command
      command: uptime
      register: server_uptime

    - name: Inspect the server_uptime variable
      debug:
        var: server_uptime

    - name: Show the server uptime
      debug:
        msg: "{{ server_uptime.stdout }}"
```

The playbook runs the `uptime` command and registers the command output in the **server_uptime** variable.

Then, you use the **debug** module along with the **var** module option to inspect the **server_uptime** variable. Notice, that you don’t need to surround the variable with curly brackets here.

Finally, the last task in the playbook shows the output (stdout) of the registered variable **server_uptime**.

Reference:

- [Ansible variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)
- [Ansible facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html)

# Ansible conditionals

## handlers

A handler is a way to run a task when a change is made on a manged node. For example when you update a file, you may need to restart a service. 

Handlers are only run when notified.

Handlers are run after all tasks in a play by default. You can trigger a handler at another point in a play using [meta: flush_handlers](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html#controlling-when-handlers-run)

```yaml
---
- name: Verify apache installation
  hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
    - name: Ensure apache is at the latest version
      ansible.builtin.yum:
        name: httpd
        state: latest

    - name: Write the apache config file
      ansible.builtin.template:
        src: /srv/httpd.j2
        dest: /etc/httpd.conf
      notify:
        - Restart apache

    - name: Ensure apache is running
      ansible.builtin.service:
        name: httpd
        state: started

  handlers:
    - name: Restart apache
      ansible.builtin.service:
        name: httpd
        state: restarted
```

handlers are run using the `notify` keyword that matches the name of the handler. In the example above:

```
notify:
  - Restart apache
handlers:
  - name: Restart apache
```

You can also notify a handler with the `listen` keyword.

```yaml
tasks:
  - name: Restart everything
    command: echo "this task will restart the web services"
    notify: "restart web services"

handlers:
  - name: Restart memcached
    service:
      name: memcached
      state: restarted
    listen: "restart web services"

  - name: Restart apache
    service:
      name: apache
      state: restarted
    listen: "restart web services"
```

A task can instruct more than one handler to execute

```yaml
tasks:
- name: Template configuration file
  ansible.builtin.template:
    src: template.j2
    dest: /etc/foo.conf
  notify:
    - Restart apache
    - Restart memcached

handlers:
  - name: Restart memcached
    ansible.builtin.service:
      name: memcached
      state: restarted

  - name: Restart apache
    ansible.builtin.service:
      name: apache
      state: restarted
```


## when

when statements are used to run a task conditionally. 

> The simplest conditional statement applies to a single task. Create the task, then add a `when` statement that applies a test. The `when` clause is a raw Jinja2 expression without double curly braces (see [group_by_module](https://docs.ansible.com/ansible/9/collections/ansible/builtin/group_by_module.html#group-by-module "(in Ansible v9)")). When you run the task or playbook, Ansible evaluates the test for all hosts. On any host where the test passes (returns a value of True), Ansible runs that task.
> - [Ansible docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html#basic-conditionals-with-when)

You may want to run a task only on servers running a particular distribution. 

```yaml
tasks:
  - name: Shut down Debian flavored systems
    ansible.builtin.command: /sbin/shutdown -t now
    when: ansible_facts['os_family'] == "Debian"
```

When statements are generally combined with Ansible facts.

## loop and item

> Ansible offers the `loop`, `with_<lookup>`, and `until` keywords to execute a task multiple times. Examples of commonly-used loops include changing ownership on several files and/or directories with the file module, creating multiple users with the user module, and repeating a polling step until a certain result is reached.
> - [Ansible Loops docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)

```yaml
---
- name: Add multiple users
  hosts: dbservers
  vars:
    dbusers:
      - username: bob
        pass: pass1
      - username: ali
        pass: pass2
      - username: jas
        pass: pass3
  tasks: 
    - name: Add users
      user:
        name: "{{ item.username }}"
        password: "{{ item.pass | password_hash('sha512') }}"
      loop: "{{ dbusers }}"
```

**Reference:**
- [Ansible handlers](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html)
- [Ansible when](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
- [Ansible loops](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)
# practice exercise

Try following along with the Terraform modules test in last weeks flipped material.

Try updating This possible solution to your week 5 lab so that the "nginx" service is only restarted if you the "copy index.html file to servers" task changes.

```yaml
---
- name: install and enable nginx
  hosts: web
  become: true
  tasks:
    - name: install nginx package
      ansible.builtin.package:
        name: nginx
        state: latest
    - name: copy index.html file to servers
      ansible.builtin.copy:
        src: ./files/index.html
        dest: /var/www/html
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted

- name: install mysql on database servers
  hosts: db
  become: true
  tasks:
    - name: install mysql-server
      ansible.builtin.package:
        name: mysql-server
        state: latest

- name: install bun on backend servers
  hosts: backend
  tasks:
    - name: install unzip
      become: true
      ansible.builtin.package:
        name: unzip
        state: latest
    - name: run local bun install script on servers
      script:
        cmd: ./scripts/bun_install.sh

```

# Flipped learning material

[Using Spacelift video](https://www.youtube.com/watch?v=okmxIFt5HYk)

# Todo
- [ ] Review flipped learning material above