# github.com/helfrichmichael/cura-novnc (wrapper repo, Dockerfile on master)

Source URL(s) + fetch date:
- https://github.com/helfrichmichael/cura-novnc/blob/master/Dockerfile (raw: https://raw.githubusercontent.com/helfrichmichael/cura-novnc/master/Dockerfile) · fetched 2026-11-26
- Repo: https://github.com/helfrichmichael/cura-novnc (named in the Docker Hub page; not fetched separately)

## Build stages
- Stage 1 `golang:bullseye` (alias `easy-novnc-build`): `go mod init build`, fetches `github.com/geek1011/easy-novnc@v1.1.0`, builds `/bin/easy-novnc`.
- Final: `debian:bullseye` (EOL base; the plan's ubuntu kasmvnc base is a rebuild, not a copy).

## Packages (final stage, apt --no-install-recommends)
- Layer 1: `openbox`, `tigervnc-standalone-server`, `supervisor`, `gosu`.
- Layer 2: `openscad`, `lxterminal`, `nano`, `wget`, `openssh-client`, `rsync`, `ca-certificates`, `xdg-utils`, `htop`, `tar`, `xzip`, `gzip`, `bzip2`, `zip`, `unzip`.
- Layer 3 (also `--allow-unauthenticated`): `lxde`, `gtk2-engines-murrine`, `gnome-themes-standard`, `gtk2-engines-pixbuf`, `arc-theme`, `freeglut3`, `libgtk2.0-dev`, `libwxgtk3.0-gtk3-dev`, `libwx-perl`, `libxmu-dev`, `libgl1-mesa-glx`, `libgl1-mesa-dri`, `xdg-utils`, `locales`, `locales-all`, `pcmanfm`, `jq`, `curl`, `git`, `firefox-esr`, `qtbase5-dev`.
- Cleanup: removes `/var/lib/apt/lists`, `apt autoclean`, `apt autoremove`.

## Cura install / AppImage
- `get_release_info.sh` copied into `/cura`; called with `url` and `name` to get the download link and file name. `curl -sSL` downloads the release; `releaseInfo.json` is deleted; file made executable.
- `--appimage-extract` produces `/cura/squashfs-root`.
- `sed -i` on `squashfs-root/AppRun`: `QT_QPA_PLATFORMTHEME=xdgdesktopportal` -> `QT_QPA_PLATFORMTHEME=gtk3` (file dialog fix). The AppImage file is then removed.

## Users / permissions
- Group `cura` and user `cura` created with `groupadd` / `useradd -g cura --create-home --home-dir /home/cura` (no fixed UID/GID).
- `/cura`, `/prints/`, `/home/cura/.config/` created; `/cura/`, `/home/cura/`, `/prints/` chowned to `cura:cura`.
- `XDG_DOWNLOAD_DIR="/prints/"` appended to `/home/cura/.config/user-dirs.dirs`; `file:///prints prints` appended to `/home/cura/.gtk-bookmarks`.
- `usermod -aG dialout cura` (USB printing).
- No `USER` instruction. Privileges dropped at runtime via `gosu`.

## Copied files
`/bin/easy-novnc` -> `/usr/local/bin/`; `menu.xml` -> `/etc/xdg/openbox/`; `supervisord.conf` -> `/etc/` (contents not shown).

## Ports / volumes / entrypoint
- EXPOSE 8080 (HTTP, easy-novnc) and 5900 (VNC).
- VOLUME `/home/cura/` and `/prints/`.
- No ENTRYPOINT. CMD: `["/bin/bash", "-c", "chown -R cura:cura /home/cura/ /prints/ /dev/stdout && exec gosu cura supervisord"]`.

## Gotchas
- Wrapper uses `chown` at container start (CMD); a read-only rootfs and non-root user need a different start (plan uses kasmvnc's base instead).
