# gregyankovoy/docker-chowdown Dockerfile (upstream container build)

Source URL(s) + fetch date:
- https://github.com/gregyankovoy/docker-chowdown/blob/9f355c82d5e74d0da93ec86d9cb32541ca6ca45c/Dockerfile (raw variant fetched 2026-11-26)

## What it is
Upstream community image that the draft's `container image` (`docker.io/gregyankovoy/chowdown`) is built from. It runs Jekyll on the chowdown source.

## Install/build steps and build deps
- `FROM gregyankovoy/alpine-base` (Alpine based).
- `COPY chowdown.sh /usr/local/bin/chowdown.sh`, then `RUN chmod +x /usr/local/bin/chowdown.sh`.
- Fetch step: `wget https://github.com/clarklab/chowdown/archive/gh-pages.zip` (unversioned branch zip), then `rm gh-pages.zip`, `mv chowdown-gh-pages /opt/app`.
- Packages: runtime `ruby ruby-json ruby-bigdecimal ruby-webrick ruby-etc libffi`; temporary `build-base ruby-dev libffi-dev` (deleted afterwards). Then `gem install jekyll --no-ri --no-rdoc`, `gem cleanup`, `apk del build-dependencies`.

## Runtime deps
Ruby + Jekyll (Alpine packages/gem).

## Binaries/entrypoint/CLI flags
- No ENTRYPOINT. `CMD [ "sh", "/usr/local/bin/chowdown.sh" ]`.
- chowdown.sh copies the source dirs into `/config` and runs `jekyll serve` there (per plan.md, not re-fetched).

## Ports
- `EXPOSE 4000` (Jekyll dev server).

## Volumes/paths and persistent data
- `VOLUME /config` (recipes are edited in /config and served live).

## Env vars
None read by the Dockerfile. (Plan notes PUID/PGID are only echoed by the script.)

## User/UID & permissions
Not set in the Dockerfile: runs as root.

## Gotchas
- Dockerfile as written is broken: the `wget ... gh-pages.zip \` line has no unzip command; the `mv chowdown-gh-pages /opt/app` line lacks a trailing backslash, which breaks the chain before `apk add`; `gem install ... --no-ri` is obsolete.
- Uses the moving `gh-pages` zip, no checksum or version pin.
- Contradicts draft.md "Ports: 80/http"; this upstream exposes 4000.
