
---
title : Aurora IAM Authentication
author : Mark Nielsen
copyright : June 2025 
---


Database Encryption
==============================

_**by Mark Nielsen
Original Copyright June 2025**_

We will use Aurora Serverless 2 as an example of IAM authentication. It is similar to Aurora. Why?
If you want to test this, it is easier on Aurora Serverless 2. You can create and destroy Aurora Serverless 2
to test most Aurora capabilities. 

* [Links](#links)
* Setup


* * *
<a name=Links></a>Links
-----

* * *
<a name=s></a>Setup
-----
We assume the following.
* You have a [AWS Serverless 2](https://github.com/vikingdata/articles/blob/main/vm/Linux_db_vm_cloud.md#s) server. 
* You have an EC2 server in AWS.
* You login into EC2 or connect by proxy.
* If you connect by proxy, you have your own admin server by
[VirtualBox](https://github.com/vikingdata/articles/blob/main/vm/Linux_db_vm_vb_part1.md),
Dagger, your laptop is Linux or
unix compatible system, and if Windows you are using Cygwin or WSL. 

* * *
<a name=ct></a>Create and Test
-----


