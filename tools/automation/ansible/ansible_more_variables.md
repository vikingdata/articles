--------
title: Ansible : More Variables 

--------

# Ansible: More Variables

*by Mark Nielsen*  
*Copyright October 2023*

The documentation about manipulating variables in Ansible is a little confusing to the beginner and it seems different ways
of manipulating data is spread among many articles. 

The purpose of this document is to:

- Describe the basic of data manipulation for strings, lists, and dictionaries in one place. 

---

* [Links](#links)
* [Basic Setup](#setup)
* [Change Variables](#var)
    * [Set variables](#1)
    * [Append to a list and dictionary](#2)
    * [Change variables](#3)
    * [Reset Everything](#4)
    * [Merge 2 lists or dictionaries](#6)
    * [Make 2 lists from a dictionary](#7)
    * [Make a dictionary from two lists](#8)
    * [Merge two lists of dictionaries](#9)1
* [One big file](#big)


* * *

<a name=links></a>Links
-----
* [Sample Ansible setup](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html)
* [Manipulating data](https://docs.ansible.com/ansible/latest/playbook_guide/complex_data_manipulation.html)
* [How to merge multiple lists in ansible?](https://codingpointer.com/ansible/merge-lists)
* [Merge lists](https://docs.ansible.com/ansible/latest/collections/community/general/docsite/filter_guide_abstract_informations_merging_lists_of_dictionaries.html)
* [Combining items from multiple lists: zip and zip_longest](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_filters.html#combining-and-selecting-data)
* [Combine dictionaries](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/combine_filter.html)

* * *
<a name=setup></a>Basic Setup
-----


Read my first article on (setting up ansible.](https://github.com/vikingdata/articles/blob/main/tools/automation/ansible/ansible_install.md)

The only thing you really need to do is add a host section to the file "/etc/ansible/hosts".

* * *
<a name=change></a>Change Variables
-----

* <a name=1></a> Set variables



```shell 
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
```

* <a name=2></a>Append to a list and dictionary

```shell
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
```

* <a name=3></a>Change variables
```shell

echo "

    - name: Change string
      set_fact:
        string1 : 'Changed string 2'

    - name : Change element in list
      ansible.utils.update_fact:
        updates:
          - path : string_list.0
            value : 'changed element'
          - path : "string_list[1]"
            value : 'changed element 2'
      register : new_list
    - name : reset list
      set_fact :
        string_list : \"{{ new_list.string_list }}\"

    - name : Change a value of a key
      ansible.utils.update_fact:
        updates :
          - path : string_dictionary.person1
            value : 'changed person'
      register : new_dict


    - name : reset dictionary
      set_fact :
        string_dictionary : \"{{ new_dict.string_dictionary  }}\"

    - name : Display changed variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}

" >>/etc/anisble/play_with_variables.yml
```

* <a name=4></a>Reset Everything
```shell

echo "

    - name : backup everything
      set_fact :
        BACKUP_string1 : string1
    - set_fact :
        BACKUP_string_list : \"{{ string_list  }}\"
    - set_fact :
        BACKUP_string_dictionary : \"{{ string_dictionary  }}\"
    - name : set the variables to empty
      set_fact :
        string1 : ""
    - set_fact :
        string_list : []
    - set_fact :
        string_dictionary : {}

    - name : Display changed variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}


" >>/etc/anisble/play_with_variables.yml
```


* <a name=6></a>Merge 2 lists or dictionaries

```shell
echo "

    - set_fact :
        string_list : [1,2,3,4]
    - set_fact :
        string_dictionary : {'key1' : 'value1', 'key2' : 'value1'}

    - set_fact :
        string_list2 : [5,6,7,8]
    - set_fact :
        string_dictionary2 : {'key10' : 'value10', 'key20' : 'value10'}
    - set_fact :
        string_list_m : '{{ string_list + string_list2 }}'
    - set_fact :
        string_dictionary_m : '{{ string_dictionary | ansible.builtin.combine( string_dictionary2)  }}'


    - name : Display changed variables
      debug :
        msg :
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}
          - list2   is     {{ string_list2 }}
          - dictionary2 is {{ string_dictionary2 }}
          - list_merged   is     {{ string_list_m }}
          - dictionary_merged is {{ string_dictionary_m }}


" >>/etc/anisble/play_with_variables.yml
```

* <a name=7></a>Make 2 lists from a dictionary
```shell
echo "

    - set_fact :
        list_keys : '{{ string_dictionary.keys()  }}'
        list_values :  '{{ string_dictionary.values()  }}'

    - name : Display changed variables
      debug :
        msg :
          - dictionary is {{ string_dictionary }}
          - list_keys  is     {{ list_keys }}
          - list_values  is     {{ list_values }}


" >>/etc/anisble/play_with_variables.yml
```

* <a name=8></a>Make a dictionary from two lists

```shell
echo "

    - set_fact:
       dict_from_lists : '{{ list_keys | zip(list_values) }}'
    - name : Display changed variables
      debug :
        msg :
          - dict_from_lists is {{  dict_from_lists }}


" >>/etc/anisble/play_with_variables.yml
```

* <a name=9></a>Merge two lists of dictionaries

```shell
echo "

    - set_fact:
        list1 :
         - name : Sam
           children : 1
        list2 :
          - name : Billy
            children : 5
    - set_fact :
        list_m : \"{{ list1 | community.general.lists_mergeby(list2, 'name') }}\"

    - name : Display changed variables
      debug :
        msg :
          - list1 is {{ list1 }}
          - list2 is {{ list2 }}
          - list_m is {{ list_m }}

" >>/etc/anisble/play_with_variables.yml
```


* * *

<a name=big></a>One Big File
-----

* Execute to make the playlist


```shell

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

    - name: Change string
      set_fact:
        string1 : 'Changed string'
    - name : Append list
      set_fact:
        string_list: \"{{ string_list + ['Added string'] }}\"
    - name : Append key
      set_fact:
        string_dictionary: \"{{ string_dictionary | combine({'person4': 'Collin'}) }}\"

    - name : Display changed variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}



    - name: Change string
      set_fact:
        string1 : 'Changed string 2'

    - name : Change element in list
      ansible.utils.update_fact:
        updates:
          - path : string_list.0
            value : 'changed element'
          - path : "string_list[1]"
            value : 'changed element 2'
      register : new_list
    - name : reset list
      set_fact :
        string_list : \"{{ new_list.string_list }}\"

    - name : Change a value of a key
      ansible.utils.update_fact:
        updates :
          - path : string_dictionary.person1
            value : 'changed person'
      register : new_dict


    - name : reset dictionary
      set_fact :
        string_dictionary : \"{{ new_dict.string_dictionary  }}\"

    - name : Display changed variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}


    - name : backup everything
      set_fact :
        BACKUP_string1 : string1
    - set_fact :
        BACKUP_string_list : \"{{ string_list  }}\"
    - set_fact :
        BACKUP_string_dictionary : \"{{ string_dictionary  }}\"
    - name : set the variables to empty
      set_fact :
        string1 : ""
    - set_fact :
        string_list : []
    - set_fact :
        string_dictionary : {}

    - name : Display changed variables
      debug :
        msg :
          - string is     {{ string1 }}
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}

    - set_fact :
        string_list : [1,2,3,4]
    - set_fact :
        string_dictionary : {'key1' : 'value1', 'key2' : 'value1'}

    - set_fact :
        string_list2 : [5,6,7,8]
    - set_fact :
        string_dictionary2 : {'key10' : 'value10', 'key20' : 'value10'}
    - set_fact :
        string_list_m : '{{ string_list + string_list2 }}'
    - set_fact :
        string_dictionary_m : '{{ string_dictionary | ansible.builtin.combine( string_dictionary2)  }}'


    - name : Display changed variables
      debug :
        msg :
          - list   is     {{ string_list }}
          - dictionary is {{ string_dictionary }}
          - list2   is     {{ string_list2 }}
          - dictionary2 is {{ string_dictionary2 }}
          - list_merged   is     {{ string_list_m }}
          - dictionary_merged is {{ string_dictionary_m }}


    - set_fact :
        list_keys : '{{ string_dictionary.keys()  }}' 
        list_values :  '{{ string_dictionary.values()  }}'

    - name : Display changed variables
      debug :
        msg :
          - dictionary is {{ string_dictionary }}
          - list_keys  is     {{ list_keys }}
          - list_values  is     {{ list_values }}
 

    - set_fact:
       dict_from_lists : '{{ list_keys | zip(list_values) }}'
    - name : Display changed variables
      debug :
        msg :
          - dict_from_lists is {{  dict_from_lists }}

    - set_fact:
        list1 :
         - name : Sam
           children : 1
        list2 :
          - name : Billy
            children : 5
    - set_fact :	    
        list_m : \"{{ list1 | community.general.lists_mergeby(list2, 'name') }}\"

    - name : Display changed variables
      debug :
        msg :
          - list1 is {{ list1 }}
          - list2 is {{ list2 }}
          - list_m is {{ list_m }}


" > /etc/ansible/play_with_variables.yml


```

* Run the playlist
```shell
cd /etc/ansible
ansible-playbook play_with_variables.yml
```

* Output should be something like

```shell


PLAY [Play with variables.] ****************************************************

TASK [Gathering Facts] *********************************************************
ok: [192.168.1.7]

TASK [Display and change variables] ********************************************
ok: [192.168.1.7] => {
    "msg": [
        "string is      Just a string ",
        "list   is     ['apple', 'banana', 'carrot']",
        "dictionary is {'person1': 'Mark', 'person2': 'John', 'person3': 'Heidi'}"
    ]
}

TASK [Change string] ***********************************************************
ok: [192.168.1.7]

TASK [Append list] *************************************************************
ok: [192.168.1.7]

TASK [Append key] **************************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "string is     Changed string",
        "list   is     ['apple', 'banana', 'carrot', 'Added string']",
        "dictionary is {'person1': 'Mark', 'person2': 'John', 'person3': 'Heidi', 'person4': 'Collin'}"
    ]
}

TASK [Change string] ***********************************************************
ok: [192.168.1.7]

TASK [Change element in list] **************************************************
changed: [192.168.1.7]

TASK [reset list] **************************************************************
ok: [192.168.1.7]

TASK [Change a value of a key] *************************************************
changed: [192.168.1.7]

TASK [reset dictionary] ********************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "string is     Changed string 2",
        "list   is     ['changed element', 'changed element 2', 'carrot', 'Added string']",
        "dictionary is {'person1': 'changed person', 'person2': 'John', 'person3': 'Heidi', 'person4': 'Collin'}"
    ]
}

TASK [backup everything] *******************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set the variables to empty] **********************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "string is     ",
        "list   is     []",
        "dictionary is {}"
    ]
}

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "list   is     [1, 2, 3, 4]",
        "dictionary is {'key1': 'value1', 'key2': 'value1'}",
        "list2   is     [5, 6, 7, 8]",
        "dictionary2 is {'key10': 'value10', 'key20': 'value10'}",
        "list_merged   is     [1, 2, 3, 4, 5, 6, 7, 8]",
        "dictionary_merged is {'key1': 'value1', 'key2': 'value1', 'key10': 'value10', 'key20': 'value10'}"
    ]
}

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "dictionary is {'key1': 'value1', 'key2': 'value1'}",
        "list_keys  is     ['key1', 'key2']",
        "list_values  is     ['value1', 'value1']"
    ]
}

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "dict_from_lists is [['key1', 'value1'], ['key2', 'value1']]"
    ]
}

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [set_fact] ****************************************************************
ok: [192.168.1.7]

TASK [Display changed variables] ***********************************************
ok: [192.168.1.7] => {
    "msg": [
        "list1 is [{'name': 'Sam', 'children': 1}]",
        "list2 is [{'name': 'Billy', 'children': 5}]",
        "list_m is [{'name': 'Billy', 'children': 5}, {'name': 'Sam', 'children': 1}]"
    ]
}

PLAY RECAP *********************************************************************
192.168.1.7                : ok=33   changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   



```