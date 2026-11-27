target "docker-metadata-action" {}

variable "APP" {
  default = "factorio"
}

variable "VERSION" {
  // renovate: datasource=docker depName=factoriotools/factorio versioning=semver
  default = "2.1.25"
}

variable "LICENSE" {
  // UNVERIFIED: the repo may not accept a non-SPDX license id; maintainers to confirm.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://factorio.com/"
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
