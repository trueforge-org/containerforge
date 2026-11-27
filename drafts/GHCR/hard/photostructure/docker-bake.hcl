target "docker-metadata-action" {}

variable "APP" {
  default = "photostructure"
}

variable "VERSION" {
  // renovate: datasource=npm depName=photostructure versioning=semver
  default = "2026.10.3"
}

variable "LICENSE" {
  // Placeholder. PhotoStructure is proprietary (npm: SEE LICENSE IN LICENSE.md). The user must decide how to record it before any PR (plan section 10).
  default = "LicenseRef-PhotoStructure-Proprietary"
}

variable "SOURCE" {
  default = "https://github.com/photostructure/photostructure-for-servers"
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
