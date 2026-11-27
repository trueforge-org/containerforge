# apt-mirror(1) man page (Debian trixie)

Source URL: https://manpages.debian.org/trixie/apt-mirror/apt-mirror.1.en.html (fetched 2026-11-27, HTML, partial extraction)

## What it is
`apt-mirror [configfile]` mirrors Debian/Ubuntu apt repositories. Reads `/etc/apt/mirror.list` by default.

## Paths
- Config: `/etc/apt/mirror.list`
- Default spool: `/var/spool/apt-mirror` with subdirs `mirror`, `skel`, `var`
- Skel path: `/var/spool/apt-mirror/skel`

## Usage notes
- "After you setup the configuration file you may run as root:" `apt-mirror` (run is manual or via cron)
- mirror.list entries: `deb http(s)://[user:pass@]host[:port]/path suite components`
- Wget-based options exist (e.g. `set auth_no_challenge 1`, `set no_check_certificate 1`), set via `set <option> <value>` lines

## Gotchas
- The man page documents the default spool at /var/spool/apt-mirror; the upstream Docker image instead sets DATA_DIR/MIRROR_DIR/CONFIG_DIR env vars (see ich777-docker-debian-mirror-dockerfile.md). Check how start.sh wires them to mirror.list (not in this summary).
- Only partial text extracted from the HTML (option table not recovered).
