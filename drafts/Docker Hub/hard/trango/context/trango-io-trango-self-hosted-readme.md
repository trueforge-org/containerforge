# trango-io/trango-self-hosted README (summary)

Source URL: https://raw.githubusercontent.com/trango-io/trango-self-hosted/master/README.md (fetched 2026-11-26; also covers repo root)

## What it is
- Local-network calling and file-sharing tool. Works without internet.
- Ships a discovery server (C++ WebSocket) and a web app (Node build, served by nginx); Python API (flask).
- Beta. Open-source self-hosted version works with mobile and desktop apps. License GPL-2.0.
- Built on WebRTC and Simple-Peer. Calls up to 4 people; file transfer.

## Docker
- `docker pull tak786/trango-self-hosted`
- `docker container run -d -p 80:80 -p 443:443 --name trango tak786/trango-self-hosted`
- Open host IP in browser.

## Manual Linux install (Debian)
- Packages: libboost-all-dev, libssl-dev, g++, nginx, python3.6, python3-pip, curl; Node.js via NodeSource setup_12.x; pip: flask_restful, flask_cors, psutil.
- RHEL equivalents: boost, boost-devel, boost-system, boost-filesystem, boost-thread, openssl-devel, gcc-c++, nginx, python3.6, python3-pip, curl.
- Steps:
  1. In `app/`: `npm i && npm run build`
  2. Start API: `python3 api.py &`
  3. Copy certs/dhparam/ssl.conf (see Dockerfile file for destinations).
  4. Edit `ssl.conf` root from `/home/app/` to the app build folder.
  5. Copy `default` to `/etc/nginx/sites-available/`; `service nginx restart`.
  6. In `discoveryserver/src/`: g++ build (see Dockerfile file); run `./WebSocketWS &`.

## Not covered
- Compose files, env vars, volumes, default credentials, user/UID.
