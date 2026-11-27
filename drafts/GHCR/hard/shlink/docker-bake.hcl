target "docker-metadata-action" {}

variable "APP" {
  default = "shlink"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shlinkio/shlink versioning=semver
  default = "5.1.9"
}

variable "SHLINK_SHA256" {
  // UNVERIFIED: no upstream checksum published; set after first download
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/shlinkio/shlink"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHLINK_SHA256 = "${SHLINK_SHA256}"
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
