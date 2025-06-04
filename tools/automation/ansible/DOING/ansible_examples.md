--------
title: Ansible Examples

--------

# Ansible Examples

*by Mark Nielsen*  
*Copyright June 2024*

---

1. [Links](#links)
2. [Execute Scripts](#scripts)
* * *

<a name=links></a>Links
-----

* https://toptechtips.github.io/2023-06-10-ansible-python/

---
* * *
<a name=scripts></a>Run scripts
-----

* Run scripts locally
* Run scripts remotely
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
cd ~/
mkdir -p install
cd install

export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export DURL=$MAIN/tools/automation/ansible/examples_dir/setup_ansible.txt
wget $DURL -O setup_ansible.txt setup_ansible.sh
bash setup_ansible.cfg



```