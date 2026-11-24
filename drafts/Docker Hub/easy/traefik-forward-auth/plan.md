# traefik-forward-auth — implementation plan
> Source: ./draft.md · Target: apps/traefik-forward-auth/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **2.3.0** (tag `v2.3.0`, marked Latest, commit `26e7995`, released 06 May; UNVERIFIED: the year was not shown, but `go.mod` dates from 2024). The draft's `latest` image tag is not pinned. |
| Renovate | `datasource=github-releases depName=thomseddon/traefik-forward-auth versioning=semver` |
| License | MIT (`LICENSE.md`, copyright 2018 Thom Seddon). SPDX `MIT`. |
| Source URL | https://github.com/thomseddon/traefik-forward-auth |
| Release assets (v2.3.0) | `traefik-forward-auth_amd64` and `traefik-forward-auth_arm` only. The `_arm` file is 32-bit ARM, **not arm64**, so it cannot be used for `linux/arm64`. The draft's "arm64: compile" is right. |
| Source archive | `https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v2.3.0.tar.gz` (HTTP 200). `go.mod` says `go 1.22` / `toolchain go1.22.2`, and the build target is `./cmd`. |
| Checksum source | None published for the assets or the source archive. With a source build the module checksums come from `go.sum` (`go mod download` verifies them). |
| Upstream Dockerfile reviewed | Commit `83f06df`: `golang:1.25-alpine` builder, `CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -installsuffix nocgo -o /traefik-forward-auth .../cmd`, then `FROM scratch` with the CA bundle and the binary, `ENTRYPOINT ["./traefik-forward-auth"]`. |
| Port | 4181/tcp (`--port` / `PORT`). The README does not describe a health endpoint. |
| Configuration | Each flag has an env var of the same name in upper case (the README lists them): `LOG_LEVEL` (warn), `LOG_FORMAT` (text), `AUTH_HOST`, `CONFIG`, `COOKIE_DOMAIN`, `INSECURE_COOKIE`, `COOKIE_NAME` (`_forward_auth`), `CSRF_COOKIE_NAME`, `DEFAULT_ACTION` (auth), `DEFAULT_PROVIDER` (google), `DOMAIN`, `LIFETIME` (43200), `LOGOUT_REDIRECT`, `URL_PATH` (`/_oauth`), `SECRET` (**required**), `WHITELIST`, `PORT` (4181), and the providers `PROVIDERS_GOOGLE_CLIENT_ID/_CLIENT_SECRET/_PROMPT`, `PROVIDERS_OIDC_ISSUER_URL/_CLIENT_ID/_CLIENT_SECRET/_RESOURCE`, `PROVIDERS_GENERIC_OAUTH_AUTH_URL/_TOKEN_URL/_USER_URL/_CLIENT_ID/_CLIENT_SECRET/_SCOPE/_TOKEN_STYLE/_RESOURCE`. Precedence: flags, then env, then config files (INI). |

## 2. Target layout

```
apps/traefik-forward-auth/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

`start.sh` is needed to provide a stable `SECRET`. No `defaults/` or `etc/`. Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both the build stage and the final stage.

The ubuntu base already ships a Go toolchain on `PATH` (`/usr/local/go/bin`, `GO_VERSION` in `apps/ubuntu`), which `apps/hishtory-server` uses for a builder stage on the same base. Closest sibling: `apps/hishtory-server` (a Go source build copied into the final image). The final stage needs only the binary and the CA certificates already in ubuntu, so no extra packages.

## 4. Dockerfile

Multi-stage (go-runtime rules: compile in a dedicated stage, then `COPY --from=`):

1. Builder: `FROM <ubuntu base> AS builder`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV GOCACHE=/tmp/go-build GOPATH=/tmp/go CGO_ENABLED=0`.
   ```sh
   curl -fsSL -o /tmp/tfa.tar.gz "https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v${VERSION}.tar.gz"
   mkdir -p /build && tar xzf /tmp/tfa.tar.gz -C /build --strip-components=1
   cd /build && GOOS=linux GOARCH=${TARGETARCH} go build -trimpath -ldflags="-s -w" -o /out/traefik-forward-auth ./cmd
   ```
   Do not use `-mod=mod`, and do not edit `go.mod` or `go.sum`. The base image pattern in `apps/hishtory-server` does `unset GOPATH; go mod download` first because its base sets `GOPATH`. Check the `GOPATH` handling when implementing. UNVERIFIED: the toolchain in the base is new enough for `go 1.22` (it should be).
2. Final: `FROM <ubuntu base>`, `ARG VERSION`, `USER root`.
   ```sh
   mkdir -p /usr/share/licenses/traefik-forward-auth
   ```
   Fetch the licence in the builder (`cp /build/LICENSE.md /out/`) and use `COPY --from=builder /out/LICENSE.md /usr/share/licenses/traefik-forward-auth/`.
3. `COPY --from=builder --chmod=0755 /out/traefik-forward-auth /app/traefik-forward-auth`
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 4181`, `VOLUME /config`, `WORKDIR /config`.

Using the source build for both architectures avoids a separate amd64 download path (one code path, and `go.sum` verifies the modules). The alternative for amd64 only is the release asset `traefik-forward-auth_amd64`, with no checksum.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "traefik-forward-auth" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=thomseddon/traefik-forward-auth versioning=semver
  default = "2.3.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/thomseddon/traefik-forward-auth" }
```

The standard `group "default"` and the targets `image`, `image-local` and `image-all` (amd64 and arm64) come from `apps/hishtory-server/docker-bake.hcl`. Run `docker buildx bake --print`. As in `apps/adguardhome-sync`, the bake version has no `v` and the URL adds it.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/thomseddon/traefik-forward-auth"
ports:
  - port: 4181
    protocol: tcp
    required: false
env:
  - name: SECRET
    default: ""
    required: true
  - name: DEFAULT_PROVIDER
    default: "google"
    required: false
  - name: AUTH_HOST
    default: ""
    required: false
  - name: COOKIE_DOMAIN
    default: ""
    required: false
  - name: INSECURE_COOKIE
    default: "false"
    required: false
  - name: LIFETIME
    default: "43200"
    required: false
  - name: LOG_LEVEL
    default: "warn"
    required: false
  - name: PORT
    default: "4181"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Add the provider variables (`PROVIDERS_GOOGLE_CLIENT_ID` and `_CLIENT_SECRET`, `PROVIDERS_OIDC_ISSUER_URL`, `_CLIENT_ID` and `_CLIENT_SECRET`, `PROVIDERS_GENERIC_OAUTH_*`) as optional entries with empty defaults. They are real env names from the README. Empty-valued variables must not be passed through to the app (see section 7). `SECRET` is `required: true` with an empty default, which is allowed because `start.sh` generates one. Dependencies: none (the OAuth/OIDC provider is external).

## 7. start.sh

`#!/usr/bin/env bash`:

1. If `SECRET` is unset or empty, read `/config/secret`. If that file does not exist, create it with `umask 077` from `head -c 32 /dev/urandom | base64 | tr -d '\n'` (idempotent: never overwritten), log "generated a cookie secret in /config/secret", then `export SECRET=$(cat /config/secret)`. Without a stable secret every restart would sign out all users. Multiple replicas must be given the same `SECRET` explicitly.
2. Unset any of the optional variables that are set to the empty string, because empty provider settings could be read as configured values (UNVERIFIED how the flag parser treats empty env values). In a loop: `for v in AUTH_HOST COOKIE_DOMAIN LOGOUT_REDIRECT ...; do [ -z "${!v-x}" ] && unset "$v"; done`.
3. Do not put secrets on the command line (visible in the process list): all of them stay in env vars.
4. `exec /app/traefik-forward-auth`. The upstream flags and env names are used as is, and the default port 4181 listens on all interfaces (UNVERIFIED: confirm from a second container).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# Upstream refuses to start without an OAuth provider configured. The test supplies dummy
# Google credentials (same approach as apps/drydock); the image itself ships none.
mainRunner:
  env:
    PROVIDERS_GOOGLE_CLIENT_ID: "test-client-id"
    PROVIDERS_GOOGLE_CLIENT_SECRET: "test-client-secret"

tcp:
- port: '4181'

filePaths:
- /app/traefik-forward-auth
- /usr/share/licenses/traefik-forward-auth/LICENSE.md
```

The TCP probe covers 4181. UNVERIFIED: that the Google provider needs no network access at startup (the OIDC provider contacts the issuer at start, but Google does not). If the process still exits, narrow to the `filePaths` check and write the reason in a comment. The `SECRET` comes from `start.sh`, so the test needs none. Use the default timeout.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| None: the upstream binary is stateless and runs from `scratch` with no filesystem writes | Nothing to remap. |
| Generated cookie secret (new) | `/config/secret` (persistent, mode 0600) |
| Go build caches (build stage only) | `/tmp` (`GOCACHE`, `GOPATH`) |

TrueCharts expectations reconciled: UID 568 and `readOnlyRootFilesystem true` match, with no extra persistence. The chart needs a `/config` volume only if it wants a stable generated secret, and otherwise should set `SECRET` from a Kubernetes secret. Not privileged.

## 10. Risks, caveats and open questions

- Cannot run alone: it needs an OAuth/OIDC provider, client ID and secret, and a cookie secret (draft caveat). With no provider config it may refuse to start (UNVERIFIED, see the test comment in section 8).
- arm64 is a source build. The release asset is 32-bit `arm`, so there is no release-binary route. Build time is longer than a download.
- The project is lightly maintained (v2.3.0 is the latest tag). The upstream Dockerfile hard-codes `GOARCH=amd64`, which is why the `GOARCH=${TARGETARCH}` change is needed.
- The Docker Hub `latest` tag used by TrueCharts is unpinned, so the target moves to the tagged `2.3.0`. Behaviour differences between `latest` and 2.3.0 are UNVERIFIED.
- `SECRET` passed as an env var is visible to anyone who can inspect the container. Prefer a secret reference in the chart.
- No blockers: static Go binary, glibc and musl both fine, no GPU, no privileged mode.

## 11. Build and test steps

```sh
cd apps/traefik-forward-auth
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name traefik-forward-auth-probe --read-only --tmpfs /tmp \
  -e PROVIDERS_GOOGLE_CLIENT_ID=x -e PROVIDERS_GOOGLE_CLIENT_SECRET=y \
  -v traefik-forward-auth-probe-config:/config traefik-forward-auth:2.3.0
docker logs -f traefik-forward-auth-probe
docker exec traefik-forward-auth-probe ls -l /config/secret
docker rm -f traefik-forward-auth-probe; docker volume rm traefik-forward-auth-probe-config
forgetool containers test --image traefik-forward-auth:2.3.0 --config ./apps/traefik-forward-auth/container-test.yaml
```

Also build once with `--set image-local.platform=linux/arm64`, since the arm64 path is a compile. Readiness signal: the process stays up with port 4181 open and no fatal log lines. The default log level is `warn`, so a quiet log is normal: raise it with `-e LOG_LEVEL=info` to see a "Listening on :4181" style line (UNVERIFIED wording). A restart must reuse `/config/secret`.

## 12. PR checklist

- Branch `feat/add-traefik-forward-auth`, commit and PR title `feat(traefik-forward-auth): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State in the PR: the source build for both arches, the generated secret, and the dummy-provider test.
- Untested at planning time: the Go build on the ubuntu base (both arches), the read-only run, `forgetool containers test`, and a real OAuth login. Do not check "Built container locally" unless it was done.
