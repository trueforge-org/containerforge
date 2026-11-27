target "docker-metadata-action" {}

variable "APP" {
  default = "rapidphotodownloader"
}

// renovate: datasource=github-releases depName=damonlynch/rapid-photo-downloader versioning=loose
variable "VERSION" {
  default = "0.9.37"
}

// UNVERIFIED: SPDX suffix (-only or -or-later) must be checked against the source headers
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/damonlynch/rapid-photo-downloader"
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

// UNVERIFIED: arm64 apt package availability; drop linux/arm64 if it is not confirmed
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
