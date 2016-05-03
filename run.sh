#!/bin/sh -e

set -m
GRAFANA_BIN=/bin/grafana-server
envtpl /etc/grafana/config-influxdb.js.tpl
envtpl /usr/share/grafana/conf/defaults.ini.tpl

: "${GF_PATHS_DATA:=/var/lib/grafana}"
: "${GF_PATHS_LOGS:=/var/log/grafana}"
: "${GF_PATHS_PLUGINS:=/var/lib/grafana/plugins}"

if [ ! -x $GRAFANA_BIN ]; then
  echo "can't find executable at $GRAFANA_BIN"
  exit 1
fi

API_URL="http://localhost:3000"
wait_for_start_of_grafana(){
    #wait for the startup of grafana
    local retry=0
    while ! curl ${API_URL} 2>/dev/null; do
        retry=$((retry+1))
        if [ $retry -gt 15 ]; then
            echo "\nERROR: unable to start grafana"
            exit 1
        fi
        echo -n "."
        sleep 1
    done
    echo
}

exec "$GRAFANA_BIN" \
  --homepath=/usr/share/grafana             \
  cfg:default.paths.data="$GF_PATHS_DATA"   \
  cfg:default.paths.logs="$GF_PATHS_LOGS"   \
  cfg:default.paths.plugins="$GF_PATHS_PLUGINS" \
  web &
ps auwx | grep -q $GRAFANA_BIN || exit 1
wait_for_start_of_grafana

if [ ! -f /.ds_is_configured ]; then
    echo "configure datasources..."
    curl "http://$GRAFANA_USER:$GRAFANA_PASS@127.0.0.1:3000/api/datasources" -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary @/etc/grafana/config-influxdb.js
    touch /.ds_is_configured
fi

echo "bringing back init process in foreground"
wait
