# metabase upstream Dockerfile and run_metabase.sh (v0.65.6)

**Source URL(s):** https://github.com/metabase/metabase/blob/v0.65.6/bin/docker/Dockerfile (fetched via https://raw.githubusercontent.com/metabase/metabase/v0.65.6/bin/docker/Dockerfile); https://raw.githubusercontent.com/metabase/metabase/v0.65.6/bin/docker/run_metabase.sh (followed from the Dockerfile ENTRYPOINT)
**Fetched:** 2026-11-26

## Base and ENV/ARG
- `FROM eclipse-temurin:25-jre-alpine` (Java 25, Alpine).
- ENV: `FC_LANG=en-US`, `LC_CTYPE=en_US.UTF-8`.
- ARG `GIT_COMMIT_SHA`, exposed as an env var of the same name.

## Build steps
1. COPY `DigiCertGlobalRootG2.crt.pem` to `/app/certs/` (before RUN, for keytool).
2. One RUN:
   - apk install: bash, fontconfig, curl, font-noto (plus arabic, hebrew, cjk, thai), java-cacerts.
   - `apk upgrade`; clear `/var/cache/apk/*`.
   - Disable `mozilla/emSign_ECC_Root_CA_-_G3.crt` in `/etc/ca-certificates.conf` (sed prefix `!`); `update-ca-certificates`.
   - keytool (`/opt/java/openjdk/bin/keytool`, storepass `changeit`): delete cacerts aliases whose owner is `CN=emSign ECC Root CA - G3`.
   - `mkdir /app/certs`; curl `https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem` to `/app/certs/rds-combined-ca-bundle.pem`; import into `/etc/ssl/certs/java/cacerts` as alias `aws-rds`.
   - Import DigiCert Global Root G2 PEM as alias `azure-cert` into the same keystore.
   - `mkdir /plugins` and `chmod a+rwx /plugins`.
3. COPY `blocked.certs` to `/app/certs/`; append `/app/certs/blocked.certs` to `/opt/java/openjdk/lib/security/blocked.certs`.
4. COPY `./metabase.jar` and `./run_metabase.sh` to `/app/`.
5. `EXPOSE 3000`; `ENTRYPOINT ["/app/run_metabase.sh"]`.
- No VOLUME, USER, WORKDIR or CMD. A Dockerfile comment says an H2 DB can be mounted to `/app/initial*.db` to seed a new instance.

## Build deps / runtime deps
- The keystore at `/etc/ssl/certs/java/cacerts` is modified at build time. Our Ubuntu base has its own `cacerts`; the RDS and DigiCert imports are optional (plan.md: include only if RDS SSL needed).

## run_metabase.sh behaviour
**Env vars read**
- `MB_JETTY_HOST`: default `0.0.0.0` if unset or empty.
- `JAVA_OPTS`: existing content kept; flags appended.
- `JAVA_TIMEZONE`: if set, adds `-Duser.timezone=<value>`.
- `MB_DB_FILE`: H2 path; default `/metabase.db`.
- `MUID`/`MGID`: IDs for the `metabase` account, default 2000.
- `_FILE` variants: via `file_env` for `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_CONNECTION_URI`, `MB_EMAIL_SMTP_PASSWORD`, `MB_EMAIL_SMTP_USERNAME`, `MB_LDAP_PASSWORD`, `MB_LDAP_BIND_DN`. Both `VAR` and `VAR_FILE` set = error exit 1.

**Java command line** (flags appended to JAVA_OPTS, in order):
`-XX:+IgnoreUnrecognizedVMOptions`, `-Dfile.encoding=UTF-8`, `-Dlogfile.path=target/log`, `-XX:+CrashOnOutOfMemoryError`, `-server`, `--add-opens java.base/java.nio=ALL-UNNAMED`, `-XX:-UseBASE64Intrinsics`, `--enable-native-access=ALL-UNNAMED`, and `-Duser.timezone` if `JAVA_TIMEZONE` set.
Final: `java $JAVA_OPTS -jar /app/metabase.jar $@`, run via `exec /bin/sh -c "exec ..."` so Java is PID 1. Script args passed through.

**Modes**
- Non-root: `docker_setup_env` then direct java launch.
- Root: creates group and user `metabase` if missing; launches via `su metabase -s /bin/sh -c` with `JAVA_HOME=/opt/java/openjdk` and its bin on PATH.

**Disk writes (root mode only)**
- DB directory named after `db_file`: if `$db_file.*` files exist and path is not a directory, moves them into a new directory; if no DB and no dir, creates an empty dir; if already a dir, no change.
- Exports `MB_DB_FILE=<dir>/<basename>`.
- `chown metabase:metabase` on the DB dir and contents; `chmod o+r /app/metabase.jar`.
- If `/app/initial*.db` exists: `chmod o+r`, then runs `java ... -jar /app/metabase.jar load-from-h2 <path without .mv.db>` as `metabase`; exits 1 on failure.
- Java logs via relative `target/log`.

**Bind/port**: only `MB_JETTY_HOST` (default 0.0.0.0). No port set in the script.

## Gotchas for our build
- Upstream jar path is `/app/metabase.jar`, not `/app/metabase/metabase.jar` as plan.md proposes.
- Upstream writes the H2 DB to `/metabase.db` by default: our build must set `MB_DB_FILE` into `/config` (plan.md's guess is now confirmed as `MB_DB_FILE`).
- The script's root mode writes to `/metabase.db`, `/plugins` and `target/log` (relative to cwd). With a read-only rootfs, cwd must be writable (`/config` as WORKDIR is fine) for `target/log`.
- Non-root `apps` run skips the chown path.
