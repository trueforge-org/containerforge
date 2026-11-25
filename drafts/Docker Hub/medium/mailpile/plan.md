# mailpile — implementation plan
> Source: ./draft.md · Target: apps/mailpile/ · Difficulty: medium (may become hard, see section 10) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.0.0rc6` (git tag; the upstream Dockerfile's `VERSION`). Tag page dated 2019-09-03. There is no GitHub release marked "latest". Chart runs `docker.io/rroemhild/mailpile:latest` (Docker Hub, only a `latest` tag, last updated 2020-12-11). |
| Draft binary source | Rejected. The draft says `pip:mailpile`. PyPI `mailpile` latest is `0.4.0.dev20141126` (2014, AGPLv3+ per PyPI metadata), not 1.0.0rc6. Use the git tag instead. |
| Renovate | UNVERIFIED. Candidate: `// renovate: datasource=github-tags depName=mailpile/Mailpile versioning=loose` (tag `1.0.0rc6` is not strict semver). |
| License | UNVERIFIED. `LICENSE` on `master` and on tag `1.0.0rc6` returned 404. The PyPI metadata (AGPLv3+) is for the 2014 dev build only. Find the license text inside the tarball before filling the bake file. |
| Source URL | https://github.com/mailpile/Mailpile |
| Download | Tag source archive, architecture-neutral Python: candidate `https://github.com/mailpile/Mailpile/archive/refs/tags/${VERSION}.tar.gz` (UNVERIFIED, not fetched; `git clone --branch 1.0.0rc6` is confirmed by the upstream Dockerfile). |
| Per-arch assets | None. No release asset was found. The source is the same on both architectures. |
| Checksum source | UNVERIFIED. No upstream checksum. Plan pins a sha256 of the archive computed by us, and records the tag's commit SHA. |
| Upstream Dockerfile reviewed | `rroemhild/docker-mailpile` commit `be578abe73423e37c2b29efa26a28faebb5f89b3`, `Dockerfile`. |
| Upstream base | `alpine:3.10` (musl). |
| Upstream apk | git, tor, zlib, gnupg, gnupg1, py2-pip, openssl, py-jinja2, py-libxml2, py-libxslt, py-lxml, py-pbr, py-pillow, py-cffi, py-cryptography, ca-certificates, tzdata. |
| Upstream install | Clones Mailpile at `$VERSION`, `pip install -r requirements.txt`, runs `./mp setup`. |
| Upstream Python | Python 2 (`py2-pip`). Python 3 compatibility of 1.0.0rc6: UNVERIFIED. |
| Upstream CMD | `./mp --www=0.0.0.0:33411 --wait`, WORKDIR `/Mailpile`. |
| Upstream user | root (no `USER`). |
| Real env vars (upstream ENV) | `VERSION=1.0.0rc6`, `TZ=Etc/GMT`, `MAILPILE_GNUPG=/usr/bin/gpg`, `MAILPILE_GNUPG/GA=/usr/bin/gpg-agent`, `MAILPILE_GNUPG/DM=/usr/bin/dirmngr`, `MAILPILE_TOR=/usr/bin/tor`, `MAILPILE_OPENSSL=/usr/bin/openssl`. |
| Ports | 33411/tcp (`EXPOSE`, confirmed). |
| Upstream write paths | `/root/.local/share/Mailpile`, `/root/.gnupg` (`VOLUME`). |
| Chart | `mailpile` version 11.0.0, appVersion `latest`, common 32.8.5 (`charts/stable/mailpile/Chart.yaml`). |

## 2. Target layout

- `apps/mailpile/Dockerfile`
- `apps/mailpile/docker-bake.hcl`
- `apps/mailpile/settings.yaml`
- `apps/mailpile/container-test.yaml`
- `apps/mailpile/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. Mail accounts are added in the web UI after first start (inferred), so no seed file. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

- The app is Python. `python` provides the Python 3 venv at `/app/venv`, which the draft also chooses.
- Closest sibling: `apps/bazarr` (Python app unpacked to `/app/bin`, pip install at build time, `apt` for native libs).
- If the Python 3 port fails, there is no Python 2 base in this repo. The app is then blocked (section 10).

## 4. Dockerfile

Two stages: a build stage that fetches and installs the source, then the final `python` stage.

1. Build stage: `FROM <python> AS build`, `ARG VERSION`, `ARG MAILPILE_SHA256`, `USER root`.
2. Build tools only in the build stage (`build-essential`, `libxml2-dev`, `libxslt1-dev`, `libffi-dev`, `libssl-dev`), as `apps/bazarr` does, if the wheels need compiling (UNVERIFIED).
3. Fetch and verify the source:
   ```dockerfile
   RUN curl -fsSL -o /tmp/mailpile.tar.gz \
       "https://github.com/mailpile/Mailpile/archive/refs/tags/${VERSION}.tar.gz" && \
     echo "${MAILPILE_SHA256}  /tmp/mailpile.tar.gz" | sha256sum -c - && \
     mkdir -p /tmp/src && \
     tar -xzf /tmp/mailpile.tar.gz -C /tmp/src --strip-components=1
   ```
4. Install Python dependencies into the base venv at build time (never at runtime):
   ```dockerfile
   RUN /app/venv/bin/pip install --no-cache-dir -r /tmp/src/requirements.txt
   ```
   `requirements.txt` is confirmed by the upstream Dockerfile. Whether each pinned package installs on Python 3 is UNVERIFIED (section 10).
5. Do not run `./mp setup` at build time. Upstream ran it to create state in `/root`. The state must go to `/config`, and the first run creates it (UNVERIFIED that the first run does the same job).
6. License: find the license text in `/tmp/src` (no `LICENSE` at the tag path, facts show 404). Copy it to `/usr/share/licenses/mailpile/LICENSE`. If none exists, stop and ask the user.
7. Final stage: `FROM <python>` (same digest), then:
   ```dockerfile
   USER root
   RUN apt-get update && \
     apt-get install -y --no-install-recommends gnupg tor && \
     rm -rf /var/lib/apt/lists/* /tmp/*
   COPY --from=build /tmp/src /app/mailpile
   COPY --from=build /app/venv /app/venv
   COPY --from=build /usr/share/licenses/mailpile /usr/share/licenses/mailpile
   RUN chown -R root:root /app && chmod -R 755 /app
   ```
   apt names: `gnupg` and `tor` are the Ubuntu names of the apk packages. `gnupg1` (upstream) may not exist on Ubuntu 26.04 (UNVERIFIED); add it only if Mailpile needs GnuPG 1. `openssl` and `ca-certificates` are in the base (UNVERIFIED).
8. Environment:
   ```dockerfile
   ENV HOME=/config \
       TZ=Etc/UTC \
       GNUPGHOME=/config/gnupg \
       TMPDIR=/tmp \
       MAILPILE_GNUPG=/usr/bin/gpg \
       MAILPILE_GNUPG/GA=/usr/bin/gpg-agent \
       MAILPILE_GNUPG/DM=/usr/bin/dirmngr \
       MAILPILE_TOR=/usr/bin/tor \
       MAILPILE_OPENSSL=/usr/bin/openssl
   ```
   `GNUPGHOME` replaces upstream's `/root/.gnupg`; whether Mailpile honours it is UNVERIFIED. `HOME=/config` moves `~/.local/share/Mailpile` to `/config/.local/share/Mailpile` without a separate variable.
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 33411
   VOLUME /config
   WORKDIR /config
   CMD ["/start.sh"]
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mailpile"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=mailpile/Mailpile versioning=loose
  default = "1.0.0rc6"
}

variable "MAILPILE_SHA256" {
  default = "UNVERIFIED: compute from the downloaded tarball on the first build"
}

variable "LICENSE" {
  default = "UNVERIFIED: set from the license text found in the source"
}

variable "SOURCE" {
  default = "https://github.com/mailpile/Mailpile"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MAILPILE_SHA256 = "${MAILPILE_SHA256}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

- arm64: the source is architecture-neutral Python, but no arm64 build has been tested. Keep both platforms in `image-all`, and report arm64 as untested.
- Validate with `docker buildx bake --print` from `apps/mailpile`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mailpile/Mailpile"
ports:
  - port: 33411
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

- The `MAILPILE_*` variables are set in the Dockerfile `ENV`. They are tool paths and not user settings, so they are not listed here.
- `TZ` default: upstream uses `Etc/GMT`. Use `Etc/UTC` to match the other apps; note the change in the PR.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/gnupg
chmod 700 /config/gnupg

cd /app/mailpile
exec /app/venv/bin/python ./mp --www=0.0.0.0:33411 --wait
```

- Idempotent: `mkdir -p` and `chmod` on the GnuPG home only. Nothing is seeded, and user state is never overwritten.
- Writes only under `/config`. Temp files go to `/tmp`.
- Binds `0.0.0.0` (the upstream CMD does this, confirmed).
- `exec` hands PID 1 to Mailpile.
- Whether `./mp` runs under `/app/venv/bin/python` (the shebang may point at Python 2; UNVERIFIED) is part of the Python 3 check.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '33411'
http:
- port: '33411'
  path: /
filePaths:
- /app/mailpile/mp
- /usr/bin/gpg
- /usr/bin/tor
- /usr/share/licenses/mailpile/LICENSE
```

- `timeoutSeconds: 120` is a starting value (UNVERIFIED; compare sibling apps).
- The HTTP probe on `/` is expected to return 200 after first start. The first-run redirect, if any, is UNVERIFIED; check the status code on the first run and do not weaken the probe.
- The test runs with no env vars. Start does not need secrets, so no `filePaths` for required-env paths.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in ContainerForge |
| --- | --- |
| `/root/.local/share/Mailpile` (state) | `/config/.local/share/Mailpile`, via `HOME=/config`. |
| `/root/.gnupg` | `/config/gnupg` via `GNUPGHOME`. The directory must be `0700`. |
| Tor data directory (default `~/.tor`) | `/config/.tor` via `HOME`, UNVERIFIED that Mailpile starts Tor with the default data directory. |
| Python bytecode and pip cache | Base sets `PYTHONDONTWRITEBYTECODE=1` and `PIP_NO_CACHE_DIR=1`. |
| Temp files | `/tmp`. |
| `upstream root` user | Runs as `apps` (568). The apt packages are installed at build time. |

- Draft expectations, reconciled: the chart forces UID 0 and state under `/root`. The image runs as 568 with state in `/config`. Verify `--read-only --tmpfs /tmp` in section 11.
- Mailpile's web UI is served on `0.0.0.0:33411` with no auth shown in the source reviewed (UNVERIFIED). Warn in the PR that it should not be exposed without a reverse proxy that adds auth.

## 10. Risks, caveats and open questions

- Blocker: Python 2. Mailpile 1.0.0rc6 is Python 2 code (upstream uses `py2-pip` and Alpine 3.10 packages). Python 3 support is UNVERIFIED. Decision needed: (a) verify that Mailpile 1.0.0rc6 runs on Python 3 in `/app/venv`, or (b) stop the app and report it as blocked. A Python 2 base is not in this repo, and no maintained fork was verified, so do not pick a fork without the user's decision.
- The upstream packages (`py-lxml`, `py-pillow`, `py-cryptography`, `py-cffi`) are Alpine Python 2 builds. Their Python 3 equivalents and pins are UNVERIFIED.
- Legacy project: the last tag is 2019, the Docker Hub image was last updated in 2020, and the PyPI package is from 2014. Expect no security fixes.
- License: UNVERIFIED for the repo. Required before the bake file can be finished.
- Checksum: no upstream checksum. The sha256 is computed by us, and the tag's commit SHA is not recorded (not fetched).
- `gnupg1` and `tor` package availability on Ubuntu 26.04: UNVERIFIED.
- Renovate `github-tags` datasource and `depName` are UNVERIFIED.
- arm64: no arm64 information for the upstream Docker Hub image. Source is architecture-neutral, so arm64 should be possible, but it is UNVERIFIED.
- Not musl-only in the target: the upstream is Alpine, but this image is built on glibc Ubuntu, so `copy-from` is `no` as in the draft.
- Blocker list: Python 2 to 3 port (decision above). No GPU, no privileged need, no database.

## 11. Build and test steps

```sh
cd apps/mailpile
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mailpile-probe --read-only --tmpfs /tmp \
  -v mailpile-probe-config:/config \
  mailpile:1.0.0rc6
docker logs -f mailpile-probe
forgetool containers test \
  --image mailpile:1.0.0rc6 \
  --config ./container-test.yaml
docker rm -f mailpile-probe; docker volume rm mailpile-probe-config
```

- Readiness: Mailpile's startup line on port 33411 is UNVERIFIED. Record the first real line. Pass also requires the process to stay up and port 33411 to answer HTTP.
- Check that `/config/.local/share/Mailpile` and `/config/gnupg` exist after start and survive a restart.
- Test from outside the container (`-p 33411:33411`) to confirm it is not bound to localhost.
- Run `gpg --version` and `tor --version` inside the container to check the tools the app calls.

## 12. PR checklist

- Branch `feat/add-mailpile`, commit and PR title `feat(mailpile): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: Python 3 runtime (if the port is attempted), arm64, read-only runtime, Tor and GnuPG flows, and the source checksum.
- Warn that the upstream project is legacy and the web UI has no auth shown in the reviewed source.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
