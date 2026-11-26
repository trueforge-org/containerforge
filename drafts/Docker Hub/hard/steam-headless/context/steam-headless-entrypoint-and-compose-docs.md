# overlay/entrypoint.sh + docs/docker-compose.md (Steam-Headless)

Source URL(s): https://github.com/Steam-Headless/docker-steam-headless/blob/824c88d/overlay/entrypoint.sh (raw); https://raw.githubusercontent.com/Steam-Headless/docker-steam-headless/master/docs/docker-compose.md (fetched 2026-11-26)

## entrypoint.sh (bash, 93 lines)
- Runs `exec $@` when args are passed (line ~16)
- `chown -R ${USER} ${USER_HOME}/init.d` (user scripts dir; scripts ending .sh in ~/init.d run at startup per README)
- Starts supervisord last: `exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon --user root`
- Uses env: USER, USER_HOME (others in the supervisord config, not fetched)

## docs/docker-compose.md
- Compose templates in repo: compose-files/docker-compose.amd+intel.privileged.yml (full host device access), docker-compose.nvidia.yml, docker-compose.nvidia.privileged.yml
- Non-privileged mode needs explicit /dev/dri card + renderD selection (per-card passthrough; example Intel card1 / renderD128)
- NVIDIA: privileged or non-privileged templates; NVIDIA runtime needed (not detailed here)
- Doc shows `ls -la /sys/class/drm/card*` steps for picking devices.
