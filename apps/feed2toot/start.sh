#!/usr/bin/env bash


if [[ ! -f /config/feed2toot.ini ]]; then
    cp /defaults/feed2toot.ini /config/feed2toot.ini
fi

touch /config/hashtags.txt

## TODO: Find exec
