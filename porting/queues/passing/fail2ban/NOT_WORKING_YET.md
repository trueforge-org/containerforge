# fail2ban: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install runtime packages ****\" &&   apt-get update &&   apt-get install -y --no-install-recommends     fail2ban     iptables     logrotate     msmtp     nftables     whois &&   echo \"**** copy fail2ban confs to /defaults ****\" &&   mkdir -p     /defaults/fail2ban &&   curl -o     /tmp/fail2ban-confs.tar.gz -L     \"https://github.com/linuxserver/fail2ban-confs/tarball/master\" &&   tar xf     /tmp/fail2ban-confs.tar.gz -C     /defaults/fail2ban/ --strip-components=1 --exclude=linux*/.editorconfig --exclude=linux*/.gitattributes --exclude=linux*/.github --exclude=linux*/.gitignore --exclude=linux*/LICENSE &&   echo \"**** fix logrotate ****\" &&   sed -i \"s#/var/log/messages {}.*# #g\"     /etc/logrotate.conf &&   sed -i 's#/usr/sbin/logrotate /etc/logrotate.conf#/usr/sbin/logrotate /etc/logrotate.conf -s /config/log/logrotate.status#g'     /etc/periodic/daily/logrotate &&   rm -rf /etc/fail2ban &&   ln -s /config/fail2ban /etc/fail2ban &&   echo \"**** cleanup ****\" &&   rm -rf     /tmp/*     $HOME/.cache" did not complete successfully: exit code: 2

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-fail2ban:amd64 .`
- Result: FAIL
- Reason: 13.10 sed: can't read /etc/periodic/daily/logrotate: No such file or directory
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large batch continuation)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after Ubuntu logrotate path handling fix.
- Full log: `amd64-build.log`
