--------
title: GPG encryption

--------

# GPG Encryption

*by Mark Nielsen*  
*Copyright November 2023*

The purpose of this document is to:

- Perform file encryption without a key, just passphrase

GPG has many more capabilities for encryption. This article is just to encrypt a file or directory.

---

1. [Links](#links)
2. [Simple Test](#simple)
3. [Issues](#issues)
4. [Decrypt on other computer](#other)
5. [Automation](#automate)


* * *

<a name=links></a>Links
-----
* [Using the GNU Privacy Guard](https://www.gnupg.org/documentation/manuals/gnupg/)
* [How do I encrypt a file or folder in my home directory?](https://statistics.berkeley.edu/computing/encrypt)
* [File encryption and decryption made easy with GPG](https://www.redhat.com/sysadmin/encryption-decryption-gpg)
* [Encrypt and decrypt files in GPG without keys](https://tinyapps.org/blog/201705300700_gpg_without_keys.html)

---
* * *
<a name=simple></a>Simple Test
-----
```
sudo apt-get install gnupg


cd ~/
mkdir -p ~/test_dir
ls ~/ > ~/test_dir/home_list.txt
cd ~/

rm -f /tmp/test.gpg
tar -zcv  test_dir |  gpg --output /tmp/test.gpg --symmetric --passphrase "test"
rm -rf test_dir

gpg  -d -o test.tgz --passphrase "test" /tmp/test.gpg
tar -zxvf test.tgz

```

However, this may not work on another server. The reason is the decryption still asks for a key even though it was not
encrypted with a key. It works on the same server because our server has the key. 

---
* * *
<a name=issues></a>Issues
-----

Using GPG can fail in different ways. The instructions don't explain this. 

* GPG now uses an agent for the keys. This has had issues.
* When decrypting a file that DOES NOT use a key, you can get a decrypt error mentioning the key. 
    * [Look at this trouble ticket](https://stackoverflow.com/questions/55780390/how-to-pass-encrypted-message-and-passphrase-when-using-os-system-to-call-gpg)
    * ERROR
```
gpg: AES.CFB encrypted data
gpg: problem with the agent: Timeout
gpg: encrypted with 1 passphrase
gpg: decryption failed: No secret key
```

---
* * *
<a name=other></a>Decrypt on other computer
-----

The true test is if you can decrypt a file WITHOUT having any keys. Thus, you need to see if you can decrypt on another server. The solution is to use "--pinentry-mode loopback" when decrypting.

* Read: (Pinentry Mode)[https://www.gnupg.org/documentation/manuals/gpgme/Pinentry-Mode.html]

* Encrypt on your server
```shell
mkdir -p ~/test_dir
ls ~/ > ~/test_dir/home_list.txt
cd ~/
tar -zcv  test_dir |  gpg --output /tmp/test.gpg --symmetric --passphrase "test"


  # Transfer to another server.
  # Decrypt on oher server ```
gpg --pinentry-mode loopback -d -o test.tgz --passphrase "test" test.gpg
tar -zxvf test.tgz
```

---
* * *
<a name=automate></a>Automation
-----

* Example automation for encryption. 

```shell

cd ~/

mkdir -p ~/test_dir
ls ~/ > ~/test_dir/home_list.txt
cd ~/

d=`date +%Y_%m_%d`
rm -rf /tmp/test*.gpg
#tar -zcv  test_dir |  gpg --output /tmp/test_$d.gpg --symmetric --passphrase "test"
tar -zcv  test_dir |  gpg --output /tmp/test.gpg --symmetric --passphrase "test"

   # At this point, copy it to a directory or transfer to a host.
   # If transferinng to a host, have ssh keys setup so you can so passswordless transfer.
HOST=host_full_address.nowhere.no
#scp /tmp/test_$d.gpg SOMEUSER@$HOST:/Some/Directory/
scp /tmp/test.gpg SOMEUSER@$HOST:/Some/Directory/

```

* Example decryption
    * gpg --pinentry-mode loopback -d -o test.tgz --passphrase "test" test.gpg
    * or to decrypt and untar
```shell
rm -rf test_dir
rm -f test.tgz
gpg --pinentry-mode loopback -d --passphrase "test" -o test.tgz  test.gpg
tar -zxvf test.tgz 

```
* NOTE: you might want to use a file to hold your password. If you source control the scripts it is a BAD idea to put the
password in the script. This applies to encryption and decryption.
``` shell
echo "test" > password_file
gpg --pinentry-mode loopback -d --passphrase `cat password_file`  test.gpg | tar -zxv

```