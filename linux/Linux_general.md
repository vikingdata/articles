'-------
title: Linux general tips

--------

# Linux General Tips

*by Mark Nielsen*  
* Original Copyright March 2024*


---

1. [Links](#links)
2. [Disk Performance](#disk)
3. [password management](#p)
4. [Add user with password](#a)
5. [Find and remove packages](#pa)
6. [CheatSheets](#c)
7. [ssh keys](#s)
8. [Disk Commands](#d)
10. [Monitor Commands](#m)
11. [List Services](#services)
12. [cygwin font size](#cygwin)
13. [Parse text files](#parse)
14. [remove binary fromn text file](#removebin)
15. [Adding swapspace temporarily](#swap)
16. [Deleted files still used.](#un)
17. [Find newest files first](#find2)
18. [Manipulate one line at a time in bash](#line)
19. [awk](#a)
20. [ssh keys -- scan](#ssh)
21. [sort](#sort)
22. [wget](#wget)
23. [misc](#misc)

* * *

<a name=links></a>Links
-----
* [Unix Commands Reference](https://www.tutorialspoint.com/unix_commands/alternatives.htm)
    * Good for learning most Linux commands
* [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/x17837.html)
* [Introducing pass](https://www.passwordstore.org/)
* [https://wiki.archlinux.org/title/Pass](https://wiki.archlinux.org/title/Pass)
* Tips and Tricks
    * (Top 35 Linux Console Tips and Tricks From Practical Experience)[https://hackernoon.com/top-35-linux-console-tips-and-tricks-from-practical-experience]
    * [6 Linux Terminal Tips and Tricks to Get Things Done Quickl](https://www.makeuseof.com/linux-terminal-tips-and-tricks/)
    * (10 Linux Terminal Tips and Tricks to Enhance Your Workflow)[https://www.learnlinux.tv/10-linux-terminal-tips-and-tricks-to-enhance-your-workflow/]
        * I use screen instead of tmux

* [Few Linux Commands](https://www.linkedin.com/posts/tuba-nimrah-13574828a_linux-networking-commands-activity-7230523794300264448-ndJp?utm_source=combined_share_message&utm_medium=member_desktop)
---
* * *
<a name=disk></a>Disk Performance
-----

* Manually
    * dd if=/dev/zero of=10gig.bin bs=10M count=1024; rm 10gig.bin"
        * On each partition
    * iostat -m 10
        * get data on disk activity every 10 seconds
    * Use Prometheus, Grafana, New Relic, or Solar Winds to graph the disk activity.
    * Make a script once a day write 10 gigs at a low point in activity and feed
    it to your graphing or in tabular format. Make are report on ones that are too
    slow. 



* * *
<a name=playbook></a>Storing passwords
-----

Goal is to use an encrypted file on Google Drive. I have been very very frustrated
with storing passwords on Google Drive. Google has its own password store but it is
not unlimited. Many programs cost money. The free Linux program "pass" looked
promising, but I could never get it to work with gpg properly. I gave up. Why? It
should work without hassle if I recommend it to others. Enter ButterCup, free
GPL software for Windows, Linux, Mac, etc. 

* setup and install [Google Drive](https://support.google.com/drive/answer/2424384?hl=en&co=GENIE.Platform%3DDesktop)
    * Set on drive G: if windows.
        * If using Cygwin and Windows
            * Use /cygdrive/c/GoogleDrive/
	    * which corresponds to c:\GoogleDrive in Windows
    * If Linux, Unix, or Mac, mount the drive wherever,

* Install [Butttercup]https://buttercup.pw/)
* In ButterCup
    * choose vault
    * Then file
    * Save the file in your Google Drive directory. 
    * Add a very good password for the vault.
* Now you can make groups, add customer entries to groups, and save passwords.
    * Don't forget to name the custom field or it won't let you save. 
* If you close the program and copy it to another computer, you can open the
vaults there with ButterCup.

* * *
<a name=a></a>Add user with password
-----

```
sudo bash # or su  -l root 

useradd test1 --shell /bin/bash --create-home 
echo "test1:test1_password" | chpasswd

# or if you want a specified id
#   useradd test1 --shell /bin/bash --create-home --uid 5000

```

Now test Login with username: test1 and password : test1_password
```
su -l test
```

If you want to remove and test again.

```
userdel -r test1

```

If you want to remove a password
```
passwd -d test1

```

To lock test1's password
```
passwd -l test1

```

* * *
<a name=pa></a>Find and remove packages
-----

To remove all mongodb packages from Ubuntu

```
apt list --installed | grep mongo | cut -d '/' -f1 | tr '\n' ',' > /tmp/remove_packages.txt
cat /tmp/remove_packages.txt| apt-get purge --auto-remove -y
```

* * *
<a name=c></a>Cheatsheets
-----
* MongoDB
    * This is a very good one [A Performance Cheat Sheet for MongoDB](https://severalnines.com/blog/performance-cheat-sheet-mongodb/)
    * AWS https://mongodb-devhub-cms.s3.us-west-1.amazonaws.com/Mongo_DB_Shell_Cheat_Sheet_1a0e3aa962.pdf
    * https://cheatography.com/ovi-mihai/cheat-sheets/mongodb/
    * https://www.mongodb.com/developer/products/mongodb/cheat-sheet/
    * https://gist.github.com/bradtraversy/f407d642bdc3b31681bc7e56d95485b6
    * https://www.interviewbit.com/mongodb-cheat-sheet/
* TODO
    * Linux
    * MySQL
    * GIT
    * snowflake
    * Python

* * *
<a name=s></a>ssh keys 
-----

* -N '' means empty password
* -f is the full path to create private key file. Another public will be named the same and appended with ".pub". 

```
   # In this example, we don't use the default diretory of "~/.ssh".
mkdir ~/ssh_keys

   # We will use an empty password
ssh-keygen -f ~/ssh_keys/test1_rsa -N ''


  # Generate random passwords. Suggestion, have script store them.
mypassphrase=`openssl rand -base64 20`
ssh-keygen -f ~/ssh_keys/pass1_rsa -N "$mypassphrase"
echo "My passphrase is $mypassphrase"

```

To copy the ssh key to other host

* https://www.ssh.com/academy/ssh/copy-id

```
ssh-copy-id -i ~/.ssh/mykey user@host

  # test with login

ssh  user@host "echo 'ssh works'"

```

* * *
<a name=d></a>Disk  commands
-----
* TODO
    * fstab
    * lvm, adding a partition. and other commands -- show in virtualbox
* lsblk -- show you the partitions available
* blkid -- shows you the uuid to can put in /etc/fstab replacing the device
```
 sudo lsblk
[sudo] password for mark:
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0 931.5G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
└─sda2   8:2    0   931G  0 part /

```
* blkid -- shows you the uuid to can put in /etc/fstab replacing the device
```
sudo blkid

/dev/sda2: UUID="0a70c609-712e-4849-8c15-ca5972114471" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="4acad244-ebdb-47d7-bfa9-b71493398ee7"
/dev/sda1: UUID="1093-3218" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="EFI System Partition" PARTUUID="ec3cbda4-bde2-411e-9c9d-a44450148230"

```


* * *
<a name=m></a>Monitor commands
-----

### First run Top
* https://www.geeksforgeeks.org/top-command-in-linux-with-examples/
* press 1
   * this tells you the activity per cpu
   * The average is sum of the percentage divided by the number of cpus
* Look at load
    * To estimate load, divide load by the no of cpus. That number you want below 1.
	* This doesn't always work out to be true.
    * Organize top by memory, cpu, and swap

### Free
* https://phoenixnap.com/kb/free-linux-command
* Run free -h
    * Total - Used is the amount of memory that is free or used by file cache.
    * Total - Used is the true amount of memory free.
    * High swap can be bad. It may be because something is reading a lot of files.
    * Check on processes using swap in top.
        * NOTE: The last used things get put into swap. What is causing high usage of swap may not
	be causing high swap.

### Iostat
* Run iostat
    * https://www.geeksforgeeks.org/iostat-command-in-linux-with-examples/
    * iostat - 5
    * Look at the amount of writes and reads.
* You can do other options as well.
* On another exact system, write a 10 gig file, divide by 10 to get the Gig/sec written.
Use this as a maximum write/sec and compare to iostat.
        * rm -rf 1gig.bin; time dd if=/dev/random of=1gig.bin bs=100M count=10;ls -al 1gig.bin

### Count all cpus.
```
cat /proc/cpuinfo  | egrep -i "processor|cpu cores"

echo "cpus", `cat /proc/cpuinfo  | egrep -i "processor" | cut -d ':' -f2 | wc -l`

echo "cores", `cat /proc/cpuinfo  | egrep -i "cpu core" | cut -d ':' -f2 | paste -sd +  | bc`


```

### diskspace
* Find files larger than 100 megs on system
* https://www.geeksforgeeks.org/find-command-in-linux-with-examples/

```#!/usr/bash

find_files="find / -size +1G -type f -printf '%s_%p\n'"
#find_files='find . -size +1M'

for l in `$find_files 2>/dev/null  |sort -nr `; do
    size=`echo $l | cut -d '_' -f 1`
    f=`echo $l | cut -d '_' -f 2`
    sizeG=`echo "scale=2; $size/1000000000" | bc`
    echo $"$sizeG""G $size $f"
done

find_files='find / -size +100M -size -1000M -type f -printf %s_%p\n'
for l in `$find_files 2>/dev/null  |sort -nr `; do
    size=`echo $l | cut -d '_' -f 1`
    f=`echo $l | cut -d '_' -f 2`
    sizeM=`echo "scale=2; $size/1000000" | bc `
    echo $"$sizeM""M $size $f"

done

   # Or just list out files by size in reverse order
find .  -type f -printf '%s %p\n'| sort -nr -k 1,1

````

### Organize TOP example with SWAP
* TODO: activity, activity per process
* What is using swap
   * article: https://my.f5.com/manage/s/article/K40027012
   * [Swap Memory: What It Is, How It Works, and How to Manage It](https://phoenixnap.com/kb/swap-memory#:~:text=Swap%20memory%2C%20also%20known%20as,preventing%20system%20slowdowns%20or%20crashes.)
   * Start top
       * press f
       * Go down to Swap
           * Click right arrow to select it
           * Move with up arrow to the first field and press enter.
       * Now we need to sort
       * press s
           * highlight the swap field
       * press Esc
       * Now it should be sorted by swap

### Network
* Speed of ethernet card
   * First do : ifconfig
   * foreach interface
       * sudo ethtool eth0 | grep Speed
       * cat /sys/class/net/eth0/speed
* activity
    * install sar
     sar -n DEV  1

### lsof
* https://phoenixnap.com/kb/linux-check-open-ports
* List open ports: sudo lsof -nP -iTCP -sTCP:LISTEN
* All files opened on root or "/": lsof /
* Show all open connections : lsof -i
* Show all open files by mysqld: lsof -c mysqld


### SAR
* https://www.accuwebhosting.com/blog/how-to-install-and-use-sar-on-linux
* https://www.linode.com/docs/guides/how-to-use-sar/
* https://docs.oracle.com/cd/E19455-01/805-7229/spmonitor-15391/index.html

For all these examples, it will gather stats for 2 seconds 5 times. 

| Topic | command |
|---  | --- |
| Network | sar -n DEV  2 5 |
| swap | sar -S 2 5 |
| disk | sar -d 2 5 3 |
| memory | sar -r 2 5 |
| cpu | sar -u 2 5 |


* * *
<a name=services></a>List services
---------------
* https://bitlaunch.io/blog/how-to-list-services-in-linux-using-the-command-line/
* ls /lib/systemd/system/ | grep ssh




* * *
<a name=cygwin></a>Cygwin font size
---------------
Not really Linux, but to increase the font size in Windows. cygwin is a Linux emulator for Widnows.

* Make a shortcut desktop
* Enter : C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico   -o FontSize=18
    * Note: Change C:\cygwin64\bin\mintty.exe to whever mintty is installed. 

* * *
<a name=parse></a>Parse text files
---------------
* Links
    * https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/
    * https://gist.github.com/r2k0/1152840
    * https://www.gnu.org/software/sed/manual/sed.html
    * https://www.tecmint.com/linux-sed-command-tips-tricks/
    * https://www.geeksforgeeks.org/cut-command-linux-examples/
    * https://gist.github.com/andfaulkner/48f3784a0e1d984cb76f
    * https://www.tutorialspoint.com/unix_commands/cut.htm


* Convert all whitespace to single space
   * sed 's/\s\s*/ /g'
* Remove beginning whitespace
   * sed 's/^\s*//g'
* Get 3rd and fourth field
   * cut -d ' ' -f 3,4
* Test

```
echo "		a b c d 1 2" > example.txt 
echo "d   e f   g 3     4" >> example.txt 


sed 's/\s\s*/ /g' example.txt

# output
 a b c d 1 2
d e f g 3 4

sed 's/\s\s*/ /g' example.txt | sed 's/^\s*//g'

# output
a b c d 1 2
d e f g 3 4
 

sed 's/\s\s*/ /g' example.txt | sed 's/^\s*//g' | cut -d ' ' -f 3,4

#output
c d
f g
```

* * *
<a name=removebin></a>Remove binary data from text file
---------------

* Using cat 
```
cat -v FILE1 > FILE2
```
* Using strings
```
strings FILE1 > FILE2

```

* What are the equiv tr, sed, and python commands? Note with tr, :print: does not include newlines.


* * *
<a name=swap></a>Adding swapspace temporarily. 
---------------

* Check diskspace with : df -h /
```
mark@mysql1:~$ df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3        24G   17G  5.8G  75% /
```
* 24 gigs of space, adding 8 gig swapfile
```

export SWAPFILE='/swapfile'

# swapoff -a
dd if=/dev/zero of=$SWAPFILE bs=1024 count=8048576
mkswap $SWAPFILE
chmod 600 $SWAPFILE
swapon -a $SWAPFILE
swapon -s
free -h 

# TO add to /etc/fstab
echo "$SWAPFILE    none    swap    sw    0    0" >> /etc/fstab



```

* * *
<a name=un></a>Deleted files still used.
---------------
Sometime when you delete a file if it is still in use, diskspace is not given back.
You need to tell if there are files deleted, but have not given diskspace back. 

* Prepare
```
sudo bash

dd if=/dev/zero of=/tmp/junk1 bs=1M count=10
dd if=/dev/zero of=/tmp/junk2 bs=1M count=102
dd if=/dev/zero of=/tmp/junk3 bs=1M count=1024
dd if=/dev/zero of=/tmp/junk4 bs=1M count=2024

```
* Open 4 more terminals and "more" each file
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Terminal 1
```
more /tmp/junk1
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Terminal 2
```
more /tmp/junk1
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Terminal 3
```
more /tmp/junk1
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Terminal 4
```
more /tmp/junk1
```
* Go back to the original terminal. You shoud have 4 open files. Delete and then list deleted files still being used.

```
rm -vf /tmp/junk*

  # List all deleted files
ls -al /proc/*/fd | grep -i deleted

  # Reduce it to just the junk files
ls -al /proc/*/fd | grep -i deleted | grep junk

  # List by size desc
  # NOTE: lsof is hard to parse correctly.
  # You might need to add more columns in awk : $1,$2,$3 etc
  # $7 "should be" the size you want to sort by
lsof | grep REG  | awk '{ print $7,$9,$10,$1 }' | sort -n -r -k1,1  | egrep "deleted"

  # REduce it to just junk
lsof | grep REG | awk '{ print $7,$9,$10,$1 }' | egrep -i "junk1|junk2|junk3|junk4"  |sort -n -r -k1,1  | egrep "deleted"

  # megabytes
  lsof | grep REG | awk '{ print int($7/1048576)"M",$9,$10,$1 }' | egrep -i "junk1|junk2|junk3|junk4"  |sort -n -r -k1,1  | egrep "deleted"

  # gigabtyes

   lsof | grep REG | awk '{ print int($7/1048576000)"G",$9,$10,$1 }' | egrep -i "junk1|junk2|junk3|junk4"  |sort -n -r -k1,1  | egrep "deleted"

  # Get total size of all deleted files in megabytes

lsof | grep REG | egrep "deleted" | awk '{ print int($7) }' | sort -n -r -k1,1   > /tmp/all_files
lsof | grep REG | egrep "deleted" | grep -i "junk" | awk '{ print int($7) }' |sort -n -r -k1,1   > /tmp/junk_files

  # sum of all sizes
paste -sd+ /tmp/all_files | bc |  awk '{ print int($1/1048576)"M"}'
  # sum of junk files
paste -sd+ /tmp/junk_files | bc |  awk '{ print int($1/1048576)"M"}'

```

Output 
```
root@mysql1:~# ls -al /proc/*/fd | grep -i deleted
lrwx------ 1 mark mark 64 Aug 24 17:35 25 -> /memfd:pipewire-memfd (deleted)
lrwx------ 1 mark mark 64 Aug 24 17:35 28 -> /memfd:pipewire-memfd (deleted)
lrwx------ 1 mark mark 64 Aug 24 17:35 6 -> /memfd:pulseaudio (deleted)
l-wx------ 1 root  root  64 Aug 24 17:35 1 -> /var/log/mysqld.log (deleted)
lrwx------ 1 root  root  64 Aug 24 17:35 14 -> /tmp/ibsSgqxF (deleted)
lrwx------ 1 root  root  64 Aug 24 17:35 15 -> /tmp/ibqUnxfE (deleted)
lrwx------ 1 root  root  64 Aug 24 17:35 16 -> /tmp/ibgsBzx2 (deleted)
lrwx------ 1 root  root  64 Aug 24 17:35 17 -> /tmp/ibpAD4kl (deleted)
l-wx------ 1 root  root  64 Aug 24 17:35 2 -> /var/log/mysqld.log (deleted)
lrwx------ 1 root  root  64 Aug 24 17:35 21 -> /tmp/ib5Mw39d (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk1 (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk2 (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk3 (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk4 (deleted)

root@mysql1:~# ls -al /proc/*/fd | grep -i deleted | grep junk
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk1 (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk2 (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk3 (deleted)
lr-x------ 1 root root 64 Aug 24 17:41 4 -> /tmp/junk4 (deleted)

root@mysql1:~# lsof | grep REG  | awk '{ print $7,$9,$10,$1 }' | sort -n -r -k1,1  | egrep "deleted"
2122317824 /tmp/junk4 (deleted) more
1073741824 /tmp/junk3 (deleted) more
106954752 /tmp/junk2 (deleted) more
67108864 /memfd:pulseaudio (deleted) pulseaudi
10485760 /tmp/junk1 (deleted) more
11361 /var/log/mysqld.log (deleted) mysqld
11361 /var/log/mysqld.log (deleted) mysqld
2312 /memfd:pipewire-memfd (deleted) pipewire
2312 /memfd:pipewire-memfd (deleted) pipewire
0 /tmp/ibsSgqxF (deleted) mysqld
0 /tmp/ibqUnxfE (deleted) mysqld
0 /tmp/ibpAD4kl (deleted) mysqld
0 /tmp/ibgsBzx2 (deleted) mysqld
0 /tmp/ib5Mw39d (deleted) mysqld

root@mysql1:~# lsof | grep REG | awk '{ print $7,$9,$10,$1 }' | egrep -i "junk1|junk2|junk3|junk4"  |sort -n -r -k1,1  | egrep "deleted"
2122317824 /tmp/junk4 (deleted) more
1073741824 /tmp/junk3 (deleted) more
106954752 /tmp/junk2 (deleted) more
10485760 /tmp/junk1 (deleted) more

root@mysql1:~# lsof | grep REG | awk '{ print int($7/(1024*1024))"M",$9,$10,$1 }' | egrep -i "junk1|junk2|junk3|junk4"  |sort -n -r -k1,1  | egrep "deleted"
2024M /tmp/junk4 (deleted) more
1024M /tmp/junk3 (deleted) more
102M /tmp/junk2 (deleted) more
10M /tmp/junk1 (deleted) more

root@mysql1:~# lsof | grep REG | awk '{ print int($7/1048576000)"G",$9,$10,$1 }' | egrep -i "junk1|junk2|junk3|junk4"  |sort -n -r -k1,1  | egrep "deleted"
2G /tmp/junk4 (deleted) more
1G /tmp/junk3 (deleted) more
0G /tmp/junk2 (deleted) more
0G /tmp/junk1 (deleted) more

root@mysql1:~# paste -sd+ /tmp/all_files | bc |  awk '{ print int($1/1048576)"M"}'
3224M
root@mysql1:~# paste -sd+ /tmp/junk_files | bc |  awk '{ print int($1/1048576)"M"}'
3160M


```

* * *
<a name=servuce></a>Managing services in Linux.
---------------
* Links
    * https://bash.cyberciti.biz/guide/Service_command
    * https://www.baeldung.com/linux/differences-systemctl-service
    * https://www.linode.com/docs/guides/introduction-to-systemctl/
    
* See files :
```
systemctl show mysql.service | grep Path
FragmentPath=/run/systemd/generator.late/mysql.service
SourcePath=/etc/init.d/mysql
```
* See if mysql has start files
```
root@mysql1:~/install# service --status-all |grep -i mysql
 [ + ]  mysql
 [ + ]  mysqlrouter
````
* Locate service files
```
root@mysql1:~/install# locate mysql.service
/var/lib/systemd/deb-systemd-helper-enabled/mysql.service.dsh-also
/var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/mysql.service
/var/lib/systemd/deb-systemd-helper-masked/mysql.service
````

* * *
<a name=find2></a>Find by date or size
---------------

* https://www.redhat.com/en/blog/linux-find-command
* https://phoenixnap.com/kb/guide-linux-find-command


```
  # List out files by size on current directory
find .  -type f -printf '%s %p\n'| sort -nr -k 1,1

  # List out by date on current directory
find .  -type f -printf '%TY%Td%Tm%TH%TM%.2TS %TY-%Td-%Tm %TH:%TM:%.2TS%p\n'| sort -nr -k 1,1

  # All files on system sorted
find /  -type f -printf '%s %p\n'| sort -nr -k 1,1
find /  -type f -printf '%TY%Td%Tm%TH%TM%.2TS %TY-%Td-%Tm %TH:%TM:%.2TS%p\n'| sort -nr -k 1,1

  # Find all  duplicates in a file
sort FILE | uniq -c | sort -r -k1,1 | awk '{$1=$1;print}' | awk '$1 > 1 { print $0 }'
    # sort because uniq doesn't work unless it sorted
    # uniq -c leaves a count nummber for duplicates
    # sort -r -k1,1 reverse sorts by the first field which is the count of duplciates
    # awk '{$1=$1;print}' removes whitespace
    # awk '$1 > 1 { print $0 }' finds all duplicated greater than 1, and prints the line

  # Find all duplicate file names
  # Where the file is located you will have to do another search
find /etc  -type f -printf '%f\n'| sort | uniq -c | sort -r -k1,1 | awk '{$1=$1;print}' | awk '$1 > 1 { print $0 }'
  # We detected .bashrc twice, so find it
find /etc -type f -name '.bashrc'
  # output
  # /etc/defaults/etc/skel/.bashrc
  # /etc/skel/.bashrc


```


* * *
<a name=line></a>Manipulate one line at a time in bash

---------------

* Make File
```
echo "

Line 1
Line 2 a b c
Line 3
e f g
" > /tmp/line_data.txt
```

* IFS
```
echo "

if [ \"\$1\" = '' ] ; then
   echo "File not given"
   exit
fi
f=\"\$1\"

if [ ! -f "\$f" ] ; then
  echo \"File '\$f' does not exist\"
  exit
fi

while IFS= read -r line; do
  w=\`echo \"\$line\" | wc -w\`  
  echo \"Line has \$w words: \$line\"
  done < \$f

" > /tmp/word_count.bash

bash /tmp/word_count.bash /tmp/line_data.txt

```
* Seconds IFS
```

echo "
if [ \"\$1\" = '' ] ; then
   echo "File not given"
      exit
fi
f=\"\$1\"

if [ ! -f "\$f" ] ; then
  echo \"File '\$f' does not exist\"
  exit
fi
    
saved_IFS=\$IFS;
IFS=\"\\n\"
while read -r line ; do
  w=\`echo \"\$line\" | wc -w\`
  echo \"Line has \$w words: \$line\"
done < \"\$f\"
      
IFS=\$saved_IFS
" > /tmp/word_count2.bash

bash /tmp/word_count2.bash /tmp/line_data.txt


```

* * *
<a name=a></a>awk
---------------
Links
* TODO

* print mutiple columns
```
echo "1 2 3
4 5 6" > sample.data

awk '{print $1 "-----" $3}' sample.data
```

* print eveurthing
```

awk '{print "LINE: "$0}' sample.data
```


* * *
<a name=ssh></a>Scan hosts
---------------
1. Timeout if you can't connect.
2. Disable password, only connect with keys
3. accept host keys

```

ssh -oPasswordAuthentication=no -o ConnectTimeout=10 -o StrictHostKeyChecking=no
ssh -oPasswordAuthentication=no -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new


```

* * *
<a name=sort></a>sort
---------------
Links
* TODO

* sort by field : look at examples in this article
* There are probably other sort examples in this article. 
* sort by delimiter
```
echo "name1,3
name2,50
name3,20
" > sample_name_list

sort -t ',' -k 2 sample_name_list


```

* * *
<a name=wget></a>wget
---------------
* Overwrite previous download : Add "-O" and the name of the output file.
* If you are not downloading new versions of files, add "--no-cache" to turn
off caching.



See if a file is at least a certain size.
```

   # This tests in bytes.
   # This is 390 megs

FILENAME="yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz"
let size_desired=1024*1024*390
file_size=`stat -c %s $FILENAME`

if [ ! "$file_size" -ge "$size_desired" ]; then
  echo "$FILE is not $size_desired bytes."
fi
```
