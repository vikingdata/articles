Things doing now. In no particular order.

* MOSTLY DONE. Virtual environment with Virtual Box Box and making images.
* Virtual Box with Ansible, Terraform
    * The purpose is to create a small virtual environment for testing
    on your computer.
        * Initially it will be windows. Why? Every company gives me a window box* Linux running Virtual Box will be done later.
    * It will be on a Nat Network, a DMZ zone where the VMs can be each other
    but no outside connections. including those host computer. TO allow
    connections from the host computer, port forward servers to a port on the
    host, but then firewall block outside connections to that port. 
    * Install
        * DONE Cygwin with Ansible and terraform
	    * DONE
	    Confirm you can run commands against virtualbox. Cygwin runs on Windows
	    in the host environment and can run Windows binaries. It can connect
	    to Virtualbox through CLI commands.
        * Make scripts through Ansible and Terraform that
             * Setup new system, 1 GB mem, 50 GB diskspace, max video ram,
	     Virtualbox , Guest Additions
	     Shared folder to windows, drag and drop, clipboard,
	     Nat network creation.
            * First install with bash scripts. 	Download ISO image and run bash
	    scripts connecting to virtualbox directly. Make Ansible scripts after this.
                * Should detect is ISO is already downloaded. Should detect
		if system already exists. Supply hostname. Record IP address to shared
		folder which all systems can see and update. 

     Install system to start and stop things installed (databases, software)
    * Things
        * An admin computer to run Ansible, terraform, and others things on.
        * Each service will be port forwarded to local host, and then blocked
	with outside connections. 
        * MySQL and MySQL Cluster
        * Mongo in replica set and sharded
        * Yugabyte, Local (single, cluster, and failover cluster)
        * TIDB
        * CockroachDB
        * Postgresql (single and replicated)
        * Web interface
        * New relic
        * Snowflake
             * AWS Aurora Server less
    * Monitoring -- Telegraf with get data, transfer to Prometheus, and Prometheus to grafana.
    All software will be monitored. 