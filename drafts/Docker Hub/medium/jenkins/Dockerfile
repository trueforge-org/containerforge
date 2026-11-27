
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
ARG WAR_SHA256
USER root

ENV \
  JENKINS_HOME=/config \
  JENKINS_UC=https://updates.jenkins.io \
  HOME=/config

RUN echo "*** Installing Jenkins ***" && \
  mkdir -p /app /usr/share/licenses/jenkins && \
  curl -fsSL -o /app/jenkins.war \
    "https://get.jenkins.io/war/${VERSION}/jenkins.war" && \
  echo "${WAR_SHA256}  /app/jenkins.war" | sha256sum -c --strict - && \
  # UNVERIFIED: the LICENSE is fetched from master, not from a tag
  curl -fsSL -o /usr/share/licenses/jenkins/LICENSE.txt \
    "https://raw.githubusercontent.com/jenkinsci/jenkins/master/LICENSE.txt" && \
  chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080 50000

VOLUME /config
