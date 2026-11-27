target "docker-metadata-action" {}

variable "APP" {
  default = "mysql-workbench"
}

variable "VERSION" {
  // renovate: UNVERIFIED no datasource fits the Oracle CDN deb; placeholder until a mechanism is chosen
  // renovate: datasource=github-releases depName=mysql/mysql-workbench versioning=loose
  default = "8.0.47"
}

variable "LICENSE" {
  default = "GPL-2.0-only" // UNVERIFIED: GitHub reports NOASSERTION; confirm from the LICENSE file before merge
}

variable "SOURCE" {
  default = "https://github.com/mysql/mysql-workbench"
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

// amd64 only: Oracle publishes no arm64 deb for this version
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
