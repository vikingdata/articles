Links
* https://www.yugabyte.com/blog/ysql-architecture-implementing-distributed-postgresql-in-yugabyte-db/
* https://www.yugabyte.com/blog/distributed-sql-yugabytedb-two-layer-architecture/
* https://docs.yugabyte.com/preview/architecture/docdb/data-model/

#### strart
* yugabytdb managed - interface to manage and create cluster son the web./
* https://www.youtube.com/watch?v=KPWpzJuugV8
* https://www.yugabyte.com/blog/5-query-pushdowns-for-distributed-sql-and-how-they-differ-from-a-traditional-rdbms/

##### TODO Tasks
* alter database search path -- what is it used for?



* https://university.yugabyte.com/pages/learning-path-yugabytedb-ysql-for-practitioners
    * YSQL Exercises: Aggregation queries
    * YSQL Exercises: Recursive queries

* YB-TServer:
    * Manages data storage and retrieval for client applications.
    * Processes SQL queries and handles data operations.
    * Stores data in tablets (shards).
    * Can be scaled out for increased capacity and resilience. 
* YB-Master:
    * Manages cluster metadata, including the PostgreSQL catalog. 
    * Coordinates cluster-wide operations like tablet placement and load balancing. 
    * Handles administrative tasks such as creating, altering, and dropping tables. 
    * Forms a Raft group for high availability, with multiple masters able to take over in case of failure.
    * Can be placed on dedicated nodes for high-performance use cases. 
* DocDB is a key-value storage engine which is NoSQL and SQL comptaible.
    There is an interface for SQL. 

* YSQL
     * PosrgreSQL compatible layer
     * Parser, Analyzer, Rewriter, Palnner, Executor