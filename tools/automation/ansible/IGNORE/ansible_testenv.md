9----
author: Mark Nielsen
title: Ansible TextEnv
Copyriht : November 2023
----

1. Links
2. [What is TestEnv](#te)
3. [MySQL Cluster install](#mysqlcluster]

* * *
<a name=links></a>Links
-----
* https://www.softwaretestinghelp.com/ansible-tutorial-1/
* [MySQL Apt Repository](https://dev.mysql.com/downloads/repo/apt/)
    * [https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb](https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb)

* Download the apt-get repository file from MySQL. Put the file in /etc/ansible/files/mysql_cluster
   * [MySQL Apt Repository](https://dev.mysql.com/downloads/repo/apt/)
       * [https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb](https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb)




* * *
<a name=#te></a>What is TestEnv
-----
TestEnv is a set of ansible scripts to install software all on one computer using the loopback device. Services that have to bind to different ip addressed or ports to simulate multiple servers can use this environment.


* * *
<a name=#te></a>MySQL Cluster install
-----
System requirements
* Ubuntu
* Have a /data directory : mkdir /data



```
stop mysql
    - name: start and enable mysql service
      service:
         name: mysql
         state: started
         enabled: yes


    - name: stop mysql
      ansible.builtin.systemd:
        name: "{{ mysql_service_name[ansible_os_family] }}"
        state: stopped
        enabled: no

- name: Check for ~/.blah/config
  delegate_to: localhost
    stat:
        path: /home/ubuntu/.blah/config
	  register: stat_blah_config


```

				     
