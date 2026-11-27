target "docker-metadata-action" {}

variable "APP" {
  default = "sqlitebrowser"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sqlitebrowser/sqlitebrowser versioning=semver
  default = "3.13.1"
}

variable "LICENSE" {
  default = "MPL-2.0 OR GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/sqlitebrowser/sqlitebrowser"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
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
