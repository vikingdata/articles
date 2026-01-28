\
mkdir -p ~/install_scripts
cd ~/install_scripts

rpm -ev ` rpm -qa | egrep -i "mysql|percona" | tr '\n' ' ' `

cd percona_8.4.7
rpm -ihv *.rpm
