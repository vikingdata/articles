

* List current configured vms
    * VBoxManage list vms 
* See if a vm in active
    * Z
* Add vm
* Get pid of virtual box
    * Window : ``` VBPID=`ps -W | grep -i virtualbox.exe | sed -e 's/  */ /g' | cut -d ' ' -f 5` ```
    * cygwin in Windows : ``` VBPID=`ps -W | grep -i VirtualBox/VirtualBox | sed -e 's/  */ /g' | cut -d ' ' -f 5` ```
    * Linux TODO

* Configuring VirtualBox
    * See if natnetwork is added:
        * ``` ncount=`VBoxManage natnetwork list NatNetwork | grep ^Name | sed -e 's/  */ /g' | sed -e "s/[\n\r]//" | cut  -d ' ' -f2 | grep ^NatNetwork$ | wc -l`  ```
    * Add natnetwork : VBoxManage natnetwork add --netname NatNetwork --network  "10.0.2.0/24" --enable --dhcp on

VBPID=`ps -W | grep -i virtualbox.exe | sed -e 's/  */ /g' | cut -d ' ' -f 5`
if [  "$VBPID" != '' ] ; then
  echo "restarting virtualbox in cygwin  : $VBPID"
    taskkill /PID $VBPID
      /cygdrive/c/Program\ Files/Oracle/VirtualBox/VirtualBox.exe &
      fi

VBPID=`ps -W | grep -i VirtualBox/VirtualBox | sed -e 's/  */ /g' | cut -d ' ' -f 5`
