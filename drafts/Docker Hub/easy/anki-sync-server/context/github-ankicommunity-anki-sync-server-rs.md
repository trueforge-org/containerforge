# ankicommunity/anki-sync-server-rs

**Source URL(s) + fetch date**
- https://github.com/ankicommunity/anki-sync-server-rs (repo, releases, LICENSE)
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/master/README.md
- https://github.com/ankicommunity/anki-sync-server-rs/blob/1.1.4/Dockerfile (fetched as raw 1.1.4/Dockerfile)
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/scripts/entrypoint.sh
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/scripts/ankisyncd.toml
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/master/docs/CONTAINER.md
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/LICENSE
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/src/main.rs
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/src/app_config.rs
- Fetched 2026-11-26

**What it is**
- Rust implementation of the Anki sync server (`ankisyncd`). The README says the project is no longer maintained, that it may only work with Anki clients up to about 2.1.64, and it points users to the official Anki sync server.
- The GitHub repository is **archived** (archived by the owner on Nov 21, 2023, read-only). Confirms plan.md's maintenance note.
- License: GNU AGPL v3 (LICENSE is the FSF AGPL v3 text, 19 November 2007). README says contributions are AGPL-v3.0 (spelled "AGLP-v3.0" in the README).

**Install/build steps and build deps (upstream Dockerfile, 1.1.4)**
- Stage 1 `protocc`: base `strophy/protoc:4.0.1`; runs `protoc -h`.
- Stage 2 `builder`: base `rust:latest`; workdir `/usr/src/anki-sync-server-rs`; copies the whole build context; copies `/usr/bin/protoc` from `protocc`; runs `scripts/clone_patch_anki`; runs `cargo build --release`; copies `./target/release/ankisyncd` out, then `cargo clean`.
- A comment says prost-build failed on armv7h (see upstream issue 22). A commented-out line would apt-install `protobuf-compiler` and `git` (not active).
- Stage 3 `runner`: base `debian:stable-slim`; copies `ankisyncd` to `/usr/local/bin/ankisyncd` and `chmod +x`; `WORKDIR /app`; `VOLUME /app`; copies `scripts/ankisyncd.toml` to `/ankisyncd.toml`; copies `scripts/entrypoint.sh` to `/entrypoint.sh`; `chmod +x /entrypoint.sh`; `CMD ["sh", "/entrypoint.sh"]`; `EXPOSE 27701`.
- No `ARG`, `ENV`, `USER` or `ENTRYPOINT` in the upstream Dockerfile.

**Runtime deps**
- Runtime base is `debian:stable-slim`. Extra runtime deps are commented out (none active).
- The release binary is statically linked per plan.md's readelf check (not re-verified here).

**Binaries/entrypoint/CLI flags**
- Entrypoint script (`scripts/entrypoint.sh`, verbatim):
  ```sh
  #!/bin/sh
  if [ ! -f /app/ankisyncd.toml ]; then
  	cp -u /ankisyncd.toml /app/ankisyncd.toml
  fi
  /usr/local/bin/ankisyncd -c /app/ankisyncd.toml
  ```
  Note: upstream uses `cp -u` (not `cp -n`), and the copy writes into `/app`.
- CLI (README): `ankisyncd user --add <user> <pass>` (Windows `ankisyncd.exe`); other user operations (delete, change password) via `ankisyncd user --help`; `./ankisyncd --config /path/to/ankisyncd.toml`. The Docker docs also show `ankisyncd user -a username password`.
- `ankisyncd -d/--default` prints the default config (src/main.rs).
- Subcommand names beyond `user` were not visible in main.rs (`parse_args` module not fetched). No `user --list` was seen in fetched sources; plan.md's `user --list` remains UNVERIFIED.

**Env vars (src/main.rs, 1.1.4)**

| Variable | Default | Behaviour |
| --- | --- | --- |
| `ANKISYNCD_USERNAME` | "" | Read via `env::var`; if username and password are both non-empty and the user does not exist, the user is added at start (`add_user`). |
| `ANKISYNCD_PASSWORD` | "" | As above. |
| `MAX_SYNC_PAYLOAD_MEGS` | "1000" | Upload size limit; stored in `MAX_COLLECTION_UPLOAD_SIZE` and re-set via `env::set_var` before start. |

- README says the env vars "can be used to add an account" and are non-empty if set.

**Ports**
- 27701/tcp (`EXPOSE 27701`; `[listen] port = 27701` in the default config; host `0.0.0.0`).

**Volumes/paths and persistent data**
- Upstream image declares `VOLUME /app`; `WORKDIR /app`.
- Data lives under `root_dir` in `ankisyncd.toml`: `auth.db` and the `collections/` folder (per app_config.rs and plan.md; `set_users` creates per-user folders with `create_dir_all`).
- Default config (scripts/ankisyncd.toml) sets `root_dir = "/app"`.
- README says the data location is configurable in `ankisyncd.toml` and gives no default path.

**User/UID & permissions**
- No `USER` in the Dockerfile, so the upstream image runs as root (default). The README gives no run-user details.

**Config files and formats (scripts/ankisyncd.toml, verbatim)**
```toml
[listen]
host = "0.0.0.0"
port = 27701

[paths]
# set root_dir as working dir where server data(collections folder) and database(auth.db...) reside
root_dir = "/app"

# The following section is optional,
# set it up if your server is compiled with tls support
[encryption]
ssl_enable = false
cert_file = ""
key_file = ""
```

**Healthcheck/readiness endpoints (src/app_config.rs routes)**
- `GET /` -> `welcome`: HTTP 200, `text/plain`, body `Anki Sync Server`.
- `GET /favicon.ico`.
- `/sync/{method}` (collection sync), `GET|POST /msync/begin`, `POST /msync/{method}` (media sync).

**Version/release info and asset naming**
- Latest release: tag `1.1.4` (titled "1.1.4 Release", marked Latest, commit `e748e32`, published by github-actions, 24 Jun, year not shown on page).
- 1.1.4 release note: adds support for dynamically adding users while the server runs (issue #70, PR #71).
- The releases page says "Assets 6" but the asset list did not load, so exact names were not confirmed from this page. Per-platform tags exist (e.g. `windows_x86_64`) according to the README.
- Asset names in plan.md (`ankisyncd_1.1.4_linux_x64.tar.gz`, `ankisyncd_1.1.4_linux_arm64.tar.gz`) were NOT confirmed by this fetch.
- No upstream checksum asset was confirmed from fetched pages.

**Arch support**
- Docker docs: images for arm64 and amd64. Upstream tarball arch names per plan.md: `x64` and `arm64` (asset names not re-confirmed here).

**Gotchas**
- Repository is archived; no further releases or fixes expected.
- README: may work with Anki clients up to about 2.1.64; newer clients may need a matching server because the sync protocol can change (docs.ankiweb.net).
- Anki client URLs: Anki >= 2.1.57 uses the custom sync server field, e.g. `http://<ip>:27701/`. AnkiDroid 2.16+ uses `/sync/` and `/msync/`.
- Upstream `docs/CONTAINER.md` example: `docker run -d -it --name=ankisyncd -e ANKISYNCD_USERNAME=test -e ANKISYNCD_PASSWORD=123456 ankicommunity/anki-sync-server-rs:latest`.
- Startup without any user: `new_server` in app_config.rs returns `ApplicationError::UserError(MissingValues("no user found on the server side"))`, which `SimpleServer` wraps. `main.rs` calls `app_config::run(&conf).await.unwrap()`, so the process panics. Plan.md's panic claim is therefore consistent with this code path. Whether `fetch_users` returns `None` or `Some(vec![])` for an empty DB was not visible, so the exact trigger is UNVERIFIED.
- Plan.md says the bundled `ankisyncd.toml` uses `root_dir = "."`. The fetched `scripts/ankisyncd.toml` at 1.1.4 uses `"/app"`. The tarball's own toml was not fetched, so this stays UNVERIFIED for the release tarball.
