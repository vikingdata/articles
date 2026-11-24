
KeePassXC for passwords
==============================

_**by Mark Nielsen
Original Copyright November 2026**_

NOTE: This is not meant for production. The files will be keep
locally which makes it insecure. Use this in all "test_environment" passwords created. 

1. [KeePassXC](#k) : Setting up KeePassXC
2. [Read passwords from file](#f)
3. [Show all accounts and passwords in database.](#s)

* * *
<a name=k></a> KeePassXC
-----

```
# Start wsl which should be an Ubuntu installation.

wsl

# Install KeePassXC

sudo apt update -y && sudo apt -y install keepassxc


# setup the database
mkdir -p -m 700 ~/.keepassxc
cd ~/.keepassxc

echo ""
keepassxc-cli db-create --set-key-file unattended.key unattended.kdbx
chmod 600  unattended.key unattended.kdbx

echo ""
echo "Creating entry for : test_account"
keepassxc-cli add -q --no-password \
  -k unattended.key unattended.kdbx "test_account"

echo ""
echo "testing putting test password into keepasscx : test_password for account test_account"
printf '%s\n' "test_password" | keepassxc-cli edit -q --no-password \
  -k unattended.key unattended.kdbx "test_account" -p

echo ""
echo "Getting password for test_account"
my_pass=`keepassxc-cli show --no-password \
 -k unattended.key -a Password unattended.kdbx "test_account"`

echo ""
echo "Password for 'test_account' is '$my_pass'."

```

***
<a name=f></a> Read passwords from file
-----
You should have a file "~/keepassxc/new_passwords.tmp" from [Initial Setup of Linux Environment on Windows](https://github.com/vikingdata/articles/blob/main/test_environment/1_Initial_Linux_setup.md).
Run this script and then delete "new_passwords.tmp" after the accounts and passwords are in the database. 

```
cd ~/.keepassxc

  # Create a has array
declare -A passwords

  # Submit the file new_passwords.tmp to fill the hash. 
while IFS='=' read -r account password; do
    # Skip empty lines and comments
  [[ -z "$account" || "$account" == \#* ]] && continue

    # Remove surrounding single quotes
    # Remove from start
  password="${password#\'}"

    # Remove from end
  password="${password%\'}"

    #Assign the account the password.
  echo "Adding $account to bash has"
  passwords["$account"]="$password"
done < new_passwords.tmp


KEY=unattended.key
DB=unattended.kdbx

for u in "${!passwords[@]}"; do
  p="${passwords[$u]}" 

  if keepassxc-cli show -q --no-password -k "$KEY" "$DB" "$u" &>/dev/null </dev/null; then
    printf '%s\n' "$p" | keepassxc-cli edit \
      -q --no-password -k "$KEY" "$DB" "$u" -u "$u" -p
    echo "Updated: $u $p"
  else
    printf '%s\n' "$p" | keepassxc-cli add \
      -q --no-password -k "$KEY" "$DB" "$u" -u "$u" -p
    echo "Added:   $u $p"
  fi
done


```

If you do not have passwords, test the above command with:
```
echo "dummy1='pass1'" >> new_passwords.tmp
echo "dummy2='pass2'" >> new_passwords.tmp
echo "dummy3='pass3'" >> new_passwords.tmp
echo "dummy4='pass4'" >> new_passwords.tmp


```


***
<a name=s></a> Show all accounts and passwords in database.
-----

```

cd ~/.keepassxc

keepassxc-cli ls -R -f -q --no-password -k unattended.key unattended.kdbx | grep -v '/$' |
while IFS= read -r entry; do
  keepassxc-cli show -q -s --no-password -k unattended.key unattended.kdbx "$entry" < /dev/null
  echo "-----"
done

```

***
<a name=p></a> Use Python to get password
-----

First install pykeepass

```
sudo apt install -y python3-pip python3-venv
sudo apt install -y python3-pykeepass
```

Then save this into a file "showpasswords.py". The title "dummy1" should exist. Replace this
with another entry. 
```

from pathlib import Path
from pykeepass import PyKeePass

secrets = Path.home() / ".keepassxc"
kp = PyKeePass(secrets / "unattended.kdbx", keyfile=secrets / "unattended.key")

for item in kp.entries:
    print (f"title    : {item.title}\nusername : {item.username}\npassword : {item.password}\n")

#import inspect
#for name, value in inspect.getmembers(item):
#    if not name.startswith("__") and not inspect.ismethod(value):
#        print(f"{name}: {value}")

```

Then execute
```
python3 showpasswords.py

```