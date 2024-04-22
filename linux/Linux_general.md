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
6. [CheetSheets](#c)
7. [ssh keys](#s)
* * *

<a name=links></a>Links
-----
* [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/x17837.html)
* [Introducing pass](https://www.passwordstore.org/)
* [https://wiki.archlinux.org/title/Pass](https://wiki.archlinux.org/title/Pass)
* Tips and Tricks
    * (Top 35 Linux Console Tips and Tricks From Practical Experience)[https://hackernoon.com/top-35-linux-console-tips-and-tricks-from-practical-experience]
    * [6 Linux Terminal Tips and Tricks to Get Things Done Quickl](https://www.makeuseof.com/linux-terminal-tips-and-tricks/)
    * (10 Linux Terminal Tips and Tricks to Enhance Your Workflow)[https://www.learnlinux.tv/10-linux-terminal-tips-and-tricks-to-enhance-your-workflow/]
        * I use screen instead of ttmux
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
<a name=c></a>Cheetsheets
-----
* MongoDB
    * This is a very good one [A Performance Cheat Sheet for MongoDB](https://severalnines.com/blog/performance-cheat-sheet-mongodb/)
    * AWS https://mongodb-devhub-cms.s3.us-west-1.amazonaws.com/Mongo_DB_Shell_Cheat_Sheet_1a0e3aa962.pdf
    * https://cheatography.com/ovi-mihai/cheat-sheets/mongodb/
    * https://www.mongodb.com/developer/products/mongodb/cheat-sheet/
    * https://gist.github.com/bradtraversy/f407d642bdc3b31681bc7e56d95485b6
    * https://www.interviewbit.com/mongodb-cheat-sheet/


* * *
<a name=s></a>ssh keys 
-----

* -N '' means etmpy password
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