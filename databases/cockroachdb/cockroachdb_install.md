 
---
title : CockroachDB install
author : Mark Nielsen  
copyright : July 2024  
---


CockroachDB install
==============================

_**by Mark Nielsen
Original Copyright March 2024**_

There are two ways to install CockroachDB reasonably. First is to download CockroachDB yourself and use it for free. The second might cost a little but is almost entirely free and
if you don't go over the storage, use, and stay within the same area on GCP, it should be free forever (don't quote me on it). 


1. [Download and Cluster on one server](#d)
2. [Serverless (almost free)(#s)

* * *
<a name=Links></a>Links
-----
* [Man pricing page](https://www.cockroachlabs.com/pricing/?utm_source=google&utm_medium=cpc&utm_campaign=g-search-na-bofu-pipe-brand&utm_term=e-cockroachdb-c&utm_content=lp660564545020&utm_network=g&_bt=660564545020&_bk=cockroachdb&_bm=e&_bn=g&gad_source=1&gclid=CjwKCAjwnK60BhA9EiwAmpHZw-orpflC7u_a-02UX6s0EP20HkXuy9E5Iiqmqe_yXe4TnFELaDdk9RoC6LMQAvD_BwE)
* [Serverless Pricing)(https://www.cockroachlabs.com/pricing/?utm_source=google&utm_medium=cpc&utm_campaign=g-search-na-bofu-pipe-brand&utm_term=p-cockroach%20labs-c&utm_content=lp660564545176&utm_network=g&_bt=660564545176&_bk=cockroach%20labs&_bm=p&_bn=g&gad_source=1&gclid=CjwKCAjwnK60BhA9EiwAmpHZwwGr7pn7rtag6UR5A5Ava97MSfBOJY8ARg3U7VBAwZaMoJc7m9Q1FxoCUVcQAvD_BwE)
    * Nearest I can tell it is free forever is if you stay below 10 gis of data and 50 M RUS each month, use GCP with no cross region traffic. Then it can be good for testing.
* Convert to cockroachdb
    * [MySQL](https://www.cockroachlabs.com/docs/stable/migrate-from-mysql)
    * [PostgreSQL](https://www.cockroachlabs.com/docs/stable/migrate-from-postgres)
* CockroachDB comparisons
    * [General](https://www.cockroachlabs.com/docs/stable/cockroachdb-in-comparison)
        * This is from cockroachdb itself. Whenever companies or technologies make their own comparison chart, somehow it always benefits themselves. Not untrue, but some critical
	things might be overlooked.
    * [DBengines](https://db-engines.com/en/system/CockroachDB%3BMySQL%3BPostgreSQL)
    


* * *
<a name=d>Download and Cluster on one server</a>
-----


* * *
<a name=s>[Serverless (almost free)</a>
-----

