target "docker-metadata-action" {}

variable "APP" {
  default = "borg-server"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=borgbackup versioning=pep440
  default = "1.4.5"
}

variable "LICENSE" {
  // UNVERIFIED: BSD-style licence text in borg's LICENSE file. Check the file for the SPDX id before commit.
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/borgbackup/borg"
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
