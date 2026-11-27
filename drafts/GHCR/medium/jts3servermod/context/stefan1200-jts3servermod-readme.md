# Upstream docs: JTS3ServerMod Readme (Stefan1200)

Source URL(s) + date: https://www.stefan1200.de/documentation/jts3servermod/readme.html (fetched 2026-11-27). Forum topic https://www.stefan1200.de/forum/index.php?...topic=2.0 not fetched (forum thread, not install docs).

## What it is
- Java TeamSpeak 3 server mod/bot. Standalone; connects to the TS3 telnet ServerQuery port, does not need to run in the TS3 server directory.
- Features: inactive client cleaner, chat commands, multiple bot instances per process, auto-reconnect, plugins (Java).

## Runtime deps
- Java SE runtime 8 or newer (8 recommended). Avoid gcj-jre and preview/alpha Java.
- TS3 server 3.0 or newer.
- Runs headless on Linux (no X server needed).

## Launch
- `java -jar JTS3ServerMod.jar` (config dir with JTS3ServerMod_InstanceManager.cfg beside the jar).
- `-config <path>` and `-log <path>` to change the InstanceManager cfg/log locations.
- `-Dapp.home=PATH` sets `%apphome%` in config/log paths.
- Heap limit recommended: `java -mx30M -jar JTS3ServerMod.jar` (for small VPS; upstream says low RAM use if client DB cache disabled and one instance).

## Config files
- `JTS3ServerMod_InstanceManager.cfg`: lists bot instances; one config per instance (copy `server1` dir to `server2`, edit path).
- `JTS3ServerMod_server.cfg`: per-instance bot settings. Full detail in ConfigHelp.html (not fetched).

## TS3 server side
- Bot IP must be whitelisted in TS3 `query_ip_whitelist.txt`, otherwise ServerQuery error 3331 (flood ban).
- Alternative: `bot_slowmode` 1 in server cfg (slows connection, disables some features).
- Query account needs permissions listed in the docs (serveradmin account has all).

## Gotchas
- Config files default to unicode (no BOM).
- Poke message max 100 characters (TS3 limit).
