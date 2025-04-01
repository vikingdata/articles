echo "Change the alias name depending which servers you are on!"

export alias_name="ssh_"`hostname`
echo " my hostname", `hostname`, " and my alias is $alias_name"
my_ip=`ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3`
echo "alias $alias_name='ssh -l $my_ip'" >> /shared/aliases
echo "$alias_name='$my_ip'" >> /shared/server_ips
echo ""; echo ""; echo "";

echo " my hostname", `hostname`, " and my alias is $alias_name"
echo "my ip is: $my_ip"

my_host=`hostname -s`
echo "alias $my_host='$my_ip'" >> /shared/virtual_host_aliases.sh
