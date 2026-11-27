# benzino77/tasmocompiler Dockerfile at 1c86359
Source URL: https://raw.githubusercontent.com/benzino77/tasmocompiler/1c863599ac02b435ffb2e8aa907fff9da5829296/Dockerfile (fetched 2026-11-27)

## Base
- `FROM node:22-bookworm-slim`
- LABEL maintainer (Piotr Antczak)

## Build steps
1. apt: python3 git python3-setuptools python3-pip python3-venv; apt clean; `npm install -g nodemon`; rm /var/lib/apt/lists/*
2. ADD public/ -> /tasmocompiler/public/, server/ -> /tasmocompiler/server/, src/ -> /tasmocompiler/src/, package.json + package-lock.json -> /tasmocompiler/
3. `cd /tasmocompiler && npm ci && npm run build && chown -R node:node /tasmocompiler && npm uninstall react react-dom react-intl react-scripts @mui/styles @mui/material @mui/icons-material @emotion/styled @emotion/react` (size hack, per comment)
4. As USER node: `python3 -m venv /home/node/.platformio/penv`; pip install uv pioarduino==6.2.0 into that venv
- ENV LC_ALL=C.UTF-8 LANG=C.UTF-8; PATH=/home/node/.platformio/penv/bin:/home/node/.local/bin:$PATH
- WORKDIR /tasmocompiler
- ENTRYPOINT ["nodemon", "server/app.js"]
- EXPOSE 3000/tcp

## User
- USER node (non-root, uid from node base image)

## Tags (per README)
- `benzino77/tasmocompiler` (latest stable), `:development` (bleeding edge Tasmota dev branch tracking)

## Gotchas
- No HEALTHCHECK, no VOLUME in Dockerfile
- Needs writable PlatformIO home /home/node/.platformio (created at build time)
- Compiles firmware via PlatformIO at runtime; pioarduino pinned 6.2.0 in build
