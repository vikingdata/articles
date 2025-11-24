---
title :  Python oop
author : Mark Nielsen
copyright : November 2025
---


Python oop
==============================

_**by Mark Nielsen
Original Copyright November 2025
1. [\_\_init\_\_.py](#c)
2. [Main object load other objects](#m)
3. [Best, load everything](#e)
4. [Explanation of Packages](#p)
* * *
<a name=c></a>\_\_init\_\_.py
-----
What does __init__.py do? I loads anything into the level of the package
but not below the package level.
1. [Defines a package and loads things into the package.](www.geeksforgeeks.org/python/what-is-__init__-py-file-in-python/) 


Loading Classes from other Classes of different files in a module

* All that __init__.py does is defines stuff at the top level of "sample_package".
Only at the level os the script that loaded the module do you not need the full path
of the loaded Classes. At the top script you can execute Print3, but inside
other modukes you have to load the class Print3 as "from sample_package import Print3"
or "from sample_package.mod3 import Print3".


1. Download the file, execute it, and execute python.
```
rm -f make1.bash
wget --no-cache https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/programming/python/python_oop_files/make1.txt -O  make1.bash

bash /tmp/make1.bash

python /tmp/sample1.py
```

<a name=m></a>Main object load other objects
-----


* Another approach is:
    * Make objects of each method in the main object. You pass the parent class to
    the other classes. 
    * When needing to load a module, use a try except loading that module
    for the class.


1. Download the file, execute it, and execute python.
```
rm -f make2.bash
wget --no-cache https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/programming/python/python_oop_files/make2.txt -O  make2.bash

bash make2.bash

python /tmp/sample2.py
```


<a name=e></a>The easiet way is to load everthing. Be careful of name clashes. 
-----

1. Download the file, execute it, and execute python.
```
rm -f make3.bash
wget --no-cache https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/programming/pytho
n/python_oop_files/make3.txt -O  make3.bash

bash make3.bash

python /tmp/sample3.py
```


```
<a name=p></a>Explanation of Packages
-----

I have not seen any good documentation an example of Python Packages.
The documentaion is terrible and does not give any good examples. Here is
a list of links and also what I got from AI.

1. link1


From AI

* Modules: The most fundamental components of a package are the modules it contains. Each .py file within the package (and its subdirectories, if any) represents a module. When a module is imported, a module object is created, which encapsulates the code, variables, functions, and classes defined within that module.
* Subpackages: A package can contain other packages, referred to as subpackages. These are essentially nested directories within the main package, each also containing an __init__.py file (in traditional packages). When a subpackage is imported, a module object representing that subpackage is also created.

* Classes: Within modules, you can define classes. When a class is defined and a module containing it is imported, the class object itself becomes an accessible object. You can then use this class object to create instances (objects) of that class.

* Functions: Similarly, functions defined within modules become function objects when the module is imported. These function objects can then be called and executed.
* Variables: Any variables (including constants) defined at the module level within a package's modules become accessible as attributes of the corresponding module object when imported.
* Package Object: The package itself, when imported, is represented by a module object (specifically, the one corresponding to its __init__.py file in traditional packages). This package object can then be used to access its contained modules and subpackages.
