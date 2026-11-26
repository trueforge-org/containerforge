# mgutt/docker-apachewebdav (upstream of apachewebdav/apachewebdav)

**Source URL(s) + fetch date**
- https://github.com/mgutt/docker-apachewebdav (repo; README via raw master/README.md)
- https://github.com/mgutt/docker-apachewebdav/blob/master/Dockerfile (fetched as raw master/Dockerfile)
- https://raw.githubusercontent.com/mgutt/docker-apachewebdav/master/docker-entrypoint.sh
- https://raw.githubusercontent.com/mgutt/docker-apachewebdav/master/conf/conf-available/dav.conf
- Fetched 2026-11-26

**What it is**
- Wrapper image that runs Apache httpd with mod_dav, configured by env vars. Derived from bytemark/webdav (MIT, per plan.md). The docker-entrypoint.sh header says it is from the docker-webdav project, MIT.
- Upstream image `apachewebdav/apachewebdav` is built from this repo's Dockerfile (see dockerhub file).

**Install/build steps and build deps (Dockerfile)**
- Base `httpd:2.4.43-alpine` (so the image is Alpine httpd 2.4.43, not Ubuntu apt httpd).
- No ARG/ENV. Comments say `HTTPD_PREFIX` comes from the base.
- `apk add --no-cache openssl` (for self-signed certs).
- One RUN: create `/var/www/html` and `/var/lib/dav/data`; create empty `/var/lib/dav/DavLock`; uncomment `LoadModule` lines for `dav`, `dav_fs`, `authn_core`, `authn_file`, `authz_core`, `authz_user`, `auth_basic`, `auth_digest`, `alias`, `headers`, `include`, `mime`, `setenvif`; enable `httpd-autoindex.conf`; append `Include conf/conf-enabled/*.conf` and `Include conf/sites-enabled/*.conf`; symlink `dav.conf` into `conf-enabled` and `default.conf` into `sites-enabled`.
- COPY `conf/` and `docker-entrypoint.sh` to `/usr/local/bin/`.
- `EXPOSE 80/tcp 443/tcp`; `ENTRYPOINT ["docker-entrypoint.sh"]`; `CMD ["httpd-foreground"]`. No USER, no VOLUME, no WORKDIR override.

**Runtime deps**
- Alpine httpd image; `htpasswd`/`htdigest`/`md5sum`/`awk`/`sed`/`addgroup`/`adduser` used by the entrypoint.

**Binaries/entrypoint/CLI flags**
- Entrypoint (`docker-entrypoint.sh`, summary of behaviour):
  - `SERVER_NAMES`: first name -> `ServerName`, rest -> `ServerAlias`, via sed on `sites-available/default*.conf`.
  - `LOCATION`: rewrites `Alias` line in `dav.conf` to `Alias $LOCATION /var/lib/dav/data/`.
  - `REALM` (default `WebDAV`): rewrites `AuthName`.
  - `AUTH_TYPE`: only `Basic` or `Digest`; anything else exits 1. Rewrites `AuthType`.
  - `/user.passwd`: created only if absent (bind mount wins). If `USERNAME` and `PASSWORD` both set: Digest writes `user:REALM:md5(user:REALM:pass)` with `md5sum`; otherwise `htpasswd -B -b -c /user.passwd $USERNAME $PASSWORD` (password passed on the command line in the upstream script).
  - `ANONYMOUS_METHODS`: `ALL` replaces `Require valid-user` with `Require all granted`; otherwise adds `Require method <list>` after `Require valid-user`.
  - `SSL_CERT=selfsigned`: `openssl req -x509 -newkey rsa:2048 -days 1000 -nodes` to `/privkey.pem` and `/cert.pem`, CN from first `SERVER_NAMES` (or `selfsigned`). When present, enables `http2`, `ssl`, `socache_shmcb` and links `default-ssl.conf`.
  - `PUID` (default 1000), `PGID` (default 1000): `addgroup`/`adduser` then `User #$PUID` and `Group #$PGID` in httpd.conf; chowns `/var/lib/dav/data` and `DavLock`.
  - `PUMASK`: `umask` if set.
  - Finally `exec "$@"`.

**Env vars** (README and entrypoint)

| Variable | Default (per entrypoint/README) | Behaviour |
| --- | --- | --- |
| `SERVER_NAMES` | `localhost` (README) | First = ServerName, rest = ServerAlias |
| `LOCATION` | `/` | WebDAV URL path |
| `AUTH_TYPE` | `Basic` | `Basic` or `Digest` |
| `REALM` | `WebDAV` | AuthName |
| `USERNAME`, `PASSWORD` | none | Single user; ignored if `/user.passwd` is mounted |
| `ANONYMOUS_METHODS` | none | Comma list, or `ALL` (disables auth) |
| `SSL_CERT` | none | `selfsigned` generates a cert |
| `PUID` | 1000 (script) | Owner UID of `/var/lib/dav/data` and run user |
| `PGID` | 1000 (script) | Owner GID and run group |
| `PUMASK` | none | umask for the process |

**Ports**
- 80 (README examples), `EXPOSE 80/tcp 443/tcp` (Dockerfile). SSL on 443 only when `SSL_CERT` is set or a cert is mounted.

**Volumes/paths and persistent data**
- `/var/lib/dav/data`: served files (rw).
- `/var/lib/dav`: app data including `DavLock` (rw).
- `/user.passwd`: optional bind-mounted auth file for multiple users.
- `/cert.pem`, `/privkey.pem`: optional bind-mounted cert and key.

**User/UID & permissions**
- Runs httpd as `PUID:PGID` (default 1000:1000) via `User`/`Group` rewrite. The chart sets `runAsUser 0` and `PUMASK 0000`.

**Config files and formats**
- `dav.conf` (verbatim key directives):
  ```apache
  DavLockDB "/var/lib/dav/DavLock"
  Alias / "/var/lib/dav/data/"
  <Directory "/var/lib/dav/data/">
    Dav On
    Options +Indexes
    IndexOptions Charset=UTF-8
    DirectoryIndex disabled
    ... (index table styling: FancyIndexing, HTMLTable, SuppressDescription, SuppressRules, NameWidth=*, IndexOrderDefault Ascending Name, IgnoreCase, FoldersFirst, VersionSort)
    AuthType Basic
    AuthName "WebDAV"
    AuthUserFile "/user.passwd"
    <RequireAny>
      Require valid-user
    </RequireAny>
  </Directory>
  BrowserMatch ... redirect-carefully   (Microsoft Data Access, MiniRedir, MS FrontPage, WebDrive, WebDAVFS/1.[01234], gnome-vfs/1.0, XML Spy, Dreamweaver-WebDAV-SCM1, Konqueror/4, gvfs, Jakarta-Commons-VFS)
  ```
- The vhost `default.conf` and `RequestHeader edit Destination` line were NOT fetched; plan.md's claim about them is unverified here.

**Healthcheck/readiness endpoints**
- None documented. Chart defines no probes.

**Version/release info and asset naming**
- Repo contents: Dockerfile, docker-entrypoint.sh, conf/, README. No release info fetched.

**Arch support**
- Not stated.

**Gotchas**
- README: without `USERNAME`/`PASSWORD` or a mounted `/user.passwd`, nobody can access the server.
- README: over plain HTTP use Digest. Custom REALM with Digest needs `htdigest` again (the entrypoint writes the Digest hash from the realm it computes).
- README: a reverse proxy is recommended for SSL.
- Upstream does provide a config and an env-driven single user, so the draft's caveat that "the Apache config file and WebDAV user accounts must be created by hand" is only true for multiple users (mounting `/user.passwd`). Plan.md section 10 repeats the draft's "no usable default config" claim, which the source contradicts.
