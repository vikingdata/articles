This is a summary in order of how I setup my test environment for home.
All resources are FREE. All have limitations for use, but not normally an issue for someone who just wants to learn.

1. Setup Linux on Windows
    1. [Setup VirtualBox](https://github.com/vikingdata/articles/blob/main/linux/vm/Multiple_linux_VirtualBox.md)
        1. Just setup one node.
    2. [WSL2](https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_under_wsl2.md#wsl2)
        1. In this article, just install WSL2 and do not bother with MySQL. 
    3. Cygwin -- not really Linux but a Linux interface. 
        1. Install cygwin with SSH and make ssh key. We will use this later.
            `ssh-keygen -t rsa -N ''`
        1. For more on installing Cygwin with ssh : (5 Installing Cygwin and Starting the SSH Daemon](https://docs.oracle.com/cd/E24628_01/install.121/e22624/preinstall_req_cygwin_ssh.htm#EMBSC150)
	


1. Internet resources

    1. Linux box
    2. Database

        1. Snowflake and postgresql. Although it is free only for a limited time, after the time limit just
        apply for new systems with the same email.
        1. Mariadb -- very similar to MySQL.
        1. MongoDB
        1. SSQL -Windows or Linux with SSMS
        1. Cockroachdb
       
    1. Cloud
        1. Links
            * Old page: [Free Setup](https://github.com/vikingdata/articles/blob/main/cloud/Free_setup.md)
        1. AWS
            1. [AWS free](https://aws.amazon.com/free/?gclid=Cj0KCQiA1Km7BhC9ARIsAFZfEIvEClUtkGLBpYAb805PJ23Ooec3uR1uURdUFUi_LwLUt_aDOrfOzUwaAoJREALw_wcB&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=categories%23compute&trk=6a455a6f-f7f7-4463-917f-b59707d5f462&sc_channel=ps&ef_id=Cj0KCQiA1Km7BhC9ARIsAFZfEIvEClUtkGLBpYAb805PJ23Ooec3uR1uURdUFUi_LwLUt_aDOrfOzUwaAoJREALw_wcB:G:s&s_kwcid=AL!4422!3!646547068075!p!!g!!cloud%20computing!2038862296!75709537127)
            1. Database + Storage
                1. Dynamo
                1. SimpleDB
                1.. S3 -- used by databases and storage. It is very very cheap.
                1.. Redshift -- not free, but free when idle
            1. Monitoring
                1.  Promethesus
            1. Cloudtrail Programming
                1. Glue (between dynamo, SimpleDB, and MySQL and MongoDB on EC2)
                1. Lambda (same as glue)
                1. security - Key Management, Security Hub, cloudtrail, * Storage -- Storage Gateway Other
                1. Route -- DNS
                1. Billing or admin - Organizations, control tower

        1. GCP Free
            1. Cloud storage ; 5GB and traffic -- enough for testing Database
            1. Database
	        1. Big Query
                1. pub/sub
	    1. Server (same as ec2 in AWS)
	        1. e2-micro VM instance
	    1. Other
                1. firestore Programming
                1. secret manager Server
                1. Google Compute --- limited resources


        1. MS Free
        1. Oracle Free
    1. Monitoring
        1. New Relic
        1. Datadog
        1. Grafana
        1. PMM
      
    1. Tools
        1. Confluence
        1. Claude AI
 