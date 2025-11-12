target "docker-metadata-action" {}

variable "APP" {
  default = "postgresql"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/postgres
  default = "18.0"
}

variable "PG_MAJOR" {
  // renovate: datasource=docker depName=docker.io/library/postgres
  default = "18"
}

variable "BARMANVERSION" {
  // renovate: datasource=pypi versioning=loose depName=barman
  default = "3.16.2"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-late"
}


variable "SOURCE" {
  default = "https://postgresql.org"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BARMANVERSION = "${BARMANVERSION}"
    PG_MAJOR = "${PG_MAJOR}"
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
