#!/usr/bin/env bash


mkdir -p /tmp/haproxy

if [ "${DISABLE_IPV6}" = 1 ]; then
    BIND_PROTO=":2375"
else
    BIND_PROTO="[::]:2375 v4v6"
fi

sed "s/@@BIND_PROTO@@/${BIND_PROTO}/g" /defaults/haproxy.cfg > /tmp/haproxy/haproxy.cfg

exec /usr/sbin/haproxy -f /tmp/haproxy/haproxy.cfg -W -db
