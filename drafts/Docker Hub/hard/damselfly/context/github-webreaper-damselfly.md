# github.com/Webreaper/Damselfly (source, README, releases, docs/Installation.md, build script, Dockerfile, entrypoint)

Source URL(s) + fetch date (all 2026-11-26):
- https://github.com/Webreaper/Damselfly (repo; via raw README) · https://raw.githubusercontent.com/Webreaper/Damselfly/master/README.md
- https://github.com/Webreaper/Damselfly/releases
- https://raw.githubusercontent.com/Webreaper/Damselfly/master/docs/Installation.md
- https://raw.githubusercontent.com/Webreaper/Damselfly/master/scripts/makeserver.sh
- https://raw.githubusercontent.com/Webreaper/Damselfly/e110926104cc93d3c87a9617ba7ab4ae70dbb216/Dockerfile (draft's commit)
- https://raw.githubusercontent.com/Webreaper/Damselfly/e110926104cc93d3c87a9617ba7ab4ae70dbb216/damselfly-entrypoint.sh (draft's commit)

## What it is
Server-based digital asset/photo management for large folder-organised collections: search, keyword tagging (IPTC), local offline ML (face detection and recognition, object detection, colour classification). Web UI (Blazor WebAssembly) plus an Electron.Net desktop client (macOS universal, Windows, Linux). README: "free, open-source software" (licence name not stated on the README).

## Version / releases
- Latest release **4.5.3** ("Release v4.5.3 - Finally!"), published 14 Jan at commit `e110926`. Previous: 4.2.3 (07 Jan), 4.2.2 (31 Dec), 4.2.1 (30 Dec). Years not shown (footer 2026).
- 4.5.3 release lists **4 assets**, names NOT loaded on the page.
- Asset naming: makeserver.sh produces `damselfly-server-${PLATFORM}-${version}.zip` (PLATFORM `linux`, `windows`, `mac`, `m1`), zipped from `bin/Release/net10.0/<rid>/publish`. Docs also cite `damselfly-server-linux-2.9.0.zip` for old releases. **Conflict:** plan.md uses `Server-Dist-linux.zip` (from a releases API check earlier); the master build script uses `damselfly-server-linux-<version>.zip`. The 4.5.3 asset name remains UNCONFIRMED here.

## Build (scripts/makeserver.sh)
`dotnet publish $project -r $runtime -f net${dotnetversion} -c Release --self-contained true /p:Version=$version /p:PublishTrimmed=false`, project `Damselfly.Web.Server`, **net10.0**, Release, self-contained, no trimming, version read from the `VERSION` file.
- Runtime IDs: `linux` -> `linux-x64`; `windows` -> `win-x64`; `mac` (default) -> `osx-x64`; `m1` -> `osx-arm64`. **No linux-arm64 target** (arm64 needs a custom publish).
- Post-publish: deletes `onnxruntime_providers*.dll` for linux/mac/m1 (Windows DLLs bundled by mistake, issue 546); `zip -rx "*.pdb"`.
- No copy of `Models`, `wwwroot` or other content in the script.

## Upstream Dockerfile (commit e110926)
- `ARG BASE_IMAGE=webreaper/damselfly-base:2.0.1`; `FROM ${BASE_IMAGE} AS final`; `WORKDIR /app`.
- `COPY` `/Models` -> `./Models`; `/desktop` -> `./wwwroot/desktop`; `/publish` -> `.`; `./damselfly-entrypoint.sh` -> `/`; `ADD VERSION`.
- `RUN chmod +x Damselfly.Web.Server` and `chmod +x /damselfly-entrypoint.sh`.
- `EXPOSE 6363`; no VOLUME; no USER (runs as root); `ENTRYPOINT ["sh","/damselfly-entrypoint.sh"]`; no CMD.
- Base image source (`damselfly-base`) not in the repo.

## Entrypoint (damselfly-entrypoint.sh, commit e110926)
- `SYNO_THUMBS` non-empty -> `cmdlineargs="--syno"`; `ONDEMAND_THUMBS` non-empty -> `cmdlineargs="--nothumbs"` (note: this overwrites SYNO_THUMBS's value when both are set).
- Exports `DOTNET_TieredPGO=1` and `COMPlus_EnableWriteXorExecute=0` (dotnet issue 70758).
- `cd /app`. If `DAMSELFLY_BLAZORSERVER` non-empty: `./Damselfly.Web /pictures --config=/config --thumbs=/thumbs ${cmdlineargs}`; else `./Damselfly.Web.Server /pictures --config=/config --thumbs=/thumbs ${cmdlineargs}`. Ends with `exec "$@"`.
- Matches plan.md section 1 and section 7.

## Install / runtime (docs/Installation.md, README)
- Docker is the easiest path. Image `webreaper/damselfly`. Run: `-v <host>:/config`, `-v <photos>:/pictures`, `-v <thumbs>:/thumbs`, `-p 6363:6363`, `-d`; compose equivalent; restart `unless-stopped`.
- Web UI on port **6363**. `/config` holds database, thumbnails and settings. `/pictures` is the photo root (extra roots as subfolders of `/pictures`). `/thumbs` thumbnail storage.
- Env: `SYNO_THUMBS=true` (Synology `@eaDir` format). No other env vars listed.
- Database: stored in `/config`; type not stated (plan's SQLite is from the migrations project, not these pages).
- inotify: `fs.inotify.max_user_instances=524288` on the host (sysctl); macOS `kern.maxfiles`.
- Non-Docker zip install: "for experts only"; needs 64-bit OS; `./Damselfly.Web /path/to/photos`; dependencies: Exiftool, fonts, `libgomp1`, `libgdiplus`, `libc6-dev`, EMGUCV deps (see the base image Dockerfile). Required .NET version and user/permission settings: not stated.
- README mentions "Microsoft .Net 7" and "EFCore 7", which conflicts with the net10.0 build script. Build script wins for plan purposes.

## Gotchas
- Upstream's README documents `/config`, `/pictures`, `/thumbs` as the only persistent paths.
