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
* [Install Ubuntu](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


Vagrant
* [https://www.youtube.com/watch?v=tayQQ_D2Rxc](https://www.youtube.com/watch?v=tayQQ_D2Rxc)
* [How to Manage Remote Instances with Vagrant & Terraform](https://brev.dev/blog/how-to-create-and-manage-remote-dev-environments-with-infrastructure-as-code)

Virtual Box
* (Using terraform for automation creating virtualbox virtual machine)[https://blog.opennix.ru/posts/use-terraform-with-virtualbox/]

---

* * *

<a name=install></a>Install Terraform
-----

```bash



wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

#echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform
```

Check if terraform is installed.

```bash
which terraform
/usr/bin/terraform
```

Since its installed, IGNORE THIS
```
echo P$ATH
mv ~/Downloads/terraform /usr/local/bin/
```

Verify it is installed
```
terraform -help
```
and it should output a help menu

* * *

<a name=create></a>Create something
-----


Install Docker or 


* * *

<a name=create></a>Create something
-----
