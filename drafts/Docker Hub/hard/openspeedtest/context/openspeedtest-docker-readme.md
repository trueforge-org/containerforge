# openspeedtest/Docker-Image README

Source URL(s): https://github.com/openspeedtest/Docker-Image (raw main README) · fetched 2026-11-26

## Run
- `docker run --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest`.
- Access: http://IP:3000 (HTTP) or https://IP:3001 (HTTPS). Browser IE10+.
- Remap host ports: `-p 80:3000`, `-p 443:3001`.

## Ports
| Purpose | Container port |
|---|---|
| HTTP | 3000 |
| HTTPS | 3001 |

## Env vars
| Name | Default | Meaning |
|---|---|---|
| ENABLE_LETSENCRYPT | false | True = Let's Encrypt cert + cron renewal (needs public IP, domain, email; ports 80/443 mapped) |
| DOMAIN_NAME | false | Domain for LE |
| USER_EMAIL | false | Email for LE |
| CHANGE_CONTAINER_PORTS | false | Must be True to change internal ports |
| HTTP_PORT | 3000 | Internal HTTP port (with CHANGE_CONTAINER_PORTS) |
| HTTPS_PORT | 3001 | Internal HTTPS port (with CHANGE_CONTAINER_PORTS) |
| SET_USER | 101 | Process user |
| ALLOW_ONLY | none | CORS allowlist `domain1.com;domain2.com` |
| SET_SERVER_NAME | none | Server name shown in UI |

## Volumes / TLS
- Own cert: mount folder at `/etc/ssl/` containing exactly `nginx.crt` and `nginx.key`.
- Without these, HTTPS 3001 is exposed but cert source not stated.

## Gotchas
- Behind reverse proxy raise body limit to 35 MB.
- Cert filenames strict.
- Compose examples use version 3.3.
