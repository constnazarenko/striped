# -*- coding: utf-8 -*-
import sys, os, psycopg2, psycopg2.extras, time, shutil, math
HOMEPATH = os.path.abspath(os.path.dirname(__file__) + '/../../../') + "/"

con = psycopg2.connect(database=sys.argv[1], user=sys.argv[2])
cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
print 'connected'

'''ACTIONS LOGS BACKUP'''
cur.execute('''SELECT count(*)
			   FROM global_log_action
			   WHERE time < now() - '1 day'::interval
			''')
cnt = cur.fetchone()

if cnt[0] == 0 :
	print 'No old actions!'

dir = HOMEPATH + 'log/actions/'
log = dir + 'actions.bkp.log'

for i in range(0,int(math.ceil(cnt[0]/100.0))) :
	'''check if directory exists'''
	if not os.path.isdir(dir) :
		os.mkdir(dir)
	
	'''check file size limit 10 MB'''
		
	if os.path.exists(log) and os.path.getsize(log) > 10485760 :
		shutil.move(log, log +'.'+ time.strftime('%Y-%m-%d_%H:%M:%S'))
	
	cur.execute('''SELECT gla.time, c.login || '-' || au.username as user, c1.name as action_name, gla.object_id, gla.action, gla.link
				   FROM global_log_action as gla
				   LEFT JOIN auth_user as au ON (gla.user_id = au.id)
				   LEFT JOIN customer as c ON (au.customer_id = c.id)
				   LEFT JOIN class as c1 ON (gla.action_id = c1.id)
				   WHERE time < now() - '1 day'::interval ORDER BY time ASC LIMIT 100
				''')
	f = open(log, 'a')
	for x in cur.fetchall() :
		cur.execute("DELETE FROM global_log_action WHERE \"time\" = %s", (x['time'],))
		x['time'] = str(x['time'])
		s = "{} | {} | {} | {} | {} | {}\n".format(x['time'], x['user'], x['action_name'], x['object_id'], x['action'], x['link'])
		f.write(s)
		print s
	f.close()
	con.commit()
	
	
'''ACCESS LOGS BACKUP'''
cur.execute('''SELECT count(*)
			   FROM global_log_access
			   WHERE time < now() - '1 month'::interval
			''')
cnt = cur.fetchone()

if cnt[0] == 0 :
	print 'No old access logs!'

dir = HOMEPATH + 'log/access/'
log = dir + 'access.bkp.log'

for i in range(0,int(math.ceil(cnt[0]/100.0))) :
	'''check if directory exists'''
	if not os.path.isdir(dir) :
		os.mkdir(dir)
	
	'''check file size limit 10 MB'''
		
	if os.path.exists(log) and os.path.getsize(log) > 10485760 :
		shutil.move(log, log +'.'+ time.strftime('%Y-%m-%d_%H:%M:%S'))
	
	cur.execute('''SELECT gla.time, c.login || '-' || au.username as user, gla.accesspoint, gla.params, gla.referer
				   FROM global_log_access as gla
				   LEFT JOIN auth_user as au ON (gla.user_id = au.id)
				   LEFT JOIN customer as c ON (au.customer_id = c.id)
				   WHERE time < now() - '1 day'::interval ORDER BY time ASC LIMIT 100
				''')
	f = open(log, 'a')
	for x in cur.fetchall() :
		cur.execute("DELETE FROM global_log_access WHERE \"time\" = %s", (x['time'],))
		x['time'] = str(x['time'])
		s = "{} | {} | {} | {} | {}\n".format(x['time'], x['user'], x['accesspoint'], x['params'], x['referer'])
		f.write(s)
		print s
	f.close()
	con.commit()
