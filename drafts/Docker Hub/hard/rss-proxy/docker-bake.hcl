target "docker-metadata-action" {}

variable "APP" {
  default = "rss-proxy"
}

variable "VERSION" {
  // renovate: datasource=docker depName=damoeb/rss-proxy versioning=semver
  default = "2.1.1"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-3.0-only vs GPL-3.0-or-later; check the LICENSE file
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/damoeb/rss-proxy"
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
