# collabora — implementation plan
> Source: ./draft.md · Target: apps/collabora/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Docker tag `26.04.6.2.1` (2026-11-20) is the newest versioned `collabora/code` tag; the draft used `26.04.6.1.1` (2026-11-07). Apt packages: `coolwsd 26.04.6.2-1` (amd64, arm64, ppc64el), `code-brand 26.04.6-2`, `collaboraoffice 26.04.6-2`. Mapping: tag `A.B.C.D.E` = apt `A.B.C.D-E`. |
| Renovate | `datasource=docker depName=docker.io/collabora/code versioning=loose` (the apt repo has no renovate datasource; the Docker tag is the tracking source and the Dockerfile derives the apt version from it). |
| License | `MPL-2.0` (COPYING header: Mozilla Public License 2.0). The bundled LibreOffice core has its own MPL/LGPL components; ship the license files the packages install. |
| Source | https://github.com/CollaboraOnline/online |
| Packages | Apt repo `https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb` (`Suites: ./`), signing keyring `https://collaboraoffice.com/downloads/gpg/collaboraonline-release-keyring.gpg`. Install `coolwsd code-brand` (coolwsd depends on `collaboraoffice*`, `adduser`, `fontconfig`, `cpio`, `libcap2`, `libpam0g` on amd64). amd64 and arm64 debs exist. |
| Checksum | Apt verifies the signed `InRelease`/`Release.gpg`; no separate checksum. |
| Upstream Dockerfile | None public for the current image (draft: `-`). Reviewed instead the legacy `CollaboraOnline/Docker-CODE` (`Dockerfile` + `scripts/start-collabora-online.sh`, old loolwsd era): `ENV domain localhost`, `EXPOSE 9980`, `USER 101`, generates a self-signed cert unless `DONT_GEN_SSL_CERT` is set, rewrites `loolwsd.xml` from env, starts `/usr/bin/loolwsd --version --o:sys_template_path=... --o:child_root_path=... --o:file_server_root_path=... --o:user_interface.mode=notebookbar ${extra_params}` (the legacy binary is `loolwsd`, not `coolwsd`; source: context/github-collaboraonline-docker-code.md). Current script is UNVERIFIED; the SDK docs site is behind Anubis and could not be fetched. |
| Env (documented by Collabora docs/forums) | `aliasgroup1`, `aliasgroup2`, ... (allowed WOPI hosts, e.g. `https://cloud.example.com:443`), `extra_params` (extra `coolwsd` flags such as `--o:ssl.enable=false --o:ssl.termination=true`), `username` / `password` (admin console), `dictionaries` (space-separated list, e.g. `en_GB en_US de_DE`), `server_name`, `DONT_GEN_SSL_CERT`, `cert_domain`. Exact current behavior of each is UNVERIFIED. |
| Port | `9980` (HTTP/WebSocket, TLS by default unless `ssl.enable=false`). Discovery endpoint: `/hosting/discovery`. Admin console: `/browser/dist/admin/admin.html`. |
| Rootless support | Per Collabora Kubernetes docs (via search summary): run with all capabilities dropped plus Collabora's seccomp profile (`docker/cool-seccomp-profile` in the online repo), which lets coolwsd use user and mount namespaces; Ubuntu 24.04+ AppArmor restricts unprivileged user namespaces. Fallback: `--o:security.capabilities=false --o:mount_jail_tree=false` (also `--o:security.seccomp=false` as Nextcloud's built-in CODE does), which turns the chroot jail off (log shows "Using Mount Namespaces: false"). |

## 2. Target layout

```
apps/collabora/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` unless a config template is seeded (see section 7: generate the config with `--o:` flags instead). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```
Why: vendor deb packages for Ubuntu; the official image is also Ubuntu based. Closest sibling: `apps/valkey` (pinned apt version derived from `VERSION`).

## 4. Dockerfile

1. `ARG VERSION` (default from bake `26.04.6.2.1`), `ARG TARGETARCH`; `USER root`.
2. Derive apt version: `APT_VERSION="${VERSION%.*}-${VERSION##*.}"` (gives `26.04.6.2-1`; `code-brand` and `collaboraoffice*` use `26.04.6-2`, so let apt resolve `code-brand` and the office packages through the coolwsd dependency instead of pinning them separately).
3. Add the repo:
   - `curl -fsSL https://collaboraoffice.com/downloads/gpg/collaboraonline-release-keyring.gpg -o /etc/apt/keyrings/collaboraonline-release-keyring.gpg`
   - write `/etc/apt/sources.list.d/collaboraonline.sources` with `Types: deb`, `URIs: https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb`, `Suites: ./`, `Signed-By: /etc/apt/keyrings/collaboraonline-release-keyring.gpg`.
4. `apt-get update && apt-get install -y --no-install-recommends coolwsd=${APT_VERSION} code-brand cpio libcap2-bin fonts-dejavu fonts-liberation openssl` (base lacks `cpio`, `libcap2-bin`; `adduser`/`fontconfig` come in via deps). The `coolwsd` postinst creates user `cool`, sets file caps with `setcap` on `coolforkit-caps` and generates `/etc/coolwsd/*`, so check the postinst runs OK in a Docker build (it may call `systemctl`; UNVERIFIED).
5. Systemplate for the jails must be built at image build time (the CODE image does this on first start otherwise): `coolwsd-systemplate-setup /opt/cool/systemplate /opt/collaboraoffice` (UNVERIFIED path; confirm with `dpkg -L coolwsd`).
6. Ownership: `chown -R apps:apps /opt/cool /etc/coolwsd /var/log/coolwsd`; remove the `cool` user's fixed UID dependency by passing `--o:user=apps` is NOT supported (UNVERIFIED), so confirm coolwsd runs as UID 568 via `--disable-cool-user-checking` (flag exists in coolwsd for non-service use; UNVERIFIED).
7. Licenses: copy `/usr/share/doc/coolwsd/copyright` and `/opt/collaboraoffice/LICENSE*` (whichever exist) to `/usr/share/licenses/collabora/`.
8. `ENV HOME=/config LC_CTYPE=C.UTF-8`; `rm -rf /var/lib/apt/lists/* /tmp/*`; `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 9980`; `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "collabora" }
variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/collabora/code versioning=loose
  default = "26.04.6.2.1"
}
variable "LICENSE" { default = "MPL-2.0" }
variable "SOURCE"  { default = "https://github.com/CollaboraOnline/online" }
```
Standard targets from `apps/adguardhome-sync/docker-bake.hcl` (`image` passes `args.VERSION`; `image-all` amd64 + arm64). Run `docker buildx bake --print`. Dockerfile ARG and bake default must both read `26.04.6.2.1`.

## 6. settings.yaml

Header + `schema_version: 1`; `upstream_env_url: "https://github.com/CollaboraOnline/online"`.
- ports: `9980` tcp, required true.
- env (only what `start.sh` implements, a subset of the documented ones): `aliasgroup1` (default `""`, required false), `server_name` (`""`), `extra_params` (`""`), `username` (`""`), `password` (`""`), `dictionaries` (`"de_DE en_GB en_US es_ES fr_FR it nl pt_BR pt_PT ru"` — default copied from the legacy script; UNVERIFIED for the current one), `TZ` (`Etc/UTC`).
- volumes: `/config` (required: false; holds the generated `coolwsd.xml`, proof key, cert).
- dependencies: none (the WOPI host, e.g. Nextcloud, is external; add `nextcloud-fpm` ✅ only as an informational note, not as a hard dependency).

## 7. start.sh

Idempotent; never write to `/app` or `/etc`.
1. `mkdir -p /config/coolwsd /tmp/cool/child-roots /tmp/cool/cache /tmp/cool/logs`.
2. Seed `/config/coolwsd/coolwsd.xml` from `/etc/coolwsd/coolwsd.xml` only when missing, then use `--config-file=/config/coolwsd/coolwsd.xml`. Generate a WOPI proof key into `/config/coolwsd/` only if missing (`coolwsd-generate-proof-key` normally writes `/etc/coolwsd/proof_key`; confirm it accepts a path, UNVERIFIED).
3. Build the argument array: `--o:ssl.enable=false --o:ssl.termination=true` by default (TLS is expected at the reverse proxy), `--o:child_root_path=/tmp/cool/child-roots --o:cache_files.path=/tmp/cool/cache --o:logging.file[@enable]=false` (log to stderr), `--o:net.listen=any`, `--o:storage.wopi.host[0]=${aliasgroup1}` and `[1]..` for `aliasgroupN` in a loop, `--o:admin_console.username=... --o:admin_console.password=...` passed through an env-file rather than `ps` when possible (secrets: coolwsd only accepts `--o:`; keep them out of logs and warn that they show in the process list; UNVERIFIED alternative: write them into the seeded XML with a safe, escaped rewrite instead), `--o:server_name=${server_name}`, `--o:allowed_languages="${dictionaries}"`.
4. Because of rootless limits add `--o:security.capabilities=false --o:mount_jail_tree=false` unless `COOL_JAILS=true` (custom switch, document it) is set with the seccomp profile.
5. Append `${extra_params}` unquoted last (it is documented as raw flags). Final: `exec /usr/bin/coolwsd --version --use-env-vars --disable-cool-user-checking "${args[@]}"` (`--use-env-vars` only if present in this coolwsd, UNVERIFIED; drop otherwise).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '9980'
http:
- port: '9980'
  path: /hosting/discovery
filePaths:
- /usr/bin/coolwsd
- /usr/share/licenses/collabora
```
The test runs without env vars; with `ssl.enable=false` default, plain HTTP works with no `aliasgroup1` (discovery needs no WOPI host). Set a generous `timeoutSeconds` (LibreOffice kit preloads on start; copy the largest value from a heavy sibling such as `apps/nextcloud-fpm` or `apps/kasmvnc`).

## 9. Rootless and read-only-rootfs adaptations

- Upstream write paths: `/etc/coolwsd` (config, proof key, SSL certs), `/opt/cool/child-roots`, `/opt/cool/cache`, `/var/log/coolwsd`, jail setup under `child-roots` (needs mount/chroot). Remap: config and proof key to `/config/coolwsd`, child roots/cache/logs to `/tmp/cool` (tmpfs; hard links from `systemplate` to a tmpfs child root fall back to copying, UNVERIFIED and slower).
- Draft: chart used `runAsUser 1001`, `allowPrivilegeEscalation true`, caps `CHOWN FOWNER SYS_CHROOT MKNOD`, `readOnlyRootFilesystem false`. Reconcile: this plan runs as `apps` (568) with read-only rootfs and NO added capabilities by disabling the capability-based jail (`security.capabilities=false`), which reduces sandboxing of document conversion. Users who want jails must run the Collabora seccomp profile with unprivileged user namespaces; document in the README or settings description.
- The coolwsd binaries carry file capabilities (`setcap`) which fail to exec when the bounding set lacks them (`operation not permitted`): remove them with `setcap -r` on `coolforkit-caps` and `coolmount` in the Dockerfile when running without caps (UNVERIFIED filenames).
- Not privileged.

## 10. Risks, caveats and open questions

- Largest risk: running coolwsd as non-root without caps, with read-only rootfs. Confirm the process spawns `coolforkit` successfully (log should not show "Cannot start kit process").
- The CODE image is built by Collabora's own pipeline; our rebuild may diverge (fonts, dictionaries, `code-brand` limits: CODE is capped at roughly 20 connections / 10 documents, UNVERIFIED; Collabora describes CODE as not recommended for production, see context/collaboraonline-code-page.md).
- Image is large (LibreOffice kit, 1 GB+); disk and RAM high.
- TLS: default off here; the reverse proxy must terminate TLS and forward WebSocket headers.
- `aliasgroup1` is required for any real WOPI host; with it unset, editing fails. Documented but cannot be tested without a WOPI host (no Nextcloud sidecar test).
- Renovate maps docker tag to apt version through shell arithmetic; if upstream changes tag shape this breaks. Also `code-brand` uses a different suffix.
- Env var semantics for the current image are UNVERIFIED (docs site blocked by a bot challenge).
- No GPU, no arm64 blockers: arm64 debs exist (also noted `collabora/code` image is multi-arch).

## 11. Build and test steps

```sh
cd apps/collabora
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name collabora-probe --read-only --tmpfs /tmp \
  -v collabora-probe-config:/config collabora:26.04.6.2.1
docker logs -f collabora-probe   # expect coolwsd "Listening to ... 9980", "Ready to accept connections"; no fatal capability errors
curl -s http://127.0.0.1:9980/hosting/discovery | head -c 200   # via published port
forgetool containers test --image collabora:26.04.6.2.1 --config ./apps/collabora/container-test.yaml
docker rm -f collabora-probe; docker volume rm collabora-probe-config
```
Extra manual run with `-e aliasgroup1=https://example.com:443 -e extra_params="--o:ssl.enable=false"` to confirm env mapping (the test harness cannot).

## 12. PR checklist

- Branch `feat/add-collabora`; commit and PR title `feat(collabora): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to list: jails/seccomp mode, real WOPI edit session, arm64 build, `aliasgroupN` mapping, admin console credentials, read-only rootfs with the generated `systemplate`, apt postinst inside `docker build`.
