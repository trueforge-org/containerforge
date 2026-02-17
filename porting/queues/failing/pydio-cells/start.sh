#!/usr/bin/env bash





mkdir -p /config/keys
SERVER_IP=${SERVER_IP:-0.0.0.0}
if [[ -f "/config/keys/cert.crt" ]] && openssl x509 -in /config/keys/cert.crt -noout -text | grep -q "$SERVER_IP"; then
    echo "using existing self signed cert"
else
    echo "generating self signed cert with SAN $SERVER_IP"
    openssl req -new -x509 -days 3650 -nodes -out /config/keys/cert.crt -keyout /config/keys/cert.key -extensions 'v3_req' \
        -config <(printf "[req]\nprompt=no\ndistinguished_name=all_the_dn_details\nreq_extensions=v3_req\n[all_the_dn_details]\nC=US\nST=CA\nL=Carlsbad\nO=Linuxserver.io\nOU=LSIO Server\nCN=*\n[v3_req]\nsubjectAltName=DNS:pydio-cells,IP:${SERVER_IP}")
fi

if [[ -f /config/pydio.json ]]; then
    CURRENTURL=$(jq -r '.defaults.url' /config/pydio.json)
    if [[ "$CURRENTURL" != "$EXTERNALURL" ]]; then
        echo "Updating external url from environment variable."
        jq  ".defaults.url = \"$EXTERNALURL\"" /config/pydio.json > /tmp/pydio.json
        mv /tmp/pydio.json /config/pydio.json
    fi
fi

# permissions

    /app \
    /config





if [[ -f /config/pydio.json ]]; then
    RUN_OPTS="start --log=production"
else
    RUN_OPTS="configure --site_bind 0.0.0.0:8080 --site_external $EXTERNALURL --tls_cert_file /config/keys/cert.crt --tls_key_file /config/keys/cert.key"
fi

exec \

         /app/cells ${RUN_OPTS}

