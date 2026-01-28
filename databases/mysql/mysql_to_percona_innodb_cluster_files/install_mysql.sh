source global_vars.sh

options=' -i id_rsa -o StrictHostKeyChecking=no '

for p in $s1_port $s2_port $s3_port; do

    echo "doing port $p"
    for f in misc_packages.txt download_mysql_8.0.43.txt reset_mysql.sh; do
	echo "executing $f"

        ssh $options root@127.0.0.1 -p $p " bash install_scripts/$f"
done
