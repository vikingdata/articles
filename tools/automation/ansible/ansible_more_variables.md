--------
title: Ansible : More Variables 

--------

# Ansible: More Variables

*by Mark Nielsen*  
*Copyright October 2023*

The purpose of this document is to:

- Change and reset strings, lists, and dictionaries


---

* [Links](#links)
* [Change Variables](#var)
    * [Set variables](#1)
    * [Append to a list and dictionary](#2)
    * [Change variables](#3)
    * [Reset Everything](#4)
    * [Merge multiple info to list and dictionary](#5)
    * [Merge Mutiple info from other list or dictionary](#6)
    * [Make a list from a dictionary](#7)
    * [Make a dictionary from two lists](#8)
    * []()
    * []()
* [One big file](#big)


* * *

<a name=links></a>Links
-----
* [Sample Ansible setup](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html)

* * *

<a name=change></a>Change Variables
-----

** <a name=1></a> Set variables



** <a name=2></a>Append to a list and dictionary

echo "
---
  - name : Play with variables.
    hosts: testservers
    vars:
      string1 : ' Just a string '

      string_list :
        - 'apple'
        - 'banana'
        - 'carrot'

      string_dictionary:
        person1 : Mark
        person2 : John
        person3 : Heidi

    tasks :
    - name : Display and change variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}

" > /etc/anisble/play_with_variables.yml

** <a name=3></a>Change variables
echo "

    - name: Change string
      set_fact:
        string1 : 'Changed string'
    - name : Append list
      set_fact:
        string_list: "{{ string_list + ['Added string'] }}"
    - name : Append key
      set_fact:
        string_dictionary: "{{ string_dictionary | combine({'person4': 'Collin'}) }}"

    - name : Display changed variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}


" >>/etc/anisble/play_with_variables.yml

** <a name=4></a>Reset Everything

echo "

" >>/etc/anisble/play_with_variables.yml

** <a name=5></a>Merge multiple info to list and dictionary
echo "

" >>/etc/anisble/play_with_variables.yml


** <a name=6></a>Merge Mutiple info from other list or dictionary
echo "

" >>/etc/anisble/play_with_variables.yml

** <a name=7></a>Make a list from a dictionary
echo "

" >>/etc/anisble/play_with_variables.yml

** <a name=8></a>Make a dictionary from two lists
echo "

" >>/etc/anisble/play_with_variables.yml

* * *

<a name=change></a>Change and reset strings, lists, and dictionaries
-----



* * *

<a name=big></a>One Big File
-----
There are more levels to define variables than listed here. 