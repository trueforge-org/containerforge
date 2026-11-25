# cloud9 — implementation plan
> Source: ./draft.md · Target: apps/cloud9/ · Difficulty: hard · Role: main · Verified on 2026-11-25

Status: BLOCKED pending a licence check and a decision on the docker tooling. The upstream project is archived, has no release tags, and GitHub reports its licence as NOASSERTION. The linuxserver wrapper adds amd64-only docker-ce and compose tooling that needs privileges. Do not start `apps/cloud9/` until section 10's decisions are made.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No release or tag. `GET /repos/c9/core/releases/latest` returns 404 and `/tags` is empty (`gh api`, public repo). Package version in `package.json` is `3.1.5000` (https://api.github.com/repos/c9/core/contents/package.json). |
| Upstream image tag (chart) | `ghcr.io/linuxserver/cloud9:version-1.29.2` (from draft.md). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-cloud9/e8b635534987561f47ab7cc1c48e57c74f1c6d8a/Dockerfile |
| Upstream FROM | `ghcr.io/linuxserver/docker-compose:amd64-version-${COMPOSE_VERSION}` (ARG `COMPOSE_VERSION=1.29.2`) as `compose`, and `ghcr.io/linuxserver/baseimage-cloud9:latest`. |
| Upstream install | `COPY --from=compose /usr/local/bin/docker-compose`. Docker GPG key fetched from download.docker.com, apt source `deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable`, then `docker-ce` installed. amd64 only. |
| Upstream ENV / EXPOSE / VOLUME / ENTRYPOINT / USER | Not in the fetched Dockerfile. They come from `baseimage-cloud9`, which was not fetched: UNVERIFIED. |
| Node / npm version and c9/core clone ref | Not in the fetched Dockerfile. UNVERIFIED (base image). |
| Renovate | UNVERIFIED. No release tags to track. Suggested `datasource=git-refs depName=https://github.com/c9/core currentValue=master`, as with `apps/fenrus`, if a commit is pinned. |
| License | GitHub reports `NOASSERTION` for c9/core (https://api.github.com/repos/c9/core). Declared licence in `package.json`: UNVERIFIED (not present in the fetched excerpt). The repo LICENSE file: UNVERIFIED. Linuxserver wrapper: GPL-3.0. |
| Repo status | `archived: true`, last push 2021-01-15 (https://api.github.com/repos/c9/core). |
| Source URL | https://github.com/c9/core |
| Website | https://c9.github.io/core/ |
| Per-arch download | None. There is no prebuilt executable. Source build only. |
| Checksum source | None. Source is pinned by commit SHA only (must be chosen, UNVERIFIED). |
| Ports | `8000` (draft, inferred). Not confirmed on any fetched page. UNVERIFIED. |
| Data / config paths | `/code` (chart pvc, draft). Upstream write paths: UNVERIFIED (base image not fetched). |
| arm64 | UNVERIFIED. Upstream docker-ce and compose are hardcoded to amd64. The c9/core native `node-pty` build is UNVERIFIED on arm64. |

## 2. Target layout

- `apps/cloud9/Dockerfile`
- `apps/cloud9/docker-bake.hcl`
- `apps/cloud9/settings.yaml`
- `apps/cloud9/container-test.yaml`
- `apps/cloud9/start.sh`

`defaults/`, `etc/` only if a seeded workspace or settings file is needed (reason: none identified). Never use `root/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the build and final stage, as the draft proposes. Reason: the draft's Node IDE with a native `node-pty` build needs node and build tools. Node version inside `python-node` is UNVERIFIED; check the `apps/python-node` Dockerfile or its settings before pinning a c9/core node requirement.

Closest sibling: `apps/changedetection` and `apps/budge` (python-node). Confirmed to exist in `apps/` (listed in the batch). `apps/python-node` does not exist as its own folder (the base lives in `apps/python`'s sibling layout, UNVERIFIED).

## 4. Dockerfile

Only after section 10's decisions. Steps:

1. Build stage `FROM <python-node> AS build`, `ARG VERSION` (a pinned c9/core commit SHA), `USER root`.
2. `curl -fL https://github.com/c9/core/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
3. Install node dependencies with `npm ci` (or `npm install` if no lockfile; UNVERIFIED that a lockfile exists). Set `npm_config_cache=/tmp/npm`. The native `node-pty` build uses the base's build tools (draft; confirm).
4. Copy the built tree into `/app/cloud9` in the final stage. Keep `/app` read-only at runtime.
5. Final stage `FROM <python-node>`, `USER root` only for any apt step (none expected), then `COPY --chmod=0755 . /`, `EXPOSE 8000`, `VOLUME /config` (or the path the chart uses for `/code`, decided in section 9), final `USER apps`.
6. Docker tooling (docker-ce, docker-compose): omit by default. Including it needs the amd64-only repo and privileges, both blockers (section 10).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "cloud9" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/c9/core currentValue=master
  default = "<pin a verified c9/core commit SHA>"
}
variable "LICENSE" { default = "<UNVERIFIED: NOASSERTION on GitHub, confirm before shipping>" }
variable "SOURCE" { default = "https://github.com/c9/core" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

Schema header per the settings rules, `schema_version: 1`, `upstream_env_url: "https://github.com/c9/core"`.

- `ports`: `8000/tcp`, `required: false` (UNVERIFIED, draft inferred).
- `env`: none confirmed. Do not invent variables.
- `volumes`: `/config` (or the decided data path), `required: true` when the app persists workspaces.
- `dependencies`: none (draft says none).

## 7. start.sh

Idempotent. Seed the workspace dir in `/config` only when missing. No writes to `/app`. Caches in `/tmp`. Bind `0.0.0.0` (c9/core default bind address UNVERIFIED). Finish with `exec node <server entry>` (the entry file is UNVERIFIED; take it from the c9/core `server.js` or the start script it ships).

## 8. container-test.yaml

Schema header per forgetool. `timeoutSeconds` from a Node sibling (UNVERIFIED which). `tcp` and `http` probes on `8000`. `filePaths`: the server entry file and `/usr/share/licenses/cloud9/` if a licence file is shipped. Test runs with no env vars, so no env-required code path is needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/code` (chart pvc, workspace) | `/config/code` (workspace), seeded empty. |
| npm / node-gyp caches | `/tmp` (`npm_config_cache`, `HOME=/tmp` for the build). |
| c9/core runtime state | UNVERIFIED. Find the real write paths in the source before wiring read-only. |

Draft security expectations reconciled: chart runs as UID 0 and `readOnlyRootFilesystem: false`. This image must run as `apps` and work with `--read-only --tmpfs /tmp`. `privileged: unknown` in the draft is resolved by omitting docker-ce (section 4).

## 10. Risks, caveats and open questions

- Blocker 1: licence. GitHub reports NOASSERTION. The LICENSE file and `package.json` licence must be read from a pinned commit before `docker-bake.hcl` can state `LICENSE`.
- Blocker 2: no release tags. A commit must be chosen. Archived since 2021; no security maintenance.
- Blocker 3: docker-ce and compose are amd64-only and need privileges. Decision: drop them (recommended) or keep them and accept a privileged, amd64-only image.
- Caveat: the native `node-pty` build makes the build slow and depends on the build toolchain.
- Caveat: Node toolchain breakage likely on a current base (archived project).
- Caveat: `ports` and `/code` are from the draft and the chart, not the source. Verify from c9/core's server config.

## 11. Build and test steps

```sh
cd apps/cloud9
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name cloud9-probe --read-only --tmpfs /tmp \
  -v cloud9-probe-config:/config cloud9:<VERSION>
docker logs -f cloud9-probe
forgetool containers test --image cloud9:<VERSION> --config ./apps/cloud9/container-test.yaml
docker rm -f cloud9-probe; docker volume rm cloud9-probe-config
```

Readiness signal: UNVERIFIED (server startup line from c9/core).

## 12. PR checklist

- Branch `feat/add-cloud9`, commit and PR title `feat(cloud9): add new container`, target `main`.
- Notes section includes `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say that this plan has not been built or run, and state the licence, port, node version and arm64 status as unverified.
