# GitHub: OpenRA/OpenRA launch-dedicated.sh (bleed branch) + latest release
Source URL(s): https://raw.githubusercontent.com/OpenRA/OpenRA/bleed/launch-dedicated.sh ; https://api.github.com/repos/OpenRA/OpenRA/releases/latest (fetched 2026-11-27)

## Entrypoint/flags (script variables, default in brackets)
| Var | Default | Maps to |
| --- | --- | --- |
| Name | "Dedicated Server" | Server.Name |
| Mod | ra | Game.Mod |
| Map | "" | Server.Map |
| ListenPort | 1234 | Server.ListenPort |
| AdvertiseOnline | True | Server.AdvertiseOnline |
| AdvertiseOnLocalNetwork | True | Server.AdvertiseOnLocalNetwork |
| Password | "" | Server.Password |
| RecordReplays | False | Server.RecordReplays |
| RequireAuthentication | False | Server.RequireAuthentication |
| ProfileIDBlacklist / ProfileIDWhitelist | "" | Server.* |
| EnableSingleplayer | False | Server.EnableSingleplayer |
| EnableSyncReports | False | Server.EnableSyncReports |
| EnableGeoIP | True | Server.EnableGeoIP |
| EnableLintChecks | True | Server.EnableLintChecks |
| ShareAnonymizedIPs | True | Server.ShareAnonymizedIPs |
| FloodLimitJoinCooldown | 5000 | Server.FloodLimitJoinCooldown |
| SupportDir | "" | Engine.SupportDir |

- Runs `dotnet ${ENGINEDIR}/bin/OpenRA.Server.dll Engine.EngineDir=".." ...` inside `while true` loop (restarts on exit)
- Note: this is the bleed branch script (dotnet). The image's pinned 20231010 build uses mono; the script shipped in the release tarball may differ. Not verified against release-20231010.

## Latest release (API)
- tag release-20250330, published 2025-03-30, not prerelease
- Assets: OpenRA-release-20250330-source.tar.bz2, AppImages (Red Alert, Dune 2000, Tiberian Dawn), winportable zips, dmg
