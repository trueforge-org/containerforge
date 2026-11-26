# docker-library/docker: 29/dind (Dockerfile and dockerd-entrypoint.sh)

Source URL(s) + fetch date:
- https://github.com/docker-library/docker/blob/70cd6b52204a3bf037510cb750e099c34b081bd4/29/dind/Dockerfile (fetched as raw.githubusercontent.com/.../70cd6b5.../29/dind/Dockerfile)
- https://raw.githubusercontent.com/docker-library/docker/70cd6b52204a3bf037510cb750e099c34b081bd4/29/dind/dockerd-entrypoint.sh
- Fetched 2026-11-26

## What it is
- Docker-library "dind" (Docker-in-Docker) official image template, version 29.10.0 at this commit. Generated from a template; Alpine-based.

## Install/build steps and build deps
- `FROM docker:29-cli` (Alpine).
- RUN 1 (apk, no cache): `ip6tables iptables openssl pigz shadow-uidmap xz`.
- RUN 2: installs `iptables-legacy` and symlinks `iptables`, `iptables-save`, `iptables-restore`, `ip6tables`, `ip6tables-save`, `ip6tables-restore` legacy variants into `/usr/local/sbin/.iptables-legacy`; checks legacy version.
- RUN 3 (userns-remap): `addgroup -S dockremap`, `adduser -S -G dockremap dockremap`, appends `dockremap:165536:65536` to `/etc/subuid` and `/etc/subgid`.
- RUN 4 (static binaries): version 29.10.0 with arch map (apk --print-arch): URL `https://download.docker.com/linux/static/stable/<arch>/docker-29.10.0.tgz`. Pinned sha256 per arch:
  - x86_64 (dir x86_64): 7c1ebadc65c716cdc6d35fc78759ed0e4317debf43c21dd12f066f2006999def
  - aarch64 (dir aarch64): 6e5159e8b5615e0c0c2954a2a1a2a12bc65f5d9b603595dba24a10cb367408cd
  - armhf (dir armel): b3e626f7560728eb601687da86c27edf9b7dd71f6a0f00737baeeb607c0f1d68
  - armv7 (dir armhf): 08757af1f923c25d170211a1de8acc4e69e9cfbe7b5af63dd787afe2057efd5f
  - ppc64le: f07fe44072d1614de38effa6492f840653dfbf9e5a7d3a0a1dab4c2dad257190
  - s390x: 09c4a2ec475121fe9c1485c65e9f54f1fa20aa4d68d0c4b271005db3943a763b
  - Other arch prints an error and exits 1.
  - Downloads with `wget -O docker.tgz`, verifies with `sha256sum -c -`, extracts into `/usr/local/bin/` with `--strip-components 1 --no-same-owner`, excluding `docker/docker` (CLI already in base) and `docker/containerd` (embedded containerd is used). Then runs `dockerd --version`, `ctr --version`, `runc --version`.
- ENV `DIND_COMMIT=8d9e3502aba39127e4d12196dae16d306f76993d`; RUN 5 downloads `https://raw.githubusercontent.com/moby/moby/${DIND_COMMIT}/hack/dind` to `/usr/local/bin/dind` and chmod +x.
- COPY `dockerd-entrypoint.sh` to `/usr/local/bin/`.
- No ARG defined. No USER (runs as root).

## Runtime deps
- Static bundle provides dockerd, containerd, runc (embedded). Alpine runtime packages listed above (iptables, pigz, xz, openssl, uidmap, ip6tables).
- Rootless path requires `rootlesskit` on PATH (this Dockerfile does not install it; whether the rootless extras tarball supplies it is not confirmed by the fetched sources), `/etc/subuid` and `/etc/subgid` entries, `XDG_RUNTIME_DIR`, `$HOME/.local/share/docker` writable, and `slirp4netns` by default (`DOCKERD_ROOTLESS_ROOTLESSKIT_NET`).

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["dockerd-entrypoint.sh"]`, `CMD []`.
- Entrypoint runs only when no args or first arg starts with `-`; if first arg is not `dockerd`, it runs `docker-entrypoint.sh "$@"`.
- Root: socket `unix:///var/run/docker.sock`. Non-root: `unix://$XDG_RUNTIME_DIR/docker.sock` (XDG_RUNTIME_DIR defaults `/run/user/$uid`). `DOCKER_HOST` unix:// overrides the socket.
- If first arg is `dockerd`: removes stale `docker*.pid` in /run and /var/run; wraps with `docker-init --` (tini); iptables legacy vs nf_tables selection (DOCKER_IPTABLES_LEGACY, /proc/net/ip_tables_names, modprobe).
- Injected dockerd flags: `--host=<socket>` plus `--host=tcp://0.0.0.0:2376` (TLS) or `--host=tcp://0.0.0.0:2375` (no TLS); TLS adds `--tlsverify --tlscacert $DOCKER_TLS_CERTDIR/server/ca.pem --tlscert .../server/cert.pem --tlskey .../server/key.pem`. User flags come last.
- Rootless (uid != 0): execs `rootlesskit --net=${DOCKERD_ROOTLESS_ROOTLESSKIT_NET:-slirp4netns} --mtu=${DOCKERD_ROOTLESS_ROOTLESSKIT_MTU:-1500} --disable-host-loopback --port-driver=builtin --copy-up=/etc --copy-up=/run ${DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS:-} "$@"`. Rootless mode is detected from non-zero uid, not a variable.
- Root with `/usr/local/bin/dind` executable: prepends `/usr/local/bin/dind` to the command.
- No `dockerd-rootless.sh` script appears in this entrypoint.

## Env vars
| Name | Read by | Notes |
| --- | --- | --- |
| DOCKER_TLS_CERTDIR | entrypoint | If set and non-empty, TLS on (2376) and certs generated there. If unset/empty, TLS off (2375). |
| DOCKER_TLS_SAN | entrypoint | Extra SAN entries, full SAN syntax (e.g. `DNS:...`, `IP:...`), appended to auto SANs. |
| DOCKER_HOST | entrypoint | If `unix://`, overrides the socket. |
| DOCKER_IPTABLES_LEGACY | entrypoint | Set empty -> nf_tables; non-empty -> legacy modules. |
| XDG_RUNTIME_DIR | entrypoint | Rootless socket dir. |
| HOME | entrypoint | Rootless data dir check `$HOME/.local/share/docker`. |
| DOCKERD_ROOTLESS_ROOTLESSKIT_NET | entrypoint | Default slirp4netns. |
| DOCKERD_ROOTLESS_ROOTLESSKIT_MTU | entrypoint | Default 1500. |
| DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS | entrypoint | Extra rootlesskit flags; TLS mode appends `-p 0.0.0.0:2376:2376/tcp`, non-TLS `-p 0.0.0.0:2375:2375/tcp`. |

## Ports
- EXPOSE `2375 2376`. TLS: 2376 on 0.0.0.0. Non-TLS: 2375 on 0.0.0.0.

## Volumes/paths and persistent data
- `VOLUME /var/lib/docker` (data root). Certificates under `$DOCKER_TLS_CERTDIR`: `ca/`, `server/`, `client/` subdirs (ca.pem, cert.pem, key.pem, client/ca.pem).

## User/UID & permissions
- Container runs as root (no USER). dockremap user 165536:65536 subuid/subgid created for userns-remap.

## Config files and formats
- Certificates: `ca/key.pem` (4096-bit RSA), `ca/cert.pem`, `server/{ca,cert,key}.pem`, `client/{ca,cert,key}.pem`. Valid 825 days. Regenerated at every startup for public certs (SAN changes, expiry). Client key chmod 0644.
- Skip case: if `server/ca.pem`, `server/cert.pem`, `server/key.pem` exist and `ca/key.pem` does not, the user manages the CA; only verify runs.

## Healthcheck/readiness endpoints
- None in the Dockerfile. Daemon readiness is TCP on 2375/2376.

## Version/release info and asset naming
- Pinned version 29.10.0. Asset pattern: `docker-<ver>.tgz` and `docker-rootless-extras-<ver>.tgz`, under `https://download.docker.com/linux/static/stable/<arch>/`.
- Note: this template's `DIND_COMMIT` is a moby commit SHA, not a tag.

## Arch support
- Static tarballs per dind Dockerfile: x86_64, aarch64, armhf, armv7, ppc64le, s390x.

## Gotchas
- The entrypoint regenerates server/client certificates on each start (not only the first).
- TLS mode is the default only when DOCKER_TLS_CERTDIR is non-empty; the Docker Hub docs use `DOCKER_TLS_CERTDIR=/certs`.
- Non-TLS mode is unauthenticated and listens on 0.0.0.0:2375.
- iptables legacy path is chosen automatically from kernel tables.
