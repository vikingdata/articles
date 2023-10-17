--------
title: Ansible : Variables 

--------

# Ansible: Variables

*by Mark Nielsen*  
*Copyright October 2023*

The purpose of this document is to:

- Explain variables
- Special Variables: Fact, connection, magic


---

* [Links](#links)
* [Variables Overview](#var)
* [Set Variables and Run Playbook](#set)
* [Notes](#notes)

* * *

<a name=links></a>Links
-----
* [Using Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)
* [How to Use Different Types of Ansible Variables](https://spacelift.io/blog/ansible-variables)
* [Ansible Roles and Variables](https://www.dasblinkenlichten.com/ansible-roles-and-variables/)
* [Sample Ansible setup](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html)



* * *

<a name=var></a>Variables
-----

First thing to do is [understand the precedence of variables](https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html#general-precedence-rules).

* Order or precedence. It seems a little confusing based on several articles.
    * [Ansible Roles and Variables](https://www.dasblinkenlichten.com/ansible-roles-and-variables/)
    * [Variable precedence](https://subscription.packtpub.com/book/cloud-and-networking/9781787125681/1/ch01lvl1sec13/variable-precedence)
    * [Controlling how Ansible behaves: precedence rules](https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html)
    

Second thing, understand the different type of variables. 

* [Special variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html) are defined by ansible. Ansible will override any attempt by the user to set them.
   * [Facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html#ansible-facts) : variables ansible gets from each host it connects to before it does anything. Facts can be turned off.
   * Connection variables : Variables which determine how to execute commands on a host.
       * Examples
           * "become" variable which will execute commands as root or superuser.
           * "ansible_user" which is the user ansible logs as into the server. 
   * [Magic Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html#information-about-ansible-magic-variables)
       * These are variables which get set when ansible runs. Many come from how the config files are set.
           * Examples  
               * groups : A dictionary of all groups in host file or inventory.
               * hostvars : variables assigned to each host.
               * inventory_hostname : The current "host" being worked on from the inventory in the host file. Note: "inventory_hostname" may not be the same as the name the host believes it is which is recorded as ansible_hostname from "facts" information. 
* Defining variables : In any YAML file you can define variables.
    * Playbook variables
        * Variables can be defined
	* Variables can be registered from output of commands or scripts
        * Registering variables
            * You execute a command and then register (record it output)
    * Inventory variables
        * Host variables : Variables for host can be defined in the host or inventory file. 
        * Group variables
    * Role variable : Variables can be defined in the role files. 
    * At runtime


* * *

<a name=set></a>Set Variables
-----
Set a role default roles and role vars. 

```shell
mkdir -p /etc/ansible/roles/role1/defaults
mkdir -p /etc/ansible/roles/role1/vars

echo "---" > /etc/ansible/roles/role1/defaults/main.yml
echo "role_default1 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml
echo "order_var1 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml
echo "order_var2 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml
echo "order_var3 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml
echo "order_var4 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml
echo "order_var5 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml
echo "order_var6 : ' role default value'" >> /etc/ansible/roles/role1/defaults/main.yml


echo "---" > /etc/ansible/roles/role1/vars/main.yml
echo "role_var1 : ' role var 1 value'" >> /etc/ansible/roles/role1/vars/main.yml
echo "order_var7 : ' role var 1 value'" >> /etc/ansible/roles/role1/vars/main.yml
echo "order_var8 : ' role var 1 value'" >> /etc/ansible/roles/role1/vars/main.yml

```

Set a Host and Group variable. Note, change this host to your server. In /etc/ansible/host

```shell
# NOTE: Change the ip address to the ip address of your target server or its hostname.

echo "[testservers]
192.168.1.7 host_var1='host var 1 value' order_var4='host var 1 value' order_var5='host var 1 value'" >> /etc/ansible/hosts

echo ""  >> /etc/ansible/hosts

echo "[testservers:vars]
group_var1 = 'group var 1 value'
order_var2 = 'group var 1 value'
order_var3 = 'group var 1 value'
order_var4 = 'group var 1 value'" >> /etc/ansible/hosts


mkdir -p /etc/ansible/host_vars
mkdir -p /etc/ansible/group_vars

echo "---
host_var2  : 'host var 2 value'
order_var5 : 'host var 2 value'
order_var7 : 'host var 2 value'" > /etc/ansible/host_vars/192.168.1.7.yml

echo "---
ansible_python_interpreter : /usr/bin/python3
group_var2 : 'group var 2 value'
order_var3 : 'group var 2 value'
order_var4 : 'group var 2 value'
order_var7 : 'group var 2 value'" > /etc/ansible/group_vars/testservers.yml

```

Set a Playbook variable. Create a file /etc/anisble/echo.yml

```shell

echo "
---
  - name : Sample echo playbook
    roles :
      - role1
    hosts: testservers
    vars:
      playbook_var1: 'playbook 1 value'
      order_var6: 'playbook var 1'
      order_var7: 'playbook var 1'

    tasks:
    - name : print vars
      debug:
        msg:
          - role default  {{ role_default1 }}
          - role var1     {{ role_var1 }}
          - host_var1     {{ host_var1 }}
          - host_var2     {{ host_var2 }}
          - group_var1    {{ group_var1 }}
          - group_var2    {{ group_var2 }}
          - playbook_var1 {{ playbook_var1 }}
          - the following values are done by order of precedence
          - order_var1    {{ order_var1 }} ,should be role default
          - order_var2    {{ order_var2 }} ,should be group var1
          - order_var3    {{ order_var3 }} ,should be group var2
          - order_var4    {{ order_var4 }} ,should be host var1
          - order_var5    {{ order_var5 }} ,should be host var2
          - order_var6    {{ order_var6 }} ,should be playbook var1
          - order_var7    {{ order_var7 }} ,should be role var1
          - order_var8    {{ order_var8 }} ,should be  line_command

    - name : Make registered variable
      shell: ls /etc | wc -l
      register: register_test

    - name : print registered
      register: register_test
      debug :
        msg :
           - Register test. There are {{register_test.stdout }} files in /etc.

    - name : print special variables
      debug :
        msg:
          - From facts. My architecture {{ ansible_facts['architecture']  }}
          - Magic variable inventory_hostname is {{ inventory_hostname }}
          - as opposed to fact ansible_facts['hostname'] {{ansible_facts['hostname'] }} or ansible_hostname {{ ansible_hostname }}
          - Magic vaiable inventory_file is {{ inventory_file }}
          - The connection variable ansible_connection is {{ ansible_connection }}
          - Displaying a string, ansible_verbosity is {{ ansible_verbosity }}
          - Displaying 2nd element in a list, ansible_facts['processor'][1] is {{ ansible_facts['processor'][1] }}
          - Displaying List, ansible_facts['processor'] is {{ ansible_facts['processor'] }}
          - Displaying an element in dictionary ansible_facts['cmdline']['BOOT_IMAGE'} is {{ ansible_facts['cmdline']['BOOT_IMAGE'] }}
          - Displaying dictionary, ansible_facts['cmdline'] is {{ ansible_facts['cmdline'] }}

" > /etc/ansible/echo.yml

```

Now execute
```shell
ansible-playbook echo.yml -e "order_var8=line_command"
```
It will
* Show you the hiearchy of variables
* show you how to register variables from the output of a command
* show you how to print facts, special variables, connection variables, an element from a dictionary and list, a dictionary, and a list 

and you should get something like

```

PLAY [Sample echo playbook] **************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [192.168.1.7]

TASK [print vars] ************************************************************************************************************
ok: [192.168.1.7] => {
    "msg": [
        "role default   role default value",
        "role var1      role var 1 value",
        "host_var1      host var1 value,",
        "host_var2     host var 2 value",
        "group_var1    group var 1 value",
        "group_var2    group var 2 value",
        "playbook_var1 playbook 1 value",
        "the following values are done by order of precedence",
        "order_var1     role default value ,should be role default",
        "order_var2    group var 1 value ,should be group var1",
        "order_var3    group var 2 value ,should be group var2",
        "order_var4    host var1 value ,should be host var1",
        "order_var5    host var 2 value ,should be host var2",
        "order_var6    playbook var 1 ,should be playbook var1",
        "order_var7     role var 1 value ,should be role var1"
        "order_var8    line_command ,should be line_command"
   ]
}

TASK [Make registered variable] ************************************************************************************************
changed: [192.168.1.7]

TASK [print registered] ********************************************************************************************************
ok: [192.168.1.7] => {
    "msg": [
        "Register test. There are 262 files in /etc."
    ]
}

TASK [print special variables] **************************************************************************************************
ok: [192.168.1.7] => {
    "msg": [
        "From facts. My architecture x86_64",
        "Magic variable inventory_hostname is 192.168.1.7",
        "as opposed to fact ansible_facts['hostname'] mark-Inspiron-3501 or ansible_hostname mark-Inspiron-3501",
        "Magic vaiable inventory_file is /etc/ansible/hosts",
        "The connection variable ansible_connection is ssh",
        "Displaying a string, ansible_verbosity is 0",
        "Displaying 2nd element in a list, ansible_facts['processor'][1] is GenuineIntel",
        "Displaying List, ansible_facts['processor'] is ['0', 'GenuineIntel', '11th Gen Intel(R) Core(TM) i3-1115G4 @ 3.00GHz', '1', 'GenuineIntel', '11th Gen Intel(R) Core(TM) i3-1115G4 @ 3.00GHz', '2', 'GenuineIntel', '11th Gen Intel(R) Core(TM) i3-1115G4 @ 3.00GHz', '3', 'GenuineIntel', '11th Gen Intel(R) Core(TM) i3-1115G4 @ 3.00GHz']",
        "Displaying an element in dictionary ansible_facts['cmdline']['BOOT_IMAGE'} is /boot/vmlinuz-5.15.0-76-generic",
        "Displaying dictionary, ansible_facts['cmdline'] is {'BOOT_IMAGE': '/boot/vmlinuz-5.15.0-76-generic', 'root': 'UUID=0a70c609-712e-4849-8c15-ca5972114471', 'ro': True, 'quiet': True, 'splash': True}"
    ]
}

PLAY RECAP ********************************************************************************************************************
192.168.1.7                : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


```

* * *

<a name=notes></a>Notes
-----
There are more levels to define variables than listed here. 