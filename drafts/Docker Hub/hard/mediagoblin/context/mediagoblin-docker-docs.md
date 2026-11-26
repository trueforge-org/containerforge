# MediaGoblin Docker chapter (official image)

**Source:** https://docs.mediagoblin.org/en/stable/siteadmin/docker.html (fetched 2026-11-26)

## Images / build
- Docker Hub `mediagoblin/mediagoblin:<VERSION>` (since 0.14.0; docs show `:unknown` and `:0.14.0.dev`).
- Nginx: `mediagoblin/nginx:unknown` (Dockerfile.nginx).
- Build: `./configure && make` (prefers Docker unless `--without-docker`); tag from `configure.ac` version.
- Custom build: `docker build .`, ARGs via `--build-arg`.
- Build is multi-stage; tests run inside a container.
- Not in image: unoconv (Documents), blender (STL).

## Run
```
docker run --interactive --tty \
  --publish=6543:6543 --volume=/PATH/TO/YOUR/DATA:/srv \
  mediagoblin/mediagoblin:unknown
```
- Bind-mount path must be absolute (relative = named volume).
- Compose: `docker-compose.standalone.yml` (single), `docker-compose.yml` (paste+celery+RabbitMQ), `docker-compose.nginx.yml` override.

## Ports
- 6543 (waitress 0.0.0.0:6543).

## Volumes / paths
- Data: `/srv` (contains mediagoblin/, mediagoblin.db, mediagoblin.ini, paste.ini, user_dev/).
- App: `/opt/mediagoblin` (venv under `/opt/mediagoblin/lib/python3.11/...`).
- Plugin statics: `/srv/user_dev/plugin_static/...`.

## Env vars (first init)
| Name | Default | Purpose |
|---|---|---|
| ADMIN_USER | admin | admin username |
| ADMIN_PASSWORD | generateme | autogenerates; printed once in logs |
| ADMIN_EMAIL | admin@example.com | admin email (verified) |
| PLUGINS | none | `[plugins]` snippet, applied on empty data dir only |
| FORCE_RECONFIG | unset | `true` forces reconfigure (not well tested) |

- Multi-container: extra vars point to RabbitMQ.

## Entrypoint behaviour
- First run with no config/DB: creates paste.ini, mediagoblin.ini, mediagoblin.db (sqlite); runs migrations; creates admin.
- Default run: `/opt/mediagoblin/lazyserver.sh -c ./paste.ini --server-name=broadcast`; `CELERY_ALWAYS_EAGER=true`; `paster serve ... --reload`.
- `usermod: no changes` in startup log; no UID stated.

## Admin password change
- `gmg changepw admin <PASSWORD>` via docker run on the same image and volume.

## Services (multi-container)
- paste, celery (same image, different command), RabbitMQ, optional nginx. Celery healthcheck adjusted.
