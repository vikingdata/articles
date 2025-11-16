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

* * *
<a name=g></a>globbing and splitting
-----
To get the name of the directory of the script, you have
to understand globbing.
* [Wordsplitting](https://mywiki.wooledge.org/WordSplitting)
* [glob](https://mywiki.wooledge.org/glob)

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
