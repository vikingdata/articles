
---
title : MySQL General
author : Mark Nielsen
copyright : June 2024 
---


MySQL General
==============================

_**by Mark Nielsen
Original Copyright June 2024**_

This article will grow over time. 

Not including

* [Info queries](info_queries.md)
* [MySQL variables](MySQL_variables.md)
* [Backup Restore Replication](mysql_backup_restore_replication.md)

Index
1. [tail a gzip file](#tailgzip)

* * *
<a name=tailgzip></a>Tail a gzipped file
-----

Assume a file is called File.gz

### Long way
This takes a long time since it has to unzip the entire file before doing tail.

```
zcat FILE.gz | tail -n 5

  ## or
gunzip -c FILE.gz | tail -n 5

```

### Faster way
A faster way is to NOT decompress the entire file.
For more information: https://github.com/circulosmeos/gztool

```
gztool -t FILE.gz | tail -n 5

```

### Or leave file uncompressed
```
tail -n 5 FILE.sql
```

* * *
<a name=tailgzip></a>What causes swap
-----
 transparent huge pages set to active
   * cat /sys/kernel/mm/transparent_hugepage/enabled
       * Should be :  always [madvise] never
   * To turn off
       * echo never > /sys/kernel/mm/transparent_hugepage/enabled
       * echo never > /sys/kernel/mm/transparent_hugepage/defrag
* jemalloc  https://support.sentieon.com/appnotes/jemalloc/
   * centos
       * yum install epel-release
       * yum install jemalloc
   * ubuntu
       * apt update
       * apt install libjemalloc2
   * Install in mysql my.cnf ```
[mysqld_safe]
   # Make sure you load the right library
   # depending on how jemaloc was installed
malloc-lib=/usr/lib64/libjemalloc.so.1
```
   * restart MySQL

 
* other reasons
   * swapinesss to 1
   * high tmp_table_size=1768M max_heap_table_size=1768M
