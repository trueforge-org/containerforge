# GitHub: ich777/docker-starmade (branch master)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-starmade/master/Dockerfile , .../scripts/start.sh (fetched 2026-11-27)

## Dockerfile
- FROM `ich777/debian-baseimage`
- LABEL source=https://github.com/ich777/docker-starmade, authors admin@minenet.at
- ENV defaults:
| var | default |
| --- | --- |
| DATA_DIR | /starmade |
| RUNTIME_NAME | basicjre |
| JAR_NAME | template |
| DL_URL | http://files.star-made.org/StarMade-Starter.jar |
| GAME_PARAMS | "" |
| XMX_SIZE / XMS_SIZE | 1024 / 1024 |
| EXTRA_JVM_PARAMS | "" |
| STARTER_PARAMS | -nogui |
| UMASK | 000 |
| UID / GID | 99 / 100 |
| USER | starmade |
| DATA_PERM | 770 |
- RUN: `mkdir $DATA_DIR`; `useradd -d $DATA_DIR -s /bin/bash $USER`; `chown -R $USER $DATA_DIR`; `ulimit -n 2048`.
- ADD scripts/ -> /opt/scripts/ (chmod 770); COPY server.cfg -> /tmp/server.cfg.
- ENTRYPOINT `["/opt/scripts/start.sh"]`. No EXPOSE, no USER directive.

## start.sh (bash, runs as root)
- usermod -u ${UID} ${USER}; groupmod -g ${GID}; usermod -g ${GID}.
- umask ${UMASK}.
- Optional hook: /opt/custom/user.sh or /opt/scripts/user.sh copied to start-user.sh and executed if present.
- chown -R root:${GID} /opt/scripts; chmod -R 750 /opt/scripts; chown -R ${UID}:${GID} ${DATA_DIR}.
- Traps SIGTERM; runs `su ${USER} -c "/opt/scripts/start-server.sh"` in background; waits; exits 0.
- start-server.sh not fetched.

## Arch
- Not stated in these files.

## Gotchas
- Script runs as root and remaps UID/GID at start, then drops to USER via su.
