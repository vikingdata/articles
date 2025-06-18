--------
title: Ansible : call specific hosts

--------

# Ansible: call specific hosts
============================
*by Mark Nielsen*  
*Copyright June 2025*

* [Explanation](#e)
* [Download and Test](#t)
* [Output](#o)

* * *
<a name=e></a>Explanation
-----

The purpose of this document is to be able to easily to apply a plyabook to
a list of hosts without complicated way of doing it. There may be a module or method
of specifying a list of hosts, but I want to do it so:
1. You don't accidentally apply the playbook to other hosts.
2. There is an easy way to abort if the list is not given.
3. Make it easy to submit the list.

Here are the problems.
1. Every playbook needs a default list of hosts.
2. You have limit the hosts by line command.

The problems make it very very easy to accidentally apply the playbook to all hosts
listed in the playbook or an inventory if specified by line command.
The point is, I want to submit an exact list of hosts without specfying
the inventory.


Thus here are the general steps.
* We assume you have installed anisble, have an inventory, and can run basic playbooks. So
we assume you not a beginner at anisble. 
* Make sure you have an inventory with a server called "myserver.local" or other name. Here is an example
of list with two servers: server1 and server2. Change the server names to your 2 servers. 
```
echo "
servers:
  hosts:
      # Change myserver.local to your remote server. 
    server1:
    server2:
      
" > my_servers.yml
```

* Create a main playbook.
    * Create a file called "top.yaml".
    * The hosts defined is just "localhost".
    * Abort script is "target_hosts" variable is not defined.
    * import a playbook with a variable called "playlist_imported" with any value".
* Create another playbook called "imported.yaml"
    * The hosts for this playbook is  "target_hosts". You can optionally check for this variable, but the
    top playbook already checked for the variable.
    * Abort if the variable "playlist_imported" is not defined.
    * Do your commands for each host in "target_hosts".

* * *

<a name=t></a>Download and test
-----


* Download these files. Remember to change "my_servers.yml" to your list of servers.
```
export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export wget_options=" --no-check-certificate --no-cache --no-cookies "

export DURL=$MAIN/tools/automation/ansible/ansible_specific_hosts_files/top.yaml
wget $wget_options $DURL -O top.yaml

export DURL=$MAIN/tools/automation/ansible/ansible_specific_hosts_files/imported.yaml
wget $wget_options $DURL -O imported.yaml

export DURL=$MAIN/tools/automation/ansible/ansible_specific_hosts_files/my_servers.yml
wget $wget_options $DURL -O my_servers.yml
```
* Change the servers listed in the file "my_servers.yml"
* Execute:
```
   # This should work.
ansible-playbook top.yaml -e target_hosts=server1 -i my_servers.yml
   # This should work with both servers.

   # This will fail. 

```

* My my_servers.yml was
```
servers:
  hosts:
      # Change myserver.local to your remote server.
    db2:
      ansible_host: 10.0.2.21
    db1:
      ansible_host: 10.0.2.20
  vars:
    ansible_ssh_common_args: ' -o ProxyJump="root@127.0.0.1:2222" -o user=root'
```

* My output was

```
ansible-playbook top.yaml -e target_hosts=db1 -i my_servers.yml > output.log
ansible-playbook top.yaml -e target_hosts=db1,db2 -i my_servers.yml > output.log
ansible-playbook top.yaml  -i my_servers.yml  > output.log 2>&1 

```

* * *
<a name=links></a>Output
-----
* Ran the commands
```
ansible-playbook top.yaml -e target_hosts=db1 -i my_servers.yml > output.log
ansible-playbook top.yaml -e target_hosts=db1,db2 -i my_servers.yml > output2.log
ansible-playbook top.yaml  -i my_servers.yml > error.log
```
* output.log
```

PLAY [Sample top playbook] *****************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Assert we are included] **************************************************
ok: [localhost] => {
    "changed": false,
    "msg": "All assertions passed"
}

PLAY [sample imported playbook] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [db1]

TASK [Assert we are included] **************************************************
ok: [db1] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Do a simple command, like get the hostname.] *****************************
changed: [db1]

PLAY RECAP *********************************************************************
db1                        : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```


* output2.log
```

PLAY [Sample top playbook] *****************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Assert we are included] **************************************************
ok: [localhost] => {
    "changed": false,
    "msg": "All assertions passed"
}

PLAY [sample imported playbook] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [db1]
ok: [db2]

TASK [Assert we are included] **************************************************
ok: [db1] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [db2] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Do a simple command, like get the hostname.] *****************************
changed: [db1]
changed: [db2]

PLAY RECAP *********************************************************************
db1                        : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
db2                        : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```


* error.log
```

PLAY [Sample top playbook] *****************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Assert we are included] **************************************************
fatal: [localhost]: FAILED! => {
    "assertion": "target_hosts is defined",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   


```