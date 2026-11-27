#!/usr/bin/env bash
set -e

mkdir -p /config/glib-2.0/settings /tmp/runtime /tmp/cache
chmod 700 /tmp/runtime
export HOSTS="${HOSTS:-['qemu:///system']}"

# Broadway web server, bound to all interfaces. UNVERIFIED: broadwayd flags and port (GTK docs).
broadwayd --address 0.0.0.0 --port 8085 :5 &
sleep 1

# HOSTS is passed through the environment, not interpolated into the shell string.
# UNVERIFIED: ssh host keys must be provided by the user (no StrictHostKeyChecking override).
exec dbus-run-session -- bash -c '
  gsettings set org.virt-manager.virt-manager.connections uris "$HOSTS"
  gsettings set org.virt-manager.virt-manager.connections autoconnect "$HOSTS"
  gsettings set org.virt-manager.virt-manager xmleditor-enabled true
  exec virt-manager --no-fork
'
