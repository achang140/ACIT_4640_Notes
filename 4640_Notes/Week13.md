# Learning outcomes and topics

- Ansible troublshooting

## verbose mode

We looked at this one earlier in the term, but it is worth reviewing.

Running playbooks in verbose mode can sometimes help diagnose problems.

```bash
ansible-playbook -vv playbook-name.yaml
```

The debug, or verbosity levels go from -v to -vvvvvv. The more vs the more information that you get. 

[Ansible playbook docs](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#cmdoption-ansible-playbook-v)

## test variables with the `assert` module

You can test that value of variables are what you expect them to be with the `assert` module.

```yaml
- ansible.builtin.assert: { that: "ansible_os_family != 'RedHat'" }

- ansible.builtin.assert:
    that:
      - "'foo' in some_command_result.stdout"
      - number_of_the_counting == 3

- name: After version 2.7 both 'msg' and 'fail_msg' can customize failing assertion message
  ansible.builtin.assert:
    that:
      - my_param <= 100
      - my_param >= 0
    fail_msg: "'my_param' must be between 0 and 100"
    success_msg: "'my_param' is between 0 and 100"

- name: Please use 'msg' when ansible version is smaller than 2.7
  ansible.builtin.assert:
    that:
      - my_param <= 100
      - my_param >= 0
    msg: "'my_param' must be between 0 and 100"

- name: Use quiet to avoid verbose output
  ansible.builtin.assert:
    that:
      - my_param <= 100
      - my_param >= 0
    quiet: true
```

[Ansible assert module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html)

## using the Ansible task `debugger`

The task debugger can be used to enter new values for a task when the task fails, rather than running a playbook again and again.

The task debugger can be enabled in playbook on a specific play, role, block, or task.

```yaml
- name: My play
  hosts: all
  debugger: on_skipped
  tasks:
    - name: Execute a command
      ansible.builtin.command: "true"
      when: False
```

The debugger accepts one of 5 values

|Value|Result|
|---|---|
|always|Always invoke the debugger, regardless of the outcome|
|never|Never invoke the debugger, regardless of the outcome|
|on_failed|Only invoke the debugger if a task fails|
|on_unreachable|Only invoke the debugger if a host is unreachable|
|on_skipped|Only invoke the debugger if the task is skipped|

When the debugger is invoked a debug prompt opens and you can change module arguments or variables and run the task again.

[Ansible Debugging tasks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_debugger.html)
# Flipped learning material

No new flipped learning material this week