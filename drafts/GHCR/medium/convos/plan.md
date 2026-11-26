# convos — implementation plan
> Source: ./draft.md · Target: apps/convos/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v8.07 (latest stable tag, https://api.github.com/repos/convos-chat/convos/tags). The GitHub "latest release" endpoint returns 404, so no formal release is published. `v9.0-rc1` is a release candidate and is not used. Draft tag v8.07 matches. |
| Renovate | `datasource=github-tags depName=convos-chat/convos versioning=semver` (proposed; not checked against renovate config) |
| License | Artistic-2.0 (https://api.github.com/repos/convos-chat/convos, `license.spdx_id`). Use it as `LICENSE`. |
| Source URL | https://github.com/convos-chat/convos |
| Download | Source tarball `https://github.com/convos-chat/convos/archive/refs/tags/v8.07.tar.gz` (from draft, not fetched). Pin with a committed SHA-256. The tag commit is `63572e5cc48d821e9fe0d85b84dcea4ec837b466` (confirmed via git ref API). |
| Checksum source | None published (no release). Verify against the digest recorded at build time, and pin the commit SHA. |
| Per-arch binary | None. Interpreted Perl app installed from source with cpanm. Same for amd64 and arm64. |
| copy-from | no (draft; upstream image is Alpine/apk-based, not glibc ubuntu). |
| Upstream Dockerfile reviewed | Commit 63572e5cc48d821e9fe0d85b84dcea4ec837b466, https://raw.githubusercontent.com/convos-chat/convos/63572e5cc48d821e9fe0d85b84dcea4ec837b466/Dockerfile (fetched via summary). `FROM ghcr.io/convos-chat/convos-base:main` (base contents `UNVERIFIED`). Copies `Changes Makefile.PL assets lib public script templates` to `/app`. One RUN: install runtime packages, install build packages, `/app/script/convos install --all`, remove build packages and caches. `ENTRYPOINT ["/app/script/convos"]`, `CMD ["daemon"]`, `EXPOSE 3000`, `VOLUME ["/data"]`, no USER (runs as root). |
| Packages (upstream, Alpine apk) | runtime: curl, openssl, perl, perl-io-socket-ssl, perl-net-ssleay, wget. build-only: build-base, perl-dev. The ubuntu equivalents must be confirmed (`UNVERIFIED`). |
| Env (upstream) | `CONVOS_DEPENDENCIES=all` (build time), `CONVOS_HOME=/data`, `CONVOS_NO_ROOT_WARNING=1`, `MOJO_MODE=production` |
| Port | 3000/tcp (confirmed `EXPOSE 3000`) |
| Data path | `CONVOS_HOME=/data` upstream. The draft sets it to `/config` for ContainerForge. |
| Dependencies | None (draft confirmed: no DB; Convos uses its own storage under CONVOS_HOME). |

## 2. Target layout

- `apps/convos/Dockerfile`
- `apps/convos/docker-bake.hcl`
- `apps/convos/settings.yaml`
- `apps/convos/container-test.yaml`
- `apps/convos/start.sh`

`defaults/` is not needed (Convos creates its own data on first start, `UNVERIFIED`). No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both the build and the final stage. Fits because the app is Perl and cpanm can run on ubuntu from apt. The base already has `libicu-dev`, curl, tar, wget, `libssl3`, `ca-certificates` (confirmed in `apps/ubuntu/Dockerfile`).

Closest siblings: `apps/ubuntu` (base) and `apps/python` (apt-based runtime on this base). No Perl sibling was checked (`UNVERIFIED: confirm with a search of apps/ for perl`).

## 4. Dockerfile

1. `ARG VERSION`. Stay on `FROM <ubuntu> AS build`, `USER root`.
2. Install build deps with apt: `perl`, `cpanminus`, and the C build packages needed by CPAN XS modules (`build-essential`, `libssl-dev`, `zlib1g-dev`, `libperl-dev`, `UNVERIFIED: exact list`). Clean apt lists.
3. `mkdir -p /app` first, then `curl -fL https://github.com/convos-chat/convos/archive/refs/tags/v${VERSION}.tar.gz | tar xz --strip-components=1 -C /app`, after verifying a committed SHA-256. Set `CONVOS_DEPENDENCIES=all` for the install step.
4. `cd /app && perl script/convos install --all` (the upstream step, run as root in the build stage, `UNVERIFIED: whether it writes into /app`). Set `PERL_CPANM_HOME=/tmp/cpanm` and `CPANM_OPT=--notest` only if needed, `UNVERIFIED`.
5. Remove build-only packages and caches (`/root/.cpanm`, `/var/lib/apt/lists/*`).
6. Final stage `FROM <ubuntu>`, `USER root`: install the runtime perl packages (`perl`, plus the runtime libs the app needs, `UNVERIFIED`), clean apt lists. Then `COPY --from=build /app /app`.
7. `ENV CONVOS_HOME=/config CONVOS_NO_ROOT_WARNING=1 MOJO_MODE=production HOME=/config`. Keep `CONVOS_DEPENDENCIES` build-only.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app
```

`start.sh` runs the upstream entrypoint: `exec /app/script/convos daemon`. License: `COPY --from=build /app/LICENSE /usr/share/licenses/convos/LICENSE` (`UNVERIFIED: the upstream file name`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "convos" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=convos-chat/convos versioning=semver
  default = "8.07"
}
variable "LICENSE" { default = "Artistic-2.0" }
variable "SOURCE" { default = "https://github.com/convos-chat/convos" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print` (`UNVERIFIED: not run`). `VERSION` is used in the Dockerfile `ARG VERSION`, so the two must match (`8.07`; the tag is `v8.07`, so the URL uses `v${VERSION}`).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/convos-chat/convos"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: CONVOS_HOME
    default: "/config"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`CONVOS_NO_ROOT_WARNING` and `MOJO_MODE` are set in the image; list them in `env` only if they become user-facing. Do not list `CONVOS_DEPENDENCIES` (build-time only). No dependencies.

## 7. start.sh

- `mkdir -p /config`. Convos creates its data on first run, so nothing is seeded (`UNVERIFIED`).
- `export CONVOS_HOME="${CONVOS_HOME:-/config}"`, so the same value that `settings.yaml` documents is applied.
- No writes to `/app`.
- Bind all interfaces: `exec /app/script/convos daemon -l http://*:3000` (or `-l http://0.0.0.0:3000`, `UNVERIFIED: the listen flag`). Use `exec` so signals reach the process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/script/convos
- /usr/share/licenses/convos/LICENSE
```

One `tcp` and one `http` probe for port 3000 (coverage rule). `timeoutSeconds: 120` is a guess to match a sibling of the same family (`UNVERIFIED`). No DB, so the narrow exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (`VOLUME ["/data"]`, `CONVOS_HOME`) | `/config` via `CONVOS_HOME=/config` (draft). Chart mount `/data` (draft) is replaced by `/config`. |
| cpanm cache (`/root/.cpanm`) | Build stage only, removed before the final stage. |
| `HOME` | `/config`, so tools that use `~` write under `/config`, not `/app`. |

Upstream runs as root (`CONVOS_NO_ROOT_WARNING=1` suppresses its warning). ContainerForge runs as `apps` (UID 568), so the app must start and serve as a non-root user (`UNVERIFIED: confirm in a run`). Port 3000 is above 1024. Draft security expectations: non-root possible, read-only rootfs possible, privileged no, extra persistence `/config` (draft: `/data` upstream). These become firm only after a run.

## 10. Risks, caveats and open questions

- Upstream is Alpine-based (apk). Replacing apk packages with ubuntu apt equivalents is the main work. `perl-dev` and `build-base` mapping `UNVERIFIED`.
- `script/convos install --all` installs CPAN modules at build time, which is slow and needs internet access (draft, inferred, confirmed by the upstream step).
- The upstream base `ghcr.io/convos-chat/convos-base:main` is a moving tag. Not used here, since the plan builds on ubuntu. Note the base's contents are `UNVERIFIED`.
- Convos is an IRC web client: outbound access to IRC networks must be allowed (draft, inferred).
- The first user is registered in the web UI after start (draft, inferred).
- v9.0-rc1 exists. Not used. Renovate should be set to stable tags only (`UNVERIFIED: whether renovate filters rc tags`).
- arm64: install from source. Perl XS modules may need arm64 build deps (`UNVERIFIED`).
- Blockers: none confirmed. Blocking if a CPAN module needs a package unavailable on ubuntu 26.04.

## 11. Build and test steps

```sh
cd apps/convos
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name convos-probe --read-only --tmpfs /tmp \
  -v convos-probe-config:/config ghcr.io/trueforge-org/convos:8.07
docker logs -f convos-probe
forgetool containers test --image convos:8.07 --config ./apps/convos/container-test.yaml
docker rm -f convos-probe; docker volume rm convos-probe-config
```

Fresh named volume for the empty-`/config` run. Expected readiness signal: `UNVERIFIED` (Mojolicious prints a "Web server available" or similar line on start, to be confirmed from a real run). Build needs internet access for cpanm.

## 12. PR checklist

- Branch: `feat/add-convos`. Commit: `feat(convos): add new container`.
- PR title matches the commit. Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (`license/cla` shows status). Only the user can sign it.
- Say what was not tested: every `UNVERIFIED` item above, plus arm64 if not built. Do not check "Built container locally" unless the build and run were done.
