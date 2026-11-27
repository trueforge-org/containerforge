target "docker-metadata-action" {}

variable "APP" {
  default = "seedsync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ipsingh06/seedsync versioning=semver
  default = "0.8.6"
}

// UNVERIFIED: confirm against the LICENSE file in the release (the raw LICENSE path returned 404 in the draft).
variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/ipsingh06/seedsync"
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
  // amd64 only: the v0.8.6 release has no arm64 .deb (arm64 would need a source build, not in this draft)
  platforms = [
    "linux/amd64"
  ]
}
