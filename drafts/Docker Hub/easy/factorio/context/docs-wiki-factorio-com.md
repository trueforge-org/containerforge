# Factorio Wiki: command-line parameters and server docs

**Source URL(s) + fetch date**
- https://wiki.factorio.com/ (main page; draft's documentation link)
- https://wiki.factorio.com/Command_line_parameters (followed one level, relevant to server flags)
- Linked but not fetched (named in the main page): https://wiki.factorio.com/Multiplayer, https://wiki.factorio.com/Application_directory
- Fetched 2026-11-26

**What it is**
Official Factorio wiki, about 5,284 articles, based on version 2.1 (latest stable 2.1.25).

**Binaries/entrypoint/CLI flags (Command_line_parameters)**

Server and hosting:
- `--start-server FILE`: start a headless multiplayer server from that save.
- `--start-server-load-latest`: start from the newest save.
- `--port N`: network port.
- `--bind ADDRESS[:PORT]`: IP (and optional port) to bind.
- `--rcon-port N`: RCON port.
- `--rcon-password PASSWORD`: RCON password.
- `--server-settings FILE`
- `--server-banlist FILE`
- `--server-whitelist FILE`
- `--use-server-whitelist BOOL`: takes a boolean, written `=true` or `=false`.
- `--server-adminlist FILE`
- `--server-id FILE`

Map creation:
- `--create FILE`: create a new map.
- `--map-gen-settings FILE` (for `--create`, `--start-server-load-scenario`, `--generate-map-preview`).
- `--map-settings FILE` (for `--create`, `--start-server-load-scenario`).
- `--preset arg`: map generation preset.

General:
- `--config PATH` (or `-c`): config file.
- `--mod-directory PATH`.

Not stated on the page: default write-data and read-data locations (page links to a "User data directory" page, not fetched in full).

**Multiplayer and application directory (main page links)**
- Multiplayer and Application_directory pages are linked from the wiki main page; not fetched. Install guide and FAQ are also linked.
- The main page does not link to a dedicated headless server page.

**Contradictions with plan.md**
- plan.md section 1 lists these flags, matching the wiki. It writes `--use-server-whitelist` without a value in its start.sh; the wiki documents it as taking a BOOL (`=true`/`=false`). The upstream image's entrypoint passes it bare, so this is left unedited and listed as unverified.
- plan.md section 7 says the default write-data path is the install dir (`__PATH__executable__/../..`) and relies on read-data `../../data`. The wiki page did not confirm these defaults. Unverified.
