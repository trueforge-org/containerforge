# icloudpd — implementation plan
> Source: ./draft.md · Target: apps/icloudpd/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | **v1.34.0** (latest GitHub release; PyPI `icloudpd` 1.34.0). Draft links v1.33.1 and says 1.32.x; both are outdated. |
| Renovate | `// renovate: datasource=github-releases depName=icloud-photos-downloader/icloud_photos_downloader` (semver; tags are `v1.34.0`) |
| License | MIT (`LICENSE.md` in the repo and PyPI metadata). SPDX `MIT`. |
| Source URL | https://github.com/icloud-photos-downloader/icloud_photos_downloader |
| Download (amd64) | `https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/download/v1.34.0/icloudpd-1.34.0-linux-amd64` |
| Download (arm64) | `.../icloudpd-1.34.0-linux-arm64` |
| **Draft error** | The draft links `icloud-1.33.1-linux-*`. Those files are a different tool ("Find My iPhone CommandLine Tool", per upstream `docs/authentication.md`). The right asset is `icloudpd-<version>-linux-<arch>`. Do not use the `musl` assets (musl builds, not for glibc ubuntu). |
| Checksum | No checksum file in the release. The GitHub release page shows a sha256 digest per asset (amd64 `c1ae4002...3b02`, arm64 `a5d59bd7...8e6e`, to re-check at implementation); the same digest is exposed as `.assets[].digest` in the release API. |
| Alternative | PyPI wheels (`pip install icloudpd==1.34.0`, `requires-python >=3.11,<3.16`). Binary chosen: no Python needed, single file. |
| Upstream Dockerfile reviewed | Reference image `boredazfcuk/icloudpd` (shell-script heavy, runs as root with its own env var set) is not the app's own image and is not copied. Upstream's own docs: `docker run -v Photos:/data -v config:/config icloudpd/icloudpd icloudpd --directory /data --cookie-directory /config --username ... --watch-with-interval 3600`. |
| Real CLI options used | `--directory`, `--cookie-directory`, `--username`, `--watch-with-interval`, `--password-provider` (parameter, keyring, console, webui), `--mfa-provider` (console, webui), `--auth-only`, `--webui-host`, `--domain`. |
| Web UI | Only starts when `webui` is chosen as password and/or MFA provider. **Fixed port 8080, cannot be changed**, listens on all interfaces by default, no login. |
| Env vars read by upstream | None documented besides TZ. All settings are CLI flags. |

## 2. Target layout

```
apps/icloudpd/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (nothing to seed), no `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: the draft suggests the python base (pip install), but the upstream ships a PyInstaller binary for glibc, so ubuntu alone is enough and avoids pulling Python. Closest sibling: `apps/adguardhome-sync` (prebuilt release binary on ubuntu, `TARGETARCH`, `start.sh` with `exec`).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `ARG TARGETARCH`; `USER root`.
2. `ENV HOME=/config TMPDIR=/tmp` (PyInstaller one-file binaries unpack to `TMPDIR`; the base already sets `HOME=/config` and `XDG_CONFIG_HOME=/config`, keep it so the keyring file and session stay in `/config`).
3. One RUN, with `set -eux`:
   - `V="${VERSION#v}"`; asset `icloudpd-${V}-linux-${TARGETARCH}` (Docker's `amd64`/`arm64` match upstream names, no mapping table needed).
   - `curl -fsSL -o /app/icloudpd ".../releases/download/v${V}/icloudpd-${V}-linux-${TARGETARCH}"`.
   - Verify: `curl -fsSL https://api.github.com/repos/icloud-photos-downloader/icloud_photos_downloader/releases/tags/v${V} | jq -r --arg n "icloudpd-${V}-linux-${TARGETARCH}" '.assets[]|select(.name==$n)|.digest'` and compare with `sha256sum`; fail the build when the digest is missing or different (jq and curl are in the base). If API rate limits hurt CI, fall back to two `ARG SHA256_AMD64/ARM64` values kept next to VERSION (renovate cannot bump those; mention in PR).
   - `chmod 0755 /app/icloudpd && chown -R apps:apps /app`.
   - License: `mkdir -p /usr/share/licenses/icloudpd && curl -fsSL -o /usr/share/licenses/icloudpd/LICENSE.md https://raw.githubusercontent.com/icloud-photos-downloader/icloud_photos_downloader/v${V}/LICENSE.md`.
   - No apt packages. `rm -rf /tmp/*`.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `VOLUME /data`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` = `icloudpd`
- `VERSION`: renovate comment above, `default = "v1.34.0"` (Dockerfile strips the `v`, as `adguardhome-sync` does)
- `LICENSE` = `MIT`
- `SOURCE` = `https://github.com/icloud-photos-downloader/icloud_photos_downloader`
- Standard four targets plus default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header and `schema_version: 1`, `upstream_env_url: "https://github.com/icloud-photos-downloader/icloud_photos_downloader"`.

- ports: `8080` tcp, `required: false` (web UI for password and 2FA; only open when a username is configured).
- env (all are read by `start.sh`, which builds the CLI flags; upstream has no env interface, so these are ContainerForge wrapper names):
  - `ICLOUDPD_USERNAME` default `""` required false (Apple ID; empty means the container idles)
  - `ICLOUDPD_WATCH_INTERVAL` default `"3600"` required false
  - `ICLOUDPD_PASSWORD_PROVIDER` default `"webui"` required false
  - `ICLOUDPD_MFA_PROVIDER` default `"webui"` required false
  - `ICLOUDPD_EXTRA_ARGS` default `""` required false (extra flags, whitespace separated)
  - `TZ` default `"Etc/UTC"` required false
- volumes: `/config` required true (session cookies, keyring), `/data` required false (downloaded photos).
- dependencies: none.

No password variable on purpose: a password in env or args would show up in the process list. The password is entered once in the web UI and saved by the keyring provider in a plain-text file under `/config` (not encrypted, per upstream docs; protect the volume, or drop `keyring` from the providers).

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.

1. Defaults: `: "${ICLOUDPD_WATCH_INTERVAL:=3600}"`, same for the two providers.
2. `mkdir -p /config/cookies /data` (idempotent, no overwrite).
3. If `ICLOUDPD_USERNAME` is empty: log `ICLOUDPD_USERNAME is not set; idling. Set it and restart.` and `exec sleep infinity` (clean start with empty `/config` and no env, as the test harness requires; no crash loop).
4. Build the argument array: `--directory /data --cookie-directory /config/cookies --username "$ICLOUDPD_USERNAME" --watch-with-interval "$ICLOUDPD_WATCH_INTERVAL" --password-provider keyring --password-provider "$ICLOUDPD_PASSWORD_PROVIDER" (add the second one only when it is not `keyring`) --mfa-provider "$ICLOUDPD_MFA_PROVIDER"`. (Upstream rule: a console/webui provider must be last in the list; keyring first lets the saved password be reused.) Append `${ICLOUDPD_EXTRA_ARGS}` unquoted on purpose (word splitting), after validation that it contains no newline.
5. Do not pass `--webui-host`; default is `0.0.0.0`, as required for use from other containers.
6. `exec /app/icloudpd "${args[@]}"`.

Nothing is written to `/app`. Session and keyring stay in `/config`, photos in `/data`, temp in `/tmp`. Upstream `docs/authentication.md` (v1.34.0): without a desktop keyring the password is saved **unencrypted** in `~/.local/share/python_keyring/keyring_pass.cfg`, which with `HOME=/config` is under `/config`. UNVERIFIED: whether the binary honours `XDG_DATA_HOME`; check the file location after the first login.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
mainRunner:
  env:
    ICLOUDPD_USERNAME: "test@example.com"
tcp:
- port: '8080'
filePaths:
- /app/icloudpd
- /usr/share/licenses/icloudpd/LICENSE.md
healthCommands:
- command: /app/icloudpd --version
  expectedContent: "1.34.0"
  matchContent: true
```

The web UI only opens after a username is set, so the main runner sets a dummy one (`mainRunner.env` is in the forgetool container-test schema; no sibling was checked that uses it, so confirm on a real run). At v1.34.0 `base.py` starts the web server thread before the per-user loop, i.e. before any Apple sign-in, whenever a `webui` provider is selected; with an empty keyring no password is available to send to Apple. The `expectedContent` string must be bumped with `VERSION`. Caveat: the image's Docker `HEALTHCHECK` reads the same file without `mainRunner.env`, so a container idling without `ICLOUDPD_USERNAME` (or run without a `webui` provider) reports unhealthy because of the 8080 probe; accept and document this. The idle path itself is run by hand per the protocol. Never weaken or remove assertions to pass.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `~/.pyicloud` session dir (`/root/.pyicloud` in Docker) | `--cookie-directory /config/cookies` |
| Keyring file | under `/config` via `HOME`/`XDG_DATA_HOME` |
| PyInstaller one-file extraction | `TMPDIR=/tmp` (tmpfs; needs exec permission on `/tmp`, check `--tmpfs /tmp` is not mounted `noexec`) |
| Photos | `/data` (draft says `/home/apps/iCloud`; use `/data`, which the base already provides, owned by `apps`) |

Draft expectations: UID 0 and `NET_RAW`/`NET_ADMIN` caps in the chart are not needed (no raw sockets in the CLI); run as `apps` (568) with no added capabilities and `readOnlyRootFilesystem`. Upstream docs note Docker files are written as root; here they are owned by 568, so existing photo libraries must be chowned.

## 10. Risks, caveats and open questions

- First run needs interactive 2FA (draft caveat). With the web UI provider this works headless; accounts with FIDO keys do not work with the web UI (upstream docs), and ADP needs `--adp-web-access` via `ICLOUDPD_EXTRA_ARGS`.
- Apple sessions expire (about two months per upstream docs); the container then waits in the web UI for a new code.
- Web UI has no login and is on all interfaces: do not expose 8080 publicly. Document in the PR.
- The saved password is stored unencrypted under `/config` (upstream docs).
- The web UI cannot request an SMS code and does not support FIDO keys (upstream docs); use a console `--auth-only` run with the same cookie directory.
- Large initial syncs need large `/data` (draft caveat).
- Upstream README says the project is "looking for a MAINTAINER" (issue 1305); long-term upkeep risk.
- UNVERIFIED: PyInstaller binary works under `--read-only` with only `/tmp` writable, glibc compatibility with ubuntu 26.04 (expected fine, test on both arches).
- No blocker: not musl-only (glibc builds exist), no GPU, no privileged, arm64 asset exists.

## 11. Build and test steps

```sh
cd apps/icloudpd
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create icloudpd-probe-config
docker run --rm -d --name icloudpd-probe --read-only --tmpfs /tmp \
  -v icloudpd-probe-config:/config icloudpd:v1.34.0
docker logs -f icloudpd-probe
```

Readiness: the idle line from `start.sh` (no env) with the process alive. Second run with `-e ICLOUDPD_USERNAME=someone@example.com -p 8080:8080`: expect the web UI to answer on 8080 and a log line asking for the password (no real Apple login is possible in CI). Check from a second container that 8080 is reachable. Then `forgetool containers test --image icloudpd:v1.34.0 --config ./apps/icloudpd/container-test.yaml`; clean up container and volume.

## 12. PR checklist

- Branch `feat/add-icloudpd`, commit and PR title `feat(icloudpd): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, tick only applicable boxes.
- Notes: `🤖 This PR is AI generated.`; mention the wrong `icloud-*` links in the draft.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to state honestly: real Apple login and 2FA, arm64, FIDO/ADP paths, keyring file location, 8080 probe via `mainRunner` until a `forgetool` run confirms it.
