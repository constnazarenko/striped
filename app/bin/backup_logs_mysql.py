# -*- coding: utf-8 -*-
import sys, os, time, shutil, math, base64
import pymysql as db
home = os.path.abspath(os.path.dirname(os.path.abspath(__file__)) + '/../../../') + "/"

 #getting downloads list
con = db.connect(db=sys.argv[1], user=sys.argv[2], passwd=sys.argv[3])
cur = con.cursor(db.cursors.DictCursor)

print('connected')

'''ACTIONS LOGS BACKUP'''
cur.execute("SELECT count(*) as count FROM global_log_action WHERE time < DATE_SUB(CONCAT(CURDATE(),' ',CURTIME()),INTERVAL 1 day)")
cnt = cur.fetchone()

if cnt['count'] == 0 :
    print('No old actions!')

dir = home + 'log/actions/'
log = dir + 'actions.bkp.log'

for i in range(0,int(math.ceil(cnt['count']/100.0))) :
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
                   WHERE time < DATE_SUB(CONCAT(CURDATE(),' ',CURTIME()),INTERVAL 1 day) ORDER BY time ASC LIMIT 100
                ''')
    f = open(log, 'a')
    for x in cur.fetchall() :
        cur.execute("DELETE FROM global_log_action WHERE time = %s", (x['time'],))
        x['time'] = str(x['time'])
        s = "{} | {} | {} | {} | {} | {}\n".format(x['time'], x['user'], x['action_name'], x['object_id'], x['action'], x['link'])
        f.write(s)
        print(s)
    f.close()
    con.commit()
    

'''ACCESS LOGS BACKUP'''
cur.execute('''SELECT count(*) as count
               FROM global_log_access
               WHERE time < DATE_SUB(CONCAT(CURDATE(),' ',CURTIME()),INTERVAL 1 day)
            ''')
cnt = cur.fetchone()

if cnt['count'] == 0 :
    print('No old access logs!')

dir = home + 'log/access/'
log = dir + 'access.bkp.log'

for i in range(0,int(math.ceil(cnt['count']/100.0))) :
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
                   WHERE time < DATE_SUB(CONCAT(CURDATE(),' ',CURTIME()),INTERVAL 1 day) ORDER BY time ASC LIMIT 100
                ''')
    f = open(log, 'a')
    for x in cur.fetchall() :
        cur.execute("DELETE FROM global_log_access WHERE time = %s", (x['time'],))
        x['time'] = str(x['time'])
        try :
        	params_decoded = base64.standard_b64decode(x['params'])
        except :
        	params_decoded = 'error while decode(('
        s = "{} | {} | {} | {} | {}\n".format(x['time'], x['user'], x['accesspoint'], params_decoded, x['referer'])
        f.write(s)
        print(s)
    f.close()
    con.commit()
con.close()