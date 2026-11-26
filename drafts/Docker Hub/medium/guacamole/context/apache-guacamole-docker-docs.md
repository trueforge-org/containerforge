# Apache Guacamole: Docker docs
Source URL(s): https://guacamole.apache.org/doc/gug (fetched; 480 lines, version 1.6.0 mentions); https://guacamole.apache.org/doc/gug/guacamole-docker.html (fetched; 708 lines)

## Docker layout (from guacamole-docker.html)
- Two images: guacamole/guacamole (Guacamole web app in Tomcat 9.x, port 8080) and guacamole/guacd (native proxy, default port 4822).
- guacd should be reached over the internal Docker network only; do not expose 4822 externally.
- Config dir: GUACAMOLE_HOME (default /etc/guacamole); env var names seen: GUACAMOLE_HOME, GUACD_HOSTNAME, GUACD_PORT.
- Web app URL: http://HOSTNAME:8080/guacamole/

## Gotchas
- Docs describe guacd on 4822 by default; the TrueCharts chart runs guacd on 10124 (see truecharts-guacamole.md).
