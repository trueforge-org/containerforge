#!/usr/bin/with-contenv bash
set -e

STAMP="/config/.grafana-setup-complete"

if [ -f ${STAMP} ]; then
  echo "grafana already configured, nothing to do."
  exit 0
fi

mkdir -p /config/etc/grafana /config/var/lib/grafana /config/var/log/grafana

cp /etc/grafana/grafana.ini /config/etc/grafana

/usr/sbin/grafana-server --homepath=/usr/share/grafana --config=/config/etc/grafana/grafana.ini cfg:default.paths.data=/config/var/lib/grafana cfg:default.paths.logs=/config/var/log/grafana 2>&1 &
GRAFANA_PID=$!

until nc -z -v -w5 localhost 3000 < /dev/null; do sleep 1; done

# create influxdb datasource
curl 'http://admin:admin@localhost:3000/api/datasources' \
    -X POST -H "Content-Type: application/json" \
    --data-binary <<DATASOURCE \
      '{
        "name":"influx",
        "type":"influxdb",
        "url":"http://localhost:8086",
        "access":"proxy",
        "isDefault":true,
        "database":"inforad",
        "user":"n/a","password":"n/a"
      }'
DATASOURCE
echo

kill ${GRAFANA_PID}
touch ${STAMP}
