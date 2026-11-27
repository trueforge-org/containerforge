target "docker-metadata-action" {}

variable "APP" {
  default = "bentopdf"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=alam00000/bentopdf versioning=semver
  default = "v2.8.12"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports AGPL-3.0; confirm against the LICENSE file before merge.
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/alam00000/bentopdf"
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
