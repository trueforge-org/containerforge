# linuxserver/docker-photoshow root/etc/cont-init.d/40-install

Source URL (fetched 2026-11-27, GitHub contents API, base64 decoded):
- https://api.github.com/repos/linuxserver/docker-photoshow/contents/root/etc/cont-init.d/40-install

## Behaviour
- Shebang: `with-contenv bash`.
- `declare config` (lint only).
- `PHOTOSHOW_COMMIT=$(cat /version.txt)`.
- Runs only if `/config/www/PhotoShow/.git` does not exist (first start).
- `git clone https://github.com/thibaud-rohmer/PhotoShow.git /config/www/PhotoShow`.
- `git --git-dir=/config/www/PhotoShow/.git --work-tree=/config/www/PhotoShow checkout ${PHOTOSHOW_COMMIT}`.
- `sed -i` on `/config/www/PhotoShow/config.php`: `photos_dir` -> `/Pictures`, `ps_generated` -> `/Thumbs`, `timezone` -> `${TZ}`.
- Copies `/defaults/keyboard.js` to `/config/www/PhotoShow/src/js/keyboard.js`.
- `chown -R abc:abc /config/www/PhotoShow /Thumbs`. No chmod.

## Paths written
- `/config/www/PhotoShow` (clone, config.php, keyboard.js)
- `/Thumbs` (ownership only)

## Gotchas
- Needs network at first start to clone upstream. `/config` must be writable.
- Requires `/defaults/keyboard.js` to exist in the image (from `root/defaults/`).
