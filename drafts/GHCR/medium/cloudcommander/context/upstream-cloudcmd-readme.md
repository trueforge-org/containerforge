# coderaiser/cloudcmd README (pinned ddf4726e4565ad8151aa391294a60ef3385d26b7; README title says v19.23.2)
Source URL(s): https://raw.githubusercontent.com/coderaiser/cloudcmd/ddf4726e4565ad8151aa391294a60ef3385d26b7/README.md (fetched 2026-11-27, first 3500 chars only)

## What it is
- Cloud Commander: web file manager with console and editor. Main site cloudcmd.io.

## Install
- npm i cloudcmd -g; start with `cloudcmd`; UI on http://localhost:8000.

## Docker (upstream docs)
- Images: amd64/arm64, linux and linux-alpine types.
- Example: `docker run -it --rm -v ~:/root -v /:/mnt/fs -w=/root -p 8000:8000 coderaiser/cloudcmd`
- Config read from home dir (/root in container); host root mounted at /mnt/fs; port 8000.
