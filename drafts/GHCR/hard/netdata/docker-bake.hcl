target "docker-metadata-action" {}

variable "APP" {
  default = "netdata"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=netdata/netdata versioning=semver
  default = "v2.13.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-3.0; confirm -only or -or-later from the licence headers.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/netdata/netdata"
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
