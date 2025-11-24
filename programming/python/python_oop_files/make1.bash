
homedir=/tmp/sample_package

mkdir -p $homedir

echo '
# load classed from files
from .mod1 import Print1
from .mod2 import Print2
from .mod3 import Print3a,Print3b
from .mod4 import Print4


  # Make Classes available when loading with *
__all__ = ["Print1", "Print2", "Print3a", "Print3b", "Print4"]
' >  $homedir/__init__.py

echo "

class Print1:
  def __init__(self):
    pass
    
  def print1(self):
    print ('executing print1 of object from Print1 class.')

" > $homedir/mod1.py

echo "

class Print2:
  def __init__(self):
    pass

  def print2(self):
    print ('executing print2 of object from Print2 class.')

" > $homedir/mod2.py

echo "

class Print3a:
  def __init__(self):
    pass

  def print3a(self):
    print ('executing print3a of object from Print3a class.')

class Print3b:
  def __init__(self):
    pass

  def print3b(self):
    print ('executing print3b of object from Print3b class.')


" > $homedir/mod3.py

echo "
  # Print3 can be imported from the package level because of __init__.py
from sample_package import Print3a
  # If you did not define it at the package level, you have to give
  # the full path as this
from sample_package.mod3 import Print3a


class Print4:
  def __init__(self):
    pass

  def print4(self):
    print ('executing print4 of object from Print4 class.')
    print ('Creating Print3a object in print4 method from class Print4')
    temp = Print3a()
    print ('Executing print3a method in print4 method4')
    temp.print3a()

    try:
      temp = Print3b()
      temp.print3b()
    except:
      print('Failed to create object from Print 3b inside of Print4')
" > $homedir/mod4.py


echo "

  # import objects from __all__ in __init_-.py
from sample_package import *

  # create objects
a = Print1()
b = Print2()
c1 = Print3a()
c2 = Print3b()
d = Print4()
  # Execute methods of objects
a.print1()
b.print2()
c1.print3a()
c2.print3b()
d.print4()
" > /tmp/sample1.py

python3 /tmp/sample1.py
