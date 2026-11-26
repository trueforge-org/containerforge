# crafty-4 — implementation plan
> Source: ./draft.md · Target: apps/crafty-4/ · Difficulty: medium · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v4.11.1, released 2026-11-18, tag commit c5c08effa959d570075f951a364216ebd658ca22. Source: https://gitlab.com/api/v4/projects/crafty-controller%2Fcrafty-4/releases/v4.11.1 . Draft tag 4.11.1 matches. |
| Renovate | Proposed: `datasource=gitlab-tags depName=crafty-controller/crafty-4` (UNVERIFIED that the repo's renovate config accepts gitlab-tags here). |
| License | GPL-3.0. Source: https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/LICENSE (also upstream image label) |
| Source | https://gitlab.com/crafty-controller/crafty-4 |
| Per-arch downloads | The release has one asset, a Windows package. No Linux asset. Linux must be built from source at the tag. The draft's binary link points at the Windows-only release page, so it does not help. |
| Checksum source | None published for the source tarball. Pin the tag commit SHA. |
| Upstream Dockerfile | https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/Dockerfile. FROM ubuntu:24.04; apt sudo, gcc, libcurl4, python3, python3-dev, python3-pip, python3-venv, libmariadb-dev, default-jre, openjdk-8/11/17/21/25-jre-headless, tzdata; user `crafty`; `/crafty`; pip install -r requirements.txt into /crafty/.venv; COPY source; config moved to config_original; ENTRYPOINT /crafty/docker_launcher.sh; CMD -d -i. |
| Python requirements | https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/requirements.txt (26 pins, including pillow==12.2.0, cryptography==48.0.0, tornado==6.5.4). arm64 wheel availability: UNVERIFIED. |
| Launcher | https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/docker_launcher.sh. On first start copies app/config_original into app/config; as root it `sudo -u crafty` and execs `python3 main.py`; non-root: exec python3 main.py directly after activating ./.venv. Fixes group perms under /crafty. |
| Env vars (real) | None found in the Dockerfile beyond build ARGs (BUILD_DATE, BUILD_REF, CRAFTY_VER). App-level env vars: UNVERIFIED (not checked in Crafty code). |
| Ports | 8443/https (web), 8000 (web HTTP), 8123, 5520-5550, 25500-25600 (Minecraft range), 19132/udp (Bedrock). Source: upstream EXPOSE lines. |
| Data write paths | Upstream: /crafty/app/config, /crafty/servers, /crafty/logs, /crafty/import, /crafty/backups (chart-added PVCs; chart values). Launcher writes ./app/config and ./import. |
| arm64 | Java and Python packages exist for arm64 (apt); Crafty arm64 is UNVERIFIED. The upstream Dockerfile has a SteamCMD arch branch (amd64 only); not needed for our build. |
| Dependencies | none. Java runtime comes from the java21 sibling base. |
| Blockers | Launcher assumes root then sudo to `crafty`; read-only rootfs requires writable /config for all state. |

## 2. Target layout

- `apps/crafty-4/Dockerfile`
- `apps/crafty-4/docker-bake.hcl`
- `apps/crafty-4/settings.yaml`
- `apps/crafty-4/container-test.yaml`
- `apps/crafty-4/start.sh` (replaces docker_launcher.sh; seeds app/config into /config, then execs main.py)
- `apps/crafty-4/defaults/` for `config_original` (default.json.example and version.json) only if the seeding in start.sh needs them. Reason: they must be in the image. Not `root/`.
- No DOWNSTREAM_CHANGES.md (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` for the app, with Java from `ghcr.io/trueforge-org/java21:...` copied in, or java21 used as the final base if the Python wheels install. Closest sibling for Python apps: apps/bazarr. Java source for spawned servers: apps/java21 (draft's choice, consistent with upstream's multi-JRE install). Pick one final base (python) and add the JRE via `COPY --from` only if feasible; otherwise switch to the java21 base and install python3 with apt. UNVERIFIED which option the Python base's Java handling supports.

## 4. Dockerfile

1. Final base from section 3 (python base; it already ships `/app/venv`): `ARG VERSION` (4.11.1), `USER root`.
2. Fetch source tarball of tag v4.11.1 from GitLab (verify it matches commit c5c08eff...), extract to /tmp/src.
3. Install into the base's existing `/app/venv` at build time (do not create a second venv): `/app/venv/bin/pip install --no-cache-dir -r requirements.txt`, with `PIP_CACHE_DIR=/tmp/pip`. Do not write to /app/venv at runtime (python-runtime rule).
4. Copy source to /app/crafty (read-only at runtime). Move `app/config` to `defaults/config_original` (or keep in /app and seed).
5. License to `/usr/share/licenses/crafty-4/LICENSE`.
6. `ENV HOME=/config`, `PYTHONDONTWRITEBYTECODE=1` (inherited).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8443 8000
VOLUME /config
```

First version exposes only the web ports; game ports are documented, not required (see section 10).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "crafty-4" }
variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=crafty-controller/crafty-4 versioning=semver
  default = "4.11.1"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://gitlab.com/crafty-controller/crafty-4" }
```

Four standard targets and default group copied from apps/adguardhome-sync. `docker buildx bake --print` before any build. The Dockerfile `ARG VERSION` must equal 4.11.1.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://gitlab.com/crafty-controller/crafty-4"
ports:
  - port: 8443
    protocol: tcp
    required: true
  - port: 8000
    protocol: tcp
    required: false
  - port: 25565
    protocol: tcp
    required: false
  - port: 19132
    protocol: udp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Game ports 25565/tcp and 19132/udp have no probe: they open only when a Minecraft server is created inside the panel, so they are not up at start. Port 25565 is the default Minecraft port (not EXPOSEd upstream; it lies inside 25500-25600). Declare it only if the server-spawning code confirms it (UNVERIFIED). No app env vars are declared because none were verified.

## 7. start.sh

- Idempotent. Create `/config/app/config`, `/config/servers`, `/config/logs`, `/config/import`, `/config/backups` if missing.
- Seed `/config/app/config` from the image defaults only when missing or empty (same rule as docker_launcher.sh). Do not overwrite existing user state.
- Copy version.json from the image on every start (as the launcher does) so the version stays current.
- Link or configure the app to read/write `/config/...` instead of `/crafty/app/config` (UNVERIFIED how Crafty resolves paths; check in step 3).
- Set `HOME=/config` and any temp to `/tmp`.
- Final line: `exec /app/venv/bin/python main.py "$@"` from the Crafty source directory, with `cd` into it first.
- No `sudo`. The container runs as `apps`, so the launcher's chown/sudo logic is not used.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '8443'
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /usr/share/licenses/crafty-4/LICENSE
- /app/venv/bin/python
```

Probes for 8443 (tcp) and 8000 (tcp + http). HTTPS 8443 may need `https` probe; use tcp only if forgetool has no https option (UNVERIFIED). Game ports 25500-25600 and 19132/udp are not probed; they are not required at start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/crafty/app/config` (chart PVC) | `/config/app/config` (persistent, seeded when missing) |
| `/crafty/servers` | `/config/servers` |
| `/crafty/logs` | `/config/logs` |
| `/crafty/import` | `/config/import` |
| `/crafty/backups` | `/config/backups` |
| Upstream runs as root then `sudo -u crafty` | Final stage `USER apps`; no sudo, no chown. Chart runAsUser 1000 (draft) is not inherited. |
| Caches, pip, temp | `/tmp` |

Draft says server data under /config, which matches. Check that spawned Minecraft servers download jars into `/config/servers`, not `/app` (UNVERIFIED in step 3).

## 10. Risks, caveats and open questions

- Minecraft server jars download on first server creation: needs network; slow first start (inferred).
- Game ports (25565/tcp, 19132/udp) must be published separately for clients to connect (inferred).
- Mojang EULA must be accepted by the user for Minecraft servers (inferred).
- Java: the upstream image installs 5 JREs; we need the right JRE for each server version. Only java21 or java25 are present as siblings; others UNVERIFIED.
- The Windows-only release asset means the Linux path depends on building from source at the tag (GPL-3.0 source is available).
- arm64: UNVERIFIED for the Crafty runtime and its Python wheels (pillow, cryptography).
- Blockers: no musl-only, GPU or privileged needs found. Root-to-crafty launcher must not be used. Read-only rootfs is the main risk.

## 11. Build and test steps

```sh
cd apps/crafty-4
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create crafty-4-probe-config
docker run --rm -d --name crafty-4-probe --read-only --tmpfs /tmp -v crafty-4-probe-config:/config crafty-4:4.11.1
docker logs -f crafty-4-probe
docker rm -f crafty-4-probe; docker volume rm crafty-4-probe-config
forgetool containers test --image crafty-4:4.11.1 --config ./apps/crafty-4/container-test.yaml
```

Expected readiness signal: Crafty log line showing the web server listening on 8443 or 8000 (UNVERIFIED wording).

## 12. PR checklist

- Branch `feat/add-crafty-4`, commit `feat(crafty-4): add new container`, title same.
- Body uses `.github/PULL_REQUEST_TEMPLATE.md`; only check applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64, Minecraft server creation, game ports, unless actually run.
