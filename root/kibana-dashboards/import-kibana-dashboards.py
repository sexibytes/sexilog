# python import-kibana-dashboards.py http://localhost:9200 < file.json
 
import sys, httplib, urllib2, json
 
if len(sys.argv) < 2 :
    print("usage :  python import-kibana-dashboards.py http://localhost:9200 < file.json")
    exit()
 
elasticsearch_url = sys.argv[1]
post_dashboard_url = elasticsearch_url + "/kibana-int/dashboard"
 
json_dashboards = sys.stdin.read()
dashboards = json.loads(json_dashboards)
 
for dashboard in dashboards:
    try:
        print("Importation de %s" % dashboard["_id"])
        data = json.dumps(dashboard['_source'])
 
        url = post_dashboard_url + "/" + urllib2.quote(dashboard["_id"])
        req = urllib2.Request(url, data)
        req.add_header('Content-Length', str(len(data)))
        req.add_header('Content-Type', 'application/octet-stream')
        res = urllib2.urlopen(req)
        print(res)
    except  httplib.BadStatusLine as e:
        print(e)
