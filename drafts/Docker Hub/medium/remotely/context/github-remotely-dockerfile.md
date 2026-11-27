# GitHub: immense/Remotely Server/Dockerfile and repo metadata

Source URL(s):
- https://raw.githubusercontent.com/immense/Remotely/ec0d45d/Server/Dockerfile (raw variant of https://github.com/immense/Remotely/blob/ec0d45d/Server/Dockerfile)
- https://api.github.com/repos/immense/Remotely
Fetched: 2026-11-27

## Dockerfile
| Item | Value |
| --- | --- |
| base | mcr.microsoft.com/dotnet/aspnet:8.0 |
| EXPOSE | `${ASPNETCORE_HTTP_PORTS}` (env-driven, no default) |
| apt | `apt -y update && apt -y install curl` |
| copy | `Server/bin/publish` to `/app` (pre-built publish output must exist in build context) |
| WORKDIR | /app |
| ENTRYPOINT | `["dotnet", "Remotely_Server.dll"]` |
| HEALTHCHECK | `curl -f http://localhost:${ASPNETCORE_HTTP_PORTS}/api/healthcheck` |
| USER | none (root) |
| CMD | none |

## Repo metadata (api.github.com/repos/immense/Remotely)
| Key | Value |
| --- | --- |
| full_name | immense/Remotely |
| default_branch | master |
| license | GPL-3.0 |
| pushed_at | 2024-12-17 |
| description | A remote control and remote scripting solution, built with .NET 8, Blazor, and SignalR. |

## Gotchas
- Dockerfile requires `Server/bin/publish` to exist in the build context (pre-built, not compiled in the Dockerfile).
- Port and healthcheck depend on ASPNETCORE_HTTP_PORTS, which the chart does not set (see truecharts-remotely.md).
- Upstream description says .NET 8; chart description says .NET 5 (chart text is stale).
- `http://*:5000` in urls.txt was a templated placeholder: skipped.
