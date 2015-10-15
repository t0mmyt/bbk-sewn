#!/usr/bin/env python2
import sys
import mysql.connector

mysql_con = mysql.connector.connect(user='sewn', database='sewn', password='Oabi8oo4chai9Roc', host='127.0.0.1')
c = mysql_con.cursor()

in_fields = 'date time ip username method path data status vhost user_agent cookies referrer'.split(' ')

insert_log = """INSERT INTO weblog (time, ip, username, method, path, data, status, vhost, user_agent, cookies, referrer) VALUES(%(datetime)s, inet_aton(%(ip)s), %(username)s, %(method)s, %(path)s, %(data)s, %(status)s, %(vhost)s, %(user_agent)s, %(cookies)s, %(referrer)s)"""

if len(sys.argv) != 2:
  print "Need logfile to import!"
  sys.exit(1)

with open (sys.argv[1], 'r') as f:
  lineno = 0
  line = f.readline()
  while line:
    lineno += 1
    row = dict(zip(in_fields,line.split(' ')))
    try:
      line = line.decode('utf8')
    except:
      line = f.readline()
      continue
    row['datetime'] = '20' + row['date'][0:2] + '-' + row['date'][2:4] + '-' + row['date'][4:6] + ' ' + row['time']
    row.pop('date', None)
    row.pop('time', None)
    row['status'] = int(row['status'])

    c.execute(insert_log, row)

    line = f.readline()

mysql_con.commit()
