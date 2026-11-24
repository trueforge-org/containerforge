# hoobs — implementation plan
> Source: ./draft.md · Target: apps/hoobs/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | npm `@hoobs/hoobs` 3.3.12 (latest on the registry). The draft's `npm:hoobs` package name returns 404 on the registry; the real package is `@hoobs/hoobs`. The Docker Hub image `hoobs/hoobs:latest` is unpinned, and its inner version is UNVERIFIED. |
| Renovate | `datasource=npm depName=@hoobs/hoobs versioning=semver` |
| License | GPL-3.0 (npm metadata, and GitHub repo shows GPL-3.0; SPDX `GPL-3.0-only`, UNVERIFIED -only/-or-later) |
| Source URL | https://github.com/hoobs-org/HOOBS (npm metadata points at `hoobs-org/hoobs-core`; reconcile when implementing) |
| Download | `npm install @hoobs/hoobs@${VERSION}`; no per-arch binary, but dependencies include native `node-pty` and optionally `bufferutil`/`utf-8-validate`, compiled per arch. |
| Checksum | npm registry integrity (sha512) is checked by npm automatically; use `npm ci`-style lockfile is not available; pin exact version. |
| Package facts | bin `hoobs` -> `bin/hoobs`; engines `node >=10.16.0`; deps include express, express-ws, homebridge ^1.3.4, node-pty, systeminformation, @hoobs/migration; `postinstall` runs `bin/hoobs upgrade` (write side effect), `prepare` runs the build. |
| Upstream Dockerfile | None found (draft says none public; HOOBS repo has no Dockerfile). Image internals are UNVERIFIED. |
| Ports | Draft says 8581/http (inferred, and it is Homebridge UI's default). HOOBS' own default web port is UNVERIFIED (older docs use 80). Verify by running `hoobs/hoobs` and `ss -ltn`. |
| Data dir | Draft: `/hoobs` (pvc). Flag/env to relocate is UNVERIFIED (check `hoobs --help`). |
| Dependencies | none |
| Project health | The HOOBS repo shows no Releases entries; maintenance status UNVERIFIED (possibly stale). |

## 2. Target layout

```
apps/hoobs/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` unless first-run seeding turns out to need a template (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Node plus Python for node-gyp as the draft proposes). Concern: python-node ships a recent Node (the ubuntu base currently ships Node 26.13.1); `node-pty` and homebridge 1.3 era code may not build on it. Fallback: install an older Node LTS from nodejs.org tarball (with SHASUMS256 verification, as in `apps/ubuntu/Dockerfile`) into `/usr/local`. Closest sibling: `apps/changedetection` (python-node plus npm tooling).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/tmp npm_config_cache=/tmp/npm npm_config_update_notifier=false`.
2. `apt-get install -y --no-install-recommends build-essential libavahi-compat-libdnssd-dev` only if `ldd`/build shows they are required (the dns-sd compat library is common for HomeKit mDNS plugins; UNVERIFIED need). Purge `build-essential` after the install, as `apps/changedetection` does.
3. `npm install --prefix /app/hoobs --omit=dev --ignore-scripts @hoobs/hoobs@${VERSION}` first, then run the build/native steps deliberately (`npm rebuild node-pty`). Avoid the `postinstall` `hoobs upgrade` writing outside `/app`; if it is required, run it with HOME and its data path pointed to a throwaway dir during the build. UNVERIFIED which steps upstream needs.
4. Symlink `/usr/local/bin/hoobs` -> `/app/hoobs/node_modules/.bin/hoobs`.
5. License: copy the package `LICENSE` (from `node_modules/@hoobs/hoobs/`) into `/usr/share/licenses/hoobs/`; also keep the dependency license files that npm already places in `node_modules`.
6. Cleanup `/tmp/*`, `$HOME/.npm`, apt lists.
7. `COPY --chmod=0755 . /`, `EXPOSE <port, UNVERIFIED; 8581 per draft>`, `VOLUME /config`, `WORKDIR /config`, `USER apps`.
8. Version alignment: `ARG VERSION` and bake default both `3.3.12`.

## 5. docker-bake.hcl

`APP="hoobs"`, `LICENSE="GPL-3.0-only"` (confirm), `SOURCE="https://github.com/hoobs-org/HOOBS"`, `VERSION` default `"3.3.12"` preceded by `// renovate: datasource=npm depName=@hoobs/hoobs versioning=semver`. Targets `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64+arm64), group default `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/hoobs-org/HOOBS"`.
- ports: the web UI port (draft 8581, UNVERIFIED; replace with the real one after running upstream), `tcp`, `required: false`. HomeKit bridge ports (HAP, random per bridge) and mDNS/UDP 5353 are not declared; document in the PR that host networking or a multicast-capable network is needed.
- env: `TZ` (`"Etc/UTC"`), plus only env vars confirmed to be read by `hoobs` (none confirmed yet; UNVERIFIED).
- volumes: `/config` required true (the draft's `/hoobs` data dir, mapped by start.sh).
- dependencies: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Ensure `/config` exists; create the HOOBS instance directory under `/config` only if missing (HOOBS creates its own tree on first start; command and flag e.g. `hoobs -d /config` or env are UNVERIFIED, check `hoobs --help` and `bin/hoobs` source).
- Keep caches in `/tmp` (`HOME=/tmp`, but HOOBS may write dotfiles under HOME; if it does, set `HOME=/config`).
- Bind on all interfaces (confirm the default host; express listen host UNVERIFIED).
- Plugins are installed at runtime from npm into the data dir; ensure the data dir under `/config` is the plugin install target, not `/app`.
- `exec hoobs <service/start subcommand>` (UNVERIFIED subcommand; the CLI uses commander).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
- port: '<web port, UNVERIFIED, 8581 per draft>'
filePaths:
- /start.sh
- /usr/local/bin/hoobs
- /usr/share/licenses/hoobs/LICENSE
```

If the web UI only starts after setup in the UI, the tcp probe may fail; then keep the filePaths and a `runners` entry `hoobs --version`, but only after observing the real behavior, never weaken afterwards. Timeout 240 reflects a slow first start with plugin install (siblings use 180 to 240).

## 9. Rootless and read-only-rootfs adaptations

- Draft: chart UID 0, `readOnlyRootFilesystem: false`, `/hoobs` pvc. Target UID 568, read-only rootfs.
- Write paths: instance data and plugins (npm installs) into `/config`; npm cache into `/tmp`; `/app/hoobs` must remain read-only. HOOBS may try `sudo`/global installs for upgrade or plugin features (UNVERIFIED); those must be disabled or redirected.
- mDNS/avahi: `avahi-daemon` cannot run rootless without D-Bus; relying on the library's built-in `bonjour`-style mDNS (UNVERIFIED) with host networking.

## 10. Risks, caveats and open questions

- No public Dockerfile; image behavior is not reproducible from sources; port, flags and data dir are all unverified. The first implementation step is to run `hoobs/hoobs` and record its listening ports, env, filesystem writes (`docker diff`) and process tree.
- Package looks old (engines >=10.16, homebridge 1.3); may not run on current Node. This could be a blocker; decide after a trial.
- Runtime npm plugin installs need internet access and make first start slow.
- HomeKit discovery needs mDNS (host network or macvlan).
- `postinstall` runs `hoobs upgrade` at install time.
- License: GPL-3.0 and trademark notice on HOOBS name/logo.

## 11. Build and test steps

```sh
cd apps/hoobs
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name hoobs-probe --read-only --tmpfs /tmp -v hoobs-probe-config:/config -p <port>:<port> hoobs:3.3.12
docker logs -f hoobs-probe
forgetool containers test --image hoobs:3.3.12 --config ./apps/hoobs/container-test.yaml
docker rm -f hoobs-probe; docker volume rm hoobs-probe-config
```

Expected readiness: HOOBS "listening"/"started" line for the web UI (exact text UNVERIFIED) and the port open; container stays up after 60 s with no stack traces. Before building, compare behavior against `docker run hoobs/hoobs:latest`.

## 12. PR checklist

- Branch `feat/add-hoobs`; commit and PR title `feat(hoobs): add new container`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- bake print, version alignment, `USER apps`, empty `/config`, read-only rootfs.
- Untested at plan time: everything; the port, data-dir flag, Node compatibility, license -only/-or-later and arm64 native build are all unverified.
