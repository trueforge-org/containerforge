# tinyMediaManager start parameters

**Source URL(s):** https://www.tinymediamanager.org/docs/start-parameters
**Fetched:** 2026-11-26

## Config file
- `launcher-extra.yml`: JVM parameters and tmm-specific parameters.
- Location: the content folder (the folder above the data folder, which holds `data`, `logs`, `backup`, `cache`). Tools -> Open data folder in the app opens the data folder.
  - Portable: the tinyMediaManager folder itself.
  - Linux: `~/.local/share/tinyMediaManager`.
  - Windows: `C:\Users\<user>\AppData\Roaming`; macOS: `~/Library/Application Support/tinyMediaManager`.
- `extra.txt` is not mentioned on this page (see installation summary).

## Format
```yaml
javaHome: "custom Java home"   # default ""
jvmOpts:                        # default []
  - "JVM - parameter"
env:                            # default []
  - "environment option"
```
- `javaHome`: custom Java runtime; overrides the shipped runtime and the system default. Example `/usr/lib/jvm/adoptopenjdk-14-hotspot-amd64/`.

## -Dtmm.* properties
| Property | Purpose | Default |
| --- | --- | --- |
| -Dtmm.contentfolder | Parent folder for all content (data, backups, cache, logs) | none |
| -Dtmm.datafolder | Data folder | `$contentfolder/data` |
| -Dtmm.cachefolder | Cache folder | `$contentfolder/cache` |
| -Dtmm.backupfolder | Backup folder | `$contentfolder/backup` |
| -Dtmm.logfolder | Log folder | `$contentfolder/logs` |
| -Dtmm.addonfolder | Downloaded third-party tools (e.g. FFmpeg) | `$contentfolder/addons` |
| -Dtmm.noupdate | Disables automatic updates | false |
| -Dtmm.consoleloglevel | NONE, ERROR, WARN, INFO, DEBUG, TRACE | NONE |
| -Dtmm.trustallcerts | Disables HTTPS certificate check | false |
| -Dtmm.useexternaltools | Automatic download of external tools (e.g. FFmpeg) | true |
| -Dtmm.uselibmediainfo | Loads libmediainfo | true |
| -Dtmm.mvstore.buffersize | MVStore autocommit buffer (MB) | 8 |
| -Dtmm.legacy.filechooser | Legacy Swing file choosers | false |

## Common JVM options
| Parameter | Purpose | Default |
| --- | --- | --- |
| -Xmx | Max heap | -Xmx512m |
| -Djava.io.tmpdir | Temp folder | /tmp |
| -Dsun.java2d.uiScale | UI scale | 1.0 |

## env
- Listed option: `_JAVA_AWT_WM_NONREPARENTING=1` (window manager is non-reparenting).

## Gotchas
- Setting `-Dtmm.contentfolder` moves all writable state in one place; the plan's `/config/data` mapping relies on this.
- The `-Dtmm.useexternaltools=true` default means FFmpeg may be downloaded at runtime; set false in an immutable image.
- `-Dtmm.noupdate` defaults to false: the plan sets it to true.
