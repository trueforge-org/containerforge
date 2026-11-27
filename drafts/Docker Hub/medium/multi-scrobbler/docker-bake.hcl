target "docker-metadata-action" {}

variable "APP" {
  default = "multi-scrobbler"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=FoxxMD/multi-scrobbler versioning=semver
  // UNVERIFIED: 0.21.2 not yet checked against upstream; 0.21.1 was the verified tag
  default = "0.21.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/FoxxMD/multi-scrobbler"
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
