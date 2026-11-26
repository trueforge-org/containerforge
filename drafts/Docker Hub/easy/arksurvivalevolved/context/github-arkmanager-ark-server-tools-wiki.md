# arkmanager/ark-server-tools wiki

**Source URL(s) + fetch date**
- https://github.com/arkmanager/ark-server-tools/wiki (fetched 2026-11-26)

**Facts**
- Last edited 13 Feb 2017. Pages: Home, "ban specific regions", "Install of required versions of glibc and gcc on RHEL CentOS", "Server Options".
- No command reference or install page; the home page points to the repo README.
- Troubleshooting on home:
  - `lsof` missing: on CentOS/Fedora/RHEL it lives in a system dir and needs the full path (`/usr/sbin/lsof`) when run as non-root; on Debian-based distros install it via `apt-get`.
  - `GLIBC_2.14 not found`: the server needs at least glibc 2.15.
  - `GameUserSettings.ini` overwritten: the file needs the section header `[/Script/ShooterGame.ShooterGameUserSettings]` and `Version=5`; non-ASCII characters can also cause it.
- No ports and no config file paths for GameUserSettings.ini given.
