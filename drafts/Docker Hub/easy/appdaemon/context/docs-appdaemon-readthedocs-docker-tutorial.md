# appdaemon.readthedocs.io: Docker tutorial

**Source URL(s) + fetch date**
- https://appdaemon.readthedocs.io/en/latest/DOCKER_TUTORIAL.html (fetched 2026-11-26)

**Usage**
- Test run: `docker run --rm -it -p 5050:5050 -e HA_URL=... -e TOKEN=... -e DASH_URL="http://$HOSTNAME:5050" acockburn/appdaemon:latest` (TOKEN optional).
- Persistent run: `mkdir -p /docker/appdaemon/conf` then `docker run --name=appdaemon -d -p 5050:5050 --restart=always -e HA_URL -e TOKEN -e DASH_URL -v <your_conf_folder>:/conf acockburn/appdaemon:latest`.
- Env: `HA_URL` (`http://[name]:[port]`, usually 8123), `TOKEN`, `DASH_URL` (`http://$HOSTNAME:5050`), tag `latest` (stable) or `dev` (each merge).
- `/conf`: host path must be absolute. If the folder is new the container copies default configs; existing files are not overwritten.
- Entrypoint searches `/conf` recursively for `requirements.txt` (pip) and `system_packages.txt` (apk).
- Timezone fix: `-v /etc/localtime:/etc/localtime:ro`. Self-signed HA certs: `-v <cert_path>:/certs`.
- Debugging: `docker run --rm -it -p 5050:5050 -v <conf>:/conf acockburn/appdaemon:latest -D DEBUG` (extra args pass to appdaemon).
- The page does not mention a container user, UID/GID or permission settings.
