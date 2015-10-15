#!/usr/bin/env python2
import sys
import cassandra
from cassandra.cluster import Cluster

cluster = Cluster(['127.0.0.1'])
c = cluster.connect('sewn')

in_fields = 'date time ip x1 type path data status vhost user_agent cookies referrer'.split(' ')
out_fields = 'datetime ip x1 type path data status vhost user_agent cookies referrer'.split(' ')

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

    try:
      c.execute(
        """INSERT INTO weblog (id, datetime, ip, x1, type, path, data, status, vhost, user_agent, cookies, referrer)
        VALUES(uuid(), %(datetime)s, %(ip)s, %(x1)s, %(type)s, %(path)s, %(data)s, %(status)s, %(vhost)s, %(user_agent)s, %(cookies)s, %(referrer)s)""",
        row)
    except cassandra.protocol.ProtocolException as e:
      print "line: %d: %s" % (lineno, e)

    line = f.readline()
