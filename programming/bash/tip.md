---
title :  Bash tips
author : Mark Nielsen
copyright : November 2025
---


Bash Tips
==============================

_**by Mark Nielsen
Original Copyright November 2025
1. [globbing and splitting](#g)
2. [Directory of the script](#d)
3. [Unbuffer tee or redirection](u)
4. [Abort bash script on first error](#e)
* * *
<a name=g></a>globbing and splitting
-----

* [Wordsplitting](https://mywiki.wooledge.org/WordSplitting)
* [glob](https://mywiki.wooledge.org/glob)

TODO: give examples. The explanations are horrible. 

* * *
<a name=d></a>Directory of the script
-----
```
# Save this to "test.sh" and then execute with "bash test.sh"
echo "Script name including path:""$0"
echo "Directory of script: $(dirname "$0") "
echo "Just the script name: $(basename "$0") "
echo "Current directory: `pwd`"

```

output
```
Script name including path:/tmp/test.sh
Directory of script: /tmp
Just the script name: test.sh
Current directory: /home/marka
```

Notes:
* You can execute commands between `` within quotes. 
* You don't have to escape quotes inside quotes if you use ();

* * *
<a name=u></a>Unbuffer tee or redirection
-----
* Unbuffer after each newline, which is probbly better.
```
# stdbuf -oL <COMMAND> | tee log.txt

stdbuf -oL cat /etc/fstab | tee /tmp/log.txt
```
* Really unbuffer everything
```
#stdbuf -o0 <COMMAND> | tee log.txt

stdbuf -o0 cat /etc/fstab | tee /tmp/log.txt
stdbuf -o0 cat /etc/fstab > tee /tmp/log.txt


```
* * *
<a name=e></a>Abort bash script on first error
-----
Bash will usually keep executing a script even if there are errors.

* "set -e " is used to abort scripts on a command EXCEPT if the command is used in a loop or other.
* "set -e" won't abort the script if the command is used in
   * if <COMMAND>; then
   * while <COMMAND>; do
   * until <COMMAND>
   * <COMMAND> && other
   * <COMMAND> || other

* This will stop on the first error.
```
echo '
set -e
echo "Starting script"
date
echo "Script should stop after this next command."
date zzzz
echo "Script should not have gone this far."
' > /tmp/test1.sh

bash /tmp/test1.sh

```

* A better for of trapping errors if one script calls another.
```
set -Eeuo pipefail
```

* To check status manually
```
echo '
set -e
echo "Starting script"
date
echo ""
echo "Script should not stop after this error."
if ! date z1  ; then
    status=$?
    echo "Failed with $status"
fi
echo ""
echo "Script should stop after this error."
date z2
echo ""
echo "Script should not have gone this far."
' > /tmp/test2.sh

bash /tmp/test2.sh


```