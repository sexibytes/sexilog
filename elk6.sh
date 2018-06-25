# Create new index with customized fields
curl -X PUT "localhost:9200/logstash-sexilog" -H 'Content-Type: application/json' -d'
{
  "settings" : {
      "number_of_replicas" : 0
  },
  "mappings": {
    "doc": { 
      "properties": { 
        "Correlator": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "alert": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "body_type_3": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "body_type_6": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "body_type_7": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "canonical_name": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "com_vmware": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "dashboard": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "datastore_name": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "esx_audit": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "esx_clear": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "esx_problem": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "failed_to": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "group": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "host": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "hostname": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "location": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "mbps": { "type": "integer" },
        "message": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "message_body": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "message_debug": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "message_program": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "message_syslog": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "microseconds": { "type": "integer" },
        "milliseconds": { "type": "integer" },
        "msg": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "nmp": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "pid": { "type": "integer" },
        "program": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "runtime_name": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "scsi_code": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "sense_data": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "syslog_facility": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "syslog_facility_code": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "syslog_pri": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "syslog_severity": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "syslog_severity_code": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "tags": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "title": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "type": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "user": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vim": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vm_name": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vmfs_uuid": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vmnic": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vmodl": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vmx_name": { "type": "text", "fields": { "raw": { "type":  "keyword" } } },
        "vob": { "type": "text", "fields": { "raw": { "type":  "keyword" } } }
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
