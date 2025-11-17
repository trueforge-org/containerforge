#!/usr/bin/env bash


cp -n /defaults/sync.conf /config/sync.conf




  exec rslsync \
        --nodaemon --config /config/sync.conf

