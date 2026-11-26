# splunk/docker-splunk splunk/common-files/Dockerfile

Source URL(s): https://github.com/splunk/docker-splunk/blob/a2c049c/splunk/common-files/Dockerfile (raw, fetched 2026-11-26)

## Build args
- `SPLUNK_BASE_IMAGE` (default `base-debian-10`), `SPLUNK_BUILD_URL` (Splunk tgz; .sha512 fetched alongside), `SPLUNK_DEFAULTS_URL` (full stage), `UID` default 41812, `GID` default 41812

## Stages
| Stage | Base | Notes |
| --- | --- | --- |
| package | `${SPLUNK_BASE_IMAGE}:latest` | wget tgz + .sha512 (retries 5), sha512sum check; make-minimal-exclude.py builds exclude list; untar to /minimal/splunk and /extras/splunk; etc moved to /minimal/splunk-etc and /extras/splunk-etc; COPY splunk/common-files/apps -> /extras/splunk-etc/apps/ |
| minimal | `${SPLUNK_BASE_IMAGE}:latest` | ENV SPLUNK_HOME=/opt/splunk, SPLUNK_GROUP=splunk, SPLUNK_USER=splunk, TMPSPLUNKDIR=${SPLUNK_HOME}/tmp, TMPETCDIR=${TMPSPLUNKDIR}/etc; groupadd -r -g 41812 splunk; useradd -r -m -u 41812 -g 41812 -s /bin/bash splunk; COPY updateetc.sh -> /sbin/; `USER splunk`; `WORKDIR /opt/splunk`; `EXPOSE 8000/tcp 8089/tcp` |
| bare | minimal | COPY --from=package /extras -> /opt; `EXPOSE 8000 8065 8088 8089 8191 9887 9997`; `VOLUME ["/opt/splunk/etc", "/opt/splunk/var"]` (BYO entrypoint) |
| full (default last stage) | bare | ENV SPLUNK_ROLE=splunk_standalone, SPLUNK_DEFAULTS_URL, SPLUNK_ANSIBLE_HOME=/opt/ansible, ANSIBLE_USER=ansible, ANSIBLE_GROUP=ansible, CONTAINER_ARTIFACT_DIR=/opt/container_artifact; `USER root`; COPY entrypoint.sh, createdefaults.py, checkstate.sh -> /sbin/; COPY splunk-ansible -> /opt/ansible; sudoers NOPASSWD for %sudo and ansible; creates ansible user/group; adds ansible to sudo and splunk group |

## Gotchas
- Splunk user UID/GID fixed 41812 (k8s UID requirement). Full image switches to root for Ansible entrypoint.
- Only 8000/8089 exposed in minimal; bare/full add 8065 8088 8191 9887 9997.
- Base image `base-debian-10` (overridable).
