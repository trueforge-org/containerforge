# mtlynch/picoshare (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/mtlynch/picoshare (fetched 2026-11-26)

**What it is**
- "A minimal, easy-to-host service for sharing images and other files." AGPL. 1M+ pulls. Live demo at demo.pico.rocks.

**Version/release info**
- Only `latest` listed (digest begins `sha256:4f4bd8e09...`, size 18.2 MB, last updated 10 days before capture).
- Chart pins `v1.5.5@sha256:4f4bd8e09aaa4649ec7904e12a395ae437e4aad3b20fba9c53be387d34cd779f`, same digest prefix as the `latest` shown here.

**Install/run**
- Example: `docker run --env PORT=3001 --env PS_SHARED_SECRET=... --publish 3001:3001/tcp --volume "${PWD}/data:/data" --name picoshare mtlynch/picoshare`.
- With cloud replication: pass Litestream vars and omit the volume; run only one container per Litestream location.
- From source: `PS_SHARED_SECRET=... PORT=3001 go run main.go`.

**Env vars and defaults on the page**
- `PORT` default stated as 3001 on the page (the code default is 4001 per GitHub source; the Hub text is stale).
- `PS_SHARED_SECRET`, `LITESTREAM_BUCKET`, `LITESTREAM_ENDPOINT`, `LITESTREAM_ACCESS_KEY_ID`, `LITESTREAM_SECRET_ACCESS_KEY`.
- `-db` flag default `data/store.db`.
- Build arg `litestream_version` stated as 0.3.8 on the page (the upstream v1.5.5 Dockerfile pins v0.3.13).

**Volumes**
- `/data` for the SQLite database (page example).

**Gotchas**
- The page's replication example sets `LITESTREAM_ENDPOINT` to the bucket variable (page says appears to be a typo in the source).
- Page text and the code disagree on the default port (3001 vs 4001) and the Litestream version (0.3.8 vs 0.3.13). The code wins for ContainerForge.
