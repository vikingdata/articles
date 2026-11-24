
KeePassXC for passwords
==============================

NOT DONE YET

_**by Mark Nielsen
Original Copyright November 2026**_

NOTE: This is not meant for production. The files will be keep
locally which makes it insecure.

1. [KeePassXC](#k) : Setting up KeePassXC
2. [Using KeePassXC](#u)
3. [Read passwords from file](#f)
4. [Show all accounts and passwords in database.](#s)

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
<a name=u></a> Using KeePassXC
-----

***
```

```
<a name=f></a> Read passwords from file
-----
You should have a file "~/keep/new_passwords/tmp" from [Initial Setup of Linux Environment on Windows](https://github.com/vikingdata/articles/blob/main/test_environment/1_Initial_Linux_setup.md).
Run this script and then delete "new_passwords.tmp" after the verify the accounts and passwords are in the database. 

```
cd ~/.keepassxc
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