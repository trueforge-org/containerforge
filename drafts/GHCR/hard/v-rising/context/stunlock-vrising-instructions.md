# V Rising dedicated server instructions (v1.1.x PC)

Source URL(s) + date: https://raw.githubusercontent.com/StunlockStudios/vrising-dedicated-server-instructions/master/1.1.x-pc/INSTRUCTIONS.md (fetched 2026-11-27)

## What it is
- Official Stunlock doc for the Windows-only V Rising dedicated server (1.1.x). Linux runs via SteamCMD/Wine in the container.

## Download
- SteamCMD AppID for server: `1829350` (default branch). Runs with client AppID from `steam_appid.txt`.
- Update: rerun download (offline server), verifies/updates.

## Run
- Executable: `VRisingServer.exe` (Windows). Example scripts `start_server_example.bat` / `download-default.bat` (not fetched).
- Settings: `ServerHostSettings.json`, `ServerGameSettings.json`.
- Defaults read from `VRisingServer_Data/StreamingAssets/Settings/`; local overrides from persistent path.
- `-persistentDataPath <path>`: settings go in `<path>/Settings`, saves in `<path>/Saves`. Recommended; required for multiple servers per host.

## ServerHostSettings.json (keys used by container)
| Key | Meaning | Env / CLI override |
| --- | --- | --- |
| Name | server list name | VR_NAME, VR_SERVER_NAME, -serverName |
| Port | UDP game port (example 27015) | VR_GAME_PORT, -gamePort |
| QueryPort | UDP Steam query (example 27016) | VR_QUERY_PORT, -queryPort |
| Password | server password | (see doc) |
| SaveName | save dir name | VR_SAVE_NAME, -saveName |
| AutoSaveCount | number of autosaves kept | |
| AutoSaveInterval | autosave interval | |
| AutoSaveSmartKeep | `A:B:C,...` retention format | |
| Rcon.Enabled / Port (example 25575, TCP) / Password / BindAddress | RCON | VR_RCON_PORT, VR_RCON_PASSWORD, VR_RCON_BIND_ADDRESS |

- Other keys: Description, Address, HideIPAddress, MaxConnectedUsers, MaxConnectedAdmins, ServerFps, LowerFPSWhenEmpty(+Value), Secure, ListOnEOS, ListOnSteam, GameSettingsPreset, GameDifficultyPreset, LanMode, ResetDaysInterval, DayOfReset, SafeReconnectTime, SafeReconnectSlots.
- Override precedence: env var (System, User, Process) or CLI param; env form `VR_<KEY>`.

## Saves
- Default Windows path `%USERPROFILE%\AppData\LocalLow\Stunlock Studios\VRisingServer\Saves`; relocated by `-persistentDataPath`.

## Gotchas
- Ports must be open for server list: both QueryPort and Port.
- Restart server daily recommended by upstream.
- Example port values in doc are 27015/27016, not the chart's 9876/9877.
