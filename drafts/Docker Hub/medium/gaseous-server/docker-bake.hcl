target "docker-metadata-action" {}

variable "APP" {
  default = "gaseous-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gaseous-project/gaseous-server versioning=semver
  default = "v1.7.14"
}

variable "LICENSE" {
  // Exact SPDX variant (-only or -or-later) is UNVERIFIED: read the LICENSE text before release.
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/gaseous-project/gaseous-server"
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
