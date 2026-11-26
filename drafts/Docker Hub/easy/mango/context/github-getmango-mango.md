# getmango/Mango (GitHub, ARCHIVED)

Source URL(s) + fetch date:
- https://github.com/getmango/Mango (repo; archived)
- https://github.com/getmango/Mango/releases/tag/v0.27.0 (release page; asset list did not load)
- https://raw.githubusercontent.com/getmango/Mango/v0.27.0/README.md
- https://raw.githubusercontent.com/getmango/Mango/v0.27.0/LICENSE
- https://raw.githubusercontent.com/getmango/Mango/v0.27.0/src/config.cr (options, env rule, defaults, missing-file behaviour)
- https://raw.githubusercontent.com/getmango/Mango/v0.27.0/src/storage.cr (first-start admin)
- https://raw.githubusercontent.com/getmango/Mango/v0.27.0/Dockerfile.arm64v8 (arm64 build, plan's arm64 note)
- Release asset URLs (direct downloads, not fetched): `https://github.com/getmango/Mango/releases/download/v<V>/mango` (amd64 static binary per plan), `.../mango-arm64v8.o`, `.../mango-arm32v7.o` (per plan; not confirmed on release page)
- Fetched 2026-11-26

## Status
- Repo archived by its owner on 23 Mar 2025, now read-only. README says the project is no longer maintained (as of March 2025).
- Final repo name getmango/Mango (old `hkalexling/mango` redirect; see github-hkalexling-mango.md).
- Release v0.27.0 is marked **Latest** (31 Jul, year not shown; published by hkalexling). Commit `1fb48648...` (short `1fb4864`). No pre-release label. Release page says "Assets 5" but the list did not load; no digests shown.

## What it is
"Mango is a self-hosted manga server and web reader." Multi-user, OPDS, dark/light mode, reading progress, thumbnail generation, mobile reader. Formats `.cbz`, `.zip`, `.cbr`, `.rar`. Nested library folders. Plugins (separate mango-plugins repo). Static files embedded in the binary.

## Install/build steps
- Pre-built binary: download `mango` from the latest release. "Dependencies are statically linked, and it should work on most Linux systems on amd64."
- Docker Hub: `hkalexling/mango` (official images).
- Build from source: requires `crystal`, `shards`, `yarn` and library headers; `make && sudo make install`.
- Upstream Dockerfile (`hkalexling/mango` at 7a7d9eb, see github-hkalexling-mango.md) builds with crystal 1.0.0 alpine, `make static`.
- arm64: `Dockerfile.arm64v8` (v0.27.0) verbatim logic:
  - `FROM arm64v8/ubuntu:18.04`
  - apt install of wget, git, make, llvm-8, llvm-8-dev, g++, libsqlite3-dev, libyaml-dev, libgc-dev, libssl-dev, libcrypto++-dev, libevent-dev, libgmp-dev, zlib1g-dev, libpcre++-dev, pkg-config, libarchive-dev, libxml2-dev, libacl1-dev, nettle-dev, liblzo2-dev, liblzma-dev, libbz2-dev, libjpeg-turbo8-dev, libpng-dev, libtiff-dev (other apt packages unpinned).
  - Clones and builds: crystal-lang/crystal at tag `1.0.0` (`make deps`); kostya/myhtml `v1.5.8`; jessedoyle/duktape.cr `v1.0.0`; hkalexling/image_size.cr `v0.5.0`.
  - `COPY mango-arm64v8.o .` then a `cc` link command into `/usr/local/bin/mango` against those libraries (libxml2, libwebp, libstbi, libmodest, libduktape, libarchive, libssl/libcrypto, gmp, sqlite3, yaml, pcre, gc, event).
  - `CMD ["/usr/local/bin/mango"]`; no ENV/ARG/VOLUME/USER/EXPOSE; runs as root.

## Runtime deps
Statically linked binary for the amd64 release (no extra runtime libraries per README). The arm64 `.o` route needs the libraries listed above at link time.

## Binaries/entrypoint/CLI flags
- `mango [sub_command] [options]`
  - `-c PATH`, `--config=PATH`: config file path.
  - `-h, --help`; `-v, --version`.
  - Sub command `admin`: admin tools.
- Upstream Dockerfile: `CMD ["/usr/local/bin/mango"]`.

## Env vars
- README documents none (only a `.env` file for docker-compose via `env.example`).
- Code (`src/config.cr`): each option is read from an env var named with the option name in uppercase (e.g. `PORT` for `port`). Strings use the env var or default; numbers `.to_i`; booleans via `env_is_true?`. Precedence per code comment: "config file > environment variable > default value".
- `CONFIG_PATH` env: used by `load` as the config path when set; otherwise `~/.config/mango/config.yml`.

## Config file and defaults (src/config.cr, OPTIONS)
| Option | Default |
| --- | --- |
| `host` | `0.0.0.0` |
| `port` | `9000` |
| `base_url` | `/` (must start with `/`; trailing `/` appended) |
| `session_secret` | `mango-session-secret` |
| `library_path` | `~/mango/library` |
| `library_cache_path` | `~/mango/library.yml.gz` |
| `db_path` | `~/mango.db` |
| `queue_db_path` | `~/mango/queue.db` |
| `scan_interval_minutes` | `5` (0 disables) |
| `thumbnail_generation_interval_hours` | `24` (0 disables) |
| `log_level` | `info` (`debug`, `info`, `warn`, `error`, `fatal`, `off`) |
| `upload_path` | `~/mango/uploads` |
| `plugin_path` | `~/mango/plugins` |
| `download_timeout_seconds` | `30` |
| `cache_enabled` | `true` (experimental) |
| `cache_size_mbs` | `50` |
| `cache_log_enabled` | `true` |
| `disable_login` | `false` (requires `default_username` to be an existing user) |
| `default_username` | `""` |
| `auth_proxy_header_name` | `""` |
| `plugin_update_interval_hours` | `24` (0 disables) |
- Format: YAML. Paths with leading `~` expand to `$HOME` (`File.expand_path home: true`) for library_path, library_cache_path, db_path, queue_db_path, upload_path, plugin_path, and the config path.
- Missing config file: prints a message, creates the directory (`Dir.mkdir_p`), writes the default config (`default.to_yaml`) to the file, prints a confirmation.

## First start (src/storage.cr)
- After migrations, if the users table is empty, creates user `admin` with a random password (`random_str`), bcrypt-hashed, admin flag 1.
- Logs in plaintext: "Initial user created. You can log in with ..." with `"username" => "admin"` and `"password" => ...`.
- The user insert writes no files; SQLite DB file is created/migrated by the constructor; missing DB directory is created with `Dir.mkdir_p`.

## Ports
9000/tcp. Compose sample maps `9000:9000`.

## Volumes/paths and persistent data
- Defaults are all under `~/mango/` (`library`, `queue.db`, `library.yml.gz`, `uploads`, `plugins`) except `db_path` (`~/mango.db`) and config (`~/.config/mango/config.yml`).
- Compose sample (Docker Hub page): `~/mango:/root/mango` and `~/.config/mango:/root/.config/mango`.

## User/UID & permissions
- Upstream Docker image runs as root (no USER). Upstream README: "files in them are owned by root" for the compose directories.

## Healthcheck/readiness endpoints
None documented. Port 9000 serves the login page.

## Login
- First run logs a default username and a random password to STDOUT. Change it right away (README).
- Login may be disabled with `disable_login: true` plus `default_username`.

## Platform / architecture
- README: pre-built binary is Linux, amd64 only as stated. No arm/arm64 statement.
- Release asset list (per plan): `mango` (amd64) plus `mango-arm64v8.o`, `mango-arm32v7.o`. Not confirmed on the release page (asset list did not load). UNVERIFIED.

## Version/release info and asset naming
- Latest tag `v0.27.0`. CLI version string `0.27.0`.
- Asset naming: `mango` (amd64 binary, direct download), `mango-arm64v8.o` (object file for arm64 build, per plan). Checksums not published on the page.

## License
MIT License. LICENSE: "The MIT License (MIT)", "Copyright (c) 2020 Alex Ling".

## Gotchas
- Config file, once written, overrides env values on later starts (config file > env > default). Written config includes `session_secret`.
- `base_url` must start with `/`.
- `disable_login: true` needs an existing `default_username`.
- Repo is archived; v0.27.0 (2022) is the last release.

## Contradictions with plan.md
- Plan section 1 says the Docker Hub `latest` and `v0.27.0` are the same version. Hub page lists only `latest` (digest `sha256:14b5e1dd...`). The `v0.27.0` tag was not visible. UNVERIFIED.
- Plan section 1 says the arm64 release only has `mango-arm64v8.o` and `mango-arm32v7.o`. Asset list did not load. UNVERIFIED.
- Plan section 10 says "`LIBRARY_PATH` is also the name of a GCC build-time variable". Not in any fetched source (general knowledge). Not checked.
