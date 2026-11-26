# Steam store page for app 1690800 (Satisfactory Dedicated Server)

Source URL(s) + fetch date:
- https://store.steampowered.com/app/1690800/Satisfactory_Dedicated_Server/ (fetched 2026-11-26)
- https://store.steampowered.com/app/1690800/ (retry, fetched 2026-11-26)

## Result
FETCH FAILURE. Both URLs returned the Steam storefront home page, not the app page. No app name, OS support, system requirements or depot info could be read.

## What this leaves unverified
- Linux depot is x86_64 only (plan.md claim, not checked here).
- Game is proprietary, Coffee Stain (plan.md claim, not checked here).

## Install/build steps / runtime deps / ports / volumes
Not available from this source. Dedicated server install details come from the wrapper scripts (see github-wolveix-satisfactory-server.md): `steamcmd +app_update 1690800`.
