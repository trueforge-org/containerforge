target "docker-metadata-action" {}

variable "APP" {
  default = "nosqlclient"
}

variable "VERSION" {
  // renovate: datasource=docker depName=mongoclient/mongoclient versioning=loose
  // NOTE: upstream has had no release since 2020, so renovate will not propose a new version.
  default = "4.0.1"
}

variable "NODE_VERSION" {
  default = "12.16.1"
}

variable "NODE_SHA256" {
  default = "b826753f14df9771609ffb8e7d2cc4cb395247cb704cf0cea0f04132d9cf3505"
}

// UNVERIFIED: AGPL-3.0-only versus AGPL-3.0-or-later, check the LICENSE header.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/nosqlclient/nosqlclient"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    NODE_VERSION = "${NODE_VERSION}"
    NODE_SHA256 = "${NODE_SHA256}"
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

// Deviation from the standard two-platform list: the upstream bundle is amd64 only.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
