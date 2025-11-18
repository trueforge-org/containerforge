#!/usr/bin/env bash

if [[ ! -L "/app/medusa/Session.cfg" ]]; then
    ln -s /config/Session.cfg /app/medusa/Session.cfg
fi

export MEDUSA_COMMIT_BRANCH=master

exec python3 /app/medusa/start.py \
    --nolaunch --datadir /config

