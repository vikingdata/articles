#!/usr/bin/python3

#print ("Requires two hosts, third option will be top X highest rows for all tables (default all)")

import mysql.connector as cpy
import sys, re, os, argparse
import subprocess
from multiprocessing import Process
import multiprocessing

from concurrent.futures import ThreadPoolExecutor


no_tables_to_conmpare=0

report_home=os.environ['HOME'] + "/sql_reports"
my_file = os.environ['HOME'] + "/.my.cnf"
print (" report home is ", report_home)

   # find bash script to count tables
   # TODO, error out if not found
com ="which tables_by_count"
result = subprocess.run(com, stdout=subprocess.PIPE, shell=True)
get_tables = result.stdout.decode()
get_tables = get_tables.strip()

   # Make report directory if it doesn't exist
if not os.path.exists(report_home):
  os.mkdir(report_home)

   # Get arguments passed to this python script. 
parser = argparse.ArgumentParser(
                    prog='compare_rows_is.py',
                    description='Compare rows of two mysql server by information schema',
                    epilog='')
parser.add_argument('-t', '--tables', type=int, help="Top no of tables to show by count row count. Default 10, use 0 for all",
                    required=False, default=10)
parser.add_argument('-s', '--servers', help='comma separated list of host, all compared to first', required=True)
parser.add_argument('-a',  help='authentication file, my.cnf', required=false)
parser.add_argument('-d',  help='domain', required=True)
#parser.add_argument('-n',  help='subnet, like 10.', required=True)
args = parser.parse_args()
print (args)

if args.a is not None:
  my_file = arg.a
  # Abort if it doesn't exist.
  if not os.path.exists(my_file):
    print ("ERROR, my.cnf file for authetication doesn not exist:", my_file)
    sys.exit()
  
print ("reading config file", my_file, "  for authentication")
servers = args.servers.split(",")

base_server = servers[0]

print ("Connection to server : ", base_server)
try:
     conn= cpy.connect(option_files=my_file, host=base_server)
except:
    print ("could not connect to 1st server, aborting: ", base_server)
    sys.exit()
                        
print (get_tables)
report_file  = report_home + "/" + base_server + "_TABLES.txt"
com = get_tables + " " + base_server + " > "  + report_file
print ("executing : " + com)
try:
   result = os.system(com)
   print (" report at " + report_home + "/" + base_server + "_TABLES.txt")
except:
    print ("command failed")
    print (result)
    sys.exit()
print ("")

no_tables = args.tables
print ("no of top tables (if 0 then all)", no_tables)
print ("printing out sql for each server, run these scripts at the same time.")

             # Define sql execute function, it connects, runs sql query, then disconnects.
def execute(sql=None, host = None, server=None):
#  print ("test", sql, my_file, server)
  try:
     conn= cpy.connect(option_files=my_file, host=host)
     cursor = conn.cursor()
  except:
    print ("could not connect, skipping ", server)
    return None

  cursor.execute(sql)
  rows = cursor.fetchone()
  return ([server,rows])

#--------------------------                        
  # Now for each table, run counts at the same time
  # across all servers.
  # Generate count report
                        
count_results = {}
table_list = []
count_lines = 0
f = open(report_file)
re_alpha = re.compile('[a-zA-Z]')
for line in f:
  print ("")

  # Abort if we have no of tables > max allowed examined. 
  count_lines += 1
  if (no_tables == 0): continue
  elif (count_lines > no_tables) : break
  print ("table no", count_lines, no_tables)
  procs = []

  # If 3 columns, process the table. 
  temp = line.split()
  if len(temp) > 3:
    futures = []

    table = temp[1] + "." + temp[2]
    table_list.append(table)
    count_results[table] = {}
    sql = "select count(1) from " + table
    print (sql)
    server_count = 0
    for server in servers:
        host = server
        if ".com" not in server and re_alpha.search(server):
            host = server + ".five9.com"
        print ("Excuting on " + server + " " + sql)

        # Execute commands
        future = executor.submit(execute, sql, host ,, server)
        # push uture
        futures.append(future)    
    wait(futures)

    for future in futures:
      result = future.result()
      h = result[0]
      count= result[1]
      count_results[table][h] = count

  # Make final report, go through all tables.                        
final_report = report_home + "compare_" + base_server + ".txt"
print (" final_report:", final_report)
f2 = open(final_report,'w')
f2.write("table")
for server in servers: f2.write( "\t" + server)
f2.write("\n")

for table in table_list:
    f2.write(table)
    for server in servers:
        try:
            count = count_results[table][server][0]
            f2.write("\t" + str(count))
        except:
            f2.write("\t-")
    f2.write("\n")
