#!/usr/bin/env bash

# Check if an alternative port was defined, set it to it or default
if [ ! -z ${INTPORT} ]; then
	port=$INTPORT
else
	port=6595
fi

# Check if the ARL environment var is set to anything. This enables legacy behavior
if [ ! -z ${ARL} ]; then
	export DEEMIX_SINGLE_USER=true
fi

export DEEMIX_DATA_DIR=/config/
export DEEMIX_MUSIC_DIR=/downloads/
export DEEMIX_SERVER_PORT=$port
export DEEMIX_HOST=0.0.0.0

echo "Starting Deemix"
exec /app/deemix-server
