# ledccn/iyuuplus-dev: rootfs s6 init-config/run (HEAD)
Source URL: https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/docker/rootfs/etc/s6-overlay/s6-rc.d/init-config/run (fetched 2026-11-26)
- Shell: with-contenv bash; cd /iyuu
- If /iyuu/.git absent: git clone ${IYUU_REPO_URL} /tmp/iyuu, copy contents into /iyuu, rm /tmp/iyuu
- Else: git remote set-url origin ${IYUU_REPO_URL}; git fetch --all; git reset --hard origin/master
- mkdir /var/tmp if missing
