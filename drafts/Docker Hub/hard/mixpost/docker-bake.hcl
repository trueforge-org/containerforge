target "docker-metadata-action" {}

variable "APP" {
  default = "mixpost"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=inovector/mixpost versioning=semver
  default = "2.6.0"
}

variable "APP_VERSION" {
  // renovate: datasource=github-tags depName=inovector/MixpostApp versioning=semver extractVersion=^v(?<version>.+)$
  default = "2.1.1"
}

variable "LICENSE" {
  // The package is MIT. The skeleton declares no license upstream (UNVERIFIED), so record this in the PR.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/inovector/mixpost"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    APP_VERSION = "${APP_VERSION}"
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
