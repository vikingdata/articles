---
title : Linux Environment variables
author : Mark Nielsen
copyright : August 2025
---


 Linux Environment variables
==============================

_**by Mark Nielsen
Original Copyright August 2025**_

I wanted to run a script to ask for a prompt to set an environment variable. 

1. [Links](#links)
2. [Set environment variable by prompt](#s)

* * *

<a name=links></a>Links
-----

* * *
<a name=mul></a>Set environment variable by prompt
-----

Goals:
1. Ask for enviroment variable, like a password, and hide what you are typing.

Issues:
1. If the variables are not secure, you can source
a file that contains the variables.
2. The parent shell will not have environment variables set by another shell.
You must "source" a script.
3. If you source a script, read -p, cannot work. And you can export the
variable to the parent shell.
4. Saving passwords as environment variables is not perfect. Neither are
cookies, saving passwords in a file, etc. Unless EVERYTIME you have to enter
a password to get another password, anything is vulnerable. Even then someone
can record your keystrokes or analyze what happened in memory or analyze
what program you used to unlock a password. 


Solution:
1. Soure a script which runs another script to ask for password.
2. Have the 2nd script print back the password to the 1st script.
3. Have the parent script set the variable.

Run commands

```
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/env_variables/Input.txt -O Input.sh
wget
chmod 755
./Example.sh
```