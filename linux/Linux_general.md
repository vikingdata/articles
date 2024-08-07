--------
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
13. [ Parse text files](#parse)

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
---
* * *
<a name=install></a>Disk Performance
-----

* Manually
    * dd if=/dev/random of=10gig.bin bs=10G count=1; rm 10gig.bin"
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

find_files='find / -size +1G -type f -printf %s_%p\n'
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

