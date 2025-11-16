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
Loading modules

Save these files
```

mkdir -p sample_module

echo "
  # load classed from files
from .mod1 import Print1
from .mod2 import Print2

  # Make Classes available when loading with *
__all__ = ["Print1", "Print2"]
" >  sample_module/__init__.py

echo "

class Print1:
  def __init__(self):
    pass
    
  def print1(self):
    print ("print1")

" > sample_module/mod1.py

echo "

class Print2:
  def __init__(self):
    pass

  def print2(self):
    print ("print2")

" > sample_module/mod2.py

echo "

  # import objects from __all__ in __init_-.py
from sample_module import *

  # create objects
a = Print1()
b = Print2()

  # Execute methods of objects
a.print1()
b.print2()
" > sample1.py

python3 sample1.py

```