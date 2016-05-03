{
    "name":"elasticsearch",
    "type":"elasticsearch",
    "url":"{{ ELASTIC_PROTO | default("http") }}://{{ ELASTIC_HOST | default("localhost") }}:{{ ELASTIC_PORT | default("9200") }}",
    "access":"{{ ELASTIC_ACCESS | default("proxy") }}",
    "isDefault": false
}
