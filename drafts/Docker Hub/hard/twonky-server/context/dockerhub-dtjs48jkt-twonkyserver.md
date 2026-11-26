# Docker Hub dtjs48jkt/twonkyserver

Source URL: https://hub.docker.com/r/dtjs48jkt/twonkyserver (fetched 2026-11-26)

- Tags: only `latest`. Digest sha256:dca3fd8e3… (truncated). Size 154.4 MB. 500K+ pulls. Updated 7 days ago (per page).
- Architectures: not stated.
- Env: `GROUP_ID`, `UPDATE_ON_START=TRUE` (per page text).
- Ports: none listed; uses `--net=host`; webconfig on 9000.
- Volumes: `/config` (rw), `/data` (ro in example), `/etc/localtime` (ro).
- Run: `docker run -d --net=host --name=twonkyserver -v /path/to/config:/config:rw -v /path/to/data:/data:ro -v /etc/localtime:/etc/localtime:ro dtjs48jkt/twonkyserver`
