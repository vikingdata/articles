

* [Passwords in MySQL](#m)
* [Saving Passwords in config](#save)

* * *
<a name=Links></a> Links
--------
* https://dev.mysql.com/doc/refman/8.4/en/mysql-config-editor.html

* * *
<a name=save></a> Saving Passwords in config
--------
### my.cnf

### mysql_config_editor

filesave=~/mysql_login/test.cnf
export MYSQL_TEST_LOGIN_FILE=$filesave
mysql_config_editor set  --user=root --password --host=localhost 

### Hostless
mysql_config_editor set  --login-path=PATH1 --user=root --password 