title : Cygwin in Windows commands
author : Mark Nielsen
copyright : May 2025
---


Cygwin in Windows commands
==============================

_**by Mark Nielsen
Original Copyright May 2025 2024**_

Yes, cygwin is not really a vm but an emulation. 

* [Links](#links)
* [General Commands](#g)

* * *
<a name=links></a>Links
-----
* [cygwin cheatsheet](https://www.voxforge.org/home/docs/cygwin-cheat-sheet)
* [cygwin cheatsheet](https://pbgworks.org/sites/pbgworks.org/files/LinuxCheatSheet2_0.pdf)
* [cygwin users guide](https://cygwin.com/cygwin-ug-net/cygwin-ug-net.pdf)

* * *
<a name=g></a>General Commands
-----
* Things to remember
    * Cygwin has an issue installing rpms, debian packages, etc.
        * Install a cygwin packages.
	* Some things like Python modules can be installed with "pip". If you have a cygwin package that install
	packages or modules, it should work. 
    * Cygwin is not a vm but an emulation.
    * Cygwin can run Windows binaries as it is a shell under windows. However...
        * "\" as in "C:\" is often needed to be converted to "/" as in "c:/"
	* Spaces need a "\" in front of them.
        * ex: "C:\Program Files" becomes "c:/Program\ Files"

* List Virtualbox process, kill it, restart it
```
   ## List out virtual box processes
ps -W | grep -i vir
   # Output  
   #   113948       0       0      48412  ?              0 01:57:53 C:\Program Files\Oracle\VirtualBox\VirtualBox.exe

   ## Kill the virtualbox process
taskkill /PID 48412
   # Output
   # SUCCESS: Sent termination signal to the process with PID 48412.

   # restart virtualbox
cygstart C:/Program\ Files/Oracle/VirtualBox/VirtualBox.exe

   # Or

VBPID=`ps -W | grep -i virtualbox.exe | sed -e 's/  */ /g' | cut -d ' ' -f 5`
echo "my vb pid is $VBPID"
echo "attempting to kill Kill vbpid: $VBPID"
if [  "$VBPID" != '' ] ; then
  taskkill /PID $VBPID
fi

/cygdrive/c/Program\ Files/Oracle/VirtualBox/VirtualBox.exe

```