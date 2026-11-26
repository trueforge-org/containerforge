# GitHub: fletchto99/hexo-dev-docker (upstream of the reference image)

Source URL(s) + fetch date: https://github.com/fletchto99/hexo-dev-docker ; files read from https://raw.githubusercontent.com/fletchto99/hexo-dev-docker/master/Dockerfile and https://raw.githubusercontent.com/fletchto99/hexo-dev-docker/master/setup/run.sh · fetched 2026-11-26. Note: plan.md pins commit b92ba8c485a0b770f7f7110eb90bf3e920d21b4c; this fetch read the master branch, which may differ from that commit.

## What it is
Docker packaging of Hexo for `fletchto99/hexo-dev-blog`.

## Install/build steps and build deps (Dockerfile)
- `FROM node:26-bookworm-slim`
- apt: `apt-get update`, install `rsync`, `openssh-client`, `tini` (no recommends), then `rm -rf /var/lib/apt/lists/*`.
- `COPY package.json package-lock.json /opt/hexo-cli/`; `WORKDIR /opt/hexo-cli`; `RUN npm ci && npm cache clean --force`; `WORKDIR /`.
- `ENV PATH="/opt/hexo-cli/node_modules/.bin:$PATH"`
- `COPY setup /setup`

## Runtime deps
- tini (ENTRYPOINT), rsync and openssh-client (for deploy via hexo-deploy-rsync).

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["/usr/bin/tini", "--"]`, `CMD ["/bin/bash", "/setup/run.sh"]`.
- run.sh final command: `exec hexo server --cwd /config -p 8080 --debug --draft`.

## Env vars (table)
| Name | Use |
| --- | --- |
| HEXO_PLUGINS | space-separated npm plugin names; each name without a version gets `@latest` appended; runs `npm install -C /config` |

## Ports
- `EXPOSE 8080`. HEALTHCHECK: Node one-liner GET to localhost:8080, expects HTTP 200; interval 30s, timeout 5s, start period 10s, 3 retries.

## Volumes/paths and persistent data
- No VOLUME instruction in the Dockerfile. run.sh requires `/config` to be a directory; if empty, runs `hexo init /config`; otherwise skips init.

## User/UID & permissions
- No USER instruction (runs as root in the upstream image).

## Healthcheck/readiness endpoints
- HTTP GET on localhost:8080, must return 200.

## Config files and formats
- Hexo config is `_config.yml` in `/config` (created by hexo init).

## Gotchas
- Upstream run.sh uses `set -e`, and fails with a message if `/config` is not a directory.
- Upstream forces `@latest` on any plugin name without a version on every start. Plan.md does not do this (deliberate deviation, recorded in plan.md section 7).
- Contradiction with plan.md: plan.md says `CMD /setup/run.sh` and the FROM/npm/apt facts match; the upstream Dockerfile has a HEALTHCHECK which the plan does not mention.
- Plan.md's `hexo clean` and the final exec line match run.sh.
