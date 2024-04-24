#!/usr/bin/python

"""
Copyright Mark Nielsen April 2024
Under GPL2
"""

import sys, re, os, argparse
import urllib
from urllib.request import urlopen
from urllib import request, parse
import json
import time

parser = argparse.ArgumentParser(
                    prog='Rundeck_submit_job.py ',
                    description='submits job to rundeck',
                    epilog='')
parser.add_argument('-r', help="Rundeck url, default http://localhost:4440",
                    required=False, default="http://localhost:4440")
parser.add_argument('-a',  help='authorization token, looks like qw8QovPQzh6LPBBu5aXFTVyouNGlIOyr', required=True)
parser.add_argument('-j',  help='job, looks like  ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709 ', required=True)
parser.add_argument('-d',  help='debug, any int larger than 0 will display urls including authorizatiopn code', required=False, type=int, default=0)

try:
    args = parser.parse_args()
except Exception as  e:
    print (e)
    print (parser.print_help())
    sys.exit()
    
debug = args.d

try:
    url_initial = str(args.r) + "/api/47/job/" + str(args.j) + "/run?authtoken=" + str(args.a)
except:
    print ("couldn't make initial url.")
    if debug > 0:
        print ([args.r, args.j + "/run?authtoken=", args.a])

if debug > 0:
    print ("initial url:", url_initial)


def submit_url(url=None, url_type="GET"):

  if url is None: return None
  
  try:
#      print (url_type)
      req = request.Request(url, method=url_type)
      response = request.urlopen(req) 
#      print (response.info())
      data_json = json.loads(response.read()) 
  except Exception as  e:
      if debug > 0:
          print ("url", url)
      print ("url failed")
      print (e)
      sys.exit()
  return data_json


url_job_info = str(args.r) + "/api/47/job/" + str(args.j) + "/info?authtoken=" + str(args.a)
job = submit_url(url=url_job_info, url_type='GET')
# job_str = json.dumps(job, indent=2)
# print (job_str)

project_name = job['project']
job_name = job['name']
job_id = job['id']
print ("executing job: "+ job_name+ " from project : ", project_name, "job id:", job_id)

run = submit_url(url=url_initial, url_type='POST')
# run_str = json.dumps(run, indent=2)
# print (run_str)
run_id = run['id']
print ("run id is ", run_id)

status = run['status']
while status == "running":
    print ("Job still running....")
    time.sleep(2)
    url_exec_link = str(args.r) + "/api/47/execution/" + str(run_id) + "?authtoken=" + str(args.a)
    if debug > 0:
        print ("url exec:", url_exec_link)
    run = submit_url(url=url_exec_link)
    status = run['status']
if status != 'running':
  print ("final status:", status)
  sys.exit()
