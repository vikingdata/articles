 ## Configure time --- this is NOT AWS, so no chrony

apt-get -y install ntp

 ## Change ulimits
echo "
*                -       core            unlimited
*                -       data            unlimited
*                -       fsize           unlimited
*                -       sigpending      119934
*                -       memlock         64
*                -       rss             unlimited
*                -       nofile          1048576
*                -       msgqueue        819200
*                -       stack           8192
*                -       cpu             unlimited
*                -       nproc           12000
*                -       locks           unlimited
" > /etc/security/limits.conf

  ## add huge pages
echo always > /sys/kernel/mm/transparent_hugepage/enable
cat  /sys/kernel/mm/transparent_hugepage/enable

bash -c 'sysctl vm.swappiness=0 >> /etc/sysctl.conf'
bash -c 'sysctl vm.max_map_count=262144 >> /etc/sysctl.conf'

mkdir -p /db/yugabyte/disks/d1
mkdir -p /db/yugabyte/log
