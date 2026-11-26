# docs.ankiweb.net: built-in sync server

**Source URL(s) + fetch date**
- https://docs.ankiweb.net/sync-server.html (fetched 2026-11-26)

**What it is**
- The official Anki sync server, built into the Anki desktop app (Anki 2.1.57+). Described as an advanced, at-your-own-risk feature. Speaks plain unencrypted HTTP.

**Install/build steps and build deps**
- Desktop: launch with `--syncserver` after setting `SYNC_USER1`. Linux: `SYNC_USER1=user:pass anki --syncserver`. macOS: `SYNC_USER1=user:pass /Applications/Anki.app/Contents/MacOS/anki --syncserver` (25.07 to 25.09.4 use `launcher` instead of `anki`). Windows: `set SYNC_USER1=user:pass` then `anki-console --syncserver`.
- Alternatives: pip standalone (`python -m anki.syncserver`, Python 3.9+); Rust build via Cargo (Anki 2.1.66+, needs protoc); build from a source checkout; a user-contributed Docker setup (no official image).

**Env vars**

| Variable | Purpose |
| --- | --- |
| `SYNC_USER1`, `SYNC_USER2`, ... | Accounts as `username:password`. `SYNC_USER1` is required. |
| `PASSWORDS_HASHED` | Set to 1 (or any value) to expect hashed passwords, entries `username:password_hash` (PHC format, generated with a separate tool). |
| `SYNC_BASE` | Data directory. Default `~/.syncserver`. Must differ from the normal Anki data folder. |
| `SYNC_HOST` | Bind address. |
| `SYNC_PORT` | Bind port. Docs example uses 8080. |
| `MAX_SYNC_PAYLOAD_MEGS` | Upload limit; default matches AnkiWeb; can be raised above 100. |
| `SYNC_ENDPOINT`, `SYNC_ENDPOINT_MEDIA` | Only for older desktop clients. |

**Ports**
- `SYNC_PORT` (default example 8080 in these docs). Not the 27701 used by the Rust `ankisyncd`.

**Volumes/paths and persistent data**
- Data dir `~/.syncserver` by default, override with `SYNC_BASE`. Data must arrive by sync from a client, not by copying files manually.

**User management**
- Users are defined only by the numbered `SYNC_USERn` env vars. No separate user database or admin UI.

**Client setup**
- Set custom sync URL in client preferences, e.g. `http://192.168.1.200:8080/`. Enter the `SYNC_USERn` credentials in the AnkiWeb account section.
- Older desktop clients use `http://<ip>:8080/sync/` and `http://<ip>:8080/msync/`.
- AnkiMobile: toggle "Allow Anki to access local network" off and on if the server cannot be reached.

**Reverse proxy notes**
- Subpath deployments need a trailing slash on the client URL. Caddy: `read_buffer 512k` in the transport block. iOS needs TLS 1.2 enabled on the proxy (error -9836 otherwise).

**Gotchas**
- Newer clients may require a matching server version (sync protocol can change).
- Anki's messages still say "AnkiWeb" even with a custom server.
- Relevance to this app: this is the official alternative mentioned in plan.md section 10. It is a different env-var set (`SYNC_USERn`) from the Rust `ankisyncd` (`ANKISYNCD_USERNAME`/`ANKISYNCD_PASSWORD`).
