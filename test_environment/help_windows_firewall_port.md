title : Windows Firewall port
author : Mark Nielsen
copyright : August 2026
---


Windows Firewall port
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

Links

* [https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/](https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/)

Steps
* This blocks the Oracle port 1521
* In Windows, type in firewall in the search field and select "Windows Defender Firewall with advanced settings".
   * Click on "Advanced Settings" if just started "Windows Defender Firewall"
   * Click on Inbound rules, and select "New Rule".
   * Click port
   * Under "specific local ports" enter port 1521 and press Next
   * Click Block connection
   * Select domain, private, and public
   * name it : A block Oracle port 1521 outside
   * Click on finish
* You can do for other ports.  