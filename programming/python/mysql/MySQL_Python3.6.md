 
---
title :  MySQL Python 3.6
author : Mark Nielsen  
copyright : September 2024  
---


MySQL Python 3.6
==============================

_**by Mark Nielsen
Original Copyright September 2024**_

1. [Links](#links)
2. [Setup](#setup)

* * *
<a name=Links></a>Links
-----
* [Version of MySQL Python Connector](https://dev.mysql.com/doc/connector-python/en/connector-python-versions.html)

* * *
<a name=s>Setup</a>
-----

```
  # Look at the versions of MySQL Python Connector
  # Example, I have MySQL and Python 3.6.
  # Thus I need version 8.0.5, there is no 8.0

cd
python3.6 -m venv pythonenv
source /home/mark/pythonenv/bin/activate
echo "" >> ~/.bashrc
echo "source /home/mark/pythonenv/bin/activate" >> ~/.bashrc

apt install python3-pip

  # 8.0 will error out, but it should tell you a close version. 
pip install mysql-connector-python==8.0.5

  # In MySQL
  # create user mark@localhost identified by 'mark';

echo '#!/home/mark/pythonenv/bin/python

import mysql.connector
cnx = mysql.connector.connect(user="mark", password="mark", host="127.0.0.1",'ssl_disabled'= True)
cursor = cnx.cursor()
cursor.execute("select now()")
print (cursor.fetchall()[0][0])

'  > /tmp/test_mysql.py

python3 /tmp/test_mysql.py

```

* Output
```
2024-09-18 01:00:22
```