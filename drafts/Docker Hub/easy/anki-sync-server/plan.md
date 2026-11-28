# anki-sync-server — implementation plan
> Source: ./draft.md · Target: apps/anki-sync-server/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.1.4 (latest GitHub release, tag `1.1.4` without `v`; matches the draft's `ankicommunity/anki-sync-server-rs:1.1.4`) |
| Renovate | `datasource=github-releases depName=ankicommunity/anki-sync-server-rs versioning=semver` |
| License | AGPL-3.0-or-later (`Cargo.toml` `license = "AGPL-3.0-or-later"`, LICENSE is the GNU AGPL v3) |
| Source URL | https://github.com/ankicommunity/anki-sync-server-rs |
| Maintenance | The repository is **archived** on GitHub (last push 2023-11-23, checked 2026-11-25). No further releases or fixes. |
| Start-up requirement | At 1.1.4 the server **panics and exits when `auth.db` holds no user** (`new_server` in `src/app_config.rs` returns "no user found on the server side" and `main` unwraps it). |
| amd64 | `https://github.com/ankicommunity/anki-sync-server-rs/releases/download/1.1.4/ankisyncd_1.1.4_linux_x64.tar.gz` (sha256 `d16510d0a7b8b39d387b87883b23d865556d63bb51a6624a4eb3e3732da7e5ef`, computed 2026-11-23) |
| arm64 | `.../ankisyncd_1.1.4_linux_arm64.tar.gz` (sha256 `20265cefc04eb1ec29c27ad1995a2e017e13cc3a461f11e671e476babe54f577`, computed 2026-11-23) |
| Tarball contents | `ankisyncd_1.1.4_linux_<arch>/ankisyncd` and `ankisyncd.toml` only (no LICENSE inside) |
| Binary linkage | Both binaries have no ELF interpreter and no `NEEDED` entries (statically linked), so they run on glibc Ubuntu; checked with `readelf` only, the binary was not executed. |
| Checksum | UNVERIFIED as an upstream checksum: the release lists no checksum asset. Use the sha256 values above as pinned values only if a manual bump on every renovate update is acceptable; otherwise rely on HTTPS. |
| Upstream Dockerfile reviewed | https://github.com/ankicommunity/anki-sync-server-rs/blob/1.1.4/Dockerfile (rust build, `debian:stable-slim`, `VOLUME /app`, `WORKDIR /app`, `EXPOSE 27701`, `CMD sh /entrypoint.sh`; the entrypoint copies `/ankisyncd.toml` to `/app/ankisyncd.toml` if missing and runs `ankisyncd -c /app/ankisyncd.toml`) |
| Port | 27701/tcp (`[listen] host = "0.0.0.0" port = 27701`). The draft's inferred 8080 is wrong. |
| Config | `ankisyncd.toml`: `[listen] host, port`, `[paths] root_dir`, `[encryption] ssl_enable, cert_file, key_file`. `-c/--config <file>`. The upstream container sets `root_dir = "/app"`; the bundled toml uses `"."`. Data written under `root_dir`: `auth.db`, `collections/`. |
| Env vars (src/main.rs) | `ANKISYNCD_USERNAME`, `ANKISYNCD_PASSWORD` (adds that user at start if it does not exist, so it is idempotent), `MAX_SYNC_PAYLOAD_MEGS` (default "1000"). |
| CLI | `ankisyncd user -a <user> <pass>` (add), `--help` for delete and change; `-d/--default` prints the default config. |

## 2. Target layout

```
apps/anki-sync-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/ankisyncd.toml     # seed file, copied to /config when missing
```
`defaults/` is in the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: prebuilt static Rust binary per arch (draft). Closest sibling: `apps/adguardhome-sync` (tarball release binary, `defaults/` config seeded with `cp -n`, `exec` run).

## 4. Dockerfile

1. `FROM`; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Arch mapping and install (no apt packages; `curl`, `tar`, `ca-certificates` are in the base):
   ```sh
   case "${TARGETARCH}" in amd64) A=x64;; arm64) A=arm64;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1;; esac && \
   mkdir -p /app /usr/share/licenses/anki-sync-server && \
   curl -fsSL -o /tmp/ankisyncd.tar.gz "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${VERSION}/ankisyncd_${VERSION}_linux_${A}.tar.gz" && \
   tar xzf /tmp/ankisyncd.tar.gz -C /app --strip-components=1 ankisyncd_${VERSION}_linux_${A}/ankisyncd && \
   curl -fsSL -o /usr/share/licenses/anki-sync-server/LICENSE "https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/${VERSION}/LICENSE" && \
   chown -R root:root /app && chmod 0755 /app/ankisyncd && rm -f /tmp/ankisyncd.tar.gz
   ```
   Optionally add `echo "<sha256>  /tmp/ankisyncd.tar.gz" | sha256sum -c -` per arch if pinning (see section 1).
3. `ENV HOME=/config` is already set by the base; no caches are produced.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 27701`, `WORKDIR /config`, `VOLUME /config`. Final `USER apps`.

## 5. docker-bake.hcl

- `APP` = `anki-sync-server`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=ankicommunity/anki-sync-server-rs versioning=semver
  default = "1.1.4"
  ```
- `LICENSE` = `AGPL-3.0-or-later`; `SOURCE` = `https://github.com/ankicommunity/anki-sync-server-rs`
- 4 targets and `default` group copied from `apps/adguardhome-sync/docker-bake.hcl`; validate with `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/ankicommunity/anki-sync-server-rs"`.
- `ports`: `27701` tcp `required: false`.
- `env`: `ANKISYNCD_USERNAME` default "" required false; `ANKISYNCD_PASSWORD` default "" required false; `MAX_SYNC_PAYLOAD_MEGS` default "1000" required false; `TZ` "Etc/UTC" required false.
- `volumes`: `/config` required true.
- `dependencies`: none.

## 7. start.sh

The server cannot start without a user (section 1), so `start.sh` creates a first user when none exists.

```bash
#!/usr/bin/env bash
set -eu
[ -f /config/ankisyncd.toml ] || cp /defaults/ankisyncd.toml /config/ankisyncd.toml
export MAX_SYNC_PAYLOAD_MEGS="${MAX_SYNC_PAYLOAD_MEGS:-1000}"
cd /config

users="$(/app/ankisyncd --config /config/ankisyncd.toml user --list)"
if [ -z "$users" ]; then
  export ANKISYNCD_USERNAME="${ANKISYNCD_USERNAME:-anki}"
  if [ -z "${ANKISYNCD_PASSWORD:-}" ]; then
    if [ ! -s /config/initial_password ]; then
      (umask 077; od -An -N16 -tx1 /dev/urandom | tr -d ' \n' > /config/initial_password)
    fi
    ANKISYNCD_PASSWORD="$(cat /config/initial_password)"
    export ANKISYNCD_PASSWORD
    echo "[anki-sync-server] No users yet: creating '${ANKISYNCD_USERNAME}', password in /config/initial_password" >&2
  fi
fi

exec /app/ankisyncd --config /config/ankisyncd.toml
```
`defaults/ankisyncd.toml`:
```toml
[listen]
host = "0.0.0.0"
port = 27701

[paths]
root_dir = "/config"

[encryption]
ssl_enable = false
cert_file = ""
key_file = ""
```
The binary adds the exported user on start, so the password never goes on a command line. UNVERIFIED: the exact output of `user --list` (the source prints one username per line and nothing when empty). `ANKISYNCD_USERNAME` and `ANKISYNCD_PASSWORD` are read by the binary itself on every start (adds the user if missing; a changed password for an existing user is not applied, use `ankisyncd user` for that; this is upstream behaviour and the secrets stay in the environment, not in files or the process list). Do not `cp -n` over an existing user file. Idempotent; nothing is written to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '27701'
http:
- port: '27701'
  path: /
  statusCode: 200
filePaths:
- /app/ankisyncd
- /defaults/ankisyncd.toml
- /usr/share/licenses/anki-sync-server/LICENSE
```
With no env, `start.sh` creates the first user, so the server starts and the probes work. Without that step the binary panics. `GET /` returns 200 with the text `Anki Sync Server` (route `welcome` in `src/app_config.rs`). The user-from-env path cannot be tested by the harness; run it by hand (section 11). No DB dependency; no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/app` (`VOLUME /app`: `ankisyncd.toml`, `auth.db`, `collections/`) | `root_dir = "/config"`; `/app` only holds the binary. |
| Config copy at `/app/ankisyncd.toml` | `/config/ankisyncd.toml` seeded from `/defaults`. |

Draft expectations: chart runs as UID 0 with writable rootfs and persists `/app/data`; resolved by using `/config` as the one data volume (draft's own "Reason" text says `/config`). A user migrating from the chart must move `/app/data` content into `/config` (`auth.db`, `collections/`); document in the PR. Not privileged. Users come from env, from `ankisyncd user -a` (draft caveat), or from the first-start fallback in section 7.

## 10. Risks, caveats and open questions

- **Decision needed:** upstream is archived. Decide whether to ship it at all, or instead package a maintained option such as the sync server built into Anki (https://docs.ankiweb.net/sync-server.html). UNVERIFIED: whether current Anki clients still work with the sync protocol in 1.1.4. Renovate will never find an update.
- The auto-created `anki` user with a generated password is this plan's own workaround for the start-up panic; confirm it is wanted.
- Draft: Anki clients must be pointed at the custom sync URL (e.g. `http://host:27701/`; AnkiDroid media sync uses `/msync`).
- Draft: data location conflict `/app/data` vs `/config`: settled on `/config` (here, UNVERIFIED against an actual chart migration).
- UNVERIFIED: the binary was only inspected (`readelf`), not run; confirm at runtime that it starts on glibc Ubuntu 26.04 for both arches, and that the tarball build is the same flavour (TLS feature) as the Docker image's. `ssl_enable` may not work if built without the `tls` feature; keep it false and use a reverse proxy.
- UNVERIFIED: that `ankisyncd` also does not need extra runtime files (collections dir creation); upstream creates data under `root_dir` on demand.
- No checksum published upstream (see section 1).
- Not blockers: no musl issue (static), no GPU, no privileged, arm64 asset exists.

## 11. Build and test steps

```sh
cd apps/anki-sync-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name anki-sync-server-probe --read-only --tmpfs /tmp -v anki-sync-server-probe-config:/config anki-sync-server:1.1.4
docker logs -f anki-sync-server-probe     # expect "listening on 0.0.0.0:27701", no panic; /config/ankisyncd.toml, auth.db, collections/anki/ and initial_password created
docker rm -f anki-sync-server-probe
# user from env
docker run --rm -d --name anki-sync-server-probe --read-only --tmpfs /tmp -e ANKISYNCD_USERNAME=test -e ANKISYNCD_PASSWORD=testpass123 -v anki-sync-server-probe-config:/config anki-sync-server:1.1.4
docker restart anki-sync-server-probe     # idempotent with existing data
docker rm -f anki-sync-server-probe; docker volume rm anki-sync-server-probe-config
forgetool containers test --image anki-sync-server:1.1.4 --config ./apps/anki-sync-server/container-test.yaml
```
Also connect from a second container (`curl http://anki-sync-server-probe:27701/`) because the tcp probe cannot prove non-localhost binding. Max 10 rounds.

## 12. PR checklist

- Branch `feat/add-anki-sync-server`; commit and title `feat(anki-sync-server): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes has `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested unless run: build on both architectures, actual Anki client sync, user creation from env, restart idempotency, migration from the chart's `/app/data`, `forgetool` run.
- Standard checklist: minimal scope, instruction files followed, bake and Dockerfile aligned, rootless and read-only, empty `/config` works, no downstream impact, `bake --print` ran.
