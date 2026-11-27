target "docker-metadata-action" {}

variable "APP" {
  default = "affine"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=toeverything/AFFiNE versioning=semver
  default = "0.27.4"
}

// UNVERIFIED: GitHub reports NOASSERTION. Set the SPDX id after reading the repository LICENSE file.
variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/toeverything/AFFiNE"
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
