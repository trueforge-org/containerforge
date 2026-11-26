# apache/guacamole-server (GitHub)

**Source URL(s) + fetch date**
- https://github.com/apache/guacamole-server (repo, draft source link)
- https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/Dockerfile (draft's Dockerfile link, pinned commit)
- https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd-docker/bin/entrypoint.sh (the root-level `entrypoint.sh` returned 404; the Dockerfile COPYs from `src/guacd-docker/bin/`)
- https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd/conf-args.c
- https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd/conf.h
- https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd/daemon.c
- Fetched 2026-11-26

**What it is**
Apache Guacamole's native server-side proxy daemon `guacd` (C). Speaks the Guacamole protocol and connects to RDP, VNC, SSH and Telnet targets through protocol client plugins. No web UI, no authentication of its own.

**Install/build steps and build deps (upstream Dockerfile, pinned commit)**
- Build args: `ALPINE_BASE_IMAGE=3.18`, `FREERDP_VERSION=2`, `PREFIX_DIR=/opt/guacamole`, `BUILD_DIR=/tmp/guacamole-server`, many per-library option ARGs.
- Builder packages (alpine): autoconf automake build-base cairo-dev cjson-dev cmake cunit-dev git grep krb5-dev libjpeg-turbo-dev libpng-dev libtool libwebp-dev make openssl1.1-compat-dev pango-dev pulseaudio-dev sdl2-dev sdl2_ttf-dev util-linux-dev webkit2gtk-dev.
- Per-library stages built with `autobuild.sh` into `/opt/guacamole`: libssh2 (`-DBUILD_SHARED_LIBS=ON`), libtelnet, libvncclient (LibVNCServer), libwebsockets, FreeRDP 2 (`-DWITH_SERVER=OFF`, `-DWITH_CLIENT=ON`, `-DWITH_OPENSSL=ON`, etc.).
- guacamole-server built with `autobuild.sh GUACAMOLE_SERVER`, options `--disable-guaclog CPPFLAGS=-Wno-error=deprecated-declarations`.
- `list-dependencies.sh` writes `${PREFIX_DIR}/DEPENDENCIES` (Alpine package list for the runtime).
- Runtime stage (alpine): `apk add ca-certificates font-noto-cjk ghostscript netcat-openbsd shadow terminus-font ttf-dejavu ttf-liberation util-linux-login`, then installs the packages from `DEPENDENCIES`.
- `ENV LC_ALL=C.UTF-8`, `ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib`.
- `HEALTHCHECK --interval=5m --timeout=5s CMD nc -z 127.0.0.1 4822 || exit 1`.
- `ARG UID=1000`, `ARG GID=1000`; group and user `guacd` (`useradd --system --create-home --shell /sbin/nologin`).
- `USER guacd`; `EXPOSE 4822`; `COPY ./src/guacd-docker/bin/entrypoint.sh /opt/guacamole/`; `ENTRYPOINT [ "/opt/guacamole/entrypoint.sh" ]`.
- No VOLUME, no CMD.

**Runtime deps**
Alpine packages above plus `DEPENDENCIES`. For ContainerForge (Ubuntu) the plan builds from source and derives the runtime package list with `ldd`.

**Binaries/entrypoint/CLI flags**
- Entrypoint (`src/guacd-docker/bin/entrypoint.sh`, fetched):
  ```
  if [ -n "$GUACD_LOG_LEVEL" ]; then echo "WARNING: The GUACD_LOG_LEVEL environment variable has been deprecated in favor of the LOG_LEVEL environment variable. ..." >&2; fi
  exec /opt/guacamole/sbin/guacd -f -b 0.0.0.0 -L "${LOG_LEVEL:-${GUACD_LOG_LEVEL:-info}}" "$@"
  ```
- `guacd` options (`src/guacd/conf-args.c`, getopt string `"l:b:p:L:C:K:fv"`):
  - `-l LISTENPORT`: port
  - `-b LISTENADDRESS`: bind host
  - `-p PIDFILE`
  - `-L LEVEL`: `trace`, `debug`, `info`, `warning`, `error`; invalid value returns 1
  - `-C CERTIFICATE_FILE`, `-K PEM_FILE`: TLS, only when built with `ENABLE_SSL`
  - `-f`: foreground
  - `-v`: print version and exit
  - Unknown option prints a usage line and returns 1.

**Env vars (table)**

| Name | Default | Notes |
| --- | --- | --- |
| `LOG_LEVEL` | `info` (via entrypoint) | Preferred name; `trace`/`debug`/`info`/`warning`/`error`. |
| `GUACD_LOG_LEVEL` | unset | Deprecated; used only if `LOG_LEVEL` is unset, with a warning. |
| `LC_ALL` | `C.UTF-8` | Image ENV. |
| `LD_LIBRARY_PATH` | `/opt/guacamole/lib` | Image ENV. |

**Ports**
`4822/tcp` (`EXPOSE 4822`). Defaults in `conf.h`: `GUACD_DEFAULT_BIND_HOST "localhost"` and `GUACD_DEFAULT_BIND_PORT "4822"`. The entrypoint overrides the host to `0.0.0.0`.

**Volumes/paths and persistent data**
None declared. Session recordings and RDP drive redirection are paths supplied by clients (plan.md; not in the fetched source).

**User/UID & permissions**
User `guacd` UID/GID 1000 (build args). Runs as `guacd` (USER).

**Config files and formats**
None. All options are flags (`conf-args.c`).

**Healthcheck/readiness endpoints**
`nc -z 127.0.0.1 4822`. Startup log lines (`src/guacd/daemon.c`, `main`):
- `"Guacamole proxy daemon (guacd) version " VERSION " started"` (INFO)
- `"Listening on host %s, port %s"` (INFO), with the bound address and port from `getnameinfo`.
Binding: `getaddrinfo` loop, `socket`, `SO_REUSEADDR`, `bind`, then `listen(socket_fd, 5)`.

**Version/release info and asset naming**
Source tarball is pulled by the plan from Apache's archive (see archive-apache-guacamole-server-1.6.0.md). Upstream Dockerfile builds its dependencies from git URLs (autobuild.sh), not release archives. Version macro `VERSION` set at build time.

**Arch support**
Dockerfile uses `*_ARM_OPTS` and `*_X86_OPTS` build args for per-arch tuning; both arches intended. Not stated on the Hub page.

**License**
Apache-2.0 (per plan.md; LICENSE not fetched here).

**Gotchas**
- Default bind host is `localhost`; the container must use `-b 0.0.0.0` (the entrypoint does) to be reachable from other containers.
- No authentication (Hub page warns about exposing it).
- The alpine runtime installs `util-linux-login` in addition to the packages listed in plan.md section 1 (plan.md's list omits it; not a fact error, see README).
- `GUACD_LOG_LEVEL` is deprecated.

**Contradictions with plan.md**
- plan.md section 1 says the upstream Dockerfile is alpine:3.18 with FreeRDP 2 compiled from source, `HEALTHCHECK nc -z 127.0.0.1 4822`, `ENTRYPOINT /opt/guacamole/entrypoint.sh`, user `guacd` UID 1000, `EXPOSE 4822`, `LC_ALL` and `LD_LIBRARY_PATH`. Confirmed.
- plan.md section 1 says the entrypoint runs `-f -b 0.0.0.0 -L ...` and that `GUACD_LOG_LEVEL` is deprecated. Confirmed.
- plan.md section 1 says the default bind host is `localhost` in `conf.h`. Confirmed (`GUACD_DEFAULT_BIND_HOST "localhost"`).
- plan.md section 1 flags list (`-l -b -p -L -C -K -f -v`). Confirmed.
- plan.md section 1 says the log lines are "Guacamole proxy daemon (guacd) version 1.6.0 started" and "Listening on host 0.0.0.0, port 4822" (readiness, section 11). Format strings confirmed.
- plan.md section 1 says the draft's apt route is invalid. Not checked here (packages.ubuntu.com not fetched in this run).
