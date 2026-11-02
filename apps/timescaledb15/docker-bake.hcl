target "docker-metadata-action" {}

variable "APP" {
  default = "timescaledb15"
}

variable "VERSION" {
  // CloudNativePG reads the PostgreSQL version from the image tag, so the tag has to be that version
  // renovate: datasource=docker depName=ghcr.io/cloudnative-pg/postgresql versioning=loose extractVersion=^(?<version>15\.\d+)-standard-trixie$
  default = "15.19"
}

variable "PG_MAJOR" {
  default = "15"
}

variable "TIMESCALEDB_VERSION" {
  // The last TimescaleDB release with packages for PostgreSQL 15
  default = "2.28.3"
}

variable "LICENSE" {
  default = "Apache-2.0 AND LicenseRef-Timescale"
}

variable "SOURCE" {
  default = "https://github.com/timescale/timescaledb"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PG_MAJOR = "${PG_MAJOR}"
    TIMESCALEDB_VERSION = "${TIMESCALEDB_VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
