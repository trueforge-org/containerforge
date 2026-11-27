# Vintage Story wiki: Server Config (serverconfig.json)

Source URL(s) + date: https://wiki.vintagestory.at/index.php/Server_Config (HTML fetched 2026-11-27; text extracted; page is MediaWiki, 200)

## Config file
- Server config file: `serverconfig.json` (Linux path example `/home/user/.config/VintagestoryData/...`).
- Secondary file: `servermagicnumbers.json`.

## Keys (from example config, version "1.10")
| Key | Example value | Note |
| --- | --- | --- |
| ConfigVersion | "1.10" | |
| ServerName | "Vintage Story Server" | |
| Port | 42420 | listen port |
| MaxClients | 16 | |
| MaxClientsInQueue | 0 | |
| Password | null | if not null, requires password |
| StartupCommands | "/time \n /info seed" | |
| WorldConfig.Seed | null | string seed, not guaranteed reproducible |
| WorldConfig.WorldName | "A new world" | |
| WorldConfig.SaveFileLocation | /home/user/.config/VintagestoryData/Saves/default.vcdbs | |
| WorldConfig.CreatedByPlayerName | null | |
| WorldConfig.WorldConfiguration | {} object | world settings (see World_Configuration page, not fetched) |

- Roles array: entries with `Name` (Survival Visitor, Creative Visitor, Limited Survival/Creative Player, Survival/Creative Player, Survival/Creative Moderator, Admin).
- Mods path example: `/home/user/.config/VintagestoryData/Mods`.

## Gotchas
- Page shows a config version "1.9" in one example and "1.10" in the full sample; use the version the server writes.
