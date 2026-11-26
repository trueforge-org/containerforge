# jsavargas/telethon_downloader (application source)

**Source URL(s) + fetch date**
- https://github.com/jsavargas/telethon_downloader (repo root, default branch `main`)
- https://raw.githubusercontent.com/jsavargas/telethon_downloader/ed9710a358ef6da97107073e64e6ae66e6ac2aff/Dockerfile (fetched 2026-11-26)
- https://github.com/jsavargas/telethon_downloader/blob/HEAD/requirements.txt (fetched via raw `main` README and pinned commit file)
- https://raw.githubusercontent.com/jsavargas/telethon_downloader/ed9710a358ef6da97107073e64e6ae66e6ac2aff/requirements.txt (fetched 2026-11-26)
- https://raw.githubusercontent.com/jsavargas/telethon_downloader/ed9710a358ef6da97107073e64e6ae66e6ac2aff/src/env_config.py (fetched 2026-11-26)
- https://raw.githubusercontent.com/jsavargas/telethon_downloader/ed9710a358ef6da97107073e64e6ae66e6ac2aff/src/app.py (fetched 2026-11-26)
- https://raw.githubusercontent.com/jsavargas/telethon_downloader/ed9710a358ef6da97107073e64e6ae66e6ac2aff/License.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/jsavargas/telethon_downloader/main/README.md (fetched 2026-11-26)
- https://github.com/jsavargas/telethon_downloader/releases (fetched 2026-11-26)

**What it is**
A Telegram bot built on the Telethon client. It downloads media files sent to the bot, fetches YouTube video/audio and direct-URL files, and hands `.torrent` files to qBittorrent or a watch folder. Files are sorted by extension, group/channel ID, keywords or regex. The bot is controlled through Telegram. It opens no listening socket.

**Install/build steps and build deps (upstream Dockerfile at ed9710a)**
- `FROM python` (no tag), `WORKDIR /app`
- `COPY requirements.txt requirements.txt`
- `apt-get update && apt-get -qy dist-upgrade && apt-get install -qy --no-install-recommends ffmpeg unzip`, then `rm -rf /var/lib/apt/lists/*`
- `python3 -m pip install --no-cache-dir --upgrade pip` and `python3 -m pip install -r requirements.txt`
- `COPY src .` (so `app.py` and the modules land in `/app`)
- `RUN chmod +x /app/app.py`

**Runtime deps**
- Python packages (requirements.txt, all unpinned): `telethon`, `yt-dlp`, `qbittorrent-api`, `aiohttp`
- System: `ffmpeg` (apt). `unzip` is also installed upstream.

**Binaries/entrypoint/CLI flags**
- `ENTRYPOINT ["python", "app.py"]`
- Source files in `src/` include `app.py` (entry point, `VERSION = "4.0.15"`), `env_config.py`, `config_manager.py` and downloader modules (not individually fetched).
- No CLI flags.

**Env vars** (from `src/env_config.py`; alias applies when the primary is empty)

| Variable (primary) | Alias | Default | Notes |
|---|---|---|---|
| `API_ID` | `TG_API_ID` | empty | required by `validate_env` |
| `API_HASH` | `TG_API_HASH` | empty | required by `validate_env` |
| `BOT_TOKEN` | `TG_BOT_TOKEN` | empty | required by `validate_env` |
| `AUTHORIZED_USER_ID` | `TG_AUTHORIZED_USER_ID` | empty | required; comma-separated chat IDs |
| `TG_DOWNLOAD_PATH` | `DOWNLOAD_PATH` | `/download` | base download path |
| `DOWNLOAD_PATH_TORRENTS` | none | `/watch` | torrent watch folder |
| `YOUTUBE_VIDEO_FOLDER` | none | `<base>/youtube/videos` | via `os.path.join` |
| `YOUTUBE_AUDIO_FOLDER` | none | `<base>/youtube/audios` | via `os.path.join` |
| `YOUTUBE_FORMAT_VIDEO` | none | `bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best` | |
| `YOUTUBE_FORMAT_AUDIO` | none | `bestaudio/best` | |
| `PATH_CONFIG` | none | `/config/` | `os.makedirs(PATH_CONFIG, exist_ok=True)` at init |
| `PUID` | none | empty | read but not used for privilege drop in the code fetched |
| `PGID` | none | empty | same as PUID |
| `YTDLP_VERSION` | none | `N/A` | |
| `TG_PROGRESS_DOWNLOAD` | `PROGRESS_DOWNLOAD` | `True` | |
| `PROGRESS_STATUS_SHOW` | none | `10` | |
| `TG_MAX_PARALLEL` | `MAX_CONCURRENT_TASKS` | `4` | |
| `YOUTUBE_TIMEOUT_OPTION` | none | `5` | converted with `int()` |
| `YOUTUBE_DEFAULT_DOWNLOAD` | none | `video` | lowercased |
| `TORRENT_MODE` | none | `watch` | lowercased; `qbittorrent` or `watch` |
| `QBT_HOST` | none | empty | qBittorrent Web UI host |
| `QBT_PORT` | none | `8080` | |
| `QBT_USERNAME` | none | empty | |
| `QBT_PASSWORD` | none | empty | |

Also named in the GitHub README but NOT read by `env_config.py` (not verified in code): `TG_DL_TIMEOUT` (default 3600), `PERMISSIONS_FOLDER` (777), `PERMISSIONS_FILE` (755), `YOUTUBE_DEFAULT_EXTENSION` (MKV), `YOUTUBE_SHOW_OPTION` (True), `YOUTUBE_LINKS_SUPPORTED`, `TZ`.

**Ports**
None. `app.py` creates no HTTP server or listening socket. The GitHub README documents no ports, and its compose example uses `network_mode: host`.

**Volumes/paths and persistent data**
- `/config`: `config.ini`, `download_files.json`, `pending_messages.json`, `/config/locale` templates (per README). `PATH_CONFIG` is created at startup.
- `/download`: download destination.
- `/watch`: torrent files for watch mode (also read by the Docker Hub compose example as the Transmission watch folder).
- `/youtube`: used in the GitHub compose example only.
- The Telethon bot session is `TelegramClient('bot', ...)`, so `bot.session` is written to the **current working directory** (not `/config`).
- Downloads are kept in a temporary location until complete (README).

**User/UID & permissions**
- No USER directive upstream: the image runs as root.
- `PUID`/`PGID` are read from env only. The compose examples set them (1000 on Docker Hub, 99/100 on GitHub). No privilege-drop code was seen in the fetched files.
- `app.py` calls `os.makedirs` for browsed folders and applies permissions/ownership in `_handle_add_path_new_folder_name` (per fetched code).

**Config files and formats**
- `config.ini` (in `PATH_CONFIG`, handled by `ConfigManager`, not fetched). Rule order: KEYWORDS, GROUP_PATH, REGEX_PATH, EXTENSIONS. Sections: `[EXTENSIONS]` (e.g. `mp4 = /download/mp4`), `[GROUP_PATH]`, `[KEYWORDS]`, `[REGEX_PATH]` (e.g. `/Halo/i = ...`), `[REMOVE_PATTERNS]`.
- No config file is required to start.

**Healthcheck/readiness endpoints**
None. No HTTP endpoint exists.

**Startup behaviour and login (verified in app.py)**
- If `validate_env()` fails, the app logs `Please set the environment variables API_ID, API_HASH, BOT_TOKEN, and AUTHORIZED_USER_ID.` and calls the builtin `exit(1)`.
- `env_config.validate_env()` itself returns False silently (no log), so the log and exit are in `app.py`.
- Client: `TelegramClient('bot', API_ID, API_HASH)`, login with `await self.bot.start(bot_token=BOT_TOKEN)`. No phone-code or 2FA login.
- After login the bot sends a welcome message to the first authorized user and calls `run_until_disconnected()`.

**Version/release info and asset naming**
- `VERSION = "4.0.15"` in `src/app.py` at commit `ed9710a`.
- GitHub releases page: "There aren't any releases here." No release assets. Git tags page not fetched (the repo has a Tags link; plan.md says only `v3.1.9` and older exist; UNVERIFIED here).
- The GitHub README's "Latest" note says 4.0.13 (2025-12-05), which is older than the 4.0.15 in code, so the README is stale.
- Source archive `archive/refs/heads/master.zip` exists but is a direct archive download and was not fetched.

**Arch support**
Not stated in the upstream README. Pure Python, so no native build is needed in the app code. The Docker Hub page lists no architectures.

**Licence**
- `License.md`: GNU GPL version 3 (full text). The file does not say "only" or "or-later"; that is set in each source file's notice, which was not fetched. UNVERIFIED for `-only` vs `-or-later`.

**Gotchas**
- README and code disagree on env names: the README's GitHub compose uses `API_ID`, `API_HASH`, `BOT_TOKEN`, `AUTHORIZED_USER_ID`; the README's variable list and Docker Hub compose use the `TG_` names. The code accepts both.
- `TG_DL_TIMEOUT` and `PERMISSIONS_FOLDER`/`PERMISSIONS_FILE` appear in the README but are not read by `env_config.py`.
- `bot.session` lands in the working directory, not in `/config`.
- The image runs as root upstream; `ffmpeg` and `unzip` are installed with `dist-upgrade`.

**plan.md consistency**
- Matches: no ports; env var names and defaults; bot-token login (not phone login); `bot.session` in cwd; `exit(1)` without credentials; `VERSION = "4.0.15"`; Python deps; VOLUME list; pinned `ed9710a` Dockerfile.
- Contradiction: the Docker Hub page (fetched) shows only a `latest` tag and no `4.0.15` tag, so plan.md's claim that the `4.0.15` tag exists is not confirmed by this fetch (its digest equals the `latest` digest).
