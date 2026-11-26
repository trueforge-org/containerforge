# sonatype/docker-nexus3 Dockerfile.java21 (aa22a3b)

**Source:** https://raw.githubusercontent.com/sonatype/docker-nexus3/aa22a3b/Dockerfile.java21 (fetched 2026-11-26; blob URL in urls.txt is the same file)

## Base / metadata
- FROM `redhat/ubi9-minimal` pinned by digest (no floating tag).
- License Apache 2.0. Marked **deprecated** in source; official images built by Sonatype internal pipeline.
- Labels: version 3.97.2-02, release 3.97.2, vendor Sonatype; exposes 8081.

## ARG
| ARG | Default |
|---|---|
| NEXUS_VERSION | 3.97.2-02 |
| NEXUS_DOWNLOAD_URL | https://download.sonatype.com/nexus/3/sonatype-nexus-repository-${NEXUS_VERSION}-assembly.zip |
| NEXUS_DOWNLOAD_SHA256_HASH | 9d20d1253e11320b707c53a0d548e4416e522cebd7fb070971b16713caa67ff1 |

## ENV
| Name | Value |
|---|---|
| SONATYPE_DIR | /opt/sonatype |
| NEXUS_HOME | ${SONATYPE_DIR}/nexus |
| NEXUS_DATA | /nexus-data |
| NEXUS_CONTEXT | "" (empty) |
| SONATYPE_WORK | ${SONATYPE_DIR}/sonatype-work |
| DOCKER_TYPE | rh-docker |
| LANG / LC_ALL | en_US.UTF-8 |
| INSTALL4J_ADD_VM_PARAMS | -Djava.util.prefs.userRoot=${NEXUS_DATA}/javaprefs -Dfile.encoding=UTF-8 |

## Packages
- microdnf (weak deps off, docs skipped): java-21-openjdk-headless, tar, procps, shadow-utils, gzip, unzip, glibc-langpack-en
- `microdnf update -y` first; cache cleaned.
- Later removed: gzip, shadow-utils, cups-libs, expat, openssl-fips-provider (+so), avahi-libs, dbus-libs (rpm --erase --nodeps)
- JDK demo dirs and jrt-fs.jar removed.

## User
- nexus system user UID 200, GID 200, shell /bin/false, home /opt/sonatype/nexus; `USER nexus`.

## Hardening step (build-time)
- Copies revoked-certs/ intermediates and SHA-256 list; adds to each JDK blocked.certs; p11-kit blocklist + `update-ca-trust extract`.
- Distrusts four eMudhra roots in Java cacerts and OS bundle.
- Build fails unless `distrust-emudhra-roots.sh check` and `EmudhraChainCheck.java` pass.
- Side effect: chains anchored only to emSign ECC Root CA - G3 or AAA Certificate Services stop validating.

## Download / install
1. WORKDIR /opt/sonatype; `curl -L` assembly zip; sha256sum -c check; unzip; delete zip/checksum.
2. Move nexus-${NEXUS_VERSION} to $NEXUS_HOME; chown -R nexus:nexus sonatype-work.
3. Move sonatype-work/nexus3 to /nexus-data; symlink back.
4. Create /opt/sonatype/start-nexus-repository-manager.sh (cd nexus; exec ./bin/nexus run) — not used by CMD.
5. chmod +x bin/nexus; sed appends NEXUS_CONTEXT to nexus-context in etc/nexus-default.properties.

## Runtime
| Item | Value |
|---|---|
| WORKDIR | /opt/sonatype |
| VOLUME | /nexus-data |
| EXPOSE | 8081 |
| ENTRYPOINT | none |
| CMD | ["/opt/sonatype/nexus/bin/nexus", "run"] |
| HEALTHCHECK | none |

## Paths
- /opt/sonatype/nexus (app); /opt/sonatype/sonatype-work/nexus3 -> /nexus-data (symlink); /nexus-data/javaprefs

## Gotchas
- Source is marked deprecated; upstream latest release is newer (see `nexus-public-release.md`).
