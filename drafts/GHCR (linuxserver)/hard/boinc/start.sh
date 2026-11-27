#!/usr/bin/env bash

mkdir -p /config

# UNVERIFIED: flag names, confirm with `boinc --help` on the build.
# The GUI RPC must listen on all interfaces, and needs an auth password (gui_rpc_auth.cfg) that is not baked into the image.
exec boinc --dir /config --allow_remote_gui_rpc
