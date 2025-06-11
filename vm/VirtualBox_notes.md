title :  VirtualBox notes
author : Mark Nielsen
copyright : June 2025
---

VirtualBox Notes
==============================

_**by Mark Nielsen
Original Copyright June 2025**_


* List current configured vms
    * VBoxManage list vms 
* List running vms
    * ```VBoxManage list runningvms```
* See if a configured vm is running
    * ``` vmName='BaseImage'
status=`VBoxManage showvminfo $vmName | grep -i ^State | sed -e "s/  */ /" | cut -d " " -f 2-`
echo "status of $vnName: $status```

* Get pid of virtual box
    * Window : ``` VBPID=`ps -W | grep -i virtualbox.exe | sed -e 's/  */ /g' | cut -d ' ' -f 5` ```
    * cygwin in Windows : ``` VBPID=`ps -W | grep -i VirtualBox/VirtualBox | sed -e 's/  */ /g' | cut -d ' ' -f 5` ```
    * Linux TODO

* Configuring VirtualBox
    * See if natnetwork is added:
        * ``` ncount=`VBoxManage natnetwork list NatNetwork | grep ^Name | sed -e 's/  */ /g' | sed -e "s/[\n\r]//" | cut  -d ' ' -f2 | grep ^NatNetwork$ | wc -l`  ```
    * Add natnetwork :
        * ```VBoxManage natnetwork add --netname NatNetwork --network  "10.0.2.0/24" --enable --dhcp on ```
    * [Add a server](https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/vm/Linux_db_vm_part1_files/create_base_vm.txt) ```
export ISO=/vb/shared/ubuntu-22.04.5-desktop-amd64.iso
mkdir -p /cygdrive/c/vb/shared
if [ ! -f "/cygdrive/c/vb/shared/ubuntu-22.04.5-desktop-amd64.iso" ]; then
  wget https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso -O /cygdrive/c/vb/shared/ubuntu-22.04.5-desktop-amd64.iso
fi

VBoxManage createvm --name "BaseImage" --ostype Ubuntu_64 --register
VBoxManage createhd --size 20480 --variant Standard --filename=$VDI
sleep 1

VBoxManage storagectl "BaseImage" --name "SATA Controller" --add sata --bootable on
sleep 1

VBoxManage storageattach "BaseImage" --storagectl "SATA Controller" \
  --port 0 --device 0 --type hdd --medium $VDI
sleep 1

VBoxManage storagectl "BaseImage" --name "IDE Controller" --add ide

VBoxManage storageattach "BaseImage" --storagectl "SATA Controller" \
  --port 0 --device 0 --type hdd --medium $VDI
sleep 1

VBoxManage storagectl "BaseImage" --name "IDE Controller" --add ide

sleep 1
VBoxManage storageattach "BaseImage" --storagectl "IDE Controller" \
    --port 0 --device 0 --type dvddrive --medium $GUEST

sleep 1
VBoxManage storagectl "BaseImage" --name "IDE Controller" --add ide
sleep 1
VBoxManage storageattach "BaseImage" --storagectl "IDE Controller" \
  --port 0 --device 0 --type dvddrive --medium $GUEST

 ### This doesn't set up the network right
 VBoxManage modifyvm BaseImage --nic1=natnetwork

  # shared folder
    # --hostpath "/vb" is relative to c:\shared
VBoxManage sharedfolder add BaseImage --name "vb" --hostpath "/vb" --auto-mount-point=/vb --automount

  # drag and drop
VBoxManage modifyvm BaseImage --clipboard-mode=bidirectional --drag-and-drop=bidirectional

vboxmanage list vms

VBoxManage unattended install "BaseImage" --iso=$ISO \
  --user=mark --password=mark --hostname=BaseImage.local \
    --locale=en_US --country=US  --start-vm=gui --install-additions
    

```

