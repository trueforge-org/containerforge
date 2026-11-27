#!/bin/sh
set -eu

# DATABASE_PASSWORD has no default and is never written to a file or to the command line.
: "${DATABASE_PASSWORD:?DATABASE_PASSWORD is required (set it to the MariaDB password)}"

# /app/data and /bookdrop are symlinks into /config (made at build time). Create the targets only when missing.
mkdir -p /config/data /config/bookdrop

exec java -jar /app/app.jar
