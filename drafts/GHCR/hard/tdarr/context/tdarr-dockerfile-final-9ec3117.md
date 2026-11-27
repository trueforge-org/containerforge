# Tdarr docker/Dockerfile.final at 9ec3117
Source URL: https://raw.githubusercontent.com/HaveAGitGat/Tdarr/9ec31178f6807861c207f8a65a1b8156e46c5b85/docker/Dockerfile.final (fetched 2026-11-27)

## Args / base
- ARG VERSION, DATE, MODULE (MODULE = Tdarr_Server or Tdarr_Node)
- `FROM docker.io/haveagitgat/tdarr_acc:base_${VERSION}_${DATE}` (base image built from Dockerfile.base)

## ENV
| env | value |
| --- | --- |
| WEB_UI_PORT | 8265 |
| SERVER_PORT | 8266 |
| NODE_PORT | 8267 |
| PUID / PGID | 1000 / 1000 |
| UMASK | 002 |
| TZ | Etc/UTC |
| HOME | /home/Tdarr |
| MODULE_LINK, NODE_LINK | "" (set at build) |
| BASE_LINK | https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/$VERSION |
| inContainer | true |

## Build steps
1. If MODULE=Tdarr_Node: remove /etc/services.d/tdarr_server
2. apt install curl unzip mkvtoolnix libtesseract-dev
3. Pick arch dir by `uname -m`: x86_64 -> linux_x64, aarch64 -> linux_arm64, armv7l -> linux_arm
   - MODULE zip: `${BASE_LINK}/<arch>/${MODULE}_$DATE.zip`; node zip: `${BASE_LINK}/<arch>/Tdarr_Node_$DATE.zip` (Server build also fetches node)
4. unzip into /app/$MODULE (and /app/Tdarr_Node), excluding *.exe
5. Build-time self-tests: `runTests=true runDockerTests=true /app_test/$MODULE/$MODULE` (copy of /app), also for Tdarr_Node
6. trash-empty; apt autoremove

## Ports
- EXPOSE 8267 (node), 8265 (web UI), 8266 (server)

## Entrypoint
- ENTRYPOINT ["/init"]

## Gotchas
- Binaries downloaded from Backblaze B2 at build time; URL built from $VERSION and $DATE (not from GitHub release)
