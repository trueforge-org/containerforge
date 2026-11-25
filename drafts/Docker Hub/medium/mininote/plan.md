# mininote — implementation plan
> Source: ./draft.md · Target: apps/mininote/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases and no tags. Pin the master commit `e9d24b5` (committed 2025-05-26T06:26:22Z, HEAD of master when checked). The full 40-character SHA is UNVERIFIED: resolve it with `git ls-remote` before writing `VERSION`. |
| Difference from draft | The draft says the base is `python-node` because the app is Node. Upstream Dockerfile is `FROM node:22-alpine`, so the ContainerForge base is a replacement, not a copy of upstream. The draft's `8080` port is inferred; the README Docker example maps `3000:3000`. |
| Docker Hub | `n1try/mininote` has only the `latest` tag (last updated 2021-08-08, amd64 only), so it is stale. The upstream README points to `ghcr.io/muety/mininote:latest`, which was NOT verified (GHCR not fetched). |
| Renovate | `datasource=git-refs depName=https://github.com/muety/mininote currentValue=master` (same pattern as `apps/fenrus`). The draft's `docker` datasource on `n1try/mininote` would track only `latest`, so it is not used. |
| License | MIT (GitHub repo license). |
| Source URL | https://github.com/muety/mininote |
| Download (amd64 and arm64) | Source tarball `https://github.com/muety/mininote/archive/${VERSION}.tar.gz`. Built with Node and yarn at image build time. No prebuilt binary. The same tarball serves both arches. |
| Checksum source | None published. The tarball is pinned by commit SHA, which is content-addressed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/muety/mininote/master/Dockerfile. `FROM node:22-alpine`, `WORKDIR /app`, `COPY . /app/`. `ARG base_url=/`, `ENV BASE_URL $base_url`. `VOLUME ["/app/data"]`. RUN steps: corepack enable, `yarn set version stable`, `yarn` in `/app`; then in `/app/webapp`: corepack enable, yarn set version stable, `yarn`, `yarn build:base`. `ENTRYPOINT yarn start` (shell form). No CMD, no USER, no EXPOSE. No arch-specific logic. |
| Upstream README reviewed | https://raw.githubusercontent.com/muety/mininote/master/README.md. Requires Node.js >= 22.12.0 LTS. Build: `yarn`, `cd webapp && yarn && yarn build`, `yarn start`. Env: `HTTPS_CERT`, `HTTPS_KEY` (TLS is mandatory for hosts other than localhost; skip with a reverse proxy). Docker example maps `3000:3000`. Data is a Docker named volume at `/app/data`. |
| Port | 3000 (README Docker example). UNVERIFIED in source: the port is not stated in the README text or Dockerfile. |
| Env vars (real) | `HTTPS_CERT`, `HTTPS_KEY` (README). `base_url` is a build ARG (Dockerfile) that sets `BASE_URL` at build time; whether the server reads `BASE_URL` at run time is UNVERIFIED. |
| Data path | Upstream volume `/app/data` (Dockerfile and README). The native data location and the database type are NOT stated (UNVERIFIED). The draft's "database" assumption is not confirmed. |
| Dependency | None. |

## 2. Target layout

- `apps/mininote/Dockerfile`
- `apps/mininote/docker-bake.hcl`
- `apps/mininote/settings.yaml`
- `apps/mininote/container-test.yaml`
- `apps/mininote/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/` (never used). No `DOWNSTREAM_CHANGES.md`, because this image is not a `FROM` base for other apps (no `apps/*/Dockerfile` uses `mininote`).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

The porter table maps Node to the ubuntu base. This plan uses `python-node` anyway, because it is the base the exemplars use for Node-in-container (`apps/changedetection` and `apps/budge`, which run Node through python-node). Reason to pick it: the Node runtime is present, and it avoids a second Node install. Node version: the README needs >= 22.12.0 LTS. The `budge` comment says python-node ships Node 24, which satisfies that. UNVERIFIED for the exact Node version in this image: check with `node --version` in the build.

Closest sibling: `apps/budge` (python-node, Node app built from a tarball, `/config` state, `start.sh` that `exec`s the Node process).

## 4. Dockerfile

1. `FROM` the python-node base above.
2. `ARG VERSION`, `ARG base_url=/` (kept from upstream, build-time only).
3. `USER root` for the install steps only.
4. apt packages: none expected (upstream needs none on Alpine; pure JS). Do not add packages without a failure to justify them.
5. Download and extract the source to `/app/mininote` (not directly to `/config`):

```dockerfile
RUN echo "*** Installing mininote ***" && \
  mkdir -p /app/mininote && \
  curl -fL -o /tmp/mininote.tar.gz \
    "https://github.com/muety/mininote/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/mininote.tar.gz -C /app/mininote --strip-components=1 && \
  rm /tmp/mininote.tar.gz
```

6. Build the backend and the webapp, following upstream's steps. Keep Yarn caches and Corepack home in `/tmp`, so no cache is written to `/config`:

```dockerfile
ENV COREPACK_HOME=/tmp/corepack \
    YARN_CACHE_FOLDER=/tmp/yarn \
    HOME=/config
RUN cd /app/mininote && corepack enable && yarn set version stable && yarn && \
  cd webapp && corepack enable && yarn set version stable && yarn && yarn build:base && \
  rm -rf /tmp/yarn /tmp/corepack
```

   `yarn build:base` and the `base_url` ARG follow upstream. The webpack build is slow and memory-heavy (draft, inferred). Check the build with the default `image-local` target. Corepack needs network at build time (UNVERIFIED that it works in the build sandbox).
7. Data redirect: the upstream data path is `/app/data`, which is read-only at runtime. Create `/config/data` and a build-time symlink `ln -s /config/data /app/mininote/data` (same pattern as `apps/fenrus`). The native location is UNVERIFIED (section 1): if the app writes a different path, grep the pinned source for the data directory before choosing the symlink target.
8. License: `/usr/share/licenses/mininote/LICENSE` from `/app/mininote/LICENSE` (MIT; file name UNVERIFIED beyond the GitHub license detection).
9. Ownership: `chown -R apps:apps /app/mininote && chmod -R 755 /app/mininote`.
10. Environment:

```dockerfile
ENV PORT=3000 \
    HOME=/config
```

   `PORT` is only set if the source reads it (UNVERIFIED); otherwise remove it and let the default stand.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/mininote
```

   The upstream `VOLUME /app/data` is replaced by `VOLUME /config` (ContainerForge rule: state goes to `/config`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mininote"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/muety/mininote currentValue=master
  default = "e9d24b5"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/muety/mininote"
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

- `VERSION` is the full commit SHA once resolved (`e9d24b5` is short and UNVERIFIED as the full value). Use the same full SHA in the `ARG VERSION` default.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/muety/mininote"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: HTTPS_CERT
    default: ""
    required: false
  - name: HTTPS_KEY
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `HTTPS_CERT` and `HTTPS_KEY` are from the README. The README says TLS is mandatory for non-localhost hosts unless a reverse proxy is used, so the defaults are empty and the app serves HTTP in that case (UNVERIFIED behaviour: check in the source).
- If the cert and key are used, they must be read from `/config` (not `/app`). Do not seed certs. Document the path in the PR.
- `TZ` is a sibling convention. Keep it only if `start.sh` or the app reads it; otherwise remove it.
- `BASE_URL` is not listed, because the run-time read is UNVERIFIED. Add it only after the source confirms it.
- No dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

cd /app/mininote
exec yarn start
```

- Idempotent: `mkdir -p` only. No seeding unless the source needs a first-run file (UNVERIFIED; the README has no setup step).
- Writes only under `/config` and `/tmp`. Nothing is written to `/app`.
- Upstream uses `ENTRYPOINT yarn start` (shell form). Here `exec yarn start` gives PID 1 signal handling. If `yarn` does not forward the signal to node, use `exec node <entry>` with the entry file from `package.json` (UNVERIFIED which file).
- Bind address: check the server's listen host in the source. Must be `0.0.0.0` (or all interfaces) for other containers to connect (ContainerForge rule). Verify from outside the container.
- `HTTPS_CERT`/`HTTPS_KEY` are read by the app, not by this script. Do not reimplement them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/mininote/package.json
- /app/mininote/webapp/build
- /usr/share/licenses/mininote/LICENSE
```

- `tcp` and `http` probes on port 3000 (the only port in `settings.yaml`). The port itself is UNVERIFIED (section 1): if the source uses a different port, change `settings.yaml` and the probes together.
- `filePaths` checks the built webapp output (`webapp/build` is UNVERIFIED as the exact output path: confirm from `webapp/package.json`).
- `timeoutSeconds: 180`: sibling value for Node apps (`apps/budge`, `apps/changedetection`).
- The test runs with no env vars. The HTTPS path is not covered; run it manually if it matters (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (upstream `VOLUME`, the notes store) | Build-time symlink `/app/mininote/data` -> `/config/data`. The real data path is UNVERIFIED: confirm in the source before finishing the symlink. |
| Yarn and Corepack caches | `/tmp/yarn`, `/tmp/corepack` (ENV), removed after the build. |
| `HOME` | `/config`. |
| Node and webpack temp files | `/tmp` (`TMPDIR` if the app needs it, UNVERIFIED). |

Draft expectations, reconciled:
- Non-root: the draft says the chart forces UID 0. The image runs as `apps` (UID 568), so the chart value must change when the image is used (chart change, not this PR).
- Read-only rootfs: draft says the chart sets `readOnlyRootFilesystem: false`. The image is designed for `--read-only --tmpfs /tmp`, verified by the test in section 11.
- Privileged: no.
- Extra persistence: draft says `/app/data` (pvc). In ContainerForge the state is `/config` (with `data/` inside). Existing chart users must move their data to `/config/data`.

## 10. Risks, caveats and open questions

- No version tags: the version is a commit SHA, so Renovate bumps on every master push (noisy). Upstream activity is low (last push 2025-05-26), so bumps should be rare. Consider a Renovate limit (repo config, not this app).
- Data store: the native location and database type are not stated in the README or Dockerfile (UNVERIFIED). The draft's assumption of a database is not confirmed. Without that, the `/config/data` symlink target may be wrong.
- Port: 3000 is from the README Docker example only (UNVERIFIED in source).
- Build: webpack on Node 22 is slow and memory-heavy (draft, inferred). The build may need more RAM than the default runner.
- Node version: >= 22.12.0 required by the README. python-node's Node version is UNVERIFIED for this tag.
- Corepack and `yarn set version stable` need network during the build.
- Upstream image: `ghcr.io/muety/mininote:latest` is referenced by the README but was NOT verified, and the Docker Hub image is stale (2021, amd64 only).
- Blockers: no release tags; the draft's python-node choice differs from upstream (node:22-alpine, replaced here); data store unverified; webpack build memory. No musl-only issue once Ubuntu/python-node is used. arm64: no upstream image; pure JS per the draft, so a native build is plausible but UNVERIFIED until built.

## 11. Build and test steps

```sh
cd apps/mininote
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mininote-probe --read-only --tmpfs /tmp \
  -v mininote-probe-config:/config mininote:<full-sha>
docker logs -f mininote-probe
forgetool containers test --image mininote:<full-sha> --config ./apps/mininote/container-test.yaml
docker rm -f mininote-probe; docker volume rm mininote-probe-config
```

- Replace `<full-sha>` with the pinned commit in `VERSION`.
- Readiness signal: the Node/yarn startup line (UNVERIFIED text; take it from the first real log) and a listen on port 3000. The process must stay running.
- Check that a note can be created and the data is written under `/config/data` (persistence check after a restart with the same `/config` volume).
- Check from outside the container (`-p 3000:3000`) that the port is reachable.
- Manual, optional: test the `HTTPS_CERT` and `HTTPS_KEY` paths if they are documented for the chart.
- No DB dependency, so the protocol's DB exception does not apply.

## 12. PR checklist

- Branch `feat/add-mininote`, commit and PR title `feat(mininote): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Tell the user. Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: the full commit SHA resolution, the data store location, the port in source, the webpack build on both arches, the HTTPS env vars, arm64 (unless built), the Node version in python-node, and the `ghcr.io/muety/mininote` image (not used).
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
