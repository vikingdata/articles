#!/usr/bin/python3

"""
File: filename.py
Author: Mark Nielsen
Date: 3-12-2024
Copyright : GPL2
Description: Count rows of tables in mysql. Used to spot check if replication is working.

Requires mysql connector module to be installed.
Requires authentication file at ~/.my.cnf de default in the format

[client]
user=<USER>
password=<PASSWORD>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

"""


import mysql.connector as cpy
import sys, re, os, argparse
from concurrent.futures import ThreadPoolExecutor
import concurrent

 # Get arguments passed to this python script. 
parser = argparse.ArgumentParser(
                    prog='compare_rows_is.py',
                    description='Compare rows of two mysql server by information schema',
                    epilog='')
parser.add_argument('-t', '--tables', type=int, help="Top no of tables to show by count row count. Default 10, use 0 for all",
                    required=False, default=10, metavar="int")
parser.add_argument('-s',  help='comma separated list of hosts, all compared to first', required=True, metavar="SERVERS")
parser.add_argument('-a',  help='authentication file, ~/.my.cnf', required=False, metavar='FILE')
parser.add_argument('-d',  help='domain', required=False, metavar="DOMAIN")
#parser.add_argument('-n',  help='subnet, like 10.', required=True)
args = parser.parse_args()
#print (args)

  # Make the multi processing object
executor = ThreadPoolExecutor(max_workers=5)
  # Intialize some variables. 
report_home=os.environ['HOME'] + "/sql_reports"
my_file = os.environ['HOME'] + "/.my.cnf"
print (" report home is ", report_home)
   # Make report directory if it doesn't exist
if not os.path.exists(report_home):
  os.mkdir(report_home)

  # Check submitted args
domain = ""
if args.d is not None:
  domain = args.d

if args.a is not None:
  my_file = arg.a
  # Abort if it doesn't exist.
  if not os.path.exists(my_file):
    print ("ERROR, my.cnf file for authetication doesn not exist:", my_file)
    sys.exit()

no_tables = args.tables

#-------------------------------------------------------------------
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
#--------------------------------------------------

count_sql = """
 SELECT table_rows, table_schema 'DB', table_name as 'Table'
  FROM information_schema.tables
  where table_rows  is not NULL
    and table_schema not in ('mysql', 'information_schema', 'performance_schema', 'sys')
    and table_rows > 0 and table_rows < 10000000
  order by  table_rows desc
"""
    
print ("reading config file", my_file, "  for authentication")
  # Make a list of servers.
servers = args.s.split(",")
  # Get the first one
base_server = servers[0]

print ("Connection to server : ", base_server)
cursor = None
try:
     conn= cpy.connect(option_files=my_file, host=base_server)
     cursor = conn.cursor()
except:
    print ("could not connect to 1st server, aborting: ", base_server)
    sys.exit()

  # Connection worked, now get the list of tables    
cursor.execute(count_sql)
rows = cursor.fetchall()

report_file  = report_home + "/" + base_server + "_TABLES.txt"
print ("Saving list of tables tp ", report_file)
f = open(report_file, 'w')
if rows is not None and len(rows) > 0:
  for row in rows:
    if row is not None:
      row = [ str(i) for i in row]
      tabs = "\t".join(row)
      f.write(tabs + "\n")
else:
  print ("unable to get table list, aborting")
  sys.exit()
f.close()

print ("no of top tables (if 0 then all)", no_tables)
print ("printing out sql for each server, run these scripts at the same time.")


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
  if len(temp) > 2:
    futures = []

    table = temp[1] + "." + temp[2]
    table_list.append(table)
    count_results[table] = {}
    sql = "select count(1) from " + table
#    print (sql)
    server_count = 0
#    print (servers)
    for server in servers:
        host = server
        if ".com" not in server and re_alpha.search(server):
            host = server + ".five9.com"
        print ("Excuting on " + server + " " + sql)

        # Execute commands
        future = executor.submit(execute, sql, host ,server)
        # push uture
        futures.append(future)    

        # Wait till all connections are done.   
    concurrent.futures.wait(futures, timeout=None, return_when='ALL_COMPLETED')

      # Save the results
    for future in futures:
      result = future.result()
      h = result[0]
      count= result[1]
      count_results[table][h] = count

  # Make final report, go through all tables.                        
final_report = report_home + "compare_" + base_server + ".csv"
print ("")
f2 = open(final_report,'w')
f2.write("table")
for server in servers: f2.write( "," + server)
f2.write("\n")

for table in table_list:
    f2.write(table)
    for server in servers:
        try:
            count = count_results[table][server][0]
            f2.write("," + str(count))
        except:
            f2.write(",-")
    f2.write("\n")
f2.close()
    
f3 = open(final_report)
for line in f3 : print (line, end='')
f3.close()
print ("")
print ("final_report:", final_report)
