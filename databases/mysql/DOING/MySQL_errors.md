 
---
title : MySQL Errors
author : Mark Nielsen  
copyright : November 2024  
---


MySQL Errors
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

1. [Links](#links)
2. [Create and Drop user with quotes](#quotes)

* * *
<a name=links></a>Links
-----

* * *
<a name=#setup></a>Setup
-----

Setup two MySQL servers. One master and one slave. MySQL 8.0.

Not tested in 8.1 or 8.4.

* * *
<a name=#quotes></a>Create and Drop user with quotes
-----

Create user on master
```

create user "quote'quote'"@localhost;

```

Check Replication
```


```

Drop user

```
drop user "quote'quote'"@localhost;


```

Check slave

```


```
Fix Slave. Drop user manually, skip slave counter 1, start slave, check
slave status. 

```


```

Output

```

```