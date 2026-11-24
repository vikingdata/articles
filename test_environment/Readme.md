NOt DONE 

This is a summary in order of how I setup my test environment for home.
All resources are FREE. All have limitations for use, but not normally an issue for someone who just wants to learn.

1. [1_Initial_Linux_setup.md](1_Initial_Linux_setup.md)
   1. Instal WSL and cygwin
   2. Install various programs locally.
2. [2_passwords.md](2_passwords.md)
   1. Setup KeepassXC and load password from previous software installs.
3. Install Cloud services and load passwords.
   1. Database
      1. Snowflake
      1. MongoDB
      1. MariaDB
      2. cockroachdb
   1. Setup AWS account
      1. Database + Storage
         1. Dynamo
         2. SimpleDB
         3. Aurora Serverless (free when not used)
         4. RedShift
	 5. S3 (really cheap) 
      2. Cloud Trail Programming
         1. Glue (between dynamo, SimpleDB, and MySQL and MongoDB on EC2)
         1. Lambda (same as glue)
         1. security - Key Management, Security Hub, cloudtrail, * Storage -- Storage Gateway Other
         1. Route -- DNS
         1. Billing or admin - Organizations, control tower
      
   2. Monitoring
      1. Grafana + Promethesus
      2. New Relic
      3. datadog
      4. pmm

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
   1. MSSQL free
   1. Oracle Free

    1. Tools
       1. Confluence
       2. AI
           1. Claude
           2. Chatgpt

Other links
1. Cloud
   1. Links
       * Old page: [Free Setup](https://github.com/vikingdata/articles/blob/main/cloud/Free_setup.md)
