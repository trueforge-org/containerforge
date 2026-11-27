# Necesse upstream sites (wiki + game site)

Source URL(s) + date: https://necessewiki.com ; https://necessewiki.com/Multiplayer ; https://necessegame.com (fetched 2026-11-27)

## What it is
- Necesse: game by Fair Games ApS (copyright line on site; publisher not labeled). Steam app 1169370.
- Steam is the only platform linked. Store page: https://store.steampowered.com/app/1169370 (not fetched).
- Site: "Host a dedicated server ..." and links to a server files page (https://necessegame.com/server/, not fetched).

## Install (SteamCMD)
- App ID 1169370. Steps: `login anonymous` -> `force_install_dir <path>` -> `app_update 1169370 validate` -> `quit`.
- Also listed as "Necesse Dedicated Server" tool in the Steam library.

## Launch (server binary, Windows-oriented wiki)
- Windows: run StartServer.bat in install folder; opens console. Stop by typing `quit`.
- Startup prompts: world name, custom options, host port, slots, password, spawn island, seed, guide house.
- Flags (`-nogui` = terminal mode):
  - -help, -nogui, -settings <file>, -world <name>, -port <port>, -slots <n>, -owner <name>, -motd <msg>, -password <pw>, -pausewhenempty <1/0>, -giveclientspower <1/0>, -logging <1/0>, -logs <folder>, -zipsaves <1/0>, -language <lang>, -ip <addr>, -datadir <path>, -localdir, -ignoreseasons
- Flags not supplied are read from the server settings file.
- -localdir: configs and saves go in the directory the server starts from.

## Network
- Protocol UDP, default port 14159. Inbound UDP must be open.
- Clients add server by public IPv4 + port.

## Files / paths (Windows defaults; Linux guide exists, not fetched)
- Server settings: server.cfg in ...\Necesse\cfg (cfg dir under AppData\Roaming\Necesse).
- World settings: worldSettings.cfg inside saves zip `...\Necesse\saves\<WorldName>.zip`.
- Saves: `.zip` per world in `...\Necesse\saves\`.
- Logs: `...\Necesse\logs`.
- Stop server before editing configs.

## Settings
- World name: prompt or -world. Password: prompt, -password, or in-game `/password [pw]` (owner). Slots: 1-250 via prompt or -slots.
- Owner perms: -owner <name> or `/permissions set <name> <permission>`.

## Gotchas
- Wiki main page has no server setup details; Multiplayer page is the source for the above.
- Default game port UDP 14159 matches chart's udpgameport; chart's TCP 9023->8080 mapping is not documented by these sources.
