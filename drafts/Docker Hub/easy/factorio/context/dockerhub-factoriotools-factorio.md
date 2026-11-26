# factoriotools/factorio (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/factoriotools/factorio
- Fetched 2026-11-26

**What it is**
Dedicated Factorio server image. Server only; the game must be bought separately.

**Tags**
- `latest` and `2.1.24` are listed on the page.
- Documented patterns: `stable`, `stable-x.y.z`, `0.x`, `0.x.y`, `0.x-z`. Rootless variants end in `-rootless`.
- The listed latest tag digest starts `sha256:69d0bb4e0...`, about 123.3 MB. Last pushed about 10 days before fetch.
- `2.1.25` is not shown in the fetched listing (the page lists only a recent tag, so this is not proof it is missing).

**Architectures**
Not listed. The page notes that Factorio 2.1+ has a native arm64 build; older versions use x64 under box64.

**Run/quick start**
`docker run -d -p 34197:34197/udp -p 27015:27015/tcp -v /opt/factorio:/factorio --name factorio --restart=unless-stopped factoriotools/factorio` after `chown 845:845 /opt/factorio`.

**Env vars (listed on page)**
`PUID`/`PGID` (845), `GENERATE_NEW_SAVE` (false), `LOAD_LATEST_SAVE` (true), `SAVE_NAME` (`_autosave1`), `PRESET`, `PORT` (34197 UDP), `BIND`, `RCON_PORT` (27015), `TOKEN`/`USERNAME` (mod updates), `UPDATE_MODS_ON_START`, `UPDATE_IGNORE`, `CONSOLE_LOG_LOCATION`, `DLC_SPACE_AGE` (true), `MODS`, `SERVER_SETTINGS_FILE`, `SERVER_ID_FILE`, `SERVER_ADMINLIST_FILE`, `SERVER_BANLIST_FILE`, `SERVER_WHITELIST_FILE`.

**Ports**
34197/udp (game, required) and 27015/tcp (RCON, optional).

**Volumes**
Single `/factorio` volume.

**Source link**
https://github.com/factoriotools/factorio-docker

**Contradictions with plan.md**
- plan.md section 1 says Docker Hub has `2.1.25` and `-rootless` and `stable-*` variants. The fetched page confirms the variant patterns and shows `2.1.24`, not `2.1.25`. Unverified for 2.1.25.
