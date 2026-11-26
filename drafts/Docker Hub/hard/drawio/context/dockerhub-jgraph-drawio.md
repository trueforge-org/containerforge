# jgraph/drawio (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/jgraph/drawio
- Fetched 2026-11-26

## What it is
- Docker image of draw.io (diagrams.net): flowcharts, network diagrams, UML, ER, BPMN, circuits. Imports .vsdx, Gliffy and Lucidchart files.
- Page says the repo provides an export server image (PDF/image output) and docker-compose setups for export server, Nextcloud integration and self-contained deployment. Built on `tomcat:9-jre11` per the page; forked from fjudith/draw.io. Since 16.5.3 only the Tomcat image is maintained (alpine and debian variants dropped).
- 10M+ pulls.

## Architectures and tags
- Architectures not listed. Only `latest` shown (digest `sha256:9911eb718...`, 407.2 MB, updated about 21 hours before fetch). Versioned tags not shown on the page.

## Documented run command
```
docker run -it --rm --name="draw" -p 8080:8080 -p 8443:8443 jgraph/drawio
```
- Browse `http://localhost:8080/?offline=1&https=0` or `https://localhost:8443/?offline=1` (offline disables cloud storage).

## Env vars and volumes (Hub)
- LETS_ENCRYPT_ENABLED (false), PUBLIC_DNS (draw.example.com), ORGANISATION_UNIT, ORGANISATION, CITY, STATE, COUNTRY_CODE, KEYSTORE_PASS (page example value), KEY_PASS (defaults to keystore password). More DRAWIO_* in docker-entrypoint.sh.
- Let's Encrypt example maps `-p 80:80 -p 443:8443` and mounts three letsencrypt dirs (`/var/log/letsencrypt/`, `/etc/letsencrypt/`, `/var/lib/letsencrypt`). SSL keystore can be mounted at `/user/local/tomcat/.keystore`.

