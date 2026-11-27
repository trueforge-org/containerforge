# Upstream Dockerfile and start.sh: pmmp/PocketMine-MP (5.44.3)

Source URL(s) + date:
- https://raw.githubusercontent.com/pmmp/PocketMine-MP/5.44.3/docker/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/pmmp/PocketMine-MP/5.44.3/docker/start.sh (2026-11-27)
- https://github.com/pmmp/PocketMine-MP/blob/5.44.3/docker/Dockerfile: raw variant used

What it is: three-stage build. PHP is compiled in its own image (`build-php`) from `build/php/compile.sh`, then the PocketMine phar is built by Composer and `build/server-phar.php`, then the final runtime.

Stages:
1. `build-php`: `ubuntu:22.04`. Build tools (build-essential, bison, re2c, cmake, etc.). Runs `./compile.sh -t linux64 -j <cpus> -f -g -P5` (ARG `COMPILE_SH_ARGS="-f -g -P5"`).
2. `build-pocketmine`: `ubuntu:22.04`, ARG `GIT_HASH` (required, fails if empty). Copies PHP bin, symlinks `/usr/bin/php`, installs composer, `composer install --classmap-authoritative --no-dev`, `php -dphar.readonly=0 ./build/server-phar.php --git ${GIT_HASH}`.
3. Final: `ubuntu:22.04`, maintainer PMMP Team. apt: ca-certificates, wget. Creates group and user `pocketmine` UID/GID 1000 (no home). Copies PHP to `/opt/pocketmine/bin`, phar to `/opt/pocketmine/PocketMine-MP.phar`, `ADD ./docker/start.sh /usr/bin/start-pocketmine`.

Runtime:
- `RUN mkdir /plugins /data`, `chown 1000:1000 /plugins /data .`
- `ENV TERM=xterm`
- `USER pocketmine`
- `EXPOSE 19132/tcp`, `EXPOSE 19132/udp`, `EXPOSE 19133/udp`
- `VOLUME ["/data", "/plugins"]`
- `CMD ["start-pocketmine"]`, no ENTRYPOINT

start.sh (`/usr/bin/start-pocketmine`, bash, `set -e`):
- Warns if files in /data or /plugins are not owned by `pocketmine` (non-fatal).
- Installs plugins from env `POCKETMINE_PLUGINS` (space-separated, optional `name:version`). Downloads `https://poggit.pmmp.io/get/<name>/<version>` to `/plugins/<name>.phar` if not present.
- Runs: `cd /opt/pocketmine` then `exec php PocketMine-MP.phar --no-wizard --enable-ansi --data=/data --plugins=/plugins` plus args from env `POCKETMINE_ARGS` (word-split).

Env vars: `TERM=xterm` (ENV), `POCKETMINE_PLUGINS`, `POCKETMINE_ARGS` (start.sh), `THREADS` (build only), `GIT_HASH` (build only).

Ports: 19132 (tcp and udp), 19133 (udp).

Volumes/paths: `/data`, `/plugins` (both must be writable by UID 1000). PHP at `/opt/pocketmine/bin/php7/bin/php`.

User/UID: pocketmine, UID/GID 1000.

Arch: ubuntu 22.04 base; PHP compiled for linux64 in build stage.

Gotchas:
- start.sh uses `--data=/data --plugins=/plugins`, so the chart mount paths match.
- `GIT_HASH` build arg is mandatory.
