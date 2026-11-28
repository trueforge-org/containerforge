# cryptofolio — implementation plan
> Source: ./draft.md · Target: apps/cryptofolio/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Status: **ok** to implement. The upstream stack is PHP with JSON files and no database, and a release asset with the app files exists. Open points are the upstream Apache routing and the PHP extensions (section 10), both checked during the build.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `V.2.2` (latest release, published 2021-09-07T19:18:44Z). Docker Hub `xtrendence/cryptofolio:V.2.2.0` and `latest` were pushed 2021-09-08. The draft names no version. |
| Image the chart uses today | `xtrendence/cryptofolio:V.2.2.0` (multi-arch: amd64 and arm64 digests published). Chart pin `V.2.2.0@sha256:e6e6612b...9f480e` is the manifest-list digest, UNVERIFIED (not fetched). |
| Renovate | `datasource=github-releases depName=Xtrendence/Cryptofolio versioning=regex:^V\.(?<major>\d+)\.(?<minor>\d+)$`. The tag `V.2.2` has a `V.` prefix and two components, which `semver` does not parse. The regex must be checked with a Renovate dry run (UNVERIFIED). |
| License | AGPL-3.0 (GitHub repo, `LICENSE.md`). |
| Source URL | https://github.com/Xtrendence/Cryptofolio |
| Download (app) | `https://github.com/Xtrendence/Cryptofolio/releases/download/${VERSION}/API-And-Website.zip` (confirmed in the release's expanded assets, https://github.com/Xtrendence/Cryptofolio/releases/expanded_assets/V.2.2). The zip holds the `api/` and `website/` trees. Its exact contents are UNVERIFIED until unzipped. |
| Download (license) | `https://github.com/Xtrendence/Cryptofolio/archive/refs/tags/${VERSION}.zip` (confirmed URL). Take `LICENSE.md` from it. |
| Architecture | PHP source, so the same files run on amd64 and arm64. |
| Checksum source | None published on the release page. The asset is pinned by release URL only. |
| Upstream Dockerfile reviewed | `master` `Dockerfile` (commit `51f7263`, https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/Dockerfile): `FROM php:7.4-apache` (Debian, PHP 7.4 EOL); copies `apache/000-default.conf`, `apache/start-apache`, `api/` to `/var/www/html/api/`, `website/` to `/var/www/html/website/`; `EXPOSE 80`; `CMD ["start-apache"]`; no `USER` (root), no `VOLUME`, no `ENV`, no build step. |
| Port | `80` (Apache, upstream `EXPOSE 80`). |
| Env vars | None in the upstream Dockerfile. Chart env is `{}`. |
| Data path | `api/data/` (README: `account.json`, `holdings.json`, `settings.json`, created on first login). The chart maps `/var/www/html/api/data`. |
| Outbound | HTTPS needed for CoinGecko market data (README). |
| Passwords | Hashed with bcrypt (README). Default admin password is `admin`, to be changed in Settings after first login (README). |

## 2. Target layout

- `apps/cryptofolio/Dockerfile`
- `apps/cryptofolio/docker-bake.hcl`
- `apps/cryptofolio/settings.yaml`
- `apps/cryptofolio/container-test.yaml`
- `apps/cryptofolio/start.sh`

No `defaults/`, `etc/` or `health/` is needed: there is no seeded config and no Apache config (the server is `php -S`, section 4). Add `etc/` only if the upstream routing needs a router script (section 10). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage.

Why: the upstream PHP 7.4 base is EOL and Debian-based, and this is the ContainerForge PHP pattern on ubuntu with `php8.5-*` from apt (`apps/kimai`, `apps/bookstack`). No separate build stage is needed, because the app is source only.

Closest siblings: `apps/kimai` and `apps/grocy` (PHP app on ubuntu, `php -S 0.0.0.0:80 -t <public>` in `start.sh`, `VOLUME /config`).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends php8.5-cli php8.5-curl unzip ca-certificates`, then `rm -rf /var/lib/apt/lists/*`. `php8.5-cli` and `php8.5-curl` match the sibling PHP packages (`php8.5-*`). `unzip` is not in the base (UNVERIFIED for every base tag). Other PHP extensions are added only if the code needs them (UNVERIFIED: check `grep -rE "extension_loaded|new PDO|mb_" api/`). The apt PHP is not pinned to `VERSION`, because it is the runtime, not the app.
3. Download and unpack the app:

```dockerfile
RUN mkdir -p /app/cryptofolio /tmp/cryptofolio && \
    curl -fL -o /tmp/cryptofolio.zip \
      "https://github.com/Xtrendence/Cryptofolio/releases/download/${VERSION}/API-And-Website.zip" && \
    curl -fL -o /tmp/cryptofolio-src.zip \
      "https://github.com/Xtrendence/Cryptofolio/archive/refs/tags/${VERSION}.zip" && \
    unzip -q /tmp/cryptofolio.zip -d /app/cryptofolio && \
    unzip -q -j /tmp/cryptofolio-src.zip '*/LICENSE.md' -d /usr/share/licenses/cryptofolio && \
    rm -rf /tmp/*
```

   `-j` flattens the path, so the licence lands at `/usr/share/licenses/cryptofolio/LICENSE.md`. Use `LICENSE.md` as the file name in `container-test.yaml`.

4. Remap the writable data directory to `/config` (section 9):

```dockerfile
RUN rm -rf /app/cryptofolio/api/data && \
    ln -s /config/data /app/cryptofolio/api/data
```

5. Ownership and modes: `chown -R apps:apps /app/cryptofolio && chmod -R 755 /app/cryptofolio`, as `apps/adguardhome-sync` does.
6. Tail:

```dockerfile
ENV HOME=/config TZ=Etc/UTC

USER apps
COPY --chmod=0755 . /

EXPOSE 80
VOLUME /config
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "cryptofolio" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Xtrendence/Cryptofolio versioning=regex:^V\.(?<major>\d+)\.(?<minor>\d+)$
  default = "V.2.2"
}
variable "LICENSE" { default = "AGPL-3.0" }
variable "SOURCE" { default = "https://github.com/Xtrendence/Cryptofolio" }
```

Use the four standard targets and the default group, copied from `apps/adguardhome-sync`. Run `docker buildx bake --print` from `apps/cryptofolio`. The image tag is `cryptofolio:V.2.2`, and the Dockerfile `ARG VERSION` must also be `V.2.2`. The Docker Hub tag `V.2.2.0` is upstream's own naming and is not used here.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Xtrendence/Cryptofolio"
ports:
  - port: 80
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. No database: the app stores its data in JSON files under `api/data`. No env vars are read, so none are listed (do not invent any).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

cd /app/cryptofolio
exec php -S 0.0.0.0:80 -t /app/cryptofolio/website
```

- Idempotent: `mkdir -p` only. Nothing is seeded; the app creates `account.json`, `holdings.json` and `settings.json` on first login (README).
- Nothing is written to `/app` at runtime: `api/data` is a symlink to `/config/data`.
- `-t` points at the document root. The docroot and the `/api` path mapping depend on the upstream Apache config (UNVERIFIED, section 10), so the `-t` value may change.
- `exec` gives PID 1 to PHP. The bind address `0.0.0.0` makes the port reachable from other containers.
- Port 80 as the `apps` user follows `apps/kimai` and `apps/grocy`, which also serve on 80 with `php -S`. The test confirms it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '80'
http:
- port: '80'
  path: /
filePaths:
- /app/cryptofolio/api
- /app/cryptofolio/website
- /usr/share/licenses/cryptofolio/LICENSE.md
```

- `tcp` and `http` probes for `80`, per the coverage rule. The status for `/` is UNVERIFIED, so confirm it is 200 on the first run.
- `filePaths` checks the app trees and the licence. The test runs without env vars, which matches the app (it reads none).
- No narrowed or DB-dependent assertions: there is no database.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/html/api/data` (`account.json`, `holdings.json`, `settings.json`) | Symlink `/app/cryptofolio/api/data` to `/config/data`, which `start.sh` creates. Chart users must move their data to `/config/data`. |
| PHP sessions and temp files | Ubuntu default `/tmp`, which is writable with `--tmpfs /tmp`. No change. |
| `HOME` | `/config`, so no write goes to `/app` or `/root`. |

Reconciliation of the draft's expectations: the chart runs as UID 0 (`runAsUser 0`, `runAsNonRoot false`), but this image runs as `apps`. The chart sets `readOnlyRootFilesystem: false`, while the image is compatible with `--read-only --tmpfs /tmp` (tested in section 11). The chart is not privileged, as in the draft. The chart's persistence `/var/www/html/api/data` becomes `/config/data` (section 9).

## 10. Risks, caveats and open questions

Blockers and must-check items:

1. **Upstream routing.** The docroot and the `/api` path come from `apache/000-default.conf` and `apache/start-apache` in the upstream repo, which were not fetched. Read them before writing `start.sh`. If the app relies on Apache rewrite rules, `php -S` does not apply `.htaccess`, so a router script is needed (put it under `etc/` and document why). Until then the `-t` value is UNVERIFIED.
2. **PHP version.** Upstream is PHP 7.4 (EOL). This plan uses apt `php8.5-cli`. Code that runs on 7.4 may warn or fail on 8.5. Treat any deprecation or fatal in the logs as a failure (protocol step 3).
3. **Chart digest.** The chart's `V.2.2.0` manifest digest is UNVERIFIED. It is not needed to build this image, but the chart update must check it.

Other caveats:

- Default admin password `admin`. The app must be changed after first login (README). The image cannot change this without an app change, so the PR should state it and the user should be told.
- No checksum is published for the release zip, so the download is trusted by URL and tag only.
- Upstream has not been updated since 2021 (inferred from the release date). Long-term maintenance may fall to ContainerForge.
- Outbound HTTPS to CoinGecko is needed for market data. The test does not check it, and the container starts without it (UNVERIFIED).
- `copy-from` (`xtrendence/cryptofolio:V.2.2.0`) was considered and rejected: it is multi-arch, but it is the PHP 7.4 runtime image, so only the app files would be copied. The zip is simpler and gives the same files.
- No musl-only, GPU or privileged needs. No arm64 blocker: the code is PHP, and arm64 is UNVERIFIED until the build runs.

## 11. Build and test steps

```sh
cd apps/cryptofolio
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name cryptofolio-probe --read-only --tmpfs /tmp \
  -v cryptofolio-probe-config:/config cryptofolio:V.2.2
docker logs -f cryptofolio-probe
forgetool containers test --image cryptofolio:V.2.2 --config ./apps/cryptofolio/container-test.yaml
docker rm -f cryptofolio-probe; docker volume rm cryptofolio-probe-config
```

Readiness signal: `php -S` prints `Development Server (http://0.0.0.0:80) started`. Expect it with no PHP errors. Then check that `/config/data` exists after start, and that a login creates `account.json` in `/config/data` (UNVERIFIED: the flow runs in the browser).

## 12. PR checklist

- Branch `feat/add-cryptofolio`, commit and PR title `feat(cryptofolio): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and tick only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it, and the `license/cla` check shows the status.
- Say honestly what is untested: the amd64 and arm64 builds, the `--read-only` start, the empty `/config` start, the upstream routing, the PHP 8.5 run of PHP 7.4 code, the `http` probe status, the first-login flow, and CoinGecko access.
- Mention the default admin password `admin` in the PR body.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion is weakened.
