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
mkdir -p ansible
cd ansible

echo"

export ANSIBLE_CONFIG="`pwd`/anisble.cfg"

echo '
acount=`grep ANISBLE_CONFIG ~/.bashrc | wc -l`

if [ $count -lt 1 ] ; then
  echo "" >> ~/.bashrc
  echo "ANSIBLE_CONFIG='$ANSIBLE_CONFIG' >> ~/.bashrc
fi

echo '' > $ANSIBLE_CONFIG/ansible.cfg

mkdir -p inventories
mkdir -p playlists

echo '
[local]
   localhost ansible_connection=local
' >> inventories/local

```