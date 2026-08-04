This is a summary in order of how I setup my test environment for home.
All resources are FREE. All have limitations for use, but not normally an issue for someone who just wants to learn. 

1. Internet resources
  a. Linux box
  b. Database
    * Snowflake and postgresql. Although it is free only for a limited time, after the time limit just
      apply for new systems with the same email.
      * Mariadb -- very similar to MySQL.
      * MongoDB
      * MSSQL -Windows or Linux with SSMS
      * Cockroachdb
       
  c. Cloud
    1. Links
          * Old page: [Free Setup](https://github.com/vikingdata/articles/blob/main/cloud/Free_setup.md)
    2. AWS
      * [AWS free](https://aws.amazon.com/free/?gclid=Cj0KCQiA1Km7BhC9ARIsAFZfEIvEClUtkGLBpYAb805PJ23Ooec3uR1uURdUFUi_LwLUt_aDOrfOzUwaAoJREALw_wcB&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=categories%23compute&trk=6a455a6f-f7f7-4463-917f-b59707d5f462&sc_channel=ps&ef_id=Cj0KCQiA1Km7BhC9ARIsAFZfEIvEClUtkGLBpYAb805PJ23Ooec3uR1uURdUFUi_LwLUt_aDOrfOzUwaAoJREALw_wcB:G:s&s_kwcid=AL!4422!3!646547068075!p!!g!!cloud%20computing!2038862296!75709537127)
      * Database + Storage
       * Dynamo
       * SimpleDB
       * S3 -- used by databases and storage. It is very very cheap.
       * Redshift -- not free, but free when idle
     * Monitoring
       * Promethesus
       * Cloudtrail Programming
         * Glue (between dynamo, SimpleDB, and MySQL and MongoDB on EC2)
         * Lambda (same as glue)
         * security - Key Management, Security Hub, cloudtrail, * Storage -- Storage Gateway Other
         * Route -- DNS
         * Billing or admin - Organizations, control tower

    3. GCP Free
      * Cloud storage ; 5GB and traffic -- enough for testing Database
        * Database
	  * Big Query
          * pub/sub
	* Server (same as ec2 in AWS)
	  * e2-micro VM instance
	* Other
          * firestore Programming
          * secret manager Server
          * Google Compute --- limited resources


    4. MS Free
    5. Oracle Free
  d. Monitoring
    1. New Relic
    2. Datadog
    3. Grefana
      
  e. Tools
    1. Confluence
    2. PMM
    3. Claude AI
 