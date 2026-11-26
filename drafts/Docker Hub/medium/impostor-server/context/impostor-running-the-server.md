# Impostor: docs/Running-the-server.md (master)
Source URL: https://raw.githubusercontent.com/AeonLucid/Impostor/master/docs/Running-the-server.md (fetched 2026-11-26, 67 lines)

## Ports
- Among Us uses TCP HTTP service (points client to UDP) and UDP game traffic; both on port 22023.
- Needs UDP 22023 reachable; HTTPS needs a reverse proxy (see Http-server docs, not fetched).
- Test: http://localhost:22023 in a browser.

## Docker
- `docker run -p 127.0.0.1:22023:22023/tcp -p 22023:22023/udp -e IMPOSTOR_Server__PublicIp=<public ip> aeonlucid/impostor:nightly`
- Configure via env vars or mount config.json.
- Compose volumes: /app/config.json (mount), /app/plugins (plugins), /app/libraries (external libs).

## Normal install
- Needs .NET 10.0 runtime; config.json; PublicIp must be set to the public address.
