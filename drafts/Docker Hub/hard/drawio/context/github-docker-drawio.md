# jgraph/docker-drawio (Dockerfile and docker-entrypoint.sh at d2e740b)

Source URL(s) + fetch date:
- https://github.com/jgraph/docker-drawio/blob/d2e740b/main/Dockerfile (fetched as raw.githubusercontent.com/jgraph/docker-drawio/d2e740b/main/Dockerfile)
- https://raw.githubusercontent.com/jgraph/docker-drawio/d2e740b/main/docker-entrypoint.sh
- Fetched 2026-11-26

## What it is
- Official draw.io Docker image build: draw.io web app (draw.war) built from source, deployed in Tomcat 9 on JDK 11.

## Install/build steps and build deps
- Stage 1 `build`: `FROM eclipse-temurin:11-jdk-jammy AS build`. RUN: `apt-get update -y`, `mkdir -p /usr/share/man/man1` (workaround for an openjdk-11-jdk-headless issue), `apt-get install -y ant git`. RUN: `cd /tmp`, `git clone --depth 1 https://github.com/jgraph/drawio.git`, `cd /tmp/drawio/etc/build/`, `ant war`.
- Stage 2: `FROM tomcat:9.0-jdk11-temurin`. LABEL maintainer and org.opencontainers.image.* (draw.io Ltd).
- ENV `RUN_USER tomcat`, `RUN_GROUP tomcat`. No ARG.
- RUN packages: `apt-get install -y --no-install-recommends certbot curl xmlstarlet unzip`, then autoremove/clean.
- COPY `--from=build /tmp/drawio/build/draw.war /tmp`.
- RUN extract: `mkdir -p $CATALINA_HOME/webapps/draw`; `unzip /tmp/draw.war -d $CATALINA_HOME/webapps/draw`; `rm -rf /tmp/draw.war /tmp/drawio`.
- RUN xmlstarlet on `conf/server.xml`: adds a `Context` under `/Server/Service/Engine/Host`, sets `path="/"` and `docBase="draw"`, adds `WatchedResource` `WEB-INF/web.xml`.
- COPY `docker-entrypoint.sh /`; `chmod 755 /docker-entrypoint.sh`.
- User: `groupadd -r -g 999 ${RUN_GROUP}`; `useradd -u 1001 -g ${RUN_GROUP} -d ${CATALINA_HOME} -s /bin/bash ${RUN_USER}`; `chown -R ${RUN_USER}:0 ${CATALINA_HOME}`; `chmod -R g=u ${CATALINA_HOME}` (group 0 gets owner rights for arbitrary-UID runs, jgraph/docker-drawio#186).
- `USER ${RUN_USER}`, `WORKDIR $CATALINA_HOME`, `EXPOSE 8080 8443`, no VOLUME.
- `ENTRYPOINT ["/docker-entrypoint.sh"]`, `CMD ["catalina.sh", "run"]`.

## Runtime deps
- Tomcat 9 on Temurin JDK 11 (base image). certbot, curl, xmlstarlet, unzip (apt, final stage).
- Export server: not in this Dockerfile.

## Binaries/entrypoint/CLI flags
- Entrypoint runs setup then `exec "$@"` (CMD `catalina.sh run`).

## Env vars (docker-entrypoint.sh, full list)
| Name | Default | Notes |
| --- | --- | --- |
| LETS_ENCRYPT_ENABLED | false | Let's Encrypt via certbot standalone when true. |
| PUBLIC_DNS | draw.example.com | Certificate DN and HTTPS connector hostName. |
| ORGANISATION_UNIT | Cloud Native Application | Cert DN. |
| ORGANISATION | example inc | Cert DN. |
| CITY | Paris | Cert DN. |
| STATE | Paris | Cert DN. |
| COUNTRY_CODE | FR | Cert DN. |
| KEYSTORE_PASS | built-in placeholder (Hub shows V3ry1nS3cur3P4ssw0rd) | Keystore password. |
| KEY_PASS | falls back to KEYSTORE_PASS | Key password. |
| CATALINA_HOME | (image env) | Used in all paths. |
| DRAWIO_CSP_HEADER | long built-in CSP | Written into PreConfig.js meta tag. |
| DRAWIO_GITLAB_ID | empty | Adds GitLab URL to connect-src when set. |
| DRAWIO_GITLAB_URL | empty | GitLab base URL (PreConfig and PostConfig). |
| DRAWIO_GITLAB_SECRET | empty | WEB-INF/gitlab_client_secret. |
| DRAWIO_SERVER_URL | empty | Server URL for PreConfig. |
| DRAWIO_BASE_URL | empty (falls back to http://localhost:8080 if neither set) | Base URL; path part sets Tomcat context path. |
| DRAWIO_VIEWER_URL | empty | PreConfig. |
| DRAWIO_LIGHTBOX_URL | empty | PreConfig. |
| DRAWIO_CONFIG | empty | JSON config (defaults null). |
| DRAWIO_CONFIG_FILE | empty | Takes precedence over DRAWIO_CONFIG. |
| DRAWIO_LANG | empty | Language code, lowercased into mxLanguage. |
| DRAWIO_GOOGLE_CLIENT_ID, DRAWIO_GOOGLE_APP_ID, DRAWIO_GOOGLE_CLIENT_SECRET | empty | Google Drive; WEB-INF/google_client_id and google_client_secret. |
| DRAWIO_GOOGLE_VIEWER_CLIENT_ID, DRAWIO_GOOGLE_VIEWER_APP_ID, DRAWIO_GOOGLE_VIEWER_CLIENT_SECRET | empty | Google viewer variants. |
| DRAWIO_MSGRAPH_CLIENT_ID, DRAWIO_MSGRAPH_CLIENT_SECRET, DRAWIO_MSGRAPH_TENANT_ID | empty | OneDrive; WEB-INF/msgraph_*. |

- No `DRAWIO_*` tuning flags beyond the above. Google disabled via `urlParams['gapi']=0` when unset; OneDrive via `od=0`; GitLab via `gl=0`.

## Ports
- EXPOSE 8080 (HTTP) and 8443 (HTTPS, only when a keystore exists and the connector is added at runtime).

## Volumes/paths and persistent data
- No VOLUME. Entrypoint writes into `$CATALINA_HOME/webapps/draw/js/PreConfig.js` (rebuilt each start) and `PostConfig.js` (appended), `$CATALINA_HOME/webapps/draw/WEB-INF/*` secret files, `conf/server.xml` (edited in place), `$CATALINA_HOME/.keystore`, `request.csr` (working dir, Let's Encrypt), reads `0001_chain.pem`.
- If `touch` on PreConfig.js fails (no write access), the script prints a warning, skips runtime config and execs the command.

## PreConfig.js (generated contents, by source)
- CSP meta from DRAWIO_CSP_HEADER or default; adds DRAWIO_GITLAB_URL to connect-src when GitLab ID set.
- window.DRAWIO_SERVER_URL / DRAWIO_BASE_URL; DRAWIO_VIEWER_URL; DRAWIO_LIGHTBOX_URL; DRAW_MATH_URL='math4/es5'; EXPORT_URL=null; DRAWIO_CONFIG; mxLanguage; urlParams sync=manual, db=0, gh=0, tr=0; gapi/od/gl set to 0 when unset.
- PostConfig.js: ICONSEARCH_PATH=null; EditorUi.enableLogging=false; enableCustomGitLabUrl=true when GitLab URL set and not https://gitlab.com; App.prototype.isDriveDomain returns true.

## Tomcat context path
- If DRAWIO_BASE_URL/SERVER_URL has a path, Context @path becomes `/<last segment>`; otherwise root.

## Keystore/TLS (runtime)
- Let's Encrypt (LETS_ENCRYPT_ENABLED=true, no .keystore): keytool genkey alias `tomcat` RSA 2048 PKCS12, certreq -> request.csr, `certbot certonly --csr ... --standalone --register-unsafely-without-email --agree-tos`, import `0001_chain.pem`.
- Self-signed (default): keytool genkey alias `selfsigned` RSA 2048, validity 3600, PKCS12.
- HTTPS connector on 8443 appended to server.xml (Http11NioProtocol, SSLEnabled=true, TLSv1.2, certificateKeystoreFile `$CATALINA_HOME/.keystore`, password KEY_PASS).

## User/UID & permissions
- Runs as `tomcat` UID 1001, GID 999 group created (`groupadd -g 999`); `$CATALINA_HOME` owned by tomcat:0 with g=u.

## Healthcheck/readiness endpoints
- None in Dockerfile.

## Gotchas
- Let's Encrypt standalone needs port 80 reachable; Hub example maps 80:80 and 443:8443.
- Hub run example uses `?offline=1` to disable cloud storage.
