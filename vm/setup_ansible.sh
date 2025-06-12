
cd ~/
mkdir -p ansible
cd ansible

export ANSIBLE_CONFIG="`pwd`/anisble.cfg"

acount=`grep ANISBLE_CONFIG ~/.bashrc | wc -l`
if [ $count -lt 1 ] ; then
  echo "Adding $ANSIBLE_CONFIG to bash.rc"
  echo "" >> ~/.bashrc
  echo "export ANSIBLE_CONFIG='$ANSIBLE_CONFIG'" >> ~/.bashrc
fi

if [ ! -f "$ANSIBLE_CONFIG" ] ; then
  echo "Creating new ansible.cfg file : $ANSIBLE_CONFIG"
  echo "Setting up directories : 
  echo "
ANSIBLE_HOME=`pwd`/ansible
inventory='pwd'/inventory
" > ansible.cfg

  mkdir -p inventory
  mkdir -p playlists

  echo '
[local]
   localhost ansible_connection=local
' >> inventory/local

fi
