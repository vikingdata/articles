 
---
title : MySQL Roles
author : Mark Nielsen  
copyright : December 2024  
---


MySQL Roles
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

Understand roles better. 

1. [Links](#links)
2. [Make roles and facts](#make)
3. [Test with and without roles](#test)

* * *
<a name=links></a>Links
-----
* https://dev.mysql.com/doc/refman/8.4/en/roles.html
* https://www.prisma.io/dataguide/mysql/authentication-and-authorization/role-management


* * *
<a name=make></a>Make roles and facts
-----
* You can make and drop roles.
* Grants can be made and revoked from roles and it affects any account logged in. 
* Roles are locked. It means you cannot login as that role. That role can only be "granted" to other accounts. 
* Roles are stored in the grants table and do not have their own table. 
* Roles cannot be:
    * Renamed
    * password protected. You can't log in as roles so no use for password. 
* Roles can be:
    * Made and assigned and can affect connected users.
        * Users must set the role.
        * The default roles should be reassigned for the user. 
    * Changing grants on roles affects connected users with those roles. 
    * Adding mandatory roles affects all users and they do not need to be set as defaults.
    They automatically are granted and to connected accounts. 
    * Anything modifying roles affects connected users immediately. The exception are roles created and
      assigned but not set by default or mandatory. Those roles have to be set the account. 

* Advantages
    * If every user in a group uses a role for permission, you change the role and you affect all of them instead
    of modifying each account. 

Make accounts and role
```
drop database if exists test_roles;
create database test_roles;
use test_roles;
create table test1 (i int);
insert into test1 values (1);

drop role if exists role_read@localhost;
drop role if exists role_write@localhost;
drop user if exists test_user@localhost;


create role role_read@localhost;
GRANT select  ON test_roles.* TO role_read@localhost;
revoke role_read@localhost from test_user@localhost;
GRANT select  ON test_roles.* TO role_read@localhost;

create role role_insert@localhost;
GRANT insert  ON test_roles.* TO role_insert@localhost;

create user  test_user@localhost identified by 'bad_password';

```


* * *
<a name=test></a>Test with and without roles
-----
### Assign role, drop roles, make role

* Create login file for root and test_user. Unless specified to do so DO NOT log out of a session
unless told to. 
```
echo "
[client]
user=root
password=root
" > ~/.my.cnf_root

echo "
[client]
user=test_user
password=bad_password
" > ~/.my.cnf_test_user


mysql --defaults-file=~/.my.cnf_root      -N -e "select 'root okay'"
mysql --defaults-file=~/.my.cnf_test_user -N -e "select 'test_user okay'"


```

### Test query, assign role, test query again.

* Login as root in window 1 and test_user in window 2. DO NOT log out of a session unless told to do so. 
```
    # In Window or terminal 1
mysql --defaults-file=~/.my.cnf_root

  # In window or terminal 2
mysql --defaults-file=~/.my.cnf_test_user

```
* Execute command as test_user and it should fail

```
SET ROLE role_read@localhost;
select * from test_roles.test1;
```
Output
```
mysql> select * from test_roles.test1;
ERROR 1142 (42000): SELECT command denied to user 'test_user'@'localhost' for table 'test1'
```

* Grant role to test_user as root
```
  # As user root in window 1
grant role_read@localhost to test_user@localhost;
```

Output
```
mysql> grant role_read@localhost to test_user@localhost;
Query OK, 0 rows affected (0.03 sec)
```

* Now select again as test_user in window2, and insert. Select should work insert should fail.
```
  # In window 2
SET ROLE role_read@localhost;
select * from test_roles.test1;

SET ROLE role_insert@localhost;
insert into test_roles.test1 values (2);
```

Output
```
mysql> SET ROLE role_read@localhost;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from test_roles.test1;
+------+
| i    |
+------+
|    1 |
+------+
1 rows in set (0.00 sec)

mysql>
mysql> SET ROLE role_insert@localhost;
ERROR 3530 (HY000): `role_insert`@`localhost` is not granted to `test_user`@`localhost`
mysql> insert into test_roles.test1 values (2);
ERROR 1142 (42000): INSERT command denied to user 'test_user'@'localhost' for table 'test1'

```

* Now add insert role as user root in window 1
```
grant role_insert@localhost to test_user@localhost;

```
Output
```
mysql> grant role_insert@localhost to test_user@localhost;
Query OK, 0 rows affected (0.02 sec)

```

* Do select and insert as test_user in window 2
```
SET ROLE role_read@localhost;
select * from test_roles.test1;

SET ROLE role_insert@localhost;
insert into test_roles.test1 values (3);
```

Output
```
mysql> select * from test_roles.test1;
+------+
| i    |
+------+
|    1 |
|    2 |
+------+
2 rows in set (0.01 sec)

mysql>
mysql> SET ROLE role_insert@localhost;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into test_roles.test1 values (3);
Query OK, 1 row affected (0.02 sec)
```

* Set both roles as default for test_user in window 1 or 2. 
```
set default role role_select@localhost, role_insert@localhost;

```
Output

```
mysql> set default role role_read@localhost, role_insert@localhost to test_user@localhost;
Query OK, 0 rows affected (0.02 sec)
```

Execute as test_user again and show grants for user
```
select * from test_roles.test1;
insert into test_roles.test1 values (4);
show grants;
show grants for role_read@localhost;
show grants for role_insert@localhost;

```

Output
```

mysql> select * from test_roles.test1;
+------+
| i    |
+------+
|    1 |
|    2 |
|    3 |
+------+
3 rows in set (0.01 sec)

mysql> insert into test_roles.test1 values (4);
show grants;
Query OK, 1 row affected (0.03 sec)

mysql> show grants;
+------------------------------------------------------------------------------------+
| Grants for test_user@localhost                                                     |
+------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `test_user`@`localhost`                                      |
| GRANT SELECT, INSERT ON `test_roles`.* TO `test_user`@`localhost`                  |
| GRANT `role_insert`@`localhost`,`role_read`@`localhost` TO `test_user`@`localhost` |
+------------------------------------------------------------------------------------+
3 rows in set (0.00 sec)
mysql> show grants for role_read@localhost;
ERROR 1142 (42000): SELECT command denied to user 'test_user'@'localhost' for table 'user'
mysql> show grants for role_insert@localhost;
ERROR 1142 (42000): SELECT command denied to user 'test_user'@'localhost' for table 'user'

```

* Revoke permissions from test_user

In Window 1 as root user
```
revoke role_read@localhost from test_user@localhost;
revoke role_insert@localhost from test_user@localhost;
```

In window 2 as test_user


```
select * from test_roles.test1;
insert into test_roles.test1 values (5);

```

Output
```
mysql> select * from test_roles.test1;
ERROR 1142 (42000): SELECT command denied to user 'test_user'@'localhost' for table 'test1'
mysql> insert into test_roles.test1 values (5);
ERROR 1142 (42000): INSERT command denied to user 'test_user'@'localhost' for table 'test1'

```
* Grant mandatory roles for test_user in window 1 as root
```
SET PERSIST mandatory_roles = 'role_read@localhost, role_insert@localhost';

```

As test_user in window 2
```
select * from test_roles.test1;
insert into test_roles.test1 values (5);
```

Output
```
mysql> select * from test_roles.test1;
+------+
| i    |
+------+
|    1 |
|    2 |
|    3 |
|    4 |
+------+
4 rows in set (0.00 sec)

mysql> insert into test_roles.test1 values (5);
Query OK, 1 row affected (0.04 sec)

```
* Drop a role

In window 1 as root
```
grant role_read@localhost   to test_user@localhost;
grant role_insert@localhost to test_user@localhost;
drop role role_insert@localhost;


```

Test as test_user in window 2
```
select * from test_roles.test1;
insert into test_roles.test1 values (6);

```

Output
```
mysql> select * from test_roles.test1;
+------+
| i    |
+------+
|    1 |
|    2 |
|    3 |
|    4 |
|    5 |
+------+
5 rows in set (0.01 sec)

mysql> insert into test_roles.test1 values (6);
ERROR 1142 (42000): INSERT command denied to user 'test_user'@'localhost' for table 'test1'
```

