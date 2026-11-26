# arkmanager/ark-server-tools (arkmanager)

**Source URL(s) + fetch date**
- https://github.com/arkmanager/ark-server-tools (repo; releases page)
- https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/LICENSE
- https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/install.sh
- https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/arkmanager.cfg
- https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/arkmanager (first part only; output truncated)
- https://github.com/arkmanager/ark-server-tools/releases
- Not fetched successfully: README at `master/README.md` (404) and `v1.6.69/README.md` (404).
- Fetched 2026-11-26

**What it is**
- arkmanager (ARK Server Tools): a bash wrapper that installs, updates, starts, stops and backs up ARK: Survival Evolved dedicated servers via SteamCMD. Used by the SickHub image.
- License: MIT (LICENSE at v1.6.69, Copyright Fez Vrasta, 2015).

**Releases**
- Latest: `v1.6.69` (commit 2a59da1), titled "ARK Server Tools v1.6.69", marked Latest, released 06 Jun (year not shown). Asset names not rendered ("Assets 2").
- Note on v1.6.69: adds an option to override the map on the arkmanager run command line.

**Install/build steps (tools/install.sh, v1.6.69)**
- Syntax: `./install.sh {<user>|--me} [OPTIONS]`. A user is mandatory. `<user>` must exist in `getent passwd`. `--me` (user install) is refused as root.
- Options: `--prefix=X` (or `--prefix X`), `--exec-prefix`, `--data-prefix`, `--install-root` (staging dir), `--bindir`, `--libexecdir`, `--datadir`, `--migrate-config`, `--install-service`, `-h`.
- System install defaults: PREFIX `/usr/local`, BINDIR `/usr/local/bin`, LIBEXECDIR `/usr/local/libexec/arkmanager`, DATADIR `/usr/local/share/arkmanager`, config `/etc/arkmanager/arkmanager.cfg`, instances `/etc/arkmanager/instances`.
- Installed (system): `BINDIR/arkmanager`; `LIBEXECDIR/arkmanager-uninstall.sh`; `/var/log/arktools` (owned by the user); `/etc/arkmanager/` and `/etc/arkmanager/instances/` (`instance.cfg.example`, `main.cfg`); `/etc/arkmanager/arkmanager.cfg.example` and `arkmanager.cfg` if absent; `/etc/bash_completion.d/arkmanager`.
- Not installed by default: no sudoers file, no cron entry. Services only with `--install-service` (systemd, sysvinit or OpenRC).
- Non-interactive (only prints messages). Exit 0 success; 1 usage; 2 when an existing config is found (writes `.NEW` files unless `--migrate-config`).
- `INSTALL_ROOT` prefixes all system paths (staging).

**Binaries/entrypoint/CLI flags**
- Binary: `arkmanager` (bash). Other files: `arkmanager-uninstall.sh`.
- `--version`: the script calls itself with `--version` after an upgrade; the exact output format and exit code were NOT visible in the truncated fetch (see plan.md section 8 "Version:" claim, unverified).
- Commands used by the upstream run script: `install`, `update --force --no-autostart`, `checkupdate`, `checkmodupdate`, `start --no-background --verbose`, `stop`, `broadcast`, `notify`, `backup`, `rconcmd`, `status`.

**Config lookup order (tools/arkmanager)**
- Global: `/etc/arkmanager/arkmanager.cfg` (override var `arkstGlobalCfgFileOverride`), sourced if present.
- User: `${HOME}/.arkmanager.cfg` (override `arkstUserCfgFileOverride`), sourced second, so it overrides global values.
- Root path does not source the files; it reads single vars from the global file with `sed` and drops to `steamcmd_user` via `runuser`.
- Working directory order: `serverbasedir`, then `${HOME}`, then `steamcmdroot`, then `/`.
- Instance config loading: details in the truncated part. Instance file names are derived as `${configfile%.cfg}.start`, `.GameUserSettings.ini` and `.Game.ini`. `doStartAll` loops `configfile_*` variables.

**Runtime deps (tools/arkmanager)**
- `lsof` (uses `/usr/sbin/lsof` if present, falls back to a Perl UDP query when missing or failing).
- `perl` (RCON, server-up check, player count, mod `.z` decompression with `Compress::Raw::Zlib`, collections need the `JSON` module).
- `curl`, `tar`, `sed`, `stat`, `find`, `xargs`, `pgrep`, `tput`, `runuser`, `getent`. Conditional: `rsync`, `sudo`, `taskset`, `renice`, `systemctl`. SteamCMD is required.

**Config files and formats (tools/arkmanager.cfg, v1.6.69, trimmed)**
- `arkstChannel="master"`, `install_bindir="/usr/bin"`, `install_libexecdir="/usr/libexec/arkmanager"`, `install_datadir="/usr/share/arkmanager"`.
- SteamCMD: `steamcmdroot="/home/steam/steamcmd"`, `steamcmdexec="steamcmd.sh"`, `steamcmd_user="steam"`, `steamcmd_appinfocache="/home/steam/Steam/appcache/appinfo.vdf"`, `steamcmd_workshoplog="/home/steam/Steam/logs/workshop_log.txt"`.
- Environment: `arkserverexec="ShooterGame/Binaries/Linux/ShooterGameServer"`, `arkbackupdir="/home/steam/ARK-Backups"`, `arkbackupcompress="true"`, `arkwarnminutes="60"`, `arkprecisewarn="false"`, `arkNoPortDecrement="true"`, `arkautorestartfile="ShooterGame/Saved/.autorestart"`, `arkAutoUpdateOnStart="false"`, `arkBackupPreUpdate="false"`, `arkMaxBackupSizeMB="500"`; `#arkStagingDir` commented out.
- Messages: `msgWarnUpdateMinutes`, `msgWarnRestartMinutes`, etc.
- Server: `serverMap="TheIsland"`, `ark_RCONEnabled="True"`, `ark_ServerPassword=""`, `ark_ServerAdminPassword` (sample value present in the file; not used by ContainerForge), `ark_MaxPlayers="70"`, `ark_GameModIds` commented.
- Service: `logdir="/var/log/arktools"`, `appid=376030`, `mod_appid=346110`, `mod_branch=Windows`, `defaultinstance="main"`.

**Ports**
- Game/query/RCON ports are set in the ARK config and the chart values, not in arkmanager.cfg. No ports are listed in the wiki.

**Volumes/paths and persistent data**
- Config and logs as above. Instance dir `/etc/arkmanager/instances`. Log dir `/var/log/arktools`.

**User/UID & permissions**
- The root path drops to `steamcmd_user` (default `steam`). The install user is passed to `install.sh`.

**Arch support**
- Not stated in these sources. The ARK server binaries are x86_64 only (plan.md; draft).

**Gotchas**
- Wiki troubleshooting (see github-arkmanager-ark-server-tools-wiki.md): needs `lsof` (on Debian it must be installed via apt); GLIBC 2.14+ required (the wiki says 2.15); `GameUserSettings.ini` needs `[/Script/ShooterGame.ShooterGameUserSettings]` and `Version=5`.
- `arkmanager.cfg` in the SickHub image is written from `am_*` env vars by `run.sh`; the lookup order above means the user file overrides the global one.
