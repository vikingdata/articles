--------
title: Linux LVM

--------

# Linux LVM

*by Mark Nielsen*  
* Original Copyright September 2024*


---

1. [Links](#links)
2. [Install Linux on  VirtualBox](#install)
3. [Add two disks to Linux in VirtualBox](#disks)
4. [Add lvm partition](#lvm)
5. [Add 2nd disk and extend lv1 partition](#add)

* * *

<a name=links></a>Links
-----

* * *
<a name=install></a>Install Linux on  VirtualBox
-----

It is beyond the scope of this article to show how to install Linux on VirtualBox. I have other articles
and I list other articles
* https://github.com/vikingdata/articles/blob/main/databases/mysql/Multiple_MySQL_virtualbox.md
* https://www.instructables.com/How-to-install-Linux-on-your-Windows/
* https://www.howtogeek.com/796988/how-to-install-linux-in-virtualbox/

* * *
<a name=disks></a>Add two disks to Linux in VirtualBox
-----
* [How to Add Disk Storage to Oracle Virtual Box on Linux](https://www.tutorialspoint.com/how-to-add-disk-storage-to-oracle-virtual-box-on-linux#:~:text=Adding%20the%20Virtual%20Drive,a%20new%20hard%20disk%20drive.)


* Shutdown Linux in Virtual Box
* Click Settings
* In the left menu, click Storage
* Next to "Sata Controller", you will see a circle and a square. When You hover over the square, it should say "Add Hard disk". Click on that.
* Click on "Create new Disk"
   * Select VDI
   * Click Next
   * Choose the amount of space.
   * Click "Choose"
* Click on "ok" at the Settings Menu.
* Repeat steps and add another disk. 

Create LVM partition
* Start Linux and login as root
* Type "lsblk" and you should be sdb and sdc
```
root@pc2:~# lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0     4K  1 loop /snap/bare/5
loop1    7:1    0  63.9M  1 loop /snap/core20/2105
loop2    7:2    0  74.2M  1 loop /snap/core22/1122
loop3    7:3    0 262.5M  1 loop /snap/firefox/3779
loop4    7:4    0   497M  1 loop /snap/gnome-42-2204/141
loop5    7:5    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop6    7:6    0  40.4M  1 loop /snap/snapd/20671
loop7    7:7    0   452K  1 loop /snap/snapd-desktop-integration/83
loop8    7:8    0  13.5M  1 loop /snap/ubuntu-mate-welcome/726
loop9    7:9    0    16K  1 loop /snap/software-boutique/57
sda      8:0    0  57.7G  0 disk
├─sda1   8:1    0     1M  0 part
├─sda2   8:2    0   513M  0 part /boot/efi
└─sda3   8:3    0  57.2G  0 part /var/snap/firefox/common/host-hunspell
                                 /
sdb      8:16   0    25G  0 disk
sdc      8:32   0    25G  0 disk
sr0     11:0    1  1024M  0 rom
```

* * *
<a name=lvm></a>Add lvm partition
-----
* Install lvm: apt lvm2 install

```
sudo bash

# Intialize disk
  # NOTE: your disks may not be /dev/sdb --- check lsblk
pvcreate /dev/sdb

  # Create volume group
vgcreate volume_group1 /dev/sdb

  # Create lvm partition from volume group
  # I have 25 gigs available So I will add 20 gig
lvcreate -L20G -n lv1 volume_group1

  # Make sure mount point exists
mkdir -p /mnt/lv1

  # Format partition
mkfs -Vt ext4 /dev/volume_group1/lv1

  # Mount partition
echo "" >> /etc/fstab
echo "/dev/volume_group1/lv1 /mnt/lv1  ext4 defaults    0 1" >> /etc/fstab
mount -a


```

* * *
<a name=add></a>Add 2nd disk and extend lv1 partition
-----

```
sudo bash
pvcreate /dev/sdc

  # Display pv display
pvdisplay |grep dev
  PV Name               /dev/sdb
  "/dev/sdc" is a new physical volume of "25.00 GiB"
  PV Name               /dev/sdc

  # Get size of current volume group
vgdisplay | grep "VG Size"
  VG Size               <25.00 GiB

  # Add another disk, 25 gig
vgextend volume_group1 /dev/sdc

  # Display size again
vgdisplay | grep "VG Size"
  VG Size               49.99 GiB

  # Display lv1 Size
lvdisplay| egrep -i "Path|Size"
  LV Path                /dev/volume_group1/lv1
  LV Size                20.00 GiB

  # Display df
df -h | grep lv1
   /dev/mapper/volume_group1-lv1   20G   24K   19G   1% /mnt/lv1

  # Increase size 20 gig
lvextend -L+20G /dev/volume_group1/lv1

  # Dispplay lvm size
lvdisplay| egrep -i "Path|Size"
  LV Path                /dev/volume_group1/lv1
  LV Size                40.00 GiB

  # Display mount again
df -h | grep lv1
  /dev/mapper/volume_group1-lv1   20G   24K   19G   1% /mnt/lv1

  # We see the partition has been extended, but the mount
  # is the same.
  # resize the mount
  # Older kernels required umounting the partition, resize, and them mount
resize2fs /dev/volume_group1/lv1

  # Check the mounted size
df -h | grep lv1
  /dev/mapper/volume_group1-lv1   40G   24K   38G   1% /mnt/lv1
  

```
