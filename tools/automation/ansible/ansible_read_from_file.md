--------
title: Ansible : read from fileB

--------

# Ansible: read from file
*by Mark Nielsen*  
*Copyright June 2025*

* [Explanation](#e)
* [Download and Test](#t)
* [Output](#o)

* * *
<a name=e></a>Explanation
-----
The purpose is to read variables or data from a file to do something. Copy a file, download a url or other. A

* * *

<a name=t></a>Download and test
-----
```
---
# tasks file for top playbook

- name: Sample top playbook
  hosts: localhost
  vars:
     source_file : /tmp/percona
     dest_dir : /tmp/p
     percona_files : {{ dest_dir }}/percona

- name: 
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    loop: "{{ lookup('file', 'files/branches.txt').splitlines() }}"
    dest: /tmp/p
    when "{{ item }}" !- ''


```