--------
title: Ansible : read and download from file

--------

# Ansible: read and download from file
*by Mark Nielsen*  
*Copyright June 2025*

* [Explanation](#e)
* [Download and Test](#t)
* [Output](#o)

* * *
<a name=e></a>Explanation
-----
The purpose is urls from a file to download other files. 

* Remove and make the test directory.
* Download the file which contains a list of files to download.
* Download the files from the lines which are not empty, do not contain a comment "#", and contain "https".
* List the files. 

* * *

<a name=t></a>Download and test
-----

Save the contents of the following to a file called "download.yml".

```
- name: Sample download files 
  hosts: localhost
  vars:
     dest_dir: /tmp/test_download
     source_main: https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
     source_url: "{{ source_main }}/tools/automation/ansible/examples_dir/download_files.txt"
     source_file: /tmp/download_files.txt
  tasks:

  - name: Recursively remove directory
    ansible.builtin.file:
      path: "{{ dest_dir }}"
      state: absent

  - name: Create download directories
    file:
      path: "{{ dest_dir }}"
      state: directory
      mode: '0755'

  - name: Download file which contains files to download
    ansible.builtin.get_url:
      url: "{{  source_url }}"
      dest: "{{ source_file }}"

  - name: download files
    ansible.builtin.get_url:
      url:  "{{ item }}"
      dest: "{{ dest_dir  }}"
    with_lines:
      - cat "{{ source_file }}"
    when :
      - item is not search ("#")
      - item != ''
      - item is search ("https")

  - command: "ls {{ dest_dir }}"
    register: dir_out

  - debug: var={{item}}
    with_items: dir_out.stdout_lines

```

* * *
<a name=o></a>Output
-----
Output from command : ansible-playbook download.yml

```

PLAY [Sample download files] ***************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Recursively remove directory] ********************************************
changed: [localhost]

TASK [Create download directories] *********************************************
changed: [localhost]

TASK [Download file which contains files to download] **************************
ok: [localhost]

TASK [download files] **********************************************************
changed: [localhost] => (item=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/tools/automation/ansible/examples_dir/d1.txt)
skipping: [localhost] => (item=) 
skipping: [localhost] => (item=# This line should be ignored. ) 
skipping: [localhost] => (item=) 
changed: [localhost] => (item=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/tools/automation/ansible/examples_dir/d2.txt)
skipping: [localhost] => (item=) 
changed: [localhost] => (item=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/tools/automation/ansible/examples_dir/d3.txt)
skipping: [localhost] => (item=) 
changed: [localhost] => (item=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/tools/automation/ansible/examples_dir/d4.txt)

TASK [command] *****************************************************************
changed: [localhost]

TASK [debug] *******************************************************************
ok: [localhost] => (item=dir_out.stdout_lines) => {
    "ansible_loop_var": "item",
    "dir_out.stdout_lines": [
        "d1.txt",
        "d2.txt",
        "d3.txt",
        "d4.txt"
    ],
    "item": "dir_out.stdout_lines"
}

PLAY RECAP *********************************************************************
localhost                  : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   






```