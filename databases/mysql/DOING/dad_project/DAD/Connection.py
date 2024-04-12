
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

class connection:
  def __init__(self, parent):
    self.parent = None
    if self.parent is None: return None
    if not hasattr(self.parent, 'connections'):
      self.parent['connections'] = {}
    return self    
    
  def connect(self, auth_file = None, host=None, port=None):
      if port is None: port = 3306
      if auth_file is None and hasattr(self.parent, 'auth_file') :
        if self.parent.auth_file is not None:
          auth_file = self.parent.auth_file
      if host is None: return None

      try:
        if auth_file is not None:
          conn= cpy.connect(option_files=auth_file, host=host, port=port)
        else:
          conn= cpy.connect(host=host, port=port)
        cursor = conn.cursor()
        name = str(host) + ":" + str(port)
        self.parent['connections'][name] = {}
        self.parent['connections'][name]['conn'] = conn
        self.parent['connections'][name]['cursor'] = cursor
        curosr.execute('set SESSION TRANSACTION READ ONLY')
        return  self.parent['connections'][name]
      except Exception as e:
        print ("Connetion failed ", host, ", auth_file, ", auth_file)
        print (e)
        return None
  
  def get_connection(self,auth_file = None, host=None, port=None):
      if port is None: port = 3306
      if auth_file is None and hasattr(self.parent, 'auth_file') :
        if self.parent.auth_file is not None:
          auth_file = self.parent.auth_file
      if host is None: return None

      name = str(host) + ":" + str(port)
      conns = self.parent['connections']
      if name in conns:
        try:
          cursor = self.parent['connections'][name].cursor()
          cursor.exectute('select now(0')
          return self.parent['connections'][name]
        except:
          return self.connect(self, auth_file = auth_file, host=host, port=port)
      else:
        return self.connect(self, auth_file = auth_file, host=host, port=port)

      
      
