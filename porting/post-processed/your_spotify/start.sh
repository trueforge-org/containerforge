#!/usr/bin/env bash
# NONROOT_COMPAT
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  shopt -s expand_aliases
  alias apk=':'
  alias apt-get=':'
  alias chown=':'
  alias chmod=':'
  alias usermod=':'
  alias groupadd=':'
  alias adduser=':'
  alias useradd=':'
  alias setcap=':'
  alias mount=':'
  alias sysctl=':'
  alias service=':'
  alias s6-svc=':'
fi

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

export API_ENDPOINT="${APP_URL}/api"
export CLIENT_ENDPOINT="${APP_URL}"

yarn --cwd /app/www/apps/server migrate
cd /app/www/apps/server
exec  yarn start

