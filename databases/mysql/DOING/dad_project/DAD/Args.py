
"""
 © 2024 Mark Nielsen
Database Administration Dashboard

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation version 2 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not,
see <https://www.gnu.org/licenses/>.



"""


import mysql.connector as cpy
import sys, re, os, argparse

class args:
  def __init__(self, parent=None):

    self.parser = argparse.ArgumentParser(
                    prog='Database Adminitration Dashboard',
                    description='Generic args parse get in python',
                    epilog='')
    self.parser.add_argument("-c", help="config file, default /etc/dad.cnf", default="/etc/dad.cnf")
    self.parser.add_argument("-s", help="command separated list of servers", default=None)
    self.parser.add_argument("-m", help="mysql authorization file, default ~/.my.cnf", default=os.environ['HOME'] + "/.my.cnf")
    self.parser.add_argument("-C", help="command : slave, master, variables, etc", default='up')

    self.args = self.parser.parse_args()

    if self.parent is not None:
      self.parent.args = self.args
      self.parent.parser = self.parser
    
  def get_parser(self): return self.parser
  def get_args(self):
      self.args = self.parser.parse_args()
      return self.parser.parse_args()
  
      
  
