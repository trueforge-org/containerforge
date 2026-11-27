# rocker-versioned2 rstudio_4.6.2.Dockerfile (pinned commit 500642d)

Source URL(s) + date:
- https://raw.githubusercontent.com/rocker-org/rocker-versioned2/500642d/dockerfiles/rstudio_4.6.2.Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/rocker-org/rocker-versioned2/500642d/scripts/install_rstudio.sh (fetched 2026-11-27)

## What it is
- Rocker image: R 4.6.2 from source + RStudio Server, s6 init, pandoc, quarto.

## Build steps (Dockerfile)
1. `FROM docker.io/library/ubuntu:resolute`
2. ENV: R_VERSION=4.6.2, R_HOME=/usr/local/lib/R, TZ=Etc/UTC, CRAN=https://p3m.dev/cran/__linux__/resolute/latest, LANG=en_US.UTF-8, S6_VERSION=v2.1.0.2, RSTUDIO_VERSION=2026.11.0+203, DEFAULT_USER=rstudio
3. `scripts/install_R_source.sh` (R from source), then `setup_R.sh` (removes uid 1000 user if present)
4. `scripts/install_rstudio.sh` (RStudio server deb)
5. `install_s6init.sh`, `default_user.sh`, `init_set_env.sh`, `init_userconf.sh`, `pam-helper.sh` copied to /rocker_scripts
6. `install_pandoc.sh`, `install_quarto.sh`
7. `EXPOSE 8787`, `CMD ["/init"]`

## install_rstudio.sh (key steps)
- apt deps: ca-certificates gdebi-core git libclang-dev libssl-dev lsb-release psmisc pwgen sudo wget
- Arg/env RSTUDIO_VERSION (default "stable"; accepts latest, preview, daily, or x.y.z[+-]build)
- Downloads `rstudio-server-<ver>-<arch>.deb` from download2.rstudio.org (fallback s3.amazonaws.com/rstudio-ide-build); stable/preview/daily use rstudio.org/download/latest/...
- Installs via `gdebi --non-interactive`; symlinks rstudio-server and rserver into /usr/local/bin
- Writes /etc/rstudio/rserver.conf (rsession-which-r), file-locks (lock-type=advisory), disable_auth_rserver.conf (auth-none=1)
- Creates /etc/services.d/rstudio/run (exec rserver --server-daemonize 0) and finish scripts
- Logging: /etc/rstudio/logging.conf (log-level=warn, logger-type=syslog)
- Ubuntu codename remap: focal->bionic, noble->jammy, resolute->jammy (for deb path)
- Ports: 8787

## Runtime deps
- s6 overlay (v2.1.0.2), R 4.6.2, pandoc, quarto (installed by Dockerfile)

## Entrypoint/flags
- CMD `/init` (s6). RStudio launched as service `rstudio` running rserver.

## Ports
- 8787

## User/UID
- DEFAULT_USER=rstudio (default_user.sh creates it). Uid 1000 removed at build.

## Config files
- /etc/rstudio/rserver.conf, /etc/rstudio/disable_auth_rserver.conf, /etc/rstudio/file-locks, /etc/rstudio/logging.conf

## Version/asset naming
- Deb: `rstudio-server-<RSTUDIO_VERSION with + replaced by ->-<ARCH>.deb`
- Dockerfile pins RSTUDIO_VERSION=2026.11.0+203

## Arch
- dpkg --print-architecture (amd64, arm64 supported by upstream deb naming)

## Gotchas
- Script writes to /var/lib/rstudio-server and /etc/rstudio at build time, so rootfs must be writable at build (not read-only at runtime for setup).
- `rm -f /var/lib/rstudio-server/secure-cookie-key` is applied by rocker (issue 137) so each container gets a fresh key.
- Dockerfile uses Ubuntu "resolute" codename; install script maps it to jammy deb.
