# node-red upstream docs (index, Docker, local install)

Source URL(s) + date: https://nodered.org/docs (index only, no facts); https://nodered.org/docs/getting-started/docker ; https://nodered.org/docs/getting-started/local (fetched 2026-11-27)

## Docker (docs)
- Image: nodered/node-red (Docker Hub). Tags: latest, versioned e.g. 1.2.0-10-amd64; arch: amd64, arm32v6, arm32v7, arm64v8, s390x.
- Port: container 1880 -> `-p 1880:1880`. Editor: http://{host}:1880.
- Volume: /data (named volume or bind mount). Bind mount host dir must be owned by uid 1000.
- Env vars:
  - TZ (e.g. Europe/Amsterdam)
  - FLOWS (default flows.json)
  - NODE_RED_ENABLE_SAFE_MODE (false)
  - NODE_RED_ENABLE_PROJECTS (false)
  - NODE_OPTIONS (e.g. --max_old_space_size=128)
  - NODE_RED_CREDENTIAL_SECRET (referenced in settings.js as credentialSecret)
- User: default uid 1000. Permission fix: chown -R 1000:1000 on host data dir.
- Files in /data: settings.js, flows.json, flows_cred.json (credentials encrypted with system key unless credentialSecret set).
- Node-RED install dir: /usr/src/node-red.
- Healthcheck: none mentioned on the docs page.
- Serial/devices: --group-add dialout, --device=/dev/ttyACM0 (not required for container base).

## Local install (docs)
- npm: `sudo npm install -g node-red`; run `node-red`; editor http://localhost:1880.
- Default port 1880 (-p/--port). User dir ~/.node-red (-u/--userDir). Settings settings.js (-s/--settings). Flows flows.json.
- CLI: `node-red [-v] [-?] [--settings settings.js] [--userDir DIR] [--port PORT] [--title TITLE] [--safe] [flows.json|projectName] [-D X=Y|@file]`
- Needs a supported Node.js (listed in Node.js versions FAQ; npm engines node >=22.9 per package).

## Gotchas
- Docker docs use Docker Hub name nodered/node-red; chart uses GHCR ghcr.io/node-red/node-red.
- Docs index page had no facts; getting-started pages used instead.
