#!/usr/bin/env bash


mkdir -p \
    /app/www/tmp \
    /config/mastodon/public/system

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
     /usr/bin/bundle exec rails db:prepare
fi

if [[ ${NO_CHOWN,,} != "true" ]]; then

        /config
fi


export RAILS_ENV=production
export PATH="${PATH}:/app/www/bin"
export RAILS_SERVE_STATIC_FILES=false
export HOME=/config

cd /app/www

## TODO: deal with multiexec
exec /usr/bin/bundle exec rails s -p 3000

cd /app/www
exec /app/www/bin/prometheus_exporter


if [[ -n ${SIDEKIQ_THREADS} ]]; then
    SIDEKIQ_THREADS=$(printf '%d' "${SIDEKIQ_THREADS}")
else
    SIDEKIQ_THREADS=$(printf '%d' 5)
fi

cd /app/www || exit 1

if [[ ${SIDEKIQ_ONLY,,} == "true" ]] && [[ -n ${SIDEKIQ_QUEUE} ]]; then
    echo "*** Starting sidekiq handling ${SIDEKIQ_QUEUE} queue with ${SIDEKIQ_THREADS} threads ***"
    exec \
         /usr/bin/bundle exec "sidekiq -q ${SIDEKIQ_QUEUE} -c ${SIDEKIQ_THREADS}"
elif [[ ${SIDEKIQ_ONLY,,} == "true" ]] && [[ -z ${SIDEKIQ_QUEUE} ]]; then
    echo "*** No sidekiq queue specified, aborting ***"
    sleep infinity
elif [[ ${SIDEKIQ_DEFAULT,,} == "true" ]]; then
    echo "*** Starting sidekiq handling default queue with ${SIDEKIQ_THREADS} threads ***"
    exec \
         /usr/bin/bundle exec "sidekiq -q default -c ${SIDEKIQ_THREADS}"
else
    echo "*** Starting sidekiq handling all queues with ${SIDEKIQ_THREADS} threads ***"
    exec \
         /usr/bin/bundle exec "sidekiq -c ${SIDEKIQ_THREADS}"
fi

cd /app/www
exec node ./streaming

