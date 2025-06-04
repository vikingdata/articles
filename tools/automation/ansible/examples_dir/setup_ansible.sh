
cd ~/
mkdir -p ansible
cd ansible

export ANSIBLE_CONFIG="`pwd`/anisble.cfg"
acount=`grep ANISBLE_CONFIG ~/.bashrc | wc -l`

if [ $count -lt 1 ] ; then
  echo "" >> ~/.bashrc
  echo "ANSIBLE_CONFIG='$ANSIBLE_CONFIG'" >> ~/.bashrc
fi

echo "
inventory='pwd'/inventory
" > $ANSIBLE_CONFIG/ansible.cfg

mkdir -p inventory
mkdir -p playlists

echo '
[local]
   localhost ansible_connection=local
' >> inventory/local
