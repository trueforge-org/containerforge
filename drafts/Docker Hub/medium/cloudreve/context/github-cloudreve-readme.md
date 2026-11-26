# cloudreve/Cloudreve README

Source: https://raw.githubusercontent.com/cloudreve/Cloudreve/master/README.md (fetched 2026-11-26)

## What it is
- Self-hosted file management/sharing with multi-cloud storage: local, remote node, OneDrive, S3-compatible, Qiniu, Aliyun OSS, Tencent COS, Huawei OBS, KS3, Upyun
- Features: direct client-to-storage transfer, Aria2/qBittorrent offline download, archive ops, WebDAV, resumable uploads, share links, online preview/edit, multi-user/group, PWA, i18n

## Docker / run
- Image `cloudreve/cloudreve` (referenced); run command not on README (see docs/quickstart and docs/deploy)

## Ports / volumes / env
- none stated on README

## Build deps
- Go (Gin, ent) backend; React + Redux + Material-UI frontend
- Docs: https://docs.cloudreve.org/overview/build/ (toolchain not on README)
- Binary build via build.sh: needs Go >= 1.18, node.js, yarn, zip; flags -a assets, -c backend, -b both, -r release cross-compile

## Binary install
- Extract tarball; `chmod +x ./cloudreve`; `./cloudreve`

## License
- GPL v3
