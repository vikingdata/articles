
---
title : MySQL Cluster
author : Mark Nielsen
copyright : March 2025 
---


MySQL Cluster
==============================

_**by Mark Nielsen
Original Copyright Mark 2025**_

This article will grow over time. 

* [Links](#links)
* [Percona Galera Cluster](#p)
    * Making MySQL Clusterset
    * Failover
    * Adding a Node
    * Removing a node
    * [Restarting 8.0 Percona Galera Cluster](#pr)
* [ClusterSet](#c)
    * Making MySQL Clusterset
    * ClusterSet Failover
    * Adding a Node
    * Removing a node
    * Restarting ClusterSet

* * *
<a name=Links></a>Links
-----


* * *
<a name=p></a>Percona Galera Cluster
-----

####  <a name=pr></a>Restarting 8.0 Percona Galera Cluster

When starting or stopping mysql
    * tail -n 100 -f mysql.err  # tail the error log
    * In mysql, check the status
        * mysql > show global status where variable_name in ('wsrep_cluster_status','wsrep_cluster_size', 'wsrep_ready';


Then do this : 
* stop all nodes
* Find grastate.dat and set safe to bootstrap to 1
* On node 1
    * systemctl systemctl start mysql@bootstrap.service
* On other nodes one at a time.
    * start other nodes one a time.
        * service mysql restart
    * Wait until one node is up. 
* On node 1, restart mysql
    * systemctl systemctl stop mysql@bootstrap.service
    * service mysql restart
* OPTIONAL : make node 1 primary

* * *
<a name=c></a>MySQL ClusterSet
-----
