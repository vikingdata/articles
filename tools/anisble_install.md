--------
title: Anisble : Install 

--------

# Ansible: Installation

*by Mark Nielsen*  
*Copyright January 2022*

The purpose of this document is to:

- Install server and client on the same computer.
- Run a command for Ansible to do basic commands.
- Run a very simple playbook.

---

1. [Links](#links)
2. [Install Ansible (Ubuntu)](#install)
3. [Initial Self Test](#initial)
4. [Initial Playbook](#playbook)

## Links

- [Ansible Overview and Architecture](https://docs.ansible.com/ansible/latest/dev_guide/overview_architecture.html)
- [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Installing Ansible - Adam the Automator](https://adamtheautomator.com/install-ansible/)
- [How to Install and Test Ansible on Linux - HowToForge](https://www.howtoforge.com/how-to-install-and-test-ansible-on-linux/)
- [Getting Started with Your First Playbook](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)
- [Ansible Tutorial - Software Testing Help](https://www.softwaretestinghelp.com/ansible-tutorial-1/)
- [Ansible Installation, Configuration, and Use with Windows and Linux](https://rdr-it.com/en/ansible-installation-configuration-and-use-with-windows-and-linux/)
- [OpenStack Ansible Documentation](https://docs.openstack.org/project-deploy-guide/openstack-ansible/latest/)
- [Ansible Installation for Alfresco](https://docs.alfresco.com/content-services/latest/install/ansible/)
- [Getting Started with Ansible Infrastructure Automation](https://blog.risingstack.com/getting-started-with-ansible-infrastructure-automation/)
- [Use Passwordless SSH Keys with Ansible to Manage Machines](https://www.ntweekly.com/2020/06/14/use-passwordless-ssh-keys-with-ansible-to-manage-machine/)

---

## Install Ansible

Please read:

- [Ansible Overview and Architecture](https://docs.ansible.com/ansible/latest/dev_guide/overview_architecture.html)
- [Installing Ansible on Specific Operating Systems](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems)

### Install

```shell
apt update
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible

cd /root

# make an SSH key and make it so we can log in as root to localhost.
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
chmod 644 .ssh/authorized_keys
ssh -o "StrictHostKeyChecking no" 127.0.0.1 echo "done"
```


# Initial Self Test

```shell
cd /etc/ansible

touch /etc/ansible/hosts
echo "[self]"    >> hosts
echo "127.0.0.1" >> hosts

echo "" >> hosts
echo "[self:vars]
ansible_connection=ssh
   " >> hosts

mv -f ansible.cfg ansible.cfg_initial

echo "[defaults]
inventory = hosts
host_key_checking = False
        " >> ansible.cfg
```
#Verify the initial "self" commands:

```shell
ansible -m ping self               # using the ping module
ansible self -a "echo 'hello'"    # and ad-hoc command
ansible self -a "date"            # get date
ansible self -a "uptime"          # Get the uptime for this server
```

# Initial Playbook

```shell
cd /etc/ansible
mkdir -p playbooks

echo "
- hosts: all

  tasks:
    - name: Ensure a list of packages installed
      apt:
        name: htop
        state: present
" >> playbooks/test-package.yml
```

# Now run the playbook:

```shell
ansible-playbook -i "127.0.0.1," playbooks/test-package.yml
```

# Re-test the playbook:
```shell
apt-get -y remove htop
# Make sure it doesn't exist
htop

# Then rerun the playbook
ansible-playbook -i "127.0.0.1," playbooks/test-package.yml

# Then see if it exists
htop
```