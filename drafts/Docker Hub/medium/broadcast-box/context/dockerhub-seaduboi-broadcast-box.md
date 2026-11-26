# hub.docker.com/r/seaduboi/broadcast-box

Source: https://hub.docker.com/r/seaduboi/broadcast-box (fetched 2026-11-26)

- Description: Docker packaging of glimesh/broadcast-box (MIT, SFU, WHIP ingest / WHEP playback)
- Tags: `latest` only (digest sha256:fad7abf9c...); ~82.3 MB; 50K+ pulls; updated ~11 days before fetch
- Local run: `docker run -e UDP_MUX_PORT=8080 -e NAT_1_TO_1_IP=127.0.0.1 -p 8080:8080 -p 8080:8080/udp seaduboi/broadcast-box`
- Cloud run: `--net=host -e INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP=yes`
- Volumes: none documented; SSL via SSL_CERT/SSL_KEY paths
- Endpoints: /api/whip, /api/whep, /api/status; OBS server `<host>/api/whip`, playback `/<streamkey>`
- Network test runs on startup in Docker; exits on failure unless NETWORK_TEST_ON_START=false
- Command/entrypoint and arch: not stated

## Docker Hub JSON (added 2026-11-26)
- Source: https://hub.docker.com/v2/repositories/seaduboi/broadcast-box/ and /tags?page_size=10
- description "Docker image of https://github.com/glimesh/broadcast-box"; pull_count 67325; star_count 1; last_updated 2026-11-16
- Tags (page 1 of 11): latest (2026-11-16, 86.3 MB, amd64+arm64); v2.1.1 (2026-11-16, amd64+arm64); v2.1.0; v2.0.2; v2.0.1; v2.0; v1.3; v1.2; sha-81ad028; sha-e8c65b6
- v2.1.1 image exists (plan pins v2.1.1 as upstream release); arm64 published
