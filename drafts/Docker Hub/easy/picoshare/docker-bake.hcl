target "docker-metadata-action" {}

variable "APP" {
  default = "picoshare"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mtlynch/picoshare versioning=semver
  default = "1.5.5"
}

variable "LICENSE" {
  // UNVERIFIED: README says AGPL; SPDX "-or-later" taken from the LICENSE header in the plan
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/mtlynch/picoshare"
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
