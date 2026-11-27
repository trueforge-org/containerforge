target "docker-metadata-action" {}

variable "APP" {
  default = "serpbear"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=towfiqi/serpbear versioning=semver
  default = "3.1.2"
}

// UNVERIFIED: sha256 of https://github.com/towfiqi/serpbear/archive/refs/tags/v3.1.2.tar.gz (not computed yet). Fill in before building.
variable "SERPBEAR_SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/towfiqi/serpbear"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SERPBEAR_SHA256 = "${SERPBEAR_SHA256}"
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
