# nitter — implementation plan
> Source: ./draft.md · Target: apps/nitter/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream has no tags and no GitHub releases (`repos/zedeus/nitter/releases` returns 0). Pin a commit SHA. Draft pins `145ca9eb68d195a74598ae39a4d6da002b252c38`; that commit was not re-fetched, so its Dockerfile is UNVERIFIED. Default-branch Dockerfile was reviewed instead. |
| Docker Hub | `zedeus/nitter:latest` (last_updated 2026-08-24), amd64 and arm64 listed. Chart: `docker.io/zedeus/nitter:latest@sha256:8ca440fa...`. |
| Renovate | UNVERIFIED in repo config. Recommended: `datasource=git-refs depName=https://github.com/zedeus/nitter currentValue=master` (precedent: `apps/tvheadend`, same as the fenrus plan). |
| License | AGPL-3.0 (GitHub API SPDX). |
| Source URL | https://github.com/zedeus/nitter |
| Download | No binary assets. Source archive `https://github.com/zedeus/nitter/archive/${VERSION}.tar.gz`, compiled in a build stage. |
| Checksum source | None (no releases). The archive is content-addressed by the pinned commit SHA. |
| Upstream Dockerfile reviewed | https://github.com/zedeus/nitter/blob/main/Dockerfile (default branch, not the pinned commit). Build stage `nimlang/nim:2.2.6-alpine-regular`: `nimble install -y --depsOnly`, `nimble build -d:danger -d:lto -d:strip --mm:refc`, `nimble scss`, `nimble md`; build deps libsass-dev, pcre. Final stage `alpine:latest` (musl): pcre, ca-certificates, openssl; copies `nitter`, `nitter.example.conf` (as `nitter.conf`), `public/` to `/src/`; `adduser nitter`, `USER nitter`, `EXPOSE 8080`, `CMD ./nitter`, no VOLUME, no ENTRYPOINT. |
| Port | 8080 (Dockerfile EXPOSE). Chart service port 10606 is chart-side only. |
| Env vars | No env vars are set in the upstream Dockerfile. `NITTER_SESSIONS_FILE=/src/sessions.jsonl` appears only in the TrueCharts values; the source-side read is UNVERIFIED, so it is not listed in settings.yaml. |
| Config path | Upstream copies the example to `nitter.conf` in the working directory (`/src`). How the binary locates its config (cwd or a flag) is UNVERIFIED. |
| Data paths | None written by upstream besides config and sessions (both mounted read-only by the chart). |
| Dependencies | Valkey/Redis as external state store (draft, from the chart). Not verified in upstream files. ✅ `apps/valkey` exists. |
| Chart | TrueCharts `charts/stable/nitter` 16.0.0, appVersion `latest`, common library 32.8.5. |

## 2. Target layout

- `apps/nitter/Dockerfile`
- `apps/nitter/docker-bake.hcl`
- `apps/nitter/settings.yaml`
- `apps/nitter/container-test.yaml`
- `apps/nitter/start.sh`

No `defaults/`: the example config is copied from the build stage, so nothing extra is needed in the app folder. No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both the build stage and the final stage.

Why: the final image must be glibc (the draft's `copy-from: no` is correct, because the upstream image is musl/alpine). Nim is compiled in a build stage, then only the native binary and `public/` are copied into ubuntu. Closest sibling for the build-then-copy pattern: `apps/pwndrop`. Closest sibling for a source build of a non-Go app: `apps/fenrus` plan (same pattern).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `USER root`.
2. Install the Nim toolchain 2.2.6. Method is UNVERIFIED: the upstream `nimlang/nim` image is alpine-only, so it cannot be copied into ubuntu. Options to check at build time: a Nim 2.2.6 tarball from nim-lang.org (checksum UNVERIFIED), or a Debian/Ubuntu `nimlang/nim` tag (existence UNVERIFIED). Do not use the alpine image.
3. `apt-get install -y --no-install-recommends libsass-dev libpcre3-dev` (build deps from upstream; package names on 26.04 UNVERIFIED, check `apt-cache`).
4. `curl -fL https://github.com/zedeus/nitter/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
5. `cd /tmp/src && nimble install -y --depsOnly && nimble build -d:danger -d:lto -d:strip --mm:refc && nimble scss && nimble md`.
6. Final stage `FROM <ubuntu>`, `USER root`, `apt-get install -y --no-install-recommends libpcre3` (runtime name UNVERIFIED for 26.04: `libpcre3` or `libpcre2-8-0`), then `apt-get clean && rm -rf /var/lib/apt/lists/*`. `libssl3` and `ca-certificates` are already in the base (`apps/ubuntu/Dockerfile`).
7. `mkdir -p /app/nitter` then:

```dockerfile
COPY --from=build /tmp/src/nitter /app/nitter/nitter
COPY --from=build /tmp/src/public /app/nitter/public
COPY --from=build /tmp/src/nitter.example.conf /defaults/nitter.conf
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/nitter/LICENSE
RUN chmod -R 755 /app/nitter /defaults
```

   `LICENSE` file name in the repo root is UNVERIFIED; check it before the build.
8. `ENV HOME=/config TMPDIR=/tmp`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

   The base image entrypoint runs `/start.sh` (same as `apps/adguardhome-sync`, which has no CMD).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "nitter"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/zedeus/nitter currentValue=master
  default = "145ca9eb68d195a74598ae39a4d6da002b252c38"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/zedeus/nitter"
}
```

Then the default group and the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/adguardhome-sync/docker-bake.hcl`. `ARG VERSION` in the Dockerfile must equal this value. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/zedeus/nitter"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: valkey
```

No upstream env var is listed because none is verified. Add `NITTER_SESSIONS_FILE` only after the source confirms it is read. Valkey is a hard dependency per the draft, so the dependency is declared. ✅ `apps/valkey` exists.

## 7. start.sh

```bash
#!/usr/bin/env bash

cp -n /defaults/nitter.conf /config/nitter.conf

# Nitter reads nitter.conf and public/ from its working directory, which is
# read-only under /app. Build a scratch run directory in /tmp that links to them.
run_dir=/tmp/nitter-run
rm -rf "${run_dir}" && mkdir -p "${run_dir}"
ln -s /app/nitter/nitter "${run_dir}/nitter"
ln -s /app/nitter/public "${run_dir}/public"
ln -s /config/nitter.conf "${run_dir}/nitter.conf"

cd "${run_dir}" || exit 1
exec ./nitter
```

- Idempotent: `cp -n` seeds `/config/nitter.conf` only when missing; user edits are kept.
- Config lookup from the working directory is UNVERIFIED. If the binary needs a flag, use that instead of the symlink.
- The session file (`sessions.jsonl`) is user-supplied and is not seeded.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/nitter/nitter
- /app/nitter/public
- /defaults/nitter.conf
- /usr/share/licenses/nitter/LICENSE
```

- Every settings port has a probe (8080 tcp; http added).
- The http probe status on `/` is UNVERIFIED. Nitter may return a non-200 without a Valkey backend. Check the real status while testing and use the path that the app serves with 200.
- Test runs without env vars and without Valkey. If the process exits without Valkey, use the database-dependent exception from the protocol only if all three of its criteria hold (valkey is a hard dependency, the app will not start without it, and a sidecar cannot be wired in `container-test.yaml`). Otherwise write a real test. Add the required narrowing comment in that case.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `nitter.conf` (copied into `/src`) | `/config/nitter.conf` (seeded from `/defaults`), linked into `/tmp/nitter-run` |
| `sessions.jsonl` (chart mount `/src/sessions.jsonl`) | User-supplied file in `/config`. Path and env read are UNVERIFIED. |
| Nitter runtime scratch (caches, logs, if any) | `/tmp` (`TMPDIR=/tmp`). Actual write paths are UNVERIFIED, so check with `--read-only` in step 11. |
| Upstream user `nitter` (root-owned `/src`) | `apps` (568). The chart's common default is 568 too. |

Draft expectations reconciled: non-root yes (`USER apps`), read-only rootfs compatible with `--read-only --tmpfs /tmp` (to be proven), privileged no. The chart's `readOnlyRootFilesystem` default is true, which matches.

## 10. Risks, caveats and open questions

- Nim 2.2.6 toolchain on ubuntu: install method and checksum UNVERIFIED. The upstream build image is alpine only.
- Pinned commit `145ca9eb...`: the Dockerfile at that commit was not fetched. Re-read it before writing the Dockerfile, and update the plan if it differs from the default branch.
- No upstream tags: Renovate bumps on every master push (noisy). Option: pin the commit and limit the schedule.
- Runtime lib name for pcre on 26.04 UNVERIFIED (`libpcre3` vs `libpcre2-8-0`).
- Config lookup and Valkey key names in `nitter.conf` UNVERIFIED.
- Nitter depends on X guest sessions; upstream X changes often break it (inferred). Expect manual session setup.
- Build is slow (Nim + libsass). Expect long buildx time on arm64.
- Draft caveat "Valkey as hard dependency" is taken from the draft, not from upstream code.
- No blockers beyond the Nim toolchain question: not musl-only in the final image, no GPU, not privileged.

## 11. Build and test steps

```sh
cd apps/nitter
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nitter-probe --read-only --tmpfs /tmp \
  -v nitter-probe-config:/config nitter:145ca9eb68d195a74598ae39a4d6da002b252c38
docker logs -f nitter-probe
forgetool containers test \
  --image nitter:145ca9eb68d195a74598ae39a4d6da002b252c38 \
  --config ./apps/nitter/container-test.yaml
docker rm -f nitter-probe; docker volume rm nitter-probe-config
```

Expected readiness signal: the exact Nitter startup line is UNVERIFIED; take it from the pinned source. Also confirm `/config/nitter.conf` exists after start and that restarting keeps it. Test from outside the container (`-p 8080:8080`) to prove the server does not bind only to localhost.

## 12. PR checklist

- Branch `feat/add-nitter`, commit and PR title `feat(nitter): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say honestly what is untested: the Nim build on both architectures, the runtime under `--read-only`, the config lookup, the Valkey-backed behaviour, and the http probe status.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
