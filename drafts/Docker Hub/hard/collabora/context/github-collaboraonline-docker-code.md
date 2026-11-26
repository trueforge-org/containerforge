# github.com/CollaboraOnline/Docker-CODE (legacy Dockerfile and start script, plan.md reference)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/CollaboraOnline/Docker-CODE/master/Dockerfile · fetched 2026-11-26
- https://raw.githubusercontent.com/CollaboraOnline/Docker-CODE/master/scripts/start-collabora-online.sh · fetched 2026-11-26

Note: this is the LEGACY (loolwsd-era) image build, not the current `collabora/code` build. Its Dockerfile base is `ubuntu:18.04`.

## Dockerfile
- `FROM ubuntu:18.04`; `ENV domain=localhost`, `LC_CTYPE=C.UTF-8`; no ARG; no apt lines in this file (apt inside `scripts/install-collabora-online.sh`, not fetched).
- `USER 101` (described as the "lool" user; creation in install script, not confirmed); `EXPOSE 9980`; no VOLUME, no ENTRYPOINT; `CMD` runs `start-collabora-online.sh` via bash.
- ADDs `install-collabora-online.sh` and `start-collabora-online.sh` to `/`; RUN executes the install script.
- No capabilities or seccomp in the Dockerfile.

## start-collabora-online.sh
- `#!/bin/sh` (uses bash-isms: `==` in test, brace expansion).
- Env read: `DONT_GEN_SSL_CERT` (certs generated only when unset), `cert_domain` (CN, default `localhost`), `SAL_LOG` (default `-INFO-WARN`), `domain` (trusted host), `username`, `password`, `server_name` (no defaults), `dictionaries` (default `de_DE en_GB en_US es_ES fr_FR it nl pt_BR pt_PT ru`), `extra_params` (appended unquoted).
- Copies `/etc/resolv.conf` and `/etc/hosts` into `/opt/lool/systemplate/etc/`.
- Cert generation: works in `/opt/ssl/`; `/C=DE/ST=BW/L=Stuttgart/O=Dummy Authority/CN=Dummy Authority` root CA (9131 days); server key and CSR with CN `localhost` or `${cert_domain}`; no SAN; outputs to `/etc/loolwsd/key.pem`, `cert.pem`, `ca-chain.cert.pem`.
- Config rewrites with `perl -pi` on `/etc/loolwsd/loolwsd.xml`: host `localhost` -> `${domain}`; username, password, server_name, allowed_languages from env.
- Optional inotify watcher sends SIGHUP to loolwsd on config change (only if `/usr/bin/inotifywait` and `/usr/bin/killall` exist).
- Runs `loolwsd-generate-proof-key`, then `exec /usr/bin/loolwsd --version --o:sys_template_path=/opt/lool/systemplate --o:child_root_path=/opt/lool/child-roots --o:file_server_root_path=/usr/share/loolwsd --o:user_interface.mode=notebookbar ${extra_params}`.
- Needs write access to `/opt/lool/systemplate/etc/`, `/opt/ssl/`, `/opt/lool/`, `/etc/loolwsd/` (suggests root or owner).

## Gotchas
- The legacy script runs **`loolwsd`** (binary name), not `coolwsd`; config is `loolwsd.xml`. Current packages use `coolwsd` and `coolwsd.xml`.
- The `${extra_params}` word-splitting and `--version` flag are legacy details; do not copy without checking the current `coolwsd` CLI.
