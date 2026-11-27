# counterstrike2d — implementation plan
> Source: ./draft.md · Target: apps/counterstrike2d/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **1.0.1.8** (latest shown on vendor page, https://www.cs2d.com/download.php). Release date not shown on the page. |
| Renovate | UNVERIFIED: the vendor page has no feed. Recommendation: `// renovate: datasource=custom.cs2d depName=cs2d` is NOT a standard manager, so pin manually and say so in the PR. Do not invent a datasource. |
| License | Closed-source freeware (draft and vendor page). Exact license text: UNVERIFIED. Upstream repo license: `null` on GitHub (https://api.github.com/repos/ich777/docker-cs2d-server). `LICENSE` value in bake: UNVERIFIED until the vendor terms are read. |
| Source URL | https://www.cs2d.com/ (vendor) |
| Download (amd64) | https://www.unrealsoftware.de/files_pub/cs2d_dedicated_linux.zip (linked from vendor page https://www.cs2d.com/download.php). Upstream script uses `http://www.unrealsoftware.de/files_pub/cs2d_dedicated_linux.zip`; plan uses HTTPS. |
| Download (arm64) | The vendor page lists a Linux ARM64 server zip (per fetch). Exact URL: UNVERIFIED. Whether the binary runs on the target base: UNVERIFIED. |
| Checksum source | Vendor publishes Dedicated CRC32 and SHA256 hash values for Linux x64 and ARM64 on https://www.cs2d.com/download.php (values behind links, not fetched; upstream repo publishes none). UNVERIFIED: plan computes SHA256 at build time and pins it in the Dockerfile after one manual download (see section 4). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/Dockerfile: `FROM ich777/debian-baseimage` (no tag), enables i386, installs `unzip` and `libgtk2.0-0:i386`, creates user `cs2d` (`ENV USER=cs2d`), `ENTRYPOINT ["/opt/scripts/start.sh"]`, runs as root, no USER/VOLUME/EXPOSE. |
| Upstream start script reviewed | https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/scripts/start.sh: root wrapper (`usermod`, `chown` of `DATA_DIR`), then `su ${USER} -c /opt/scripts/start-server.sh`. |
| Upstream server script reviewed | https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/scripts/start-server.sh: downloads the CS2D client zip (`https://github.com/ich777/docker-cs2d-server/raw/master/cs/cs2d_1008_linux.zip`, not needed for a dedicated server) and the dedicated zip (`http://www.unrealsoftware.de/files_pub/cs2d_dedicated_linux.zip`), both `unzip -qo` into `${SERVER_DIR}`, then runs `${SERVER_DIR}/cs2d_dedicated ${GAME_PARAMS}`. The Force Update block contains a malformed second `wget -O <url>` line: do not copy it. |
| Ports | UNVERIFIED: upstream declares none (no EXPOSE, no port in scripts). Draft's 36963 (tcp and udp) is `(inferred)` only. Confirm from `server.cfg`/the server's own log after first start before listing it. |
| Env vars (real, upstream) | `DATA_DIR=/serverdata`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `GAME_PARAMS`, `FORCE_UPDATE`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=cs2d` (from upstream Dockerfile). |
| arm64 | Vendor offers an ARM64 zip (per fetch): UNVERIFIED for this plan. Default plan: amd64 only until the arm64 binary is run. |
| copy-from amd64 | `ghcr.io/ich777/cs2dserver:latest` (draft). Not used: the plan downloads from the vendor (see section 3). |
| copy-from arm64 | no |

## 2. Target layout

- `apps/counterstrike2d/Dockerfile`
- `apps/counterstrike2d/docker-bake.hcl`
- `apps/counterstrike2d/settings.yaml`
- `apps/counterstrike2d/container-test.yaml`
- `apps/counterstrike2d/start.sh`

No `defaults/`, `etc/`, `health/` needed unless a default `server.cfg` must be seeded (section 7). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build stage and the final stage.

Why: the draft says "Runtime image: none (ubuntu alone is enough)". The server is a 32-bit-era freeware binary, so the draft's `libgtk2.0-0:i386` is a candidate dependency (UNVERIFIED: whether the dedicated server needs GTK 2 at all; the GUI libs are a client-side need). Closest sibling: `apps/webgrabplus` (vendor zip extracted on ubuntu) and `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

Decision: download the vendor zip **at build time**, not at runtime. Reason: `/app` is read-only and the rules require verifying downloads; a runtime download on every fresh start is the draft's main caveat. A build-time download with a pinned SHA256 gives a reproducible image. (Writer: say so in the PR; it differs from the upstream runtime download.)

1. `ARG VERSION` (must equal `docker-bake.hcl` `VERSION`, `1.0.1.8`) and `ARG CS2D_SHA256` (UNVERIFIED until computed, see below). The download URL has no version in it, so `VERSION` is only a label; `CS2D_SHA256` must be set as a Dockerfile `ARG` default or passed through the bake `args` (section 5 only passes `VERSION`), and must be updated together with `VERSION`.
2. Build stage `FROM <ubuntu> AS build`, `USER root`:
   ```dockerfile
   RUN set -eux; \
       mkdir -p /tmp/cs2d; \
       curl -fL -o /tmp/cs2d/cs2d_dedicated_linux.zip "https://www.unrealsoftware.de/files_pub/cs2d_dedicated_linux.zip"; \
       echo "${CS2D_SHA256}  /tmp/cs2d/cs2d_dedicated_linux.zip" | sha256sum -c -; \
       unzip -q /tmp/cs2d/cs2d_dedicated_linux.zip -d /tmp/cs2d/server
   ```
   `CS2D_SHA256` must be computed by the writer or the maintainer from one manual download of this exact URL and recorded in the PR (vendor SHA256 values are on https://www.cs2d.com/download.php and must be cross-checked; not fetched). Mark it as such in the PR.
3. Confirm the extracted layout: the binary is `cs2d_dedicated` (upstream launch line); confirm it is at the zip root (UNVERIFIED) and whether the zip contains a license file (copy it if present).
4. Final stage `FROM <ubuntu>`, `USER root`:
   - Install libraries only if the binary needs them (`ldd cs2d_dedicated` in the build stage, UNVERIFIED). Candidate: `libgtk2.0-0t64` (the draft's i386 GTK 2 is a 32-bit package and should be dropped if `ldd` shows no need). Do not add packages the base already has.
   - `mkdir -p /app/counterstrike2d`, `COPY --from=build /tmp/cs2d/server/ /app/counterstrike2d/`, `chmod 0755 /app/counterstrike2d/cs2d_dedicated`.
   - License: `install -Dm0644 <vendor license file, if in zip> /usr/share/licenses/counterstrike2d/LICENSE`, otherwise a `NOTICE` file citing https://www.cs2d.com/ and the vendor freeware terms (UNVERIFIED wording).
   - Data: `ln -s /config/serverdata /app/counterstrike2d/data` only if the server writes to its own directory (UNVERIFIED, section 9).
   - `ENV HOME=/config`? No: `HOME=/tmp` (caches go to `/tmp`); server state goes to `/config` through `start.sh`.
5. Ownership: `chown -R root:root /app/counterstrike2d && chmod -R a+rX /app/counterstrike2d` (read-only for `apps`).
6. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   VOLUME /config
   WORKDIR /config
   ENTRYPOINT ["/start.sh"]
   ```
   `EXPOSE` only after the ports are confirmed (section 1).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "counterstrike2d"
}

variable "VERSION" {
  // renovate: datasource=custom depName=cs2d-vendor versioning=loose
  default = "1.0.1.8"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.cs2d.com/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
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
  platforms = ["linux/amd64"]
}
```

- The renovate line is a placeholder: no standard datasource exists for the vendor page. The writer should either remove the annotation and note manual updates in the PR, or add a `customManagers` rule in the repo renovate config (outside this app; do not do it in the app PR). Flag it as an open question.
- `image-all` is amd64 only until arm64 is run (section 1).
- Validate with `docker buildx bake --print` from `apps/counterstrike2d`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.cs2d.com/"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `ports` is empty until the server's listening port is confirmed (section 1). When confirmed, add a `tcp` and/or `udp` entry for it and a matching probe in `container-test.yaml` (see section 8).
- Env vars: only what `start.sh` actually reads. `GAME_PARAMS` is read by the upstream launch line; list it only if the port and config are passed through it (UNVERIFIED). Do not list `FORCE_UPDATE`, `UID`, `GID`, `DATA_PERM` (root-wrapper vars with no meaning in this image).
- No database dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/tmp

server_dir="/config/serverfiles"
mkdir -p "${server_dir}"

# Seed the server folder from the image only when it is missing or empty.
if [ ! -x "${server_dir}/cs2d_dedicated" ]; then
    cp -a /app/counterstrike2d/. "${server_dir}/"
fi

cd "${server_dir}"
exec ./cs2d_dedicated ${GAME_PARAMS:-}
```

- Idempotent: copies the server only when the binary is missing. Keeps saves and config in `/config/serverfiles` (existing data untouched).
- Never writes to `/app`: the copy goes from `/app` to `/config` (read-only source, fine).
- `GAME_PARAMS` is word-split on purpose (matches the upstream launch line). Do not pass it through untrusted shell expansions (keep it as an env var, not a file).
- Seeding a default `server.cfg` is UNVERIFIED: only add it if the server refuses to start without one (decide in the run).
- Use `exec` so signals reach the server.
- Binding: the server must listen on all interfaces (UNVERIFIED: check with `ss -lun`/`ss -ltn` in the run; the default config may bind a specific address).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/counterstrike2d/cs2d_dedicated
- /usr/share/licenses/counterstrike2d/LICENSE
- /start.sh
```

- Add a `tcp` (or `http`, if the server speaks HTTP, which it does not in the upstream scripts) probe for each confirmed port from section 6. Without a confirmed port, there is no probe to write, so none is invented.
- `filePaths` checks the binary and the start script. If the license file is replaced by a `NOTICE`, change the path to match.
- No env var is needed to start. `GAME_PARAMS` is optional and empty by default.
- `timeoutSeconds` 120: the server starts from a local copy; no runtime download (section 4).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/serverfiles` (`SERVER_DIR`, pvc) | `/config/serverfiles` (seeded once by `start.sh`) |
| `/opt/scripts` (root wrapper ownership) | Not used: no root wrapper in this image |
| runtime zip download to `SERVER_DIR` | Replaced by build-time download with SHA256 pin (section 4) |
| `cs2d_dedicated` own write paths (config, maps, logs, saves) | UNVERIFIED: the binary may write next to itself (`/config/serverfiles`, which is writable) or to a fixed path under the game folder. Confirm in the `--read-only` run; if it writes into `/app/counterstrike2d`, add a symlink for that directory to `/config`. |
| `HOME` | `/tmp` |

Draft expectations reconciled:
- Draft says non-root possible: the plan runs as `apps`, no root wrapper, no `usermod`.
- Draft says `readOnlyRootFilesystem` possible: `/app` is read-only, server state in `/config`, proved in section 11.
- Not privileged. No extra security settings.
- Draft expects `/serverdata/serverfiles` as chart persistence: this image uses `/config/serverfiles`, so chart users must move their data (PR note).

## 10. Risks, caveats and open questions

- Vendor publishes SHA256 hash values on https://www.cs2d.com/download.php: cross-check the pinned SHA256 against them (section 4). Note the check in the PR.
- Vendor freeware terms: the license text and redistribution rights are UNVERIFIED. The bake `LICENSE` value and the shipped license file depend on this. Resolve before merging.
- Vendor link: the vendor page links `www.unrealsoftware.de` and the upstream script uses `http://`. The plan uses HTTPS. If the HTTPS link fails, use the URL from the vendor page and record it.
- The ARM64 zip is listed by the vendor (per fetch). Not planned in this PR; open question for a follow-up.
- Ports unverified (section 1). Draft's 36963 is inferred only.
- The server version can change if the vendor replaces the zip under the same name. The SHA256 pin protects against that: the build fails instead of silently taking the new file.
- Build-time download means the image size grows by the zip size (about 3 MB, per the vendor page for the server section as a whole).
- Blockers: none confirmed. Possible one: if `cs2d_dedicated` needs GTK 2 (i386), the image needs 32-bit libs (section 4, step 4). Confirm with `ldd` before adding them.

## 11. Build and test steps

```sh
cd apps/counterstrike2d
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name counterstrike2d-probe --read-only --tmpfs /tmp \
  -v counterstrike2d-probe-config:/config counterstrike2d:1.0.1.8
docker logs -f counterstrike2d-probe
docker exec counterstrike2d-probe ss -lun
docker exec counterstrike2d-probe ss -ltn
docker rm -f counterstrike2d-probe; docker volume rm counterstrike2d-probe-config

forgetool containers test --image counterstrike2d:1.0.1.8 --config ./apps/counterstrike2d/container-test.yaml
```

- Expected readiness signal: the server prints its startup banner and binds the confirmed port (exact line UNVERIFIED: read it from the first run). The process stays alive after the startup window.
- Run twice with the same `/config` volume to prove the seed step does not overwrite existing files.
- Check that a `--read-only` run does not fail on a write into the game folder (section 9).
- Also run the arm64 build only if the writer adds the ARM64 zip (out of scope for this PR).

## 12. PR checklist

- Branch `feat/add-counterstrike2d`, commit `feat(counterstrike2d): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it; `license/cla` shows the status.
- Note the data migration from `/serverdata/serverfiles` to `/config/serverfiles` (section 9) and the build-time download (section 4).
- Untested to say in the PR: arm64, the ports, the SHA256 pin's source (computed by us), the license text, the renovate annotation (no datasource), and any run longer than one start.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION` (1.0.1.8).
