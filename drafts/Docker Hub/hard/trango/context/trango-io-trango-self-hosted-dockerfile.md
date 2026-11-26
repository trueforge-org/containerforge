# trango-io/trango-self-hosted Dockerfile

Source URL: https://raw.githubusercontent.com/trango-io/trango-self-hosted/master/Dockerfile (fetched 2026-11-26)
Blob URL: https://github.com/trango-io/trango-self-hosted/blob/master/Dockerfile

## Base
- `FROM ubuntu:18.04` (EOL base)

## RUN
- apt: libboost-all-dev, libssl-dev, g++, nginx, python3.6, python3-pip, curl
- NodeSource setup script from deb.nodesource.com (Node.js 12.x), then nodejs install
- pip3: flask_restful, flask_cors, psutil
- `service nginx restart`
- In `/home/app/`: `npm install`, `npm run build`
- In `/home/discoveryserver/src/`: g++ compile main.cpp, WebSocketWS.cpp, WebSocketMainWS.cpp; include `../lib/SimpleWebSocketServer/`; link boost_system, ssl, crypto, pthread; output `WebSocketWS`
- `chmod +x run.sh`; apt clean; rm `/var/lib/apt/lists/*`

## COPY
| Src | Dest |
| --- | --- |
| discoveryserver/ | /home/discoveryserver/ |
| app/ | /home/app/ |
| nginx-selfsigned.crt | /etc/ssl/certs/ |
| nginx-selfsigned.key | /etc/ssl/private/ |
| dhparam.pem | /etc/ssl/certs/ |
| ssl.conf | /etc/nginx/conf.d/ |
| default | /etc/nginx/sites-available/ |
| run.sh | /home/discoveryserver/src/ |

## WORKDIR
1. /home/app/
2. /home/discoveryserver/src/

## Entrypoint / ports
- `CMD ./run.sh` (shell form)
- `EXPOSE 80 443`

## Not present
- ARG, ENV, VOLUME, USER, HEALTHCHECK, ENTRYPOINT.
- Runs as root (no USER).
