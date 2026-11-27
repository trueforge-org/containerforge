target "docker-metadata-action" {}

variable "APP" {
  default = "friendica"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=friendica/friendica versioning=loose extractVersion=^(?<version>\d{4}\.\d{2})(?:-\d+)?$
  // UNVERIFIED: regex not tested against the tag list (2026.05 and 2026.05-1 must both resolve to 2026.05)
  default = "2026.05"
}

variable "LICENSE" {
  // UNVERIFIED: whether the source headers say "or later"
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/friendica/friendica"
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
