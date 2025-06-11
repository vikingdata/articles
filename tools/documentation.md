---
title: Documentation
---

This will be using a Windows system with WSL which is a Linux emulation under Windows.

Downloading documentation for offline
* General
    * [Git ansible](https://github.com/ansible)
        * [git ansible docs](https://github.com/ansible/ansible-documentation)
    * [Install WSL](https://www.howtogeek.com/744328/how-to-install-the-windows-subsystem-for-linux-on-windows-11/)
        * wsl --install
    * Start WSL:
        * In the command prompt or Powershell in windows type: wsl
    * Setup WSL environment
```
mkdir -p ~/docs/source
mkdir -p ~/docs/finished
mkdir -p /mnt/c/temp/

sudo apt install -y xterm
sudo apt-get install -y  xfonts-base
alias x20=" xterm -fa UbuntuMono-R -fs 20 -fg white -bg black &"
echo "export x20=' xterm -fa UbuntuMono-R -fs 20 -fg white -bg black &'" >> ~/bashrc

echo "" >> ~/.bashrc
echo "export PATH=\"\$PATH:`pwd`/.local/bin\"" >> ~/.bashrc

```

* [Ansible](https://docs.ansible.com/ansible/latest/community/documentation_contributions.html#setting-up-your-environment-to-build-documentation-locally)
```
## DO THIS INSTEAD
sudo  apt-get update
sudo apt install python3.11
sudo rm -f /usr/bin/python3
sudo ln -s /usr/bin/python3.11 /usr/bin/python3

python3 -m venv ./venv
source ./venv/bin/activate

#sudo rm /usr/bin/python3-config
#sudo ln -s /usr/bin/python3-config /usr/bin/python3-config.11

pip install ansible-core

cd ~/docs/source
git clone https://github.com/ansible/ansible-documentation
cd ansible-documentation
python3 docs/bin/clone-core.py
pip install -r tests/requirements.in -c tests/requirements.txt # Installs tested dependency versions.
pip install -r tests/requirements.in # Installs the unpinned dependency versions.
cd docs/docsite

rm ~/.ansible.cfg
make coredocs
make webdocs     # This can take a while. 
rsync -av _build/html /mnt/c/temp/

```

* Virtualbox
    * Only pdf : https://download.virtualbox.org/virtualbox/7.1.10/UserManual.pdf
    * Unless you can suck down an entire website. 

* Terraform (NOT DONE)
    * Snap: https://snapcraft.io/install/terraform-docs/ubuntu
    * https://terraform-docs.io/
```
sudo apt update
sudo apt install snapd
sudo snap install terraform-docs

cd ~/docs/source
git clone https://github.com/terraform-docs/terraform-docs
cd terraform-docs/

sudo apt install python3-pip
pip install markdown


mkdir -p output
cd docs
for i in `find . -type d`; do
  mkdir -vp ../output/$i
done
cd ..

for i in `find docs  -name "*.md" -type f -printf '%p '`; do

  j=`echo $i | sed -e "s/docs/output/" | sed -e "s/md$/html/"`
  echo $j
  python3 -m markdown $i  -f $j
done

```
