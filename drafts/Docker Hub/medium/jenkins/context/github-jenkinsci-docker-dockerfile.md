# jenkinsci/docker: debian/Dockerfile (tag 2.544)
Source URL(s): https://github.com/jenkinsci/docker/blob/2.544/debian/Dockerfile = raw at 2.544 (fetched 2026-11-26, 168 lines)

## Stages
1. jre-build: FROM debian:trixie-20251117-slim; ARG JAVA_VERSION=17.0.17_10; COPY jdk-download-url.sh, jdk-download.sh to /usr/bin; apt ca-certificates curl jq; RUN /usr/bin/jdk-download.sh (JDK to /opt/jdk-${JAVA_VERSION}); jlink custom runtime to /javaruntime (--add-modules ALL-MODULE-PATH; compress per JDK major: 17 -> --compress=2, 21 -> zip-6, 25 -> full copy)
2. controller: FROM debian:trixie-20251117-slim
   - apt: ca-certificates curl git gnupg gpg libfontconfig1 libfreetype6 procps ssh-client tini unzip tzdata
   - Git LFS 3.7.1 tarball from github.com/git-lfs/git-lfs releases, install.sh
   - user jenkins uid/gid 1000 (ARG user/group/uid/gid); JENKINS_HOME=/var/jenkins_home; REF=/usr/share/jenkins/ref
   - ARG JENKINS_VERSION; ENV JENKINS_VERSION=${JENKINS_VERSION:-2.534}
   - WAR: ARG WAR_URL=https://get.jenkins.io/war/${JENKINS_VERSION}/jenkins.war -> /usr/share/jenkins/jenkins.war; sha256 check with ARG WAR_SHA (default fcf13a8ebbe69d678608cc4b3885ece7d7e697d6da4c3691025a06968ddef228)
   - plugin manager: ARG PLUGIN_CLI_VERSION=2.13.2 -> /opt/jenkins-plugin-manager.jar, sha256 from release .sha256
   - ENV JENKINS_UC=https://updates.jenkins.io, JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental, JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
   - ENV JAVA_HOME=/opt/java/openjdk; PATH includes it; COPY --from=jre-build /javaruntime $JAVA_HOME
   - COPY jenkins-support, jenkins.sh, jenkins-plugin-cli.sh
3. Runtime: USER jenkins; ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]; EXPOSE 8080 (http_port) and 50000 (agent_port); VOLUME $JENKINS_HOME; LABEL org.opencontainers.image.licenses=MIT

## Env (image)
| Env | Value |
| --- | --- |
| LANG | C.UTF-8 |
| JENKINS_HOME | /var/jenkins_home |
| JENKINS_SLAVE_AGENT_PORT | 50000 |
| REF | /usr/share/jenkins/ref |
| COPY_REFERENCE_FILE_LOG | $JENKINS_HOME/copy_reference_file.log |
| JENKINS_UC / JENKINS_UC_EXPERIMENTAL / JENKINS_INCREMENTALS_REPO_MIRROR | see above |

## Gotchas
- JENKINS_VERSION ENV default in file is 2.534 but tag is 2.544: pass JENKINS_VERSION as build arg. WAR_SHA is a fixed default sha; overriding the version requires the matching WAR_SHA (sha256 check fails otherwise). Matching sha for 2.544 not verified here.
- War download is at build time from get.jenkins.io (binary; not fetched).
- Runs as jenkins uid 1000.
