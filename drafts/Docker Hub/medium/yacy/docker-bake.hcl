target "docker-metadata-action" {}

variable "APP" {
  default = "yacy"
}

variable "VERSION" {
  // renovate: datasource=custom.yacy depName=yacy_v versioning=loose
  // UNVERIFIED: no built-in renovate datasource tracks download.yacy.net; a customManagers regex is needed.
  default = "1.942_202608150808_f9c4b9700"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-2.0-or-later per project docs; confirm from the LICENSE file in the tarball.
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/yacy/yacy_search_server"
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
