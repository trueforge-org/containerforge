target "docker-metadata-action" {}

variable "APP" {
  default = "kiwix-serve"
}

variable "VERSION" {
  // renovate: datasource=deb depName=kiwix-tools registryUrl=https://archive.ubuntu.com/ubuntu
  // UNVERIFIED: apt 3.7.0 is older than the upstream 3.8.2 tag. The apt route cannot give 3.8.2.
  default = "3.7.0-1.1build2"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-3.0; confirm the SPDX id against the LICENSE file.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/kiwix/kiwix-tools"
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
