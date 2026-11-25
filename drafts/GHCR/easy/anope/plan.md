# anope — implementation plan
> Source: ./draft.md · Target: apps/anope/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest upstream stable is `2.0.21`, published 2026-11-22. Source: https://api.github.com/repos/anope/anope/releases/latest (read via `gh api`), https://github.com/anope/anope/releases/tag/2.0.21 |
| Draft pin | Draft says `2.0.20`. That is not the latest release. Decision needed (see section 3 and 10): build `2.0.21` from source, or use the Ubuntu package. |
| Ubuntu package | `anope 2.0.17-1.1` on resolute (26.04), amd64 and arm64 listed. Source: https://packages.ubuntu.com/resolute/anope. Description: "IRC Services designed for flexibility and ease of use". |
| Renovate | `datasource=github-releases depName=anope/anope versioning=loose` (plain `2.0.x` tags) |
| License | GPL-2.0 (GitHub license API `spdx_id`: `GPL-2.0`). Source: https://api.github.com/repos/anope/anope/license. Use the `LICENSE`/`docs` file of the tag to confirm the `-only` or `-or-later` wording (UNVERIFIED which file holds it; the repo `docs/LICENSE` path returned 404). |
| Source URL | https://github.com/anope/anope |
| Website | https://www.anope.org/ |
| Download (binary) | No Linux binary asset. The 2.0.21 release has only `anope-2.0.21.exe` (Windows). Linux path is the tag source archive `https://github.com/anope/anope/archive/refs/tags/2.0.21.tar.gz` (build from source) or the Ubuntu apt package. |
| Checksum source | None found for the Linux source archive (release body has no sha256 list in the reviewed part). Apt verifies package signatures. |
| Upstream reference image | `ich777/docker-anope` (https://github.com/ich777/docker-anope/blob/master/Dockerfile). `FROM ich777/debian-baseimage`, apt `curl screen`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `EXPOSE`, no `VOLUME`, no `USER`. Its ENV set (`HOST`, `IP_ADDR`, `PORT=7000`, `PASSWORD`, `IRCD=inspircd3`, `CASEMAP`, `LOCAL_HOSTNAME`, `DATA_DIR=/anope`, `UID`, `GID`, `UMASK`, `DATA_PERM`, `SSL`) belong to that helper's own start script, not to Anope. Do not copy them as Anope env vars. |
| Anope's own env vars | None confirmed. The daemon reads its config file, not environment variables (UNVERIFIED for every Anope build). |
| Ports | None inbound. Anope connects out to an IRC server (link block). Draft lists no ports. |
| Config and data paths | Config (`services.conf`, `modules.conf`) and data (databases) are read from the Anope config and data directories (UNVERIFIED exact default paths and the CLI flags for overriding them on the apt build; check `anope --help` or the packaged `/etc/anope` layout during the first build). |
| Dependencies | None (draft). An IRC server must be reachable (external, not a ContainerForge app). |
| arm64 | Apt package is listed for arm64 on resolute (2.0.17-1.1). The source build should be arm64-native through buildx. |
| Blockers | None found. Caveat: the daemon needs a valid services config with a link block before it can start (draft, inferred; UNVERIFIED whether the apt package ships a usable default). |

## 2. Target layout

- `apps/anope/Dockerfile`
- `apps/anope/docker-bake.hcl`
- `apps/anope/settings.yaml`
- `apps/anope/container-test.yaml`
- `apps/anope/start.sh`
- `apps/anope/defaults/services.conf` (seeded into `/config` only when missing; reason: the daemon cannot start without a services config and link block, and `defaults/` is the allowed place for shipped files)

No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). `.dockerignore` lets `defaults/` through, so `COPY . /` brings the file in.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build stage and the final stage. Apt has anope on resolute, and the source build (if chosen) needs compilers that the build stage installs. Closest sibling: `apps/ngircd` or `apps/znc` (IRC daemons on ubuntu with a config file in `/config`). Check both during the build for layout (UNVERIFIED which one is the closer template).

Version decision (must be made before scaffolding):
- Option A (default in this plan): Ubuntu apt `anope=2.0.17-1.1`, `VERSION=2.0.17`. Simplest, matches the apt pin rule (the apt version is checked against `VERSION`). Drawback: 2.0.17 is older than the 2.0.21 release, and the draft asked for 2.0.20.
- Option B: build `2.0.21` from the source archive in a build stage, then `COPY --from` into the ubuntu final stage. Matches the latest release. Requires the build dependencies (cmake or the configure step, a C++ compiler, OpenSSL, and any Anope build deps) to be confirmed on the 26.04 base (UNVERIFIED which packages). Checksum: none published.

Pick A for the first PR unless the user asks for the latest release. Record the choice and the reason in the PR.

## 4. Dockerfile

Option A (apt), the default:

1. `ARG VERSION`, `ARG APT_VERSION=2.0.17-1.1`, `USER root`.
2. Install the pinned package and check it matches `VERSION`:

```dockerfile
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends "anope=${APT_VERSION}"; \
    rm -rf /var/lib/apt/lists/*; \
    anope --version 2>&1 | grep -q "${VERSION}"
```

The version-check command depends on the binary: `anope` may print its version only with a specific flag (UNVERIFIED flag; check `anope --help` during the first build). If no flag prints the version, check with `dpkg-query -W anope` instead and assert `${APT_VERSION}`.

3. Licence file: copy the Debian copyright to `/usr/share/licenses/anope/copyright` (path `/usr/share/doc/anope/copyright`, UNVERIFIED until the first build).
4. Runtime env: `ENV HOME=/config`. No Anope env vars are added (none confirmed).
5. Tail:

```dockerfile
RUN install -d -o apps -g apps /config
USER apps
COPY --chmod=0755 . /
WORKDIR /config
VOLUME /config
```

Option B (source), if chosen: build stage `FROM <ubuntu> AS build`, download `https://github.com/anope/anope/archive/refs/tags/${VERSION}.tar.gz`, configure with the install prefix `/usr/local/anope` (UNVERIFIED flags), `make install`, then `COPY --from=build /usr/local/anope /app/anope` in the final stage. Keep the build tools in the build stage only. Set `VERSION=2.0.21` in bake and the renovate annotation above.

## 5. docker-bake.hcl

Option A values (change `VERSION` to `2.0.21` only with Option B):

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "anope"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=anope/anope versioning=loose
  default = "2.0.17"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/anope/anope"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Notes: the renovate annotation tracks the upstream release (2.0.21) while Option A pins 2.0.17 from apt. This mismatch is intentional only if the PR says so; otherwise renovate will propose 2.0.21 and the Dockerfile will fail the apt version check. Resolve before merge (either Option B, or leave renovate on the apt package). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/anope/anope"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Notes: `ports: []` because Anope opens no inbound listener (services only connect out to the IRC server). If the schema rejects an empty list, check a sibling IRC app with no ports (UNVERIFIED). No env vars are declared beyond `TZ` (only add the ones `start.sh` reads; do not add the ich777 helper's variables). The IRC server host and password are settings in `/config/services.conf`, not env, unless `start.sh` templates them (see section 7 and open questions).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

[ -f /config/services.conf ] || cp /defaults/services.conf /config/services.conf

cd /config
exec anope --nofork --confdir=/config --datadir=/config
```

Notes:
- The flags shown (`--nofork`, `--confdir`, `--datadir`) are UNVERIFIED for the apt build. Replace them with the real options from `anope --help` during the first build. The goal is: config and databases under `/config`, the daemon in the foreground, PID 1 via `exec`.
- Do not write to `/app` and do not write to the packaged `/etc/anope` (read-only at runtime).
- `defaults/services.conf` must contain a link block and a placeholder server. The IRC host and password must not be shipped as real credentials. Options: (a) template them from env at start with `sed` (new env names needed: for example `IRC_HOST`, `IRC_PORT`, `IRC_PASSWORD`, which must be declared in `settings.yaml`), or (b) require the user to edit `/config/services.conf` and document it. Pick (a) only if the file can be templated safely; apply the password on every start (rule for DB and secrets), not only on first seed.
- If option (a) is taken, quote env values so special characters do not break the config (start-script rule).
- Keep `umask` out unless the daemon needs it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /usr/bin/anope
- /defaults/services.conf
- /usr/share/licenses/anope/copyright
```

Notes:
- No ports, so no `tcp` or `http` probe (coverage rule applies only to declared ports).
- `filePaths` checks the binary and the shipped config. The seeded `/config/services.conf` exists only at runtime; check it in the run step, not in `filePaths`.
- Without an IRC server the daemon may retry the link and exit or log errors. The test must not be weakened to pass: if the daemon exits with no IRC server, use the database-dependent narrowing only if all three criteria of the protocol hold (they do not: there is no `dependencies:` DB entry, so this is not a DB-dependent app). Instead, run the daemon against a local IRC server for the test (for example the `ngircd` sibling image in `apps/ngircd`, as a manual test, not in CI unless forgetool supports a sidecar). Record the decision in the PR.
- `timeoutSeconds` is a placeholder; take the closest sibling value.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Config and data dirs (packaged `/etc/anope`, `/var/lib/anope` on apt; UNVERIFIED defaults) | Overridden to `/config` by flags in `start.sh` (UNVERIFIED flags); the shipped config lives in `/defaults` and is seeded to `/config`. |
| Logs (UNVERIFIED default location) | `/config/logs` if the flag exists, otherwise `/tmp` (if logs are only useful for the session). |
| `/tmp` | Tmpfs under `--read-only --tmpfs /tmp`. |

The draft's expectations are reconciled: draft says `USER apps` (yes), read-only rootfs possible (yes, once the data and logs are redirected), privileged no. Chart runs as UID 0 and `readOnlyRootFilesystem: false`; this image needs neither. Existing chart users with `/anope` PVC content must copy it to `/config` (migration note in the PR).

## 10. Risks, caveats and open questions

- Version: draft pin 2.0.20, apt 2.0.17, latest release 2.0.21. Decide Option A or B (section 3). The draft's 2.0.20 is not used by either option as written.
- Renovate and apt mismatch (section 5) must be resolved before merge.
- No default services config ships in the upstream reference image (draft caveat, confirmed as UNVERIFIED for the apt package).
- Link block: without an IRC server reachable from the container, the services cannot connect. Document it; do not add an IRC server dependency to `settings.yaml` (it is external).
- Secrets: the link password must not be stored in the image. Use the templating option (section 7) or document manual edit.
- Anope runs as the `apps` user only if its apt build allows a non-root run; UNVERIFIED (some daemons refuse to start as non-root or need the `anope` system user). Check at first run.
- Source build dependencies (Option B) unverified.
- No checksum for the source archive.
- Draft caveat "`extra-persistence: /anope pvc`" is confirmed in chart terms only; the path mapping is in section 9.

## 11. Build and test steps

```sh
cd apps/anope
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create anope-probe-config
docker run --rm -d --name anope-probe --read-only --tmpfs /tmp \
  -v anope-probe-config:/config anope:2.0.17
docker logs -f anope-probe
docker exec anope-probe anope --help
forgetool containers test --image anope:2.0.17 --config ./apps/anope/container-test.yaml
docker rm -f anope-probe; docker volume rm anope-probe-config
```

Use an empty `/config` per round. Readiness signal: the daemon stays up (no exit), and its log shows a startup line (UNVERIFIED exact text; record it after the first run). If it cannot link to an IRC server, expect connection-retry lines; a process that stays alive with retries and no fatal exit counts as ready under the protocol only if the normal startup line also appears. Test against a local `ngircd` (apps/ngircd) to get a real link in a manual run.

Restart the container with the same `/config` volume and confirm the seeded config is not overwritten and the databases persist.

## 12. PR checklist

- Branch `feat/add-anope`, commit and PR title `feat(anope): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- DOWNSTREAM_CHANGES.md: not needed.
- State the version choice (apt 2.0.17 or source 2.0.21) and why the draft's 2.0.20 was not used.
- Untested to state honestly (unless done): Option B build, arm64 build and run, the apt version check flag, the link to a real IRC server, the templated password path (if used), and the log readiness text.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; apt pin checked against `VERSION`; no assertion weakened.
