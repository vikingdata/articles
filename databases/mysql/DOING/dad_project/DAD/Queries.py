

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



class queries:
  def __init__(self, cursor = None, parent=None):
    self.parent = None
    if parent is not None:
      self.parent = parent
    return self  

  def Dictionary_from_2_columns (self, cursor=None):
    if cursor is None:
        return None

    dic = {}
    for row in cursor.fethcall():
        try:
            h = row[0]
            v = row[1]
            dic[h] = v
        except: pass
    return dic

  def Dictionary_one_per_row (self, cursor=None, return_one=0):
    if cursor is None:
        return None

    rows = []
    try:
      headers = cursor.column_names
      for row in cursor.fetchall():
          dic = dict(zip(headers,row))
          rows.append(dic)

    except: pass

    if return_one > 0:
        if len(rows) > 0:
          return rows[0]

    return rows

  def get_slave_status(self, host=None, port=None):
    self.cursor = parent.Connection.get_connection(host=host, port=port)


