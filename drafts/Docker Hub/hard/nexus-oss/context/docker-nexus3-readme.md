# sonatype/docker-nexus3 README

**Source:** https://raw.githubusercontent.com/sonatype/docker-nexus3/master/README.md (fetched 2026-11-26)

## Image tags
- `sonatype/nexus3:latest` (Alpine, default since 3.91.0, Java 21)
- `sonatype/nexus3:3.XX.y` and `-alpine` (Alpine); `3.XX.y-ubi` (Red Hat UBI)
- Red Hat certified image: registry.connect.redhat.com/sonatype/nexus-repository-manager
- Other variants: Dockerfile.rh.el, Dockerfile.rh.centos

## Build variables (optional)
- NEXUS_VERSION, NEXUS_DOWNLOAD_URL, NEXUS_DOWNLOAD_SHA256_HASH (required with version/URL)
- UBI: `docker build --rm=true --tag=sonatype/nexus3 -f Dockerfile.java21 .`; Alpine: `-f Dockerfile.alpine.java21`
- Runtime and app layers built with Chef Solo (cookbook sonatype/chef-nexus-repository-manager)

## Run
- `docker run -d -p 8081:8081 --name nexus sonatype/nexus3`
- Named volume: `-v nexus-data:/nexus-data`; host dir needs `chown -R 200`.
- Graceful stop: `docker stop --time=120`.
- Startup 2-3 min; tail logs.

## Env vars
| Name | Default | Purpose |
|---|---|---|
| INSTALL4J_ADD_VM_PARAMS | -Djava.util.prefs.userRoot=${NEXUS_DATA}/javaprefs | JVM args for Install4J script |
| NEXUS_CONTEXT | / | context path (e.g. `nexus`) |

- JVM tuning example: `-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m`

## Ports / volumes / user
- 8081; /nexus-data (persistent, must be writable); /opt/sonatype/nexus install dir.
- Admin password in admin.password file inside data volume (user `admin`).
- Runs as UID 200. Red Hat image entrypoint handles OpenShift restricted SCC.
- Healthcheck: none.

## Versions
- 3.77.0: free edition renamed Community Edition.
- 3.91.0: default image switched to Alpine; UBI via `-ubi` suffix.
