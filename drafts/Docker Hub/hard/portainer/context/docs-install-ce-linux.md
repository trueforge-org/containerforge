# Portainer CE install on Linux (Docker standalone)

Source URL: https://docs.portainer.io/start/install-ce/server/docker/linux (fetched; redirect-free)
Follow-up: https://docs.portainer.io/start/install-ce/server/docker/linux.md (flags/env check; none listed)
Index pages: https://docs.portainer.io/start/install-ce/server (fetched; lists Kubernetes, Docker Standalone, Swarm, Podman), https://docs.portainer.io/start/install/server (BE variant; same methods)

## Prerequisites
- Working Docker (docs advise against snap on Ubuntu); sudo on host
- Ports: 9443 (HTTPS UI); 8000 (TCP tunnel for Edge agents, optional); 9000 legacy HTTP (optional, add -p 9000:9000)
- Assumes Docker over unix socket, SELinux off (else --privileged), Docker as root (rootless needs extra config)

## docker run
```
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
  portainer/portainer-ce:lts
```
- Image: portainer/portainer-ce:lts
- Volumes: /var/run/docker.sock; portainer_data -> /data (DB location)

## Compose
```yaml
services:
  portainer:
    container_name: portainer
    image: portainer/portainer-ce:lts
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    ports:
      - 9443:9443
      - 8000:8000  # remove if no Edge agents
volumes:
  portainer_data:
    name: portainer_data
networks:
  default:
    name: portainer_network
```
- Official compose download: https://downloads.portainer.io/ce-sts/portainer-compose.yaml

## Other
- Env vars: none documented on page. Flags: none listed on page (setup-token startup flag exists; see FAQ faqs/installing/setup-token).
- User: not specified (root assumed).
- TLS: self-signed cert on 9443 by default; custom cert at install or via UI (docs advanced/ssl).
- New instances require setup token by default.
- Login https://<host>:9443 -> initial setup page.
