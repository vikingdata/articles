#!/usr/bin/expect -f

# Check if arguments are provided
if {[llength $argv] != 3} {
    puts stderr "Usage: myscript.exp user password host"
    exit 1
}

# Access command line arguments
set user     [lindex $argv 0]
set pass     [lindex $argv 1]
set host     [lindex $argv 2]
#set savefile [lindex $argv 3]

#set env(MYSQL_TEST_LOGIN_FILE) $savefile

spawn mysql_config_editor set  --user=$user --password --host=$host
expect "password:"
send "$pass\r"

