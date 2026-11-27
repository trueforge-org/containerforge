#!/usr/bin/env bash
# Seeded into /config/cronjob.sh only when missing. Edit the copy in /config, not this file.
# UNVERIFIED: modelled on the upstream cronjob.sh call (owi2plex -h -u -p -b -o). The full upstream script was not read.
# Caveat: -p puts the password in the process list (upstream does the same). Replace the placeholders below.
set -eu

owi_ip="192.168.1.103"
owi_user="root"
owi_pass="password"
bouquets="UHD SPORT"

for bouquet in ${bouquets}; do
  owi2plex \
    -h "${owi_ip}" \
    -u "${owi_user}" \
    -p "${owi_pass}" \
    -b "${bouquet}" \
    -o "/config/owi2plex/enigma${bouquet}.xml"
done
