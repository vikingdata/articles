x
import subprocess, sys
com = "ls"
try:
  result = os.system(com)
except:
  print ("Command failed", com)
  sys.exit

result = subprocess.run(com, stdout=subprocess.PIPE, shell=True)
lines = result.stdout.decode()
return lines.split("\n")
