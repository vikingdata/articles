--------
title: Ansible Examples

--------

# Ansible Examples

*by Mark Nielsen*  
*Copyright June 2024*

WARNING: This document needs a lot of testing and is far from complete. I want to list the
most common tasks I do. 

---

1. [Links](#links)
2. [Execute Scripts](#scripts)
3. [layout](#layout)
* * *

<a name=links></a>Links
-----

* https://toptechtips.github.io/2023-06-10-ansible-python/

---
* * *
<a name=scripts></a>Execute scripts
-----
* Test commands:
    * List out all hosts: ``` ansible all --list-hosts ```
    * Ping all hosts : ```ansible -m ping admin ```
    * Ad hoc command : ```ansible admin -a "echo 'hello'"```
    * Verbose : ``` ansible -vvv all -m ping ````
* [Run scripts locally without ssh](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_delegation.html) :
    * Line command: ansible-playbook --connection=local <playbook_name.yml>
    * Line command: ansible self -m command -a "uptime"  -c local
    * in playbook: local_action or delegate_to
    * In the inventory
```
[local]
   localhost ansible_connection=local
```

* Capture data to file
* Capture data to database
* Run tasks
* Run modules
* Mutiple host lists.
    * Host list cannot include other lists. 
    * When you run ansible use "-i" to represent the lists.
    * Use a directroy option, where it grabs all the files in a directory.
         *  ansible-inventory -i inventories/ all
    * Modify the env ANSIBLE_INVENTORY
    * Change [inventory] in ansible.cfg
* Specify a directory for ansible
    * Change the envrionment variable ansible.cfg
```
export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export DURL=$MAIN/tools/automation/ansible/examples_dir/setup_ansible.txt
wget $DURL -O setup_ansible.sh
bash setup_ansible.sh

```

---
* * *
<a name=layout></a>Layout
-----
Links
* https://www.ansiblejunky.com/blog/ansible-101-standards/
* https://docs.rockylinux.org/books/learning_ansible/00-toc/
* https://spacelift.io/blog/ansible-best-practices
* https://spacelift.io/blog/ansible-roles

There are some important concepts in Ansible.
* ansible.cfg is the main config file.
    * Specifies inventory file is (or which directory contains inventory files. 
    * Contains the base configuration of where everything is.
    * Can be overriden with anvironments variable "ANSIBLE_CONFIG"
    or passed at line command "--config".
* Ansible will not look in every directory in root directory for config files.
    * Anisble will look at default locations specified in ansible.cfg
    * Next: https://docs.ansible.com/ansible/latest/playbook_guide/playbook_pathing.html
    * Based on which playbook is executed:
        * Look at default locations from ansible.cfg
	* In the current directory of the playbook
	    * The "roles" directory will have a certain directory structure. Every directory
	    in the "roles" directory is a named "role". Each other those directories will have
	    directories with the file "main.yml". Thos directories are (and there may be more) :
	    tasks/, handlers/, vars/, defaults/, and meta/.
	* group_vars/ and host_vars/ are looked in the directory of the playbook or the inventory.
	    * You can specify inventories by file or directories.
	    * You can also use separate files and not directories for variables. 
       * [Best Prctices](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html) is just best practices. It doesn't mean you have to follow it and you can make up really
       confusing yml files that actually work but only you understand. 


TODO: Example detailed structure showing multiple inventories, playbooks, and variables and
tasks or roles calling specific files. 


---
* * *
<a name=vars></a>Important variables
-----
Links
* https://github.com/vikingdata/articles/blob/main/tools/automation/ansible/ansible_variables.md
* https://github.com/vikingdata/articles/blob/main/tools/automation/ansible/ansible_more_variables.md

* "ansible_hostname" is gathered from facts. "inventory_hostname" is the hostname given
in the inventory file. 