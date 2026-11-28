# endlessh — implementation plan
> Source: ./draft.md · Target: apps/endlessh/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.1` (latest tag, commit `8daa5992f1874ab73c6addfe1f0907c1b12edd2a`, 2020-01-31). The GitHub "latest release" is `1.0` (2019-04-29), but tag `1.1` is newer. Source: https://api.github.com/repos/skeeto/endlessh/tags (read with `gh api`). |
| Draft version | Draft pins the linuxserver image `2021.11.21`, which is a wrapper tag, not upstream. Not used. |
| Renovate | `datasource=github-tags depName=skeeto/endlessh versioning=loose` (tags are `1.1`, not three-part semver). |
| License | Unlicense (GitHub SPDX `Unlicense`): https://github.com/skeeto/endlessh/blob/master/UNLICENSE |
| Source URL | https://github.com/skeeto/endlessh |
| Binary source | No prebuilt binary upstream (only `endlessh-1.0.tar.xz` on the 1.0 release). Use Ubuntu's apt package `endlessh` `1.1-5.1build1` (universe), listed for amd64 and arm64: https://packages.ubuntu.com/resolute/endlessh |
| Checksum source | apt verifies packages against the Ubuntu archive signatures. No separate upstream checksum for the tarball is used. |
| Upstream runtime | `endlessh [-vhs] [-d MS] [-f CONFIG] [-l LEN] [-m LIMIT] [-p PORT]`; defaults `-p 2222`, `-d 10000`. README: https://raw.githubusercontent.com/skeeto/endlessh/master/README.md (fetched via `gh api`). |
| Env vars read by the program | None. Config is by flags or `-f` file. |
| Ports | 2222/tcp (default). |
| Write paths | None required. Logs go to stdout/stderr with `-v`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-endlessh/master/Dockerfile: `baseimage-alpine:3.18`, `make` from source, `COPY /root /`, `EXPOSE 2222`, no `VOLUME`. Alpine/musl build, so not reused (`copy-from amd64/arm64: no`). |
| Upstream ships | `make install` target and man page only; no release binary. |

Facts that were not confirmed: exact startup log line of the apt build (UNVERIFIED: not fetched, check during the build); whether Ubuntu 1.1 accepts `-f` (UNVERIFIED: README is from master). This plan avoids `-f`.

## 2. Target layout

Files to create in `apps/endlessh/`:

- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required, to `exec` endlessh with the right flags.
- `defaults/`, `etc/`, `scripts/`, `health/`: not needed. Nothing is seeded and no s6 service is used.
- `root/`: never use.
- `DOWNSTREAM_CHANGES.md`: not needed. No ContainerForge app uses endlessh as a `FROM` base.

Note: `include/.dockerignore` is an allow-list. `start.sh` is allowed, so `COPY --chmod=0755 . /` puts it in the image.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (copied from the current base table).
- Why: the program is a single C binary from apt. No language runtime is needed, so ubuntu alone is enough, as the draft says.
- Closest sibling: `apps/adguardhome-sync` (ubuntu base, `USER root` for a fetch, `USER apps`, `COPY --chmod=0755 . /`, `tcp` probe). Apt-install pattern: `apps/valkey` (pinned apt version).

## 4. Dockerfile

Steps:

1. `ARG VERSION` and `ARG TARGETARCH`, `USER root`.
2. Install the pinned apt package and check it:
   ```dockerfile
   RUN set -eux; \
       apt-get update; \
       apt-get install -y --no-install-recommends endlessh=1.1-5.1build1; \
       test "$(dpkg-query -W -f='${Version}' endlessh)" = "1.1-5.1build1"; \
       rm -rf /var/lib/apt/lists/*
   ```
   The apt pin is the upstream `1.1` tag plus the Ubuntu packaging revision. Bump `VERSION` and this pin together by hand. Renovate does not update apt pins.
3. Ship the license: `mkdir -p /usr/share/licenses/endlessh && cp /usr/share/doc/endlessh/copyright /usr/share/licenses/endlessh/` (check the path with `dpkg -L endlessh` during the build).
4. `USER apps`, then `COPY --chmod=0755 . /`.
5. `EXPOSE 2222`. No `VOLUME`, because the app persists nothing (see section 9).

The image must not write under `/app`. The binary is at `/usr/bin/endlessh`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "endlessh"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=skeeto/endlessh versioning=loose
  default = "1.1"
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/skeeto/endlessh"
}
```

Then the standard `group "default"` and the `image`, `image-local` and `image-all` targets, copied from `apps/luanti/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/endlessh`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/skeeto/endlessh"
ports:
  - port: 2222
    protocol: tcp
    required: true
env:
  - name: CLI_ARGS
    default: ""
    required: false
```

- `ports`: 2222/tcp. This is the only port.
- `env`: `CLI_ARGS` is a wrapper convention copied from `apps/luanti`. The program does not read it, so the start script must pass it through. If you prefer strictly app-read env vars, use `env: []` instead.
- `volumes`: omitted. Nothing persists, so `/config` is not required. A reason for this choice is in section 9.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

read -r -a cli_args <<< "${CLI_ARGS:-}"
exec endlessh -v -p 2222 "${cli_args[@]}"
```

- `exec` so signals reach the process.
- `-v` gives basic log lines, which the readiness check needs. Without it the program is silent.
- No seeding and no writes, so an empty `/config` needs no handling.
- Port 2222 is listened on for all interfaces by default (`bind` not set). UNVERIFIED that the default is `0.0.0.0` for the apt build; check with `ss -ltn` in the build step.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '2222'
filePaths:
  - /usr/bin/endlessh
```

- A `tcp` probe on 2222 covers the only port in `settings.yaml`.
- `filePaths` checks the binary exists.
- The test runs without env vars, and `CLI_ARGS` is empty, so the normal code path is what is tested.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (`USER apps`). The draft's chart expectation `runAsUser 0` comes from the linuxserver s6 image and does not apply here.
- Port 2222 is above 1024, so no root capability is needed.
- Read-only rootfs: endlessh writes nothing, so `--read-only --tmpfs /tmp` is enough.
- No `VOLUME /config`: the app persists nothing. If a future change adds state, add `VOLUME /config` and a `volumes` entry together.
- Not privileged. No extra persistence.
- Chart mapping (service-level, not in the image): SSH port 22 must be forwarded to 2222 at the service level. The image does not bind 22.

## 10. Risks, caveats and open questions

- Caveat (from draft): the tarpit listens on 2222. Forwarding SSH port 22 to 2222 happens outside the container.
- Risk: the apt package name and version can change on a future Ubuntu release. The pin `endlessh=1.1-5.1build1` is for resolute (26.04) and must be checked on build.
- Risk: arm64 is listed for the apt package, but the package was not installed on arm64 here. Only the amd64 build is confirmed.
- Open: exact `-v` startup line and whether `bind` is `0.0.0.0` (UNVERIFIED, see section 1).
- Blockers: none. No musl-only, GPU, privileged or missing-arm64 issue.

## 11. Build and test steps

From `apps/endlessh`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Check the apt install and license path inside the image: `docker run --rm --entrypoint sh endlessh:1.1 -c 'dpkg -L endlessh | head; ls /usr/share/licenses/endlessh'`.
4. Readiness probe:
   ```sh
   docker run --rm -d --name endlessh-probe --read-only --tmpfs /tmp \
     -v endlessh-probe-config:/config endlessh:1.1
   docker logs -f endlessh-probe   # expect a verbose log line; exact text UNVERIFIED
   docker exec endlessh-probe sh -c 'ss -ltn | grep 2222'
   docker rm -f endlessh-probe; docker volume rm endlessh-probe-config
   ```
   Pass: the container stays up, port 2222 is listening, no fatal lines. The readiness signal is the port being open, since the exact log line is unverified.
5. `forgetool containers test --image endlessh:1.1 --config ./container-test.yaml`.
6. Also test `CLI_ARGS` by running once with `-e CLI_ARGS="-m 10"` (must start).

## 12. PR checklist

- Branch: `feat/add-endlessh`.
- Commit: `feat(endlessh): add new container`. PR title is the same.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and only check what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows status.
- Say what was not tested: arm64 build and the exact startup log line, unless they are run.
- Do not check "Built container locally" unless the image was built.
