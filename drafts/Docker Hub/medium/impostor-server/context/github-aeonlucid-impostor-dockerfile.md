# AeonLucid/Impostor: Dockerfile (tag v1.10.10)
Source URL(s): https://github.com/AeonLucid/Impostor/blob/v1.10.10/Dockerfile = raw at v1.10.10 (fetched 2026-11-26, 47 lines)

## Build stage
- FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
- ARG TARGETARCH; ARG VERSIONSUFFIX="docker" (set "none" to empty)
- Copies csproj files (Impostor.Server, Impostor.Api.Innersloth.Generator, Impostor.Api, src/Directory.Build.props), then `dotnet restore -r <RID>` per project
- RID map: amd64 -> linux-x64, arm64 -> linux-arm64, arm -> linux-arm; other arch errors
- COPY src/. ./src/; `dotnet publish -c release -o /app -r <RID> -p:VersionSuffix=... --no-restore ./src/Impostor.Server/Impostor.Server.csproj`

## Final stage
- FROM --platform=$TARGETPLATFORM mcr.microsoft.com/dotnet/aspnet:10.0
- WORKDIR /app; COPY --from=build /app ./
- ENV ASPNETCORE_URLS= (empty, silences warning)
- EXPOSE 22023/tcp 22023/udp
- ENTRYPOINT ["./Impostor.Server"]
- No USER, no VOLUME, no HEALTHCHECK (runs as image default user)

## Gotchas
- Config via env (IMPOSTOR_<Section>__<Key>) or mounted /app/config.json; plugins at /app/plugins, libraries at /app/libraries (per docs).
- Multi-arch: amd64, arm64, arm only.
