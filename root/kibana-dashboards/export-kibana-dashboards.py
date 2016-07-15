# python export-kibana-dashboards.py http://localhost:9200 > data/dashboards.json

import sys, urllib, json

if len(sys.argv) < 2 :
    print("usage :  python export-kibana-dashboards.py http://localhost:9200 > file.json")
    exit()

elasticsearch_url = sys.argv[1]
query_url = elasticsearch_url + "/_search?q=dashboard:*&size=100"
response = urllib.urlopen(query_url)
data = json.loads(response.read())
dashboards = data['hits']['hits']

print(json.dumps(dashboards, sort_keys=True, indent=4))
