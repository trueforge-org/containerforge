# Qolors/FeedCord (Dockerfile + README)

Source URL(s): https://github.com/Qolors/FeedCord ; https://github.com/Qolors/FeedCord/blob/c9568b968505c2979b5123f9d84262fe0d65dd85/FeedCord/Dockerfile (raw variant fetched) ; https://raw.githubusercontent.com/Qolors/FeedCord/master/README.md (main branch 404, master used) ; https://hub.docker.com/r/qolors/feedcord (not fetched)
Date: fetched 2026-11-26

## What it is
- Self-hosted RSS/Atom + YouTube reader that posts updates to Discord webhooks (incl. Forum channels). Multiple instances per config. Latest in changelog: 3.0.0 (2025-02-10).

## Build (Dockerfile @ c9568b9, dir FeedCord/)
- Stage build: `FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build`, WORKDIR `/src`, COPY `FeedCord.csproj`, then `src` -> `./src`.
  - RUN `dotnet restore && dotnet build -c Release -o /app/build && dotnet publish -c Release -o /app/publish`
- Stage final: `FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final`, WORKDIR `/app`, `COPY --from=build /app/publish .`
- `ENTRYPOINT ["dotnet", "FeedCord.dll"]`
- No ARG, ENV, USER, EXPOSE, VOLUME, CMD, HEALTHCHECK. No package installs.

## Runtime deps
- .NET 9.0 runtime (aspnet image). Outbound HTTPS to Discord webhook and feed hosts.

## Entrypoint/flags
- `dotnet FeedCord.dll` (config path given as argument when run from source: `dotnet run -- <path to appsettings.json>`).

## Env vars
- None documented (configuration is file-based).

## Ports
- None.

## Volumes/paths
| Path | Use |
| --- | --- |
| `/app/config/appsettings.json` | config file (Docker docs: mount host file here) |

## Config (appsettings.json)
- Top level: `Instances` (array), `ConcurrentRequests` (example 40).
- Per instance (example values): `Id`, `YoutubeUrls` (list), `RssUrls` (list), `Forum` (false), `DiscordWebhookUrl`, `RssCheckIntervalMinutes` (25), `EnableAutoRemove` (false), `Color` (8411391), `DescriptionLimit` (250), `MarkdownFormat` (false), `PersistenceOnShutdown` (true).
- README says 17 properties total; full reference in docs/reference.md (not fetched). Required vs optional not stated; changelog says some became optional in 2.0.0 and YouTube URLs are optional.
- YouTube: channel home URLs accepted; more reliable form `https://www.youtube.com/feeds/videos.xml?channel_id=...`.

## User/UID
- No USER instruction: runs as image default (root unless base sets otherwise).

## Gotchas
- Discord posting has fixed 10 s buffer (added 2.1.0).
- Config must be mounted; no default config is shipped.
- License not stated in README.
