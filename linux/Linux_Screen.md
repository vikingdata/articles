---
title : Linux Screen
author : Mark Nielsen
copyright : October 2024
---


Linux Screen
==============================

_**by Mark Nielsen
Original Copyright October 2024**_

I wanted to run screen with multiple windows. It needs to wipe out dead screens
and start a new one. It needs to exit properly. 

1. [Links](#links)
2. [Opening with multiple screens](#mul)

* * *

<a name=links></a>Links
-----
* https://linuxize.com/post/how-to-use-linux-screen/
* https://kapeli.com/cheat_sheets/screen.docset/Contents/Resources/Documents/index
* https://www.baeldung.com/linux/background-command-with-delay

* * *
<a name=mul></a>Opening with multiple screens
-----

First, read this: https://linuxize.com/post/how-to-use-linux-screen/

1. First make directories and files

```
rm -rf example
mkdir -p example
echo "file1" > example/file1.txt
```

2. Then Make this file and name is ex.bash
```
echo "killall screen;
screen -wipe
sleep 1 "  > ex.bash
echo " \`sleep 1; screen -S example ;  echo $! > /tmp/ex.pid \` & " >> ex.bash

echo "
sleep 3
screen -S example -X screen echo $! > /tmp/ex.pid
   # run command every 1 second
screen -dmS example -X screen sh -c 'sleep 1; clear; while sleep 1; do ls -al ; done'
   # open empty shell
screen -dmS example -X screen sh -c 'sleep 1; bash'
   # edit a file
screen -S example -X screen  emacs -nw example/file1.txt

  # record the parent pid of the shell which is screen
screen -S example -X screen sh -c 'cat /proc/\$\$/ppid > /tmp/screen.pid; sleep 1'
 
sleep 2

  #
  # Now check every second to see if screen is running
  # If not print message and exit. 
ppid=\`cat /tmp/screen.pid\`
  
while ps -p \$ppid > /dev/null; do sleep 1; done

echo "Exiting script \$ppid"

 " >> ex.bash
```

3. Now execute ex.bash
```

bash ex.bash

```

4. Exit out of every screen. Either stop the editor  (Ctrl-x Ctrl-c),
kill the script running, or if it is a shell type in "exit". 
