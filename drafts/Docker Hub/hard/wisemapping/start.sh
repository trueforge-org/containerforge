#!/bin/sh
set -eu

mkdir -p /config /tmp/nginx /tmp/wisemapping

# Spring placeholders read the database settings from the environment, so the
# password never lands in a file or the process list.
if [ -n "${WISEMAPPING_DB_URL:-}" ]; then
  cat > /tmp/wisemapping/application.yml <<'EOF'
spring:
  datasource:
    url: ${WISEMAPPING_DB_URL}
    username: ${WISEMAPPING_DB_USER:wisemapping}
    password: ${WISEMAPPING_DB_PASSWORD}
    driver-class-name: org.postgresql.Driver
    hikari:
      data-source-properties:
        prepareThreshold: 0
  sql:
    init:
      mode: always
      platform: postgresql
      schema-locations: classpath:schema-postgresql.sql
      data-locations: classpath:data-postgresql.sql
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
EOF
else
  echo "WISEMAPPING_DB_URL not set, using embedded in-memory HSQLDB (data is lost on restart)" >&2
fi

# nginx serves the frontend on 8080 and proxies /api to the Java API on 8081
nginx -c /etc/nginx/nginx.conf -g 'daemon off;' &

# -XX:-UseBASE64Intrinsics is the upstream Java4Shell mitigation; UNVERIFIED whether still needed on 27.0.1.1
# shellcheck disable=SC2086
exec java -XX:-UseBASE64Intrinsics ${JAVA_OPTS:-} \
  -Dserver.port=8081 \
  -Dspring.config.additional-location=optional:file:/tmp/wisemapping/,optional:file:/config/ \
  -jar /app/wisemapping-api.jar
