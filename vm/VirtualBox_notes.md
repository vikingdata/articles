title :  VirtualBox notes
author : Mark Nielsen
copyright : June 2025
---

VirtualBox Notes
==============================

_**by Mark Nielsen
Original Copyright June 2025**_


* List current configured vms : ``` VBoxManage list vms``` 
* List running vms: ``` VBoxManage list runningvms ```
* See if a configured vm is running: ```
vmName='BaseImage'
status=`VBoxManage showvminfo $vmName | grep -i ^State | sed -e "s/  */ /" | cut -d " " -f 2-`
echo "status of $vnName: $status
```

* Get pid of virtual box
    * Window : ``` VBPID=`ps -W | grep -i virtualbox.exe | sed -e 's/  */ /g' | cut -d ' ' -f 5`  ```
    * cygwin in Windows : ``` VBPID=`ps -W | grep -i VirtualBox/VirtualBox | sed -e 's/  */ /g' | cut -d ' ' -f 5` ```
    * Linux TODO
