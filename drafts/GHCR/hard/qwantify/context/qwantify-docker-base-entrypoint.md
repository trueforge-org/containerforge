# qwantify docker/base/entrypoint.sh (master)

**Source URL(s):** https://raw.githubusercontent.com/wanjohiryan/qwantify/master/docker/base/entrypoint.sh · fetched 2026-11-27

## Behaviour
1. `chown -R $USER:$USER /home/$USER`.
2. `echo "$USER:$PASSWD" | sudo chpasswd`.
3. `/etc/localtime` from `$TZ` (sudo ln, /etc/timezone via sudo tee).
4. `DISPLAY` default `:0`.
5. WARP: `WARP_SERVER_HOST` = `${WARP_HOST:-localhost}`, `WARP_SERVER_PORT` = `${WARP_PORT:-4443}`, `WARP_ADDRESS` = `${WARP_ADDRESS:-host:port}`.
6. `URL_NAME` = `${NAME}` or random 16 alphanumeric chars.
7. `WARP_FULL_URL` = `${URL}` or `https://$WARP_ADDRESS/$URL_NAME`.
8. `sudo mkdir -pm755 /dev/input`; `sudo touch /dev/input/{js0..js3}`.
9. `exec /sbin/init --log-level=err` (systemd PID 1).

## Env vars read
| var | default |
| --- | --- |
| USER | (required, used for chown and chpasswd) |
| PASSWD | (required) |
| TZ | (required) |
| DISPLAY | :0 |
| WARP_HOST | localhost |
| WARP_PORT | 4443 |
| WARP_ADDRESS | derived |
| NAME | random |
| URL | derived |

## Gotchas
- Uses sudo, chpasswd, /dev/input writes, and `chown -R` on home: incompatible with read-only rootfs and non-root user.
- Does not start any game app; only sets up user, tz, and systemd.
