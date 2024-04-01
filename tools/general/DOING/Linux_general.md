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

* * *

<a name=links></a>Links
-----


* (Introducing pass)[https://www.passwordstore.org/]
* (https://wiki.archlinux.org/title/Pass)[https://wiki.archlinux.org/title/Pass]
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
    * Save the drive in a shell variable "GoogleDrive"
        * ex : export GoogleDrive=/cygdrive/c/GoogleDrive/
* In cygwin or Linux make sure "pass" is installed 

* Install [Butttercup]https://buttercup.pw/)
* In ButterCup
    * choose vault
    * Then file
    * Save the file in your Google Drive
    * Add a very good password for the vault.
* Now you can make groups, add customer entries to groups, and save passwords.
    * Don't forget to name the custom field or it won't let you save. 
* If you close the program and copy it to another computer, you can open the
vaults there with ButterCup. 