target "docker-metadata-action" {}

variable "APP" {
  default = "scrypted"
}

variable "VERSION" {
  // renovate: datasource=npm depName=@scrypted/server versioning=semver
  default = "0.147.0"
}

// UNVERIFIED: npm metadata says ISC; confirm the SPDX id against the repository LICENSE file.
variable "LICENSE" {
  default = "ISC"
}

variable "SOURCE" {
  default = "https://github.com/koush/scrypted"
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
