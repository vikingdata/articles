--------
title: Ansible Examples

--------

# Ansible Examples

*by Mark Nielsen*  
*Copyright June 2024*

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

There are some important concepts in Ansible.
* ansible.cfg is the main config file.
    * Specifies inventory file is (or which directory contains inventory files. 
    * Contains the base configuration of where everything is.
    * Can be overriden with anvironments variable "ANSIBLE_CONFIG"
    or passed at line command "--config".

* Inventory:
    * Inventory can be specified by file or directories.
    * If directories, you can include other groups from other files. An advantage
    to using directories can be people only have access to certain files.
    * You can put into ansible.cfg the default location of the inventory
    which can be overidden by line command with "-i" or "--inventory".
* You can have everything in one big file or separate out into direcories for roles, inventory,
handlers, etc. An example where you have to use a directory are for files you wish to transfer. 
   * The directory structure for files below is OPTIONAL. You can in theory corrupt your yaml files.
       * [Best Prctices](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html) is just best practices. It doesn't mean you have to follow it and you can make up really
       confusing yml files that actually work but only you udnerstand. 
       * For example, you could put variables for the group "[webservers]" underneath the
       the host_vars, roles, tasks, or other directories into any yml or ini file.
           * Just put into [group variables](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#assigning-a-variable-to-many-machines-group-variables) into any ini or yml file.
```
## INI file
[webservers:vars]
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com

### yml file
webservers:
  vars:
    ntp_server: ntp.atlanta.example.com
    proxy: proxy.atlanta.example.com
```

### Referring to https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html
* [Inventory files](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
    * In general, you want to separate out inventories to different files or directories.
    Then you can specify at line command which inventory you want to use for commands. You
    can restrict access to files. This helps preventing development environment changes for testing
    to affect production.
    * The inventory specifes the hosts or servers you want to affect. Servers can also be put in
    groups and the same server can be in multiple groups and groups can include other groups. 
```
production                # inventory file for production servers
staging                   # inventory file for staging environment
```
* group_vars : If you want to assign variables to groups you assinged in the inventory.
```
group_vars/
   group1.yml             # here we assign variables to particular groups
   group2.yml
```
host_vars/
   hostname1.yml          # here we assign variables to particular systems
   hostname2.yml

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies
        library/          # roles can also include custom modules
        module_utils/     # roles can also include custom module_utils
        lookup_plugins/   # or other types of plugins, like lookup in this case

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""
