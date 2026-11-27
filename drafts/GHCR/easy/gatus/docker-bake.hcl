target "docker-metadata-action" {}

variable "APP" {
  default = "gatus"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=home-operations/gatus-sidecar versioning=semver
  default = "0.6.1"
}

variable "REVISION" {
  // UNVERIFIED: set to the commit SHA of the tag when building. Empty falls back to "unknown" in the Dockerfile.
  default = ""
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/home-operations/gatus-sidecar"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    REVISION = "${REVISION}"
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
