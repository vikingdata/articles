---
title :  Python tips
author : Mark Nielsen
copyright : November 2025
---


Python Tips
==============================

_**by Mark Nielsen
Original Copyright November 2025
1. [One way of classes](#c)


* * *
<a name=c></a>One way of classes
-----
Loading Classes from other Classes of different files in a module

* All that __init__.py does is defines stuff at the top level of "sample_module".
Only at the level os the script that loaded the module do you not need the full path
of the loaded Classes. At the top script you can execute Print3, but inside
other modukes you have to load class Print3 as "from sample_module import Print3"
or "from sample_module.mod3 import Print3".

If you wish one object to load another object, 

Save these files
```

mkdir -p sample_module

echo '
# load classed from files
from .mod1 import Print1
from .mod2 import Print2
from .mod3 import Print3
from .mod4 import Print4


  # Make Classes available when loading with *
__all__ = ["Print1", "Print2", "Print3", "Print4"]
' >  sample_module/__init__.py

echo "

class Print1:
  def __init__(self):
    pass
    
  def print1(self):
    print ('executing print1 of object from Print1 class.')

" > sample_module/mod1.py

echo "

class Print2:
  def __init__(self):
    pass

  def print2(self):
    print ('executing print2 of object from Print2 class.')

" > sample_module/mod2.py

echo "

class Print3:
  def __init__(self):
    pass

  def print3(self):
    print ('executing print3 of object from Print3 class.')
" > sample_module/mod3.py

echo "
from sample_module import Print3
  # Same as this. __init__.py defines Print3 at top
  # of sample_module, so you don not need to specify sample_module.mod3
from sample_module.mod3 import Print3


class Print4:
  def __init__(self):
    pass

  def print4(self):
    print ('Creating Print3 object in print4 method from class Print4')
    temp = Print3()
    print ('Executing print3 method in print4 method4')
    temp.print3()
    print ('executing print4 of object from Print4 class.')
" > sample_module/mod4.py


echo "

  # import objects from __all__ in __init_-.py
from sample_module import *

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

* Another approach is:
    * Make objects of each method in the main object.
    * When needing to load a module, use a try except loading that module
    for the class.

TODO: give example. 