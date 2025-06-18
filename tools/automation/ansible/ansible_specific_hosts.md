--------
title: Ansible : call specific hosts

--------

# Ansible: call specific hosts
============================
*by Mark Nielsen*  
*Copyright June 2025*

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
of list with two servers: server1.local and server2.local. Change the server names to your 2 servers. 
```
echo "
hosts:
      # Change myserver.local to your remote server. 
  server1.local:
  server2.local:
      
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

* Download these files. Remember to change "my_servers.yml" to your list of servers.
```
export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export DURL=$MAIN/tools/automation/ansible/examples_dir/setup_ansible.txt
export wget_options=" --no-check-certificate --no-cache --no-cookies "
wget $wget_options $DURL -O setup_ansible.sh
source setup_ansible.sh



```
