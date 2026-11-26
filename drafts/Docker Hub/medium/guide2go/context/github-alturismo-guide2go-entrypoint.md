# alturismo/guide2go: entrypoint.sh (master)
Source URL: https://raw.githubusercontent.com/alturismo/guide2go/master/entrypoint.sh (fetched 2026-11-26, 27 lines)

- #!/bin/bash
- If /config/cronjob.sh missing: copy /cronjob.sh to /config/cronjob.sh, chmod 777 (exists: chmod only)
- If /config/cron.txt exists: source it. Else write `0 0 * * * /config/cronjob.sh` to /etc/crontabs/root and copy /sample_cron.txt to /config/sample_cron.txt
- Runs `crond -l 2 -f` (foreground). Exit 0.
- Writes need /config, /etc/crontabs (root user).
