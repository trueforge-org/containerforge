# revenz/Fenrus (Dockerfile + README)

Source URL(s): https://github.com/revenz/Fenrus ; https://github.com/revenz/Fenrus/blob/fc8f57ac9d5643d16f7d8427f8341397e645f501/Dockerfile (raw variant fetched) ; https://raw.githubusercontent.com/revenz/Fenrus/master/README.md ; https://hub.docker.com/r/revenz/fenrus (not fetched)
Date: fetched 2026-11-26

## What it is
- Self-hosted personal home page / new-tab dashboard for own apps. .NET app; Docker preferred.
- Item types: links, basic apps, smart apps, links to other dashboards. Custom search engines.

## Build (Dockerfile @ fc8f57a)
- Single stage: `FROM mcr.microsoft.com/dotnet/aspnet:10.0`
- WORKDIR `/app`; ENV `Docker=1`; no ARG.
- COPY `./build` -> `./`; `/Apps` -> `/app/Apps`; `/reset.sh` -> `/app/reset.sh`; `/docker-entrypoint.sh` -> `/app/docker-entrypoint.sh`.
- RUN: chmod +x reset.sh and docker-entrypoint.sh; `/bin/sh` symlinked to `/bin/bash`. No packages installed.
- `ENTRYPOINT ["/app/docker-entrypoint.sh"]`. No CMD, EXPOSE, VOLUME, HEALTHCHECK, USER (runs as base default).

## Runtime deps
- ASP.NET Core 10.0 runtime (aspnet image). Dotnet run form: `dotnet Fenrus.dll` (needs ASP.NET Core Runtime 10.0).

## Entrypoint/flags
- `/app/docker-entrypoint.sh`. Dotnet direct: `dotnet Fenrus.dll --urls=http://*:1234`.

## Env vars
| Var | Default | Meaning |
| --- | --- | --- |
| TZ | (unset; example Pacific/Auckland) | timezone |
| PORT | 3000 (Docker) | listen port |
| ReverseProxySettings__UseForwardedHeaders | false | honour forwarded headers |
| ReverseProxySettings__DebugPrintRequestHeaders | false | debug header print |
| ReverseProxySettings__KnownProxies | [] | known proxy list |
| ReverseProxySettings__KnownIPv4Network__Enabled | true | |
| ReverseProxySettings__KnownIPv4Network__IpAddress | "10.0.0.0" | |
| ReverseProxySettings__KnownIPv4Network__PrefixLength | 8 | |
| ReverseProxySettings__KnownIPv6Network__Enabled | true | |
| ReverseProxySettings__KnownIPv6Network__IpAddress | "fe80::" | |
| ReverseProxySettings__KnownIPv6Network__PrefixLength | 64 | |

- Proxy settings have no effect unless UseForwardedHeaders=true. Behind OAuth proxy pass X-Forwarded-Proto and X-Forwarded-For.

## Ports
- 3000/tcp (Docker default; `-p 3000:3000`), overridable via PORT.

## Volumes/paths
| Path | Use |
| --- | --- |
| `/app/data` | all user config; LiteDB `Fenrus.db` plus encryption key file alongside it |

## User/UID
- Not set in Dockerfile (base default).

## Config
- No default user. First registration on login page becomes admin. Open registrations can be disabled under "System".

## Healthcheck
- None in image.

## Gotchas
- Encryption key stored next to DB in /app/data; must persist with DB.
- Architectures and license not stated on README page.
