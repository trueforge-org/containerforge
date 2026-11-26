# context: domoticz

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/domoticz/domoticz (README via raw master) | github-domoticz-domoticz.md | 2026-11-26 |
| https://github.com/domoticz/domoticz/releases/latest | github-domoticz-domoticz.md | 2026-11-26 |
| https://github.com/domoticz/domoticz-docker/blob/master/Dockerfile (fetched as raw master) | github-domoticz-domoticz-docker-dockerfile.md | 2026-11-26 |
| https://raw.githubusercontent.com/domoticz/domoticz-docker/master/docker-entrypoint.sh (followed from the Dockerfile COPY) | github-domoticz-domoticz-docker-entrypoint.md | 2026-11-26 |
| https://hub.docker.com/r/domoticz/domoticz | dockerhub-domoticz-domoticz.md | 2026-11-26 |
| https://www.domoticz.com | docs-domoticz-com.md | 2026-11-26 |
| https://wiki.domoticz.com/ | docs-domoticz-wiki-home.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/domoticz (read via raw values.yaml) | truecharts-domoticz.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link.
- https://github.com/domoticz/domoticz/releases/download/${VERSION}/domoticz_linux_${A}.tgz (and `.tgz.sha256sum`), and the 2026.4 x86_64/aarch64 tgz and sha256sum URLs: direct archive and checksum downloads. Naming recorded in github-domoticz-domoticz.md / the plan.
- http://127.0.0.1:8080/json.htm?type=command&param=getversion: localhost.

## Fetch failures
- `https://raw.githubusercontent.com/domoticz/domoticz-docker/master/entrypoint.sh`: 404. Retried once with the correct name `docker-entrypoint.sh`, which succeeded.
- releases/latest: asset list failed to load; no checksums visible.

## plan.md corrections
- None made. Confirmed from context: 2026.4 latest (commit cc668a1), upstream debian trixie-slim + python compiler stage, apt list, env names (WWW_PORT, SSL_PORT, LOG_PATH, DATABASE_PATH, EXTRA_CMD_ARG, TZ), EXPOSE 8080 443, VOLUME, entrypoint command line, rsync sources and `--ignore-existing` behaviour, `chown 1000:1000`, chart image digest for 2026.4.
- Unverified (left as-is): plan.md's GPL-3.0 "only" vs "or later"; plan's checksum file names and sha256 values (not visible on the release page); plan.md's `-wwwbind` default `0.0.0.0` and `-sslwww 0` meaning; "Python plugins need libpython" (not checked); plan.md's "with no password set the UI is open to anyone". The wiki says the default login is `admin/domoticz`, and the README says setup creates the admin account or uses `DOMOTICZ_ADMIN_PASSWORD`. These are not reconciled, so the plan's risk note is left as written.
- Note: upstream's bundled plugins are rsynced with `--update` (replaced when the image is newer). plan.md uses copy-if-missing and documents this difference already.
