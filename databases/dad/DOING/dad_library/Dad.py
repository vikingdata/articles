#!python3


import sys, re, os, argparse, traceback
import subprocess
from multiprocessing import Process
import multiprocessing


import configparser
config = configparser.ConfigParser()


class Dad:
  def __init__(self):
      self.config_file="/etc/dad/dad.cfg"
      self.configvars= None
      self.args = None

      
      loadConfig()
      parseArgs()

  def loadCconfig(self):
      if not os.path.exists(self.config_file) :
        print ("Config file doesn't exist:" + self.config_file)
        return None

      try:
          config.read(self.config_file)
          if not 'main' in config:
              print ("ERROR: no [main] section in "+ self.config_file)
              sys.exit()

          cref = config['main']
          if 'homedir'  in cref: self.homedir   = cref['homedir']
          if 'maxlevel' in cref: self.max_level = cref['maxlevel']
          if 'problem'  in cref: self.problem   = cref['problem']

          self.config      = cref

      except Exception as e:
          message =  "ERROR: could not parse " + self.config_file
          self.exception(e=sys.exc_info(), message=message)

  def parseArgs(self):

      parser = argparse.ArgumentParser(prog='dad',  description='Database Adminsitration Dashboard', epilog='')
      parser.add_argument('-c', type=int, help="Commands options", required=True, default="query")
      parser.add_argument('-s', help='comma seaprated list of host, all compared to first', required=True)
      parser.add_argument('--comand_list', help='List command options and exit', action='store_true')
      args = parser.parse_args()
      print (args)

      if args.comand_list and args.comand_list is True:
          Message = """
  -c options. Given servers given by -s
          sp
          compare_rows
          explain_processlist
          rep_info
          cluster_info
          




          """
          parser.print_help()
          print (Messsage)



