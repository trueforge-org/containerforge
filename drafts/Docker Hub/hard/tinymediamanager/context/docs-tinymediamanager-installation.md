# tinyMediaManager installation docs

**Source URL(s):** https://www.tinymediamanager.org/docs/installation (fetched); https://www.tinymediamanager.org/docs/ (home, fetched, mostly navigation)
**Fetched:** 2026-11-26

## Linux install and run
- Linux build is a packaged archive; format and filename not stated on this page (the download page gives `.tar.xz`).
- Extract all files into any folder. Start the `tinyMediaManager` executable in that folder.
- Desktop shortcut: a script run from the instance folder writes `~/.local/share/applications/tinyMediaManager.desktop` (Exec=`$PWD/tinyMediaManager`, Icon=`$PWD/tmm.png`).
- If the app says libmediainfo is not working, install an official MediaInfo from mediaarea.net.
- A blank-window fix is in a section the page references but which is not in the content.

## Java / JRE
- Since v4.0 the app ships its own Java runtime, so no separate Java install is needed.
- ARM: no Java is packaged for ARM devices. Download a JRE (Java 11+, e.g. AdoptOpenJDK) and place it in a `jre` subfolder of the tinyMediaManager installation so the executable is `jre/bin/java`.
- This means the arm64 Universal Package may not include a JRE. plan.md assumed the arm64 tarball bundles `jre/`; that is UNVERIFIED and conflicts with this statement. Check the arm64 tarball contents.
- Falls back to the system Java if the shipped one is absent; `javaHome` in launcher-extra.yml overrides both.

## Data locations
- By default settings, databases, cache, logs and backups are in the app folder.
- Redirect with `-Dtmm.contentfolder=` or the individual `-Dtmm.*folder` properties.
- Set them in an `extra.txt` file in the tinyMediaManager folder (static) or in the start shell script (dynamic, allows `${HOME}`). This is the only mention of `extra.txt` in the docs; the start-parameters page documents `launcher-extra.yml`.
- `.userdir` file: not mentioned.

## System requirements (docs home, v5)
- 64-bit OS. Windows 10 / Server 2016+, macOS 11+, Debian 10 / Ubuntu 20.04 or equivalent.
- At least 512 MB free RAM; screen resolution 1366x768 or higher.
- v4 requirements: Windows 8 / Server 2012+, macOS 10.14+.
- The app runs an automatic update check at startup.

## Docs home (summary)
- Described as a media manager "written in Java/Swing" to supply metadata for Kodi.
- Downloads at tinymediamanager.org/download; auto-updates after user confirmation.
- Docs sub-pages: /docs/installation, /docs/start-parameters, /docs/docker, /docs/upgrade-v5.
