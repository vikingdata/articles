--------
title: Ansible : Running commands on my dev servers in VirtualBox

--------

# Ansible: Running commands on my dev servers in VirtualBox

*by Mark Nielsen*  
*Copyright May 2024*

---

1. [Links](#links)
2. [Setup directory](#setup)

* * *
<a name=links></a>Links
-----

---
* * *
<a name=setup></a>Setup
-----

```
mkdir -p project1
cd project1
mkdir -p roles/sample
mkdir -p hosts

echo "[dev]
192.168.1.28
192.168.1.24
192.168.1.27
192.168.1.21

[dev:vars]
ansible_user =  root
" > hosts/test.ini

```

Save his as roles/sample/main.yml
```
# tasks file for detect
- name: Print all available facts
  ansible.builtin.debug:
    var: ansible_facts
   var : ansible_facts["os_name"]

  # Copy file to rmote server. 
- name: Copy file with owner and permissions
  ansible.builtin.copy:
   src: /etc/hosts
   dest: /tmp/file_test1

  # Copy static data to remote server. 
- name: Copy using inline content
  ansible.builtin.copy:
    content: '# This file was moved to /blah/blah/blah'
    dest: /tmp/file_test2

  # Save variable data to file on remote server. 
- name: Copy using inline content
  ansible.builtin.copy:
    content: "{{ ansible_facts | to_nice_json  }}"
    dest: /tmp/file_test3

```

