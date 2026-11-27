target "docker-metadata-action" {}

variable "APP" {
  default = "gonic"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sentriz/gonic versioning=semver
  default = "0.23.0"
}

variable "LICENSE" {
  // UNVERIFIED: confirm GPL-3.0-only or GPL-3.0-or-later against the upstream LICENSE file.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/sentriz/gonic"
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
