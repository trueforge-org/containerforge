# docs.cloudreve.org/overview/deploy/ (planning overview)

Source: https://docs.cloudreve.org/overview/deploy/ (fetched 2026-11-26)

- Docker Compose (recommended): Cloudreve, Redis, PostgreSQL, Aria2, VIPS/FFmpeg/LibreOffice, FFprobe
- Docker single container (official image): Cloudreve, Aria2, VIPS/FFmpeg/LibreOffice, FFprobe; DB and Redis separate
- Supervisor: Cloudreve only; DB and Redis separate
- DB: MySQL, PostgreSQL, SQLite; default SQLite when none configured
- Redis optional; without it in-memory cache persisted to `cache_persist.bin` on normal exit
- Not on this page: run commands, ports, volumes, CR_CONF_ vars, default admin, config path
- Sub-pages listed (not fetched): /en/overview/deploy/docker-compose, /docker, /supervisor, /configure; /en/overview/configure
