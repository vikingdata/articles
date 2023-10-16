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
* [Special Variables](#special)
    * [Facts](#facts)
    * [Connection](#connection)
    * [Magic](#magic)
* [Defining Variables](#define)
    * [Playbook](#playbook)
        * [Playbook Definitions](#pbdef)
        * [Playbook Output Defintions](#pbdefoutput) 
    * [Inventory](#iv)
        * [Host](#host)
        * [Group](#group)

    * Role
    * Runtime
    

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

First thing to do is (understand the precedence of variables)[https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html#general-precedence-rules]

Second thing, understand the different type of variables. 

* [Special variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html) are defined by ansible. Ansible will override any attempt by the user to set them.
   * (Facts)[https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html#ansible-facts] : variables ansible gets from each host it connects to before it does anything. Facts can be turned off.
   * Connection variables : Variables which determine how to execute commands on a host.
       * Examples
           * "become" variable which will execute commands as root or superuser.
           * "ansible_user" which is the user ansible logs as into the server. 
   * (Magic Variables)[https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html#information-about-ansible-magic-variables]
       * These are variables which get set when ansible runs. Many come from how the config files are set.
           * Examples  
               * groups : A dictionary of all groups in host file or inventory.
               * hostvars : variables assigned to each host.
               * inventory_hostname : The current "host" being worked on from the inventory in the host file. Note: "inventory_hostname" may not be the same as the name the host believes it is which is recorded as ansible_hostname from "facts" information. 
* Defining variables : In any YAML file you can define variables.
    * Playbook variables
        * Variables can be defined
	* Variables can be regisered from output of commands or scripts
        * Registering variables
            * You execute a command and then register (record it output)
    * Inventory variables
        * Host variables : Variables for host can be defined in the host or inventory file. 
        * Group variables
    * Role variable : Variables can be defined in the role files. 
    * At runtime

