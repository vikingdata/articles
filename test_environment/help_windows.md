title : Help Windows
author : Mark Nielsen
copyright : August 2026
---


Help Windows
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

This are Windows help techniques to setup the test environment. 
* [Setup Firewall](#f) in Windows
* [Run Powershell as Administrator](#p)


Links

* [https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/](https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/)

* * *
<a name=f></a>Setup Firewall in Windows
-----


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

* * *
<a name=p></a>Run Powershell as Administrator
-----
1. From the Start menu
   * Press Windows key.
   * Type PowerShell.
   * Right-click Windows PowerShell (or PowerShell).
      * Select Run as administrator.
      * Click Yes on the UAC prompt.
2. Or from Powershell
   * Start-Process pwsh -Verb RunAs
3. Or Win + R
   * Press Win + R
      * type: powershell
      * press Ctrl + Shift + Enter

To check if you run as administrtor execute: "net session".

If it does not say "Access is denied", then you are running as administrator.