---
title: Snowflake, SQL, DBT, and other links
Author: Mark Nielsen
Date: Sept 2023
Copyright: \@Sept 2023
---

## DBT
* [https://docs.getdbt.com/docs/introduction](https://docs.getdbt.com/docs/introduction) 
* [https://docs.getdbt.com/docs/core/installation](https://docs.getdbt.com/docs/core/installation )
* [https://docs.getdbt.com/docs/supported-data-platforms](https://docs.getdbt.com/docs/supported-data-platforms)
* [https://www.youtube.com/watch?v=5rNquRnNb4E&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT](https://www.youtube.com/watch?v=5rNquRnNb4E&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT])
* [https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup](https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup)
* [https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup)

* [https://github.com/dbt-labs/dbt-starter-project](https://github.com/dbt-labs/dbt-starter-project)

* [https://youtube.com/playlist?list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&si=6s7Og5oAnuuf2Bf0](https://youtube.com/playlist?list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&si=6s7Og5oAnuuf2Bf0
* or [https://www.youtube.com/playlist?list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT](https://www.youtube.com/playlist?list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT)

## Better SQL
* [https://www.getdbt.com/blog/write-better-sql-a-defense-of-group-by-1](https://www.getdbt.com/blog/write-better-sql-a-defense-of-group-by-1])
* [https://modern-sql.com/](https://modern-sql.com/)
* {https://stackdiary.com/sql-2023-is-released/#:~:text=SQL%3A2023%20now%20officially%20includes,JSON%20capabilities%20with%20modern%20JavaScript.](https://stackdiary.com/sql-2023-is-released/#:~:text=SQL%3A2023%20now%20officially%20includes,JSON%20capabilities%20with%20modern%20JavaScript.)
* [https://www.stratascratch.com/blog/best-practices-to-write-sql-queries-how-to-structure-your-code/](https://www.stratascratch.com/blog/best-practices-to-write-sql-queries-how-to-structure-your-code/)
* [https://youtu.be/MnEDHFOqqno?si=2DhLIeum2NoWZkX1](https://youtu.be/MnEDHFOqqno?si=2DhLIeum2NoWZkX1)

## Snowflake
* [https://docs.snowflake.com/en/release-notes/2023/7_22#sql-updates](https://docs.snowflake.com/en/release-notes/2023/7_22#sql-updates)
* [https://docs.snowflake.com/en/sql-reference/functions/min_by](https://docs.snowflake.com/en/sql-reference/functions/min_by)
* [https://www.intricity.com/learningcenter](https://www.intricity.com/learningcenter)
* [https://learn.snowflake.com/en/courses/](https://learn.snowflake.com/en/courses/)
* [https://docs.snowflake.com/en/release-notes/new-features](https://docs.snowflake.com/en/release-notes/new-features)

## Python
* [https://dlthub.com/](https://dlthub.com/)


## Data Warehouse and more
* [https://docs.getdbt.com/terms/dimensional-modeling](https://docs.getdbt.com/terms/dimensional-modeling)
* [https://static1.squarespace.com/static/51237d33e4b03a5603cd7aa4/t/57190b477da24f4efb600620/1461259091302/Agile-Data-Warehouse-Design-Sampler.pdf](https://static1.squarespace.com/static/51237d33e4b03a5603cd7aa4/t/57190b477da24f4efb600620/1461259091302/Agile-Data-Warehouse-Design-Sampler.pdf)
* [https://www.getdbt.com/blog/future-of-the-modern-data-stack](https://www.getdbt.com/blog/future-of-the-modern-data-stack)

## Terms
* CTE  -- Common Table Expressions. One thing is to use the "with as " clause to make nested queries simplier to read.
* UDF -- user defined functions. Like in SnowFlake, you make a UDF python function. Snowflake can make python scripts. The reason why Python can be used is for analytics. Python in a database for web applications
  might have performance issues. In analytics you are not spawning lots of python scripts (normally).
* DBT -- Is a transformtion flow for your data.  Its the "T" in ETL. Actually, ELT -- extract, load data, and then transform.  For more info, [https://docs.getdbt.com/docs/introduction](https://docs.getdbt.com/docs/introduction)


## Terms
* A CTE is a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement.
  * It is defined using the WITH keyword followed by a query that produces a result set.
  * CTEs are often used to simplify complex queries by breaking them down into smaller, more manageable parts.
  * They can make SQL queries more readable and maintainable, especially when dealing with recursive queries or when you need to reference the same subquery multiple times within a larger query.

* UDF (User Defined Functions):
  * UDFs are functions created by users or developers to extend the functionality of a database system.
  * In the context of Snowflake, you can create UDFs using Python. These functions allow you to perform custom operations and calculations within the database.
  * Python UDFs are particularly useful for analytics tasks, where you might need to apply complex transformations or calculations to your data.
  * While Python UDFs can be powerful, it's essential to use them judiciously to avoid performance issues, as they can be resource-intensive.

* DBT (Data Build Tool):
  * DBT is a popular open-source tool used for transforming data within a data warehouse.
  * It focuses on the transformation part of the ETL (Extract, Transform, Load) process, and it's often associated with ELT (Extract, Load, Transform) workflows.
  * With DBT, you can define data transformations, create models, and organize your data pipeline in a structured and version-controlled manner.
  * DBT is known for its ease of use, flexibility, and integration with popular data warehouse platforms like Snowflake, BigQuery, and Redshift.
  * It allows data analysts and engineers to collaborate effectively on data transformations and ensures that data is transformed consistently and reliably.

These concepts play significant roles in data management, analytics, and ETL processes, and they are commonly used in data-centric applications and data warehousing solutions.tps://streamlit.io/gallery](https://streamlit.io/gallery)



## Markdown
* [Markdown Guide](https://www.markdownguide.org/basic-syntax/)
* [Markdown CheetSheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
* [GitHub Writing](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

```markdown
Title:    A Sample MultiMarkdown Document  
Author:   Fletcher T. Penney  
Date:     February 9, 2011  



```





