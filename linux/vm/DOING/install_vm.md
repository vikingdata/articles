 
---
title : Linux: Install Linux under Windows
author : Mark Nielsen  
copyright : Feburary 2024  
---


Linux: Install Linux under Windows
==============================

_**by Mark Nielsen
Original Copyright February 2024**_


1. [Links](#links)
2. [wls2](#wsl2)
3. [Vrgrant](#vagrant)
4. [VirtualBox](#vb)
5. [Docker](#d)
6. [nerdctl](#n)

There are two types of virtualization.
Full virutalzation solutions which run an operating system, which is meant for entire
OS or machines. 
And one that runs containers, which is meant for applications.


* * *
<a name=Links></a>Links
-----

* [Docker vs VirtualBox](https://stackshare.io/stackups/docker-vs-virtualbox#:~:text=Docker%20containers%20start%20up%20quickly,performance%20compared%20to%20Docker%20containers.)
* [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
* [Basic commands for WSL](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
* [VirtualBox](https://www.virtualbox.org/)
* [Docker](https://www.docker.com/)
* [Nerdctrl on github](https://github.com/containerd/nerdctl)
* [Installing/Upgrading Rancher](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade)
* [Getting Started With Vagrant] (https://phoenixnap.com/kb/vagrant-beginner-tutorial#:~:text=Before%20you%20start%2C%20make%20sure,%2DV%2C%20and%20custom%20solutions.)
* [Getting Started with Vagrant and VirtualBox](https://www.itu.dk/people/ropf/blog/vagrant_install.html#:~:text=Getting%20Started%20with%20Vagrant%20and,%2C%20MacOS%2C%20Windows%2C%20etc.)

* * *
<a name=wsl2>WSL2</a>
-----

Info Commands is Windows Shell or Powershell
* See what version you are using : wsl -l -v
* See where is installs stuff: wsl pwd
* List versions available : wsl --list --online
* List versions installed : wsl --list --verbose

* Open Shell as administrator
    * wsl --install --distribution  Ubuntu-22.04
       * It will ask for a username and password
    * If you leave , you can reenter by :
```bash
wsl --distribution Ubuntu-22.0
   # to get to your home directory in Linux and not the Windows hom directory
cd
```

To remove
* wsl --unregister Ubuntu-22.04

Do first things:
* Put your account into sudoers file.

```text
apt-get update
apt-get install emacs screen


* * *
<a name=vagrant></a>Vagrant
-----

A free software by HashiuCorp to create virtual environment.
It works with VirtualBox, VMware, Docker, Hyper-V, and custom solutions.
Ity can run on Windows, Mac, Linux. 

* * *
<a name=vb></a>VirtualBox
-----
Owned by Oracle. It is a free (but not open source) VM system that appears to be able to be used for free by personal or commercial use.

Problems: Most things work, except MongoDB. 


* * *
<a name=d></a>Docker
-----

Runs containers under different operating systems. 


* * *
<a name=n></a>Nerdctl and Rancher
-----
It is a free version of Docker. 




