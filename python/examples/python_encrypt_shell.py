#!/usrbin/python


# to create dummy password
# echo "testsecret" > secret_file


import subprocess,os, sys

password=sys.argv[1]

f = open('secret_file')
secret = f.readline().strip()
f.close


com = "echo '" + str(password) + "' | openssl enc -k " + str(secret) + " -aes256 -base64  2>/dev/null"
result = subprocess.run(com, stdout=subprocess.PIPE, shell=True)
enc_pass = result.stdout.decode().strip()
print ("command:", com)
print ("secret", secret)
print ("original:", password)
print ("ecnryted :", enc_pass)


print ("")
com = "echo '" + str(enc_pass) + "' | openssl enc -d -k " + str(secret) + " -aes256 -base64  2>/dev/null"
result = subprocess.run(com, stdout=subprocess.PIPE, shell=True)
pass2 = result.stdout.decode().strip()
print ("passsword decrypted:", pass2)

