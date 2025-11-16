# ===== From ./processed/mastodon/root/etc/s6-overlay//s6-rc.d/init-mastodon-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p \
    /app/www/tmp \
    /config/mastodon/public/system

lsiown -R abc:abc \
    /app/www/tmp

# Remove old pid in the event of an unclean shutdown
if [[ -f /app/www/tmp/pids/server.pid ]]; then
    rm /app/www/tmp/pids/server.pid
fi

if [[ ! -L "/app/www/public/system" ]]; then
    rm -rf "/app/www/public/system"
    ln -s "/config/mastodon/public/system" "/app/www/public/system"
fi

cd /app/www/ || exit 1

# Don't run DB prep if this is a sidekiq-only container
if [[ ${SIDEKIQ_ONLY,,} != "true" ]]; then
    s6-setuidgid abc /usr/bin/bundle exec rails db:prepare
fi

if [[ ${NO_CHOWN,,} != "true" ]]; then
    lsiown -R abc:abc \
        /config
fi

# ===== From ./processed/mastodon/root/etc/s6-overlay//s6-rc.d/svc-mastodon/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export RAILS_ENV=production
export PATH="${PATH}:/app/www/bin"
export RAILS_SERVE_STATIC_FILES=false

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3000" \
    cd /app/www s6-setuidgid abc /usr/bin/bundle exec rails s -p 3000

# ===== From ./processed/mastodon/root/etc/s6-overlay//s6-rc.d/svc-prom/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export RAILS_ENV=production
export HOME=/config
export PATH="${PATH}:/app/www/bin"

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${PROMETHEUS_EXPORTER_PORT:-9394}" \
    cd /app/www s6-setuidgid abc /app/www/bin/prometheus_exporter

# ===== From ./processed/mastodon/root/etc/s6-overlay//s6-rc.d/svc-sidekiq/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export RAILS_ENV=production
export PATH="${PATH}:/app/www/bin"

if [[ -n ${SIDEKIQ_THREADS} ]]; then
    SIDEKIQ_THREADS=$(printf '%d' "${SIDEKIQ_THREADS}")
else
    SIDEKIQ_THREADS=$(printf '%d' 5)
fi

cd /app/www || exit 1

if [[ ${SIDEKIQ_ONLY,,} == "true" ]] && [[ -n ${SIDEKIQ_QUEUE} ]]; then
    echo "*** Starting sidekiq handling ${SIDEKIQ_QUEUE} queue with ${SIDEKIQ_THREADS} threads ***"
    exec \
        s6-setuidgid abc /usr/bin/bundle exec "sidekiq -q ${SIDEKIQ_QUEUE} -c ${SIDEKIQ_THREADS}"
elif [[ ${SIDEKIQ_ONLY,,} == "true" ]] && [[ -z ${SIDEKIQ_QUEUE} ]]; then
    echo "*** No sidekiq queue specified, aborting ***"
    sleep infinity
elif [[ ${SIDEKIQ_DEFAULT,,} == "true" ]]; then
    echo "*** Starting sidekiq handling default queue with ${SIDEKIQ_THREADS} threads ***"
    exec \
        s6-setuidgid abc /usr/bin/bundle exec "sidekiq -q default -c ${SIDEKIQ_THREADS}"
else
    echo "*** Starting sidekiq handling all queues with ${SIDEKIQ_THREADS} threads ***"
    exec \
        s6-setuidgid abc /usr/bin/bundle exec "sidekiq -c ${SIDEKIQ_THREADS}"
fi

# ===== From ./processed/mastodon/root/etc/s6-overlay//s6-rc.d/svc-streaming/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export NODE_ENV=production
export PATH="${PATH}:/app/www/bin"

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 4000" \
    cd /app/www s6-setuidgid abc node ./streaming

