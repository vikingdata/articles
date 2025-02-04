* AWS lambda - You can use AWS Lambda to run code without provisioning or managing servers. Lambda runs your code on a high-availability compute infrastructure and performs all
   * https://www.youtube.com/watch?v=9-8eBPwYk4Q

* AWS Kinesis data firehose- Reliably load real-time streams into data lakes, warehouses, and analytics services
    * https://www.youtube.com/watch?v=1I1DcJvmd4w
    * https://www.youtube.com/playlist?list=PL8JO6Q_xfjelrryCOF0SBm7eThI5JNKYi

* AWS GLue : takes differnet sources of data and puts into a datalake. 

* S3 -- place to put files and can be used by other services for input and output.

* VPC route - Based on the destination of the ip address, which server should server the request. Ususually used
for end apps.

* Data Lake -- place to store structured and unstructures data. 

* Adding an Amazon S3 location to your data lake -- you can assign permissions on S3 sections to different users.

* Data Sync -- move data from AWS, on premises, or cloud to one another. Simplfies data movement,  ex: you have many
customers who need data transferred. It uses agents and tied to cloudwatch.
    * https://docs.aws.amazon.com/datasync/latest/userguide/what-is-datasync.html

* EMR -- Elastic Map Reduce == simplifies running hadoop or spark. 
   * https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html

* Lamdba Layers -- for example, using Python, a way making code respository that other scripts will use. Instead of
making changes to 10 scripts, have them use  layer to load code, so that you change it in one place.
   * https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html

* Combinations
   * Use Kinessis to get input, lamdba to process input
   * to create a data mesh combining access control, analysis, and governace
       * RDS for storage, EMR for analysis, GLue to prepare data. 