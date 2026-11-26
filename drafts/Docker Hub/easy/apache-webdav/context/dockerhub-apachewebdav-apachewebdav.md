# Docker Hub: apachewebdav/apachewebdav

**Source URL(s) + fetch date**
- https://hub.docker.com/r/apachewebdav/apachewebdav (fetched 2026-11-26)

**What it is**
- "An Apache WebDAV container derived from bytemark/webdav, with several community pull requests merged in." Maintainer says the original appears abandoned. Last updated over 5 years ago. 100K+ pulls. Image size 17.1 MB.

**Merged changes**
- Non-ASCII filename fix, PUID/PGID support, umask support, Windows 10 and Apache Commons User-Agent additions, `DirectoryIndex disabled` (DoS), an SSL error fix.

**Facts from the page**
- Tags: only `latest`. Architectures: not stated. Ports: port 80 in examples only.
- Volumes: `/var/lib/dav/data` (served data), `/var/lib/dav` (app data), `/user.passwd` (optional), `/cert.pem` and `/privkey.pem` (optional).
- Env (all optional): `SERVER_NAMES` (default localhost), `LOCATION` (default /), `AUTH_TYPE` (Basic|Digest, default Basic), `REALM` (default WebDAV), `USERNAME`/`PASSWORD`, `ANONYMOUS_METHODS` (`ALL` disables auth), `SSL_CERT` (`selfsigned`), `PUID`, `PGID`, `PUMASK`.
- Run example: `docker run -d --restart always -e AUTH_TYPE=Digest -e USERNAME=alice -e PASSWORD=mypassword -v /mnt/webdav:/var/lib/dav/data:rw -v /mnt/appdata:/var/lib/dav:rw -p 80:80 apachewebdav/apachewebdav`.

**Gotchas**
- Image is a rolling community build of httpd 2.4.43 (Alpine), not an Apache release. Matches plan.md's note.
- Digest with HTTP recommended; Basic over plain HTTP sends credentials in cleartext.
