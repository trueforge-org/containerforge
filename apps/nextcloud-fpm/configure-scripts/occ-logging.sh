#!/bin/sh
occ_logging() {
  echo '## Configuring Logging...'
  log_file="${NX_LOG_FILE:-"/var/www/html/data/nextcloud.log"}"
  log_file_audit="${NX_LOG_FILE_AUDIT:-"/var/www/html/data/audit.log"}"

  # Nextcloud silently falls back to <datadirectory>/nextcloud.log if the
  # directory of the configured logfile does not exist, while log rotation
  # keeps checking the configured path and therefore never rotates.
  for log_dir in "$(dirname "$log_file")" "$(dirname "$log_file_audit")"; do
    mkdir -p "$log_dir" || echo "Failed to create log directory [$log_dir]"
  done

  occ config:system:set log_type --value="file"
  occ config:system:set log_type_audit --value="file"
  occ config:system:set loglevel --value="${NX_LOG_LEVEL:-2}"
  occ config:system:set logfile --value="$log_file"
  occ config:system:set logfile_audit --value="$log_file_audit"
  occ config:system:set logdateformat --value="${NX_LOG_DATE_FORMAT:-"d/m/Y H:i:s"}"
  occ config:system:set logtimezone --value="${NX_LOG_TIMEZONE:-$TZ}"
}
