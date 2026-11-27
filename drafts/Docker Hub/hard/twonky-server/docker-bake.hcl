target "docker-metadata-action" {}

variable "APP" {
  default = "twonky-server"
}

variable "VERSION" {
  // renovate: none. Closed source with no release feed. Bump VERSION and TWONKY_SHA256 together by hand.
  default = "8.5.2"
}

variable "TWONKY_SHA256" {
  // sha256 of twonky-x86-64-glibc-2.22-${VERSION}.zip, computed from the vendor download. Recompute on every bump.
  default = "d8cc1785aa4498b95564ee1bce02851b7e66372b93f7ff249bb4568cecd7b58b"
}

variable "LICENSE" {
  // Proprietary. UNVERIFIED: redistribution in a public image needs maintainer review.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.twonky.com/download/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    TWONKY_SHA256 = "${TWONKY_SHA256}"
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
  // No arm64 build is published by the vendor.
  platforms = [
    "linux/amd64"
  ]
}
