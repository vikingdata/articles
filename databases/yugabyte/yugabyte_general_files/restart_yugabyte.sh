

export ybconfig=`locate yugabyte.config`
export base_dir=`jq .base_dir $ybconfig | sed -e 's/\"//g'`
export data_dir=`jq .data_dir $ybconfig | sed -e 's/\"//g'`
#  export myip=`ifconfig  | grep "inet " | grep -v 127 | sed -e 's/  */ /g' | cut -d ' ' -f3`
#  export myip=`hostname -I`
myip=`jq .advertise_address $ybconfig | sed -e 's/"//g'`

echo "
advertising ip : $myip
base_dir       : $base_dir
data_dir       : $data_dir
"

ysqlsh -h $myip -c "select yb_servers();" 2>/dev/null > /dev/null
yactive="$?"

if [ "$yactive" ! 0 ]; then
    echo "Stopping yugabyte"
    yugabyted stop --base_dir $base_dir
fi
  
ysqlsh -h $myip -c "select yb_servers();" 2>/dev/null > /dev/null
yactive="$?"

if [ "$yactive" = 0 ]; then
  echo "yugabyte still running, aborting"
else
  echo "starting yugabyte"
  yugabyted start --config $ybconfig

  1ysqlsh -h $myip -c "select yb_servers();" 2>/dev/null > /dev/null
  yactive="$?"

  if [ "$yactive" = 0 ]; then
     ysqlsh -h $myip -c "select yb_servers();"
  else
      echo "Unable to connect to yugabyte"
      ps -e -o pid,user,comm | egrep "postgres|yb-|yuga"
      echo "Unable to connect to yugabyte, check the processes above"
      echo "You might want to run
        ps -aux | egrep 'postgres|yb-|yuga' | grep -v grep        "

  fi
fi
