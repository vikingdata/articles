
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

from DAD.Args       import *
from DAD.Connection import * 
from DAD.queries    import * 
class dad:
  def __init__(self):

    self.connections = {}
    self.parser = None
    self.args = None
    
    args(parent=self) 
    self.connection = connection(parent=self)
    self.queries = queries(parent=self)
  
