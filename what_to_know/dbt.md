# What to know : dbt

* [snowflake](https://docs.getdbt.com/quickstarts/snowflake?step=1)

* models
    * yml and sql files can be named anything, depends on what you put in them. 
    * sources.yml
        * You sepcify sources of data, where you get the initial data from. Under "sources", specify name of project, specify database and schema. and under tables
	list the tables. When you run "dbt run" It will make the output tables. You can do a specific table with "-s" option. [Selection](https://docs.getdbt.com/reference/node-selection/syntax)
       
```text
sources:
    - name: jaffle_shop
      description: This is a replica of the Postgres database used by our app
      database: raw
      schema: jaffle_shop
      tables:
          - name: customers
            description: One record per customer.
          - name: orders
            description: One record per order. Includes cancelled and deleted orders.
```
    * schema.yml : Meant for models to run tests against. Specify models, table, columns, and property of columns. Then run "dbt test". Also meant for dbt build which tests you resourcs. 
```
version: 2

models:
  - name: customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
```

    * Any *.sql file
        * Runs a query, an query against source tables or tables you create and creates another table or a view.
	* DBT figures out depencies.
	* Uses commands to specify the output is a table or view.
	* Users references to setup a list of depemdencies. 


        