# Create new index with customized fields
curl -X PUT "localhost:9200/logstash-sexilog" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "doc": { 
      "properties": { 
        "dummyfieldtext3": {
          "type": "text",
          "fields": {
            "raw": { 
              "type":  "keyword"
            }
          }
        },
        "dummyfieldint3":  { "type": "integer" }
      }
    }
  }
}
'

set -euo pipefail
url="http://localhost:5601"
index_pattern="logstash-*"
id="logstash-*"
time_field="@timestamp"

# Create index pattern
# curl -f to fail on error
curl -f -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
  "$url/api/saved_objects/index-pattern/$id" \
  -d"{\"attributes\":{\"title\":\"$index_pattern\",\"timeFieldName\":\"$time_field\"}}"

# Make it the default index
curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
  "$url/api/kibana/settings/defaultIndex" \
  -d"{\"value\":\"$id\"}"

# Retrieve json data for index pattern
# curl -X GET "localhost:5601/api/index_patterns/_fields_for_wildcard?pattern=logstash-*" 

# Refresh index pattern by putting these data in the index pattern
# the index pattern 5cc05bc0-7594-11e8-aac5-f7fc6de727b6 should be retrieve programaticaly
# curl -X PUT 'localhost:5601/api/saved_objects/index-pattern/5cc05bc0-7594-11e8-aac5-f7fc6de727b6' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' -H 'kbn-xsrf: true' --data-binary '{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp","fields":"[#####blablafield#####]"}}' --compressed
