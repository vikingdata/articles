--------
title: Ansible : Playbook 

--------

# Ansible: Playbook

*by Mark Nielsen*  
*Copyright October 2023*

The purpose of this document is to:

- Use an ansible playbook to install MongoDB
- Use if conditions to abort if it is already installed.
- Use static custom configutation. 

---

1. [Links](#links)
2. [Setup](#setup)
3. [Condtionals](#conditionals)


* * *

<a name=links></a>Links
-----
* [Ansible Conditionals](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
* [file exists](https://www.tutorialspoint.com/ansible-check-if-a-file-exists)
* [file esists](https://phoenixnap.com/kb/ansible-check-if-file-exists)
* [fail or assert](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html)




* * *

<a name=setup></a>Setup
-----
If you have not setup ansible yet with these articles:

* Follow the steps in (Anisble : Install) [https://github.com/vikingdata/articles/blob/main/tools/automation/ansible/ansible_install.md]

* In /etc/ansible/hosts make sure you have a "[testervers]" entry.


* * *

<a name=conditionals></a>Contitions
-----

This for an Ubuntu system. One thing that could be added is to check the facts variable for type of operating
system, the version, and if resources are available. For this article we will assume it is the latest
Ubuntu with enough resources. 


* Test if "installed_mysql" variable exists.
    * If not, define the variable.
* Run a test if 3 files exist or if mysql package exists (for ubuntu).
* Run a test if mysql is running. Abort if so. 
* Test if "installed_mysql" variables is equal to 1.
* If not installed, install it
* Test if custom mysql is installed, if it is abort.
* If not,
    * install it
    * Copying config files.
    * initialize it
    * Have it start on startup.
    * Change default password


ps auxw | grep /usr/sbin/mysqld | grep -v grep | sed -e 's/  */ /g'| cut -d ' ' -f11 | head -n 1

Make the following playbook

```shell

echo "
---
  - name : Sample custom mysql install
    hosts: testservers
  
    tasks :
    - name : define mysql_is_installed variable
      shell : echo "mysql_is_installed is not defined"
#      vars:
#        mysql_is_installed
#      when : mysql_is_installed is not defined

#      fail : msg = "mysql_is_installed is not defined "
#      when : mysql_is_installed is not defined

" > /etc/ansible/mysql_custom_install.yml

```

execute ths script
```
ansible-playbook mysql_custom_install.yml
```