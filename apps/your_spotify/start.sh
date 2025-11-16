# ===== From ./processed/your_spotify/root/etc/s6-overlay//s6-rc.d/init-your_spotify-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

VAR_PATH="/app/www/apps/client/build"

cp "$VAR_PATH/variables-template.js" "$VAR_PATH/variables.js"

export API_ENDPOINT="${APP_URL}/api"

if [[ -z "$API_ENDPOINT" ]]
then
    echo "API_ENDPOINT is not defined, web app won't work"
    exit 1
fi

echo "Setting API Endpoint to '$API_ENDPOINT'"
sed -i "s;__API_ENDPOINT__;$API_ENDPOINT;g" "$VAR_PATH/variables.js"

# Editing meta image urls
sed -i "s;image\" content=\"\(.[^\"]*\);image\" content=\"$API_ENDPOINT/static/your_spotify_1200.png;g" "$VAR_PATH/index.html"

# Restricting connect-src to API_ENDPOINT with a trailing /, or to * if hostname has an _
CSP_CONNECT_SRC=$API_ENDPOINT
if [[ "$CSP_CONNECT_SRC" == *_*.*.* ]]
then
    echo "It seems that your subdomain has an underscore in it, falling back to less strict CSP"
    CSP_CONNECT_SRC="*"
elif ! echo "$CSP_CONNECT_SRC" | grep -q "/$"
then
    CSP_CONNECT_SRC="$CSP_CONNECT_SRC/"
fi

sed -i "s#connect-src \(.*\);#connect-src 'self' $CSP_CONNECT_SRC;#g" "$VAR_PATH/index.html"

HOME="/app"

# ===== From ./processed/your_spotify/root/etc/s6-overlay//s6-rc.d/svc-your_spotify/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export API_ENDPOINT="${APP_URL}/api"
export CLIENT_ENDPOINT="${APP_URL}"

s6-setuidgid abc yarn --cwd /app/www/apps/server migrate

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8080" \
        cd /app/www/apps/server s6-setuidgid abc yarn start

