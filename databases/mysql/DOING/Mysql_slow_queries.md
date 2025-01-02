 
---
title : MySQL slow queries
author : Mark Nielsen  
copyright : June 2024  
---


MySQL Slow Queries
==============================

_**by Mark Nielsen
Original Copyright March 2024**_


1. [Links](#links)
2. [built-in](#b)
3. [Percona pt-query-digest](#pt)
4. [Python script](#p)
5. Other tools
   * New Relic
   * Solar Winds
   * AWS Cloudwatch and GLobal Insights
       * https://chromewebstore.google.com/detail/eversql-integrations-mysq/amihcpfgniggncfcljabdgcdbccbpiin
   * [datadog]( https://www.datadoghq.com/dg/monitor/mysql-benefits/?utm_source=google&utm_medium=paid-search&utm_campaign=dg-dbm-na-mysql&utm_keyword=mysql%20slow%20query&utm_matchtype=p&igaag=148293718920&igaat=&igacm=15895795662&igacr=646875197688&igakw=mysql%20slow%20query&igamt=p&igant=g&utm_campaignid=15895795662&utm_adgroupid=148293718920&gad_source=1&gclid=Cj0KCQiAyc67BhDSARIsAM95Qzt3FRSbGwjQN6K5ph1nX91siZ9pnANDvGIxsRKHOc5j0fVTdX6aQPAaAnJvEALw_wcB)
   * grafana

<a name=Links></a>Links
-----
* built in
* pt-query-digest
* Python script

* * *
<a name=b>Built-in</a>
-----
NOTE: if you are using Percona MySQL, turn off extended Percona slow query.
    * log_slow_verbosity=off



NOTE:
* Install oracle community version
* edit script to work with percona
* Make Python script
