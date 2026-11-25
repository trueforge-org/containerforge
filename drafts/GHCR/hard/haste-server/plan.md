# haste-server — implementation plan
> Source: ./draft.md · Target: apps/haste-server/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Draft container | `ghcr.io/k8s-at-home/haste-server:latest` (rolling tag, not pinnable). Docker Hub lookup for `k8s-at-home/haste-server` returned "object not found" (https://hub.docker.com/v2/repositories/k8s-at-home/haste-server/). The GHCR image may no longer exist: UNVERIFIED. |
| Upstream `seejohnrun/haste-server` | Not reachable in this run (GitHub API and raw `master/package.json` both 404). UNVERIFIED. |
| Fork used by the draft | `nzzane/haste-server`: default branch `master`, not archived, last push 2021-03-01, no SPDX license, no releases (https://api.github.com/repos/nzzane/haste-server). |
| Fork Dockerfile | https://api.github.com/repos/nzzane/haste-server/contents/Dockerfile: `FROM node:14.8.0-stretch` (EOL Debian stretch, Node 14), `USER node:node`, `WORKDIR /usr/src/app`, npm install plus pinned extras (`redis@0.8.1`, `pg@4.1.1`, `memcached`, `aws-sdk`, `rethinkdbdash`), `VOLUME /app/data`, `EXPOSE ${PORT}`, `ENTRYPOINT ["bash","docker-entrypoint.sh"]`, `CMD ["npm","start"]`. |
| Fork env (Dockerfile) | `STORAGE_TYPE=file`, `STORAGE_FILEPATH=/app/data`, `HOST=0.0.0.0`, `PORT=7777`, `KEY_LENGTH=10`, `MAX_LENGTH=400000`, `STATIC_MAX_AGE=86400`, `RECOMPRESS_STATIC_ASSETS=true`, `KEYGENERATOR_TYPE=phonetic`, `LOGGING_LEVEL=verbose`, `LOGGING_TYPE=Console`, `LOGGING_COLORIZE=true`, `DOCUMENTS=about=./about.md`, `RATELIMITS_NORMAL_TOTAL_REQUESTS=500`, `RATELIMITS_NORMAL_EVERY_MILLISECONDS=60000` |
| Fork config.js | Matches the env defaults above (host 0.0.0.0, port 7777, file storage, phonetic keys). |
| Fork package.json | `name: haste`, `version: 0.1.0`, `"private": true`, no license field, `scripts.start: node server.js`, dependencies include `redis 0.8.1`, `connect ^3.7.0`, `winston ^2.0.0`, `uglify-js 3.1.6`. |
| npm `haste-server` | Latest fetched: 0.2.1 (a different fork by Jakub Jirutka), MIT, `bin: server.js`. Not verified to be the same code as the nzzane fork. https://registry.npmjs.org/haste-server/latest |
| Latest stable version | None for the nzzane fork (no tags, no releases). Nothing to pin. |
| Renovate | UNVERIFIED: no pinnable upstream version. Do not add a renovate datasource until a source is chosen. |
| Ports | `7777/tcp` (HTTP web UI and API), from the fork's `PORT` default. |
| Data path | `/app/data` (fork `VOLUME` and `STORAGE_FILEPATH`). |
| License | UNVERIFIED: the fork declares no license. The npm package is MIT but a different fork. Confirm before setting `LICENSE`. |
| arm64 | UNVERIFIED: no arch information for the GHCR image. Node packages are arch-neutral. |

## 2. Target layout

- `apps/haste-server/Dockerfile`
- `apps/haste-server/docker-bake.hcl`
- `apps/haste-server/settings.yaml`
- `apps/haste-server/container-test.yaml`
- `apps/haste-server/start.sh`
- `defaults/` only if a default `config.js` is seeded into `/config` (reason: the app reads its settings from a file). Never use `root/`.

No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: the app is Node-only, and python-node provides Node (draft reason). Closest siblings: `apps/kasm` and `apps/budge` (python-node final stage). Do not reuse the fork's `node:14.8.0-stretch` base: it is EOL.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fetch the source from the fork at a pinned commit. Do not use `master` (moving target). Pin by commit SHA in `VERSION`: the fork's latest commit is `8c45a370a79cc5caaf446ba0088574dfcb489694` (2021-03-01). Confirm before use.
3. `curl -fL https://github.com/nzzane/haste-server/archive/${VERSION}.tar.gz | tar xz -C /app/haste-server --strip-components=1`. Verification: no published checksum; the tarball is content-addressed by commit SHA only.
4. `npm ci --omit=dev` (or `npm install --omit=dev`) with `NPM_CONFIG_CACHE=/tmp/npm`. Do not install the pinned extras (redis, pg, memcached, aws-sdk, rethinkdbdash) unless `start.sh` uses them. Document this as a deviation from the fork Dockerfile.
5. `chown -R apps:apps /app/haste-server && chmod -R 755 /app/haste-server`.
6. `ENV HOME=/config NPM_CONFIG_CACHE=/tmp/npm HOST=0.0.0.0 PORT=7777 STORAGE_TYPE=file STORAGE_FILEPATH=/config/data`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 7777
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "haste-server"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/nzzane/haste-server currentValue=master
  default = "8c45a370a79cc5caaf446ba0088574dfcb489694"
}

variable "LICENSE" {
  default = "UNLICENSED"   // UNVERIFIED: fork declares no license; confirm before merge
}

variable "SOURCE" {
  default = "https://github.com/nzzane/haste-server"
}
```

The renovate `git-refs` line follows `apps/tvheadend` (precedent). Add the four standard targets and `default` group from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nzzane/haste-server"
ports:
  - port: 7777
    protocol: tcp
    required: false
env:
  - name: KEY_LENGTH
    default: "10"
    required: false
  - name: MAX_LENGTH
    default: "400000"
    required: false
  - name: KEYGENERATOR_TYPE
    default: "phonetic"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only list env names that `start.sh` or the app actually reads. Dependencies: none.

## 7. start.sh

- Seed `/config/config.js` from `/defaults/config.js` only when missing (`cp -n`).
- Create `/config/data` when missing (file storage path).
- Export `HOST`, `PORT`, `STORAGE_FILEPATH` from env with the same defaults as `settings.yaml`.
- `cd /app/haste-server` then `exec node server.js` (the app reads `config.js` from its working directory or `--config`: UNVERIFIED which path the fork uses; confirm against `lib/` before writing).
- No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
tcp:
- port: '7777'
http:
- port: '7777'
  path: /
```

Add `filePaths` for `/app/haste-server/server.js` and the license file if one is shipped. No env vars are required to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (paste storage) | `/config/data` via `STORAGE_FILEPATH`. |
| npm cache | `/tmp/npm`. |
| Chart expectations (non-root 568, read-only rootfs true, no override) | Consistent with the plan. Verify, do not assume. |

## 10. Risks, caveats and open questions

- **Blocker: source provenance.** The upstream `seejohnrun/haste-server` is unreachable. The image is built from an unmaintained fork (`nzzane`, last push 2021) with no license.
- **Blocker: the published image is gone or unpinnable.** The draft's `ghcr.io/k8s-at-home/haste-server:latest` tag cannot be pinned, and the k8s-at-home repo is gone. The plan uses the fork source instead.
- The fork's Node 14 / Debian stretch base is EOL. This plan moves to python-node. Run the app and confirm it starts on Node from python-node.
- Pastes can be large (`MAX_LENGTH=400000`); `/config` size is not bounded by the image.
- The npm `haste-server@0.2.1` (MIT) is a different fork; do not substitute it without review.
- arm64 runtime not verified.

## 11. Build and test steps

```sh
cd apps/haste-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name haste-server-probe --read-only --tmpfs /tmp \
  -v haste-server-probe-config:/config haste-server:8c45a370a79cc5caaf446ba0088574dfcb489694
docker logs -f haste-server-probe
forgetool containers test --image haste-server:8c45a370a79cc5caaf446ba0088574dfcb489694 --config ./apps/haste-server/container-test.yaml
docker rm -f haste-server-probe; docker volume rm haste-server-probe-config
```

Expected readiness signal: a `listening` or `started` line on port 7777 (UNVERIFIED: exact text from the fork).

## 12. PR checklist

- Branch `feat/add-haste-server`, commit `feat(haste-server): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- PR description: `🤖 This PR is AI generated.` in Notes, PR template kept.
- State what was not tested: no build or run has happened in this planning step.
- Do not tick "Built container locally" until the image is built.
