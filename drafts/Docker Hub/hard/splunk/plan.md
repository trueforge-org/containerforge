# splunk — implementation plan
> Source: ./draft.md · Target: apps/splunk/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 10.6.2 (draft tag `10.6.2`, build `10.6.2.5-b07ce3b48d58`). The download URL below exists and its `.sha512` file exists (checked). A web search saw the vendor download page listing 10.6.1.1, so "latest" is UNVERIFIED; 10.6 is the LTS line released 2026-09-30 |
| Renovate | `datasource=docker depName=splunk/splunk` (Docker Hub tags `10.6.2`); the build id `b07ce3b48d58` is not derivable from the tag and must be updated by hand with `VERSION` |
| License | Proprietary (Splunk General Terms / EULA, free trial and free-tier limits). Use `LicenseRef-Splunk-General-Terms`. Redistribution in a public image: UNVERIFIED, see section 10 |
| Source | https://www.splunk.com/en_us/download/splunk-enterprise.html |
| Download amd64 | `https://download.splunk.com/products/splunk/releases/10.6.2.5/linux/splunk-10.6.2.5-b07ce3b48d58-linux-amd64.tgz` |
| Download arm64 | Not available from the vendor per draft; UNVERIFIED |
| Checksum | `<url>.sha512` published next to the tarball (reachable, 182 bytes). Upstream Dockerfile downloads it at build time and runs `sha512sum --check`. Plan: copy the hash value into an `ARG SPLUNK_SHA512` so the check is independent of the download host |
| Upstream Dockerfile | `splunk/docker-splunk` at a2c049c `splunk/common-files/Dockerfile`: base `base-debian-10`, user/group `splunk` 41812, `SPLUNK_HOME=/opt/splunk`, `VOLUME /opt/splunk/etc /opt/splunk/var`, `EXPOSE 8000 8065 8088 8089 8191 9887 9997`, `ENTRYPOINT /sbin/entrypoint.sh`, `CMD start-service`, ansible provisioning (splunk-ansible) |
| Ports | 8000/http (web UI), 8089 (management API, https), 9997 (forwarder receiving). Others upstream: 8065 (appserver), 8088 (HEC), 8191 (KV store), 9887 (replication) |
| Env (docker-splunk docs) | `SPLUNK_PASSWORD` (admin password), `SPLUNK_START_ARGS` (e.g. `--accept-license`). Newer images may also need a general-terms acceptance variable (`SPLUNK_GENERAL_TERMS`): UNVERIFIED, not on the docs page read |
| Paths | `/opt/splunk/etc` and `/opt/splunk/var` (draft persistence), `/splunkdata` (draft pvc, index data) |
| Dependencies | none |

## 2. Target layout

```
apps/splunk/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/inputs.conf       # [splunktcp://9997] so the forwarder port is open
  defaults/web.conf          # optional: only if the web bind needs forcing (UNVERIFIED)
```
`root/` not used. No DOWNSTREAM_CHANGES.md. The ansible-based upstream setup is deliberately not ported (large, python/ansible, root-era).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Splunk bundles its own Python and OpenSSL, so only the base is needed (draft agrees). Closest sibling: `apps/adguardhome-sync` (tarball extracted to `/app`).

## 4. Dockerfile

1. `ARG VERSION=10.6.2`, `ARG SPLUNK_BUILD=10.6.2.5-b07ce3b48d58`, `ARG SPLUNK_SHA512`, `ARG TARGETARCH` (amd64 only: fail early if not amd64).
2. `USER root` only for the install `RUN`. No extra apt packages expected (curl, tar, ca-certificates in base).
3. Download `https://download.splunk.com/products/splunk/releases/${SPLUNK_BUILD%%-*}/linux/splunk-${SPLUNK_BUILD}-linux-amd64.tgz` to `/tmp/splunk.tgz`; verify with `echo "${SPLUNK_SHA512}  /tmp/splunk.tgz" | sha512sum -c -` (value copied from the `.sha512` file).
4. `tar xzf /tmp/splunk.tgz -C /app` (tarball top dir is `splunk`), so `SPLUNK_HOME=/app/splunk`. Assert the version: `/app/splunk/bin/splunk version --accept-license` must contain `${VERSION}` (build-time check).
5. Preserve the pristine config: `cp -a /app/splunk/etc /app/splunk/etc.dist`; then replace `/app/splunk/etc` and `/app/splunk/var` with symlinks to `/config/etc` and `/config/var`.
6. License files: copy `/app/splunk/license-eula.txt` and `/app/splunk/third-party-credits.txt` (UNVERIFIED exact names; copy whatever license/credits files the tarball ships) to `/usr/share/licenses/splunk/`.
7. `ENV SPLUNK_HOME=/app/splunk HOME=/config TMPDIR=/tmp PATH=/app/splunk/bin:$PATH`.
8. `chown -R apps:apps /app/splunk`; `rm -f /tmp/splunk.tgz`.
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8000 8089 9997`, `VOLUME /config`, `WORKDIR /app/splunk`, final `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "splunk" }
variable "VERSION" {
  // renovate: datasource=docker depName=splunk/splunk
  default = "10.6.2"
}
variable "SPLUNK_BUILD" { default = "10.6.2.5-b07ce3b48d58" }   // bump together with VERSION
variable "SPLUNK_SHA512" { default = "<copy from the .sha512 file>" }
variable "LICENSE" { default = "LicenseRef-Splunk-General-Terms" }
variable "SOURCE" { default = "https://www.splunk.com/en_us/download/splunk-enterprise.html" }
```
`args` pass `VERSION`, `SPLUNK_BUILD`, `SPLUNK_SHA512`. Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (linux/amd64 only), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://www.splunk.com/en_us/download/splunk-enterprise.html"`.
- ports: `8000` tcp, `8089` tcp, `9997` tcp (all `required: false`, the forwarder port only when a forwarder is used; web UI is the main one: `8000` required true).
- env: `TZ` (`Etc/UTC`, false), `SPLUNK_PASSWORD` (default "", required true: handled by start.sh, which refuses to start and logs why, like `apps/bookstack` does for `APP_KEY`), `SPLUNK_START_ARGS` (default "", required true, handled the same way: must contain `--accept-license`; the license is never accepted on the user's behalf).
- volumes: `/config` required true.
- dependencies: none.

## 7. start.sh

1. `set -euo pipefail`; `export SPLUNK_HOME=/app/splunk`.
2. If `SPLUNK_START_ARGS` does not contain `--accept-license` or `SPLUNK_PASSWORD` is empty: print a clear error and `sleep infinity` (same pattern as bookstack) instead of exiting.
3. Seed `/config` only when missing: if `/config/etc` is empty, `cp -a /app/splunk/etc.dist/. /config/etc/`; `mkdir -p /config/var /tmp/splunk`; copy `/defaults/inputs.conf` to `/config/etc/system/local/inputs.conf` only if absent (opens receiver 9997). Never overwrite existing user config.
4. First start only (`/config/etc/passwd` absent): write `/config/etc/system/local/user-seed.conf` with `[user_info] USERNAME = admin` and the password from the environment, using `printf` from the variable (not via argv, keeps it out of the process list and handles special characters); delete the file after startup. Password changes on later starts are not applied automatically (Splunk only reads user-seed when no passwd exists): document `splunk edit user`.
5. Bind: Splunk web (8000) and management (8089) listen on all interfaces by default (UNVERIFIED; confirm from another container, force `server.conf`/`web.conf` if not).
6. Final command: `exec /app/splunk/bin/splunk start --nodaemon --accept-license --answer-yes --no-prompt` (flag `--nodaemon` UNVERIFIED for 10.6; upstream uses `start-service` through ansible). Splunk auto-updates `splunk.secret`/ftr files under SPLUNK_HOME: see section 9.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
tcp:
- port: '8000'
- port: '8089'
- port: '9997'
http:
- port: '8000'
  path: /
runners:
- entrypoint: /app/splunk/bin/splunk version --accept-license
filePaths:
- /start.sh
- /app/splunk/bin/splunk
- /usr/share/licenses/splunk/license-eula.txt
```
Probes exist for 8000, 8089 and 9997. IMPORTANT: the test runs with no env vars, so without `SPLUNK_START_ARGS` and `SPLUNK_PASSWORD` start.sh waits and no port opens: the port probes cannot pass as written. Maintainers must choose (see section 10) between a baked default for the test only and narrowing the port probes; the `runners` and `filePaths` entries cover the non-env path. Do not weaken or drop the probes silently.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/opt/splunk/etc` | `/app/splunk/etc` symlink to `/config/etc`, seeded from `etc.dist` |
| `/opt/splunk/var` (indexes, logs, run) | symlink to `/config/var` |
| `/splunkdata` (draft pvc) | same `/config/var/lib/splunk`; no second volume |
| `/opt/splunk/tmp`, `TMPDIR` | `/tmp` |
| SPLUNK_HOME top-level marker files (e.g. `ftr`, `.ui_login`) | UNVERIFIED which exist; test with `--read-only` and symlink each offender into `/config` |

Draft: root, writable rootfs. Image runs UID 568, rootfs read-only; Splunk supports non-root installs when the user owns the install tree. Upstream ran as UID 41812 plus a sudo-capable `ansible` user: dropped.

## 10. Risks, caveats and open questions

- BLOCKER to confirm: proprietary license; a public ghcr image containing the Splunk tarball may not be permitted (Splunk publishes its own image). Consider a build that downloads at first start instead.
- Test design: license acceptance and admin password are env-driven, but tests run with no env. Needs a maintainer decision.
- Heavy RAM/disk, slow first start (draft). Splunk expects high ulimits and transparent huge pages disabled; warnings are expected in logs.
- amd64 only (no arm64 build from the vendor).
- `splunk.secret`/passwd are created under `/config/etc`: losing `/config` loses the encryption key.
- Build id and sha512 need manual bumps with every `VERSION` change (renovate cannot compute them).
- UNVERIFIED: `--nodaemon`, exact license file names, SPLUNK_HOME write locations, additional general-terms env variable.

## 11. Build and test steps

```sh
cd apps/splunk
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name splunk-probe --read-only --tmpfs /tmp -v splunk-probe-config:/config \
  -e SPLUNK_START_ARGS=--accept-license -e SPLUNK_PASSWORD=<test-password> splunk:10.6.2
docker logs -f splunk-probe
forgetool containers test --image splunk:10.6.2 --config ./apps/splunk/container-test.yaml
docker rm -f splunk-probe; docker volume rm splunk-probe-config
```
Readiness: the log shows the web interface started on port 8000 (`curl -I http://127.0.0.1:8000/` returns 200/303) and 8089 and 9997 accept TCP. Also run once without env to prove the container waits and logs the missing variables. Restart on the same volume to prove idempotency.

## 12. PR checklist

- Branch `feat/add-splunk`, commit `feat(splunk): add new container`, target `main`.
- Use the PR template; check only what applies.
- Notes: `🤖 This PR is AI generated.` and the redistribution/license question.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge ; only the user can sign it.
- Untested: full runtime, read-only behaviour, non-root start, forwarder ingest, upgrade path; state it if the image was not built.
- Pre-completion: `bake --print`, aligned `VERSION`/`SPLUNK_BUILD`, final `USER apps`, empty `/config` start.
