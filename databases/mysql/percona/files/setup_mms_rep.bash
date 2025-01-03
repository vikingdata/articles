if [[ -z "$DB1" ]]; then
    echo "Must provide DB1 in environment" 1>&2
    exit 1
fi
if [[ -z "$DB2" ]]; then
    echo "Must provide DB1 in environment" 1>&2
    exit 1
fi
if [[ -z "$DB3" ]]; then
    echo "Must provide DB1 in environment" 1>&2
    exit 1
fi

echo "Master1 = $DB1, Master2 = $DB2, slave of Master2 = $DB3"

mysql1_ip=$DB1
mysql2_ip=$DB2
mysql4_ip=$DB3

muser=root
mpass=root


f1=`mysql -u $muser -p$mpass -h $mysql1_ip -e "show master status\G" | grep File| cut -d ':' -f2| sed -e "s/ //g"`
p1=`mysql -u $muser -p$mpass -h $mysql1_ip -e "show master status\G" | grep Position| cut -d ':' -f2| sed -e "s/ //g"`

f2=`mysql -u $muser -p$mpass -h $mysql2_ip -e "show master status\G" | grep File| cut -d ':' -f2| sed -e "s/ //g"`
p2=`mysql -u $muser -p$mpass -h $mysql2_ip -e "show master status\G" | grep Position| cut -d ':' -f2| sed -e "s/ //g"`

# stop repl
for i in $mysql1_ip $mysql2_ip $mysql4_ip; do
    mysql -u $muser -p$mpass -h $i -e "stop slave" 
done


# rep 1 to 2
mysql -u $muser -p$mpass -h $mysql2_ip -e "change master to master_host='$mysql1_ip', master_user='repl', master_password='repl', master_ssl=1"
mysql -u $muser -p$mpass -h $mysql2_ip -e "change master to master_log_file='$f1', master_log_pos=$p1"

# rep 2 to 1 and 4
mysql -u $muser -p$mpass -h $mysql1_ip -e "change master to master_host='$mysql2_ip', master_user='repl', master_password='repl', master_ssl=1"
mysql -u $muser -p$mpass -h $mysql4_ip -e "change master to master_host='$mysql2_ip', master_user='repl', master_password='repl', master_ssl=1"

mysql -u $muser -p$mpass -h $mysql1_ip -e "change master to master_log_file='$f2', master_log_pos=$p2"
mysql -u $muser -p$mpass -h $mysql4_ip -e "change master to master_log_file='$f2', master_log_pos=$p2"


for i in $mysql1_ip $mysql2_ip  $mysql4_ip; do
    mysql -u $muser -p$mpass -h $i -e "start slave"
done

mysql -u $muser -p$mpass -h $mysql1_ip -e "create database if not exists admin"
mysql -u $muser -p$mpass -h $mysql1_ip -e "drop table if exists admin.m1" admin
mysql -u $muser -p$mpass -h $mysql1_ip -e "create table if not exists m1 (h text); insert into m1 values ('$mysql1_ip')" admin
sleep 5
mysql -u $muser -p$mpass -h $mysql2_ip -e "insert into m1 values ('$mysql2_ip')" admin


# slave check

for i in $mysql1_ip $mysql2_ip $mysql4_ip; do

    echo "" 
    echo checking $i 
    mysql -u $muser -p$mpass -h $i -e "show slave status\G" | cat | egrep "Host|User|Port|Seconds|Running|Log_File|Log_Pos"
    mysql -u $muser -p$mpass -h $i -e "select * from admin.m1"
done    
    
#mysql -u $muser -p$mpass -h $mysql1_ip -e "show slave status\G"
#echo "change master to master_log_file='$f2', master_log_pos=$p2"
