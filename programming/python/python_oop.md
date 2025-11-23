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
2. [Main objects load other objects](#m)
3. [Explanation of Packages](#p)
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
other modukes you have to load class Print3 as "from sample_package import Print3"
or "from sample_package.mod3 import Print3".

If you wish one object to load another object, 

Save these files
```

mkdir -p sample_package

echo '
# load classed from files
from .mod1 import Print1
from .mod2 import Print2
from .mod3 import Print3
from .mod4 import Print4


  # Make Classes available when loading with *
__all__ = ["Print1", "Print2", "Print3", "Print4"]
' >  sample_package/__init__.py

echo "

class Print1:
  def __init__(self):
    pass
    
  def print1(self):
    print ('executing print1 of object from Print1 class.')

" > sample_package/mod1.py

echo "

class Print2:
  def __init__(self):
    pass

  def print2(self):
    print ('executing print2 of object from Print2 class.')

" > sample_package/mod2.py

echo "

class Print3:
  def __init__(self):
    pass

  def print3(self):
    print ('executing print3 of object from Print3 class.')
" > sample_package/mod3.py

echo "
  # 
from sample_package import Print3
  # Same as this. __init__.py defines Print3 at top
  # of sample_package, so you don not need to specify sample_package.mod3
from sample_package.mod3 import Print3


class Print4:
  def __init__(self):
    pass

  def print4(self):
    print ('Creating Print3 object in print4 method from class Print4')
    temp = Print3()
    print ('Executing print3 method in print4 method4')
    temp.print3()
    print ('executing print4 of object from Print4 class.')
" > sample_package/mod4.py


echo "

  # import objects from __all__ in __init_-.py
from sample_package import *

  # create objects
a = Print1()
b = Print2()
c = Print3()
d = Print4()
  # Execute methods of objects
a.print1()
b.print2()
c.print3()
d.print4()
" > sample1.py

python3 sample1.py

```

<a name=m></a>Main object load other objects
-----


* Another approach is:
    * Make objects of each method in the main object.
    * When needing to load a module, use a try except loading that module
    for the class.

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
