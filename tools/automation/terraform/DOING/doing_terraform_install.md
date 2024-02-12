--------
title: Terraform : Install 

--------

# Terraform: Installation

*by Mark Nielsen*  
*Copyright February 2024*

---

1. [Links](#links)
2. [Install Terraform (Ubuntu)](#install)
3. [Create something](#create)

* * *

<a name=links></a>Links
-----
* [Install Ubuntu[](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

---

* * *

<a name=install></a>Install Terraform
-----

```bash

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo
 tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform

echo $PATH
mkdir -p /usr/local/bin
 
```

* * *

<a name=create></a>Create something
-----
