# ErsatzTV docker/nvidia/Dockerfile

Source URL: https://raw.githubusercontent.com/ErsatzTV/ErsatzTV/2271d5497becc30f8cf689715d115fb36d0abc8a/docker/nvidia/Dockerfile (commit 2271d54, fetched 2026-11-27; same content as blob URL in urls.txt)

## Stages
1. `FROM mcr.microsoft.com/dotnet/aspnet:9.0-noble-amd64 AS dotnet-runtime`
2. `FROM jasongdove/ersatztv-ffmpeg:7.1.1 AS runtime-base` (third-party ffmpeg image); `COPY --from=dotnet-runtime /usr/share/dotnet /usr/share/dotnet`
3. `FROM mcr.microsoft.com/dotnet/sdk:9.0-noble-amd64 AS build`
   - `apt-get install -y ca-certificates gnupg`; WORKDIR /source
   - Copies *.sln, artwork/, and csproj files of ErsatzTV, Application, Core, FFmpeg, Infrastructure, Infrastructure.Sqlite, Infrastructure.MySql, Scanner
   - `dotnet restore -r linux-x64 ErsatzTV/`
   - ARG INFO_VERSION="unknown"
   - Publish Scanner: `dotnet publish ErsatzTV.Scanner.csproj -c release -o /app -r linux-x64 --self-contained false --no-restore /p:DebugType=Embedded /p:InformationalVersion=${INFO_VERSION}`
   - In /source/ErsatzTV: `sed -i '/Scanner/d' ErsatzTV.csproj`, then publish ErsatzTV the same way into /app
4. Final `FROM runtime-base`
   - ENV FONTCONFIG_PATH=/etc/fonts; `RUN fc-cache update`
   - WORKDIR /app; `COPY --from=build /app ./`
   - ENV ETV_CONFIG_FOLDER=/config, ETV_TRANSCODE_FOLDER=/transcode, ETV_DISABLE_VULKAN=1
   - `ENTRYPOINT ["./ErsatzTV"]`

## Not declared
- No EXPOSE, VOLUME, USER, HEALTHCHECK. Port 8409 comes from the docs (see ersatztv-docs.md), not the Dockerfile.

## Gotchas
- Build is .NET 9 SDK, linux-x64 only (`-r linux-x64`); no arm64 path in this file.
- Runtime is the third-party `jasongdove/ersatztv-ffmpeg:7.1.1` image (ffmpeg build details not in this file).
- `ETV_TRANSCODE_FOLDER=/transcode` in this Dockerfile (the plan proposes /tmp/transcode).
