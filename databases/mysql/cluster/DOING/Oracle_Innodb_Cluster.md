
---
title : Oracle InnoDB Cluster
author : Mark Nielsen
copyright : June 2025
---


Oracle Innodb Locking
==============================

_**by Mark Nielsen
Copyright June 2025**_

This covers Oracle InnoDB Cluster. It invovles ClusterSet and the Router.

Terms:
* Group replication is used for InnoDB Cluster.
* Innodb Cluster is a true cluster.
    * 2 out 3 nodes must be up for the cluster to be active. If it is reduced to one node, that
    node becomes read-only.
    * A router is used for applications to connect to. It keeps track of which node is Primary.
    * It tries to load balance between nodes.
    * Each node is a complete copy.
    * Every node or one node can be made to take writes.
        * In general, to reduce locks, only one node should be made writable. Otherwise if a node fails,
	more queries will be distributed to the other nodes. If a node fails, with multi-node write,
	and all the nodes are at maximum capabilities, a failover of one node could add too much
	resources to the other nodes. 
* InnoDB Clusterset is an InnoDB Cluster with a Backup Cluster.
    * The replication from the Primary Cluster to the Backup Cluster is regulat replication.
    * All servers in the backup cluster are read only.
    