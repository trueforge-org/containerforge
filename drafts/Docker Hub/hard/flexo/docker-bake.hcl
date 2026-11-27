target "docker-metadata-action" {}

variable "APP" {
  default = "flexo"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=nroi/flexo versioning=semver
  default = "1.6.14"
}

variable "SCRUFFY_VERSION" {
  // renovate: datasource=github-tags depName=nroi/scruffy versioning=semver
  default = "0.2.0"
}

variable "LICENSE" {
  default = "MIT AND GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/nroi/flexo"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SCRUFFY_VERSION = "${SCRUFFY_VERSION}"
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
