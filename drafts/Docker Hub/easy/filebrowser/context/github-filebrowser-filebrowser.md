# filebrowser/filebrowser (GitHub)

**Source URL(s) + fetch date**
- https://github.com/filebrowser/filebrowser (repo; draft source link)
- https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/Dockerfile
- https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/README.md
- https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/docker/common/healthcheck.sh
- https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/docker/common/defaults/settings.json
- https://github.com/filebrowser/filebrowser/releases/tag/v2.63.23
- https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/filebrowser_2.63.23_checksums.txt (redirects to a signed release-asset URL; the signed URL was fetched)
- Fetched 2026-11-26

**What it is**
Web file manager for a chosen directory: upload, delete, preview, rename, edit, multi-user with per-user directories. Apache-2.0. The project is archived: the maintainers' final release is v2.63.23; the repo is read-only after archiving (2026-09-01 per README, banner says archived Aug 31, 2026). No further fixes. Upstream says "treat it as unmaintained software", do not expose it directly to the internet, and keep the command runner disabled (off by default).

**Install/build steps and build deps (upstream Dockerfile at the pinned commit)**
- Stage 1: `FROM alpine:3.23 AS fetcher`; `apk add ca-certificates mailcap tini-static`; downloads `JSON.sh` (dominictarr) to `/JSON.sh`.
- Stage 2: `FROM busybox:1.37.0-musl`.
- `ENV UID=1000 GID=1000`; creates user `user` (uid 1000, gid 1000).
- `COPY --chown=user:user filebrowser /bin/filebrowser` (binary built in the same build, not fetched here).
- `COPY --chown=user:user docker/common/ /` and `docker/alpine/ /` (so `/init.sh` and `/healthcheck.sh` come from `docker/common`).
- `tini-static` copied to `/bin/tini`; CA certs, mime.types, ssl copied from fetcher.
- `mkdir -p /config /database /srv && chown -R user:user /config /database /srv && chmod +x /healthcheck.sh`.
- `HEALTHCHECK --start-period=2s --interval=5s --timeout=3s CMD /healthcheck.sh`
- `USER user`; `VOLUME /srv /config /database`; `EXPOSE 80`; `ENTRYPOINT [ "tini", "--", "/init.sh" ]`; no CMD.

**Runtime deps**
busybox/musl userland in upstream; `jq` is used by healthcheck.sh (`jq -r .port /config/settings.json`) and `wget`.

**Binaries/entrypoint/CLI flags**
- Binary: `/bin/filebrowser` (upstream). Config flag: `--config <file>` (used by init.sh, per plan; init.sh itself could not be fetched).
- Entrypoint: `tini -- /init.sh`.

**Env vars (table)**

| Name | Default | Notes |
| --- | --- | --- |
| `FB_PORT` | from `/config/settings.json` `port` (80 in upstream defaults) | Read by healthcheck.sh; viper `FB_` prefix per plan (cmd/root.go, not re-fetched). |
| `FB_ADDRESS` | from settings `address` (empty), then `localhost` in healthcheck | Read by healthcheck.sh. |
| `UID` / `GID` | `1000` / `1000` | Build-time ENV for upstream user. |

**Ports**
Upstream `EXPOSE 80`. Upstream defaults listen on 80.

**Volumes/paths and persistent data**
- Upstream `VOLUME /srv /config /database`.
- Defaults (`docker/common/defaults/settings.json`): `"database": "/database/filebrowser.db"`, `"root": "/srv"`, `"port": 80`, `"address": ""`, `"baseURL": ""`, `"log": "stdout"`.

**User/UID & permissions**
Upstream runs as `user` (UID 1000). Directories `/config`, `/database`, `/srv` owned by that user.

**Config files and formats**
- `settings.json` (JSON) at `/config/settings.json`, used via `--config`. Keys seen: `port`, `baseURL`, `address`, `log`, `database`, `root`.
- Defaults file path in upstream: `docker/common/defaults/settings.json`.

**Healthcheck/readiness endpoints**
- `healthcheck.sh` (fetched verbatim-ish):
  ```
  PORT=${FB_PORT:-$(jq -r .port /config/settings.json)}
  ADDRESS=${FB_ADDRESS:-$(jq -r .address /config/settings.json)}
  ADDRESS=${ADDRESS:-localhost}
  wget -q --spider http://$ADDRESS:$PORT/health || exit 1
  ```
- Endpoint: `GET /health`.

**Version/release info and asset naming**
- Release `v2.63.23`, marked Latest, released 27 Jul (year not shown). Release page banner: archived; "final planned release".
- Asset naming: `linux-<arch>-filebrowser.tar.gz` (e.g. `linux-amd64-filebrowser.tar.gz`, `linux-arm64-filebrowser.tar.gz`) and checksum file `filebrowser_<version>_checksums.txt` with `<sha256>  <file>` lines.
- Checksums from `filebrowser_2.63.23_checksums.txt` (fetched): `b14db2bb8033caa3f80205eb6578b2ed0744ebd9e716b790bc4a9703ce909e88  linux-amd64-filebrowser.tar.gz`; `c55b3450b6ac07ef73b5b49f0b2955a8e755100b71af1df73f9e5d25b12fd27a  linux-arm64-filebrowser.tar.gz`. Also 19 other platform tarballs and zips listed.
- The release asset list on the release page did not load; asset names are taken from the checksum file.

**Arch support**
Assets exist for linux-386, linux-amd64, linux-arm64, linux-armv5/v6/v7, linux-riscv64 (per checksum file), plus darwin, freebsd, openbsd, windows.

**Gotchas**
- Upstream listens on port 80 (plan uses 8080 to avoid privileged ports).
- Upstream `settings.json` uses `root: /srv` and `database: /database/filebrowser.db`; the plan remaps to `/data` and `/config`.
- Healthcheck depends on `jq` and `wget`; ensure they exist in the target image if the check is reused.
- Release page banner and README give slightly different archive dates (Aug 31 vs Sep 1, 2026).

**Contradictions with plan.md**
- None in the facts checked: checksums for linux-amd64 and linux-arm64 match plan.md section 1; archived status matches; `FB_PORT`/`FB_ADDRESS` names confirmed.
- plan.md section 1 says upstream `init.sh` copies `/defaults/settings.json` to `/config/settings.json` and execs filebrowser. Could not fetch `docker/common/init.sh` (404 at the pinned commit and on master). Unverified.
