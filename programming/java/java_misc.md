 
---
title :  Jav Misc
author : Mark Nielsen  
copyright : June 2025
---


Java Misc
==============================

_**by Mark Nielsen
Original Copyright June 2025**_

THIS ARTICLE IS NOT COMPLETE, and will be edited over the next few months.
I unfortunately am required to do java, so I am writing down some notes. 

1. [Links](#links)
2. [Misc](#misc)
2. [Exaplantions](#e)

* * *
<a name=Links></a>Links
-----



* * *
<a name=<misc>Misc</a>
-----

* To run java commands in a shell : jshell
* Invalid variables start with number. Can start with a letter (A-Z or a-z), underscore (_), or dollar sign ($).
* int myMethod( ) { }
  * int is the return type.
  * myMethod is the method name.
  * () indicates no parameters.
  * { } is the method body.
* For x* = 1 + 2 and X = 10. Answer is 30. You do everything on the right
and then you multiply it. x*=1+2 is x* = 3 is X*3 which is 10*3 which is 30.
Basically, you do everything on the right and apply the sign.
* For an if condtion in a print
   * a=2; b=1; System.out.println(a > b ? "2 > 1" : "1 < 2");
   * This will print : 1 < 2.
* Initilize an array
    * int[] numbers = {1, 2, 3, 4, 5};
    * int numbers[] = new int[]{1, 2, 3, 4, 5};
* If an "if" condition is not encapsulated with brackets, only the first lin
  is executed.

### 3

* Advantages of static methods are variables
    * shared across all instances, so only one copy exists in memory, reducing memory usage.
    * methods that don't depend on instance variables
    * used as global variables within a class
    * accessed without creating an instance of the class
* "final" is used to prevent a method from being overridden in the subclass.
It makes a method or variable constant and cannot be overridden or modified.
* To access a static variable within a static method
    * Variable -- if defined in the same class
    * class.variable
* To differentiate between static method and a non-static (instance) method
  Determine their association with class or instances.
* static blocks in java are executed before the main method. 
* Static Nested classes can be instantiated without an instance of the outer class.
* Instance variables shadow or take precedence over static variables.
* static methods cannot access non-static variables
* static methods and variables can have a problem in multi threaded
 environments where they may get initialized without synchronization
* "break" is used to exit a loop
* a & B returns 1 if both if both bits are 1, it returns 0
* static methods and variables are stored separately and shared amoung all
instances of the class saving memory.
* method overiding - The overridden method in the subclass must have the same access modifier as the superclass method.
* The scope of a static variable is limited to the class it was declared in.
* "&" is not a logical operator, it is a bitwise operator.
* "==" compares two values for equality.
* Array
    * To change an item: set(int index, E element)
    * int[] numbers = new int[5]; # This defaults all valus to 0. 
* Array List
    * Added elements automatically increase list in an arrayList.
    * list1.size() is the numbers of elements in arrayList
    * list1.get(1) gets the 2nd element. Position 0 is the first. 
* abstract and final classed:
    * final
    *

* To initialize an array int numbers[ ] = new int[ ]{10, 20, 30};
* Abstract classes can implement interfaces.
* remove() is used to remove the first occurance item in a list. 
* Method overloading allows for multiple methods with the same name but different parameters, while method overriding involves redefining a method in a subclass with the same name and parameters as in the superclass.
* define and give examples: TODO: Other terms
    * Inheritance
    * Abstraction
    * Encapsulation
    * Polymorphism
    * interface
    * overloading
    * overriding
    * abstract class
    * final class
    * static
    * public and private



* * *
<a name=e>Explanations</a>
-----
* TODO Describe scenarios of static variables, methods, and non-static and when they
get used. OVerridden or not.
* Describe logical and bitwise functions
* Describe scopes of static and non-static variables and methods. 

* Describe how "A" gets printed. The method to call is resolved at
compile-time based on the reference type,
not the actual object type. "obj" is declared
as "A" sp A.print is called. Both methods are static, B's is hidden. 
```
class A {
    static void print() {
        System.out.println("A");
    }
}
class B extends A {
    static void print() {
        System.out.println("B");
    }
}
public class Main {
    public static void main(String[] args) {
        A obj = new B();
        obj.print();
    }
}
```