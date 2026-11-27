target "docker-metadata-action" {}

variable "APP" {
  default = "kanboard"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kanboard/kanboard versioning=semver
  default = "v1.2.58"
}

variable "ARCHIVE_SHA256" {
  // UNVERIFIED: sha256 of https://github.com/kanboard/kanboard/archive/refs/tags/v1.2.58.tar.gz. Empty until filled in, so the build fails on purpose.
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/kanboard/kanboard"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ARCHIVE_SHA256 = "${ARCHIVE_SHA256}"
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
