target "docker-metadata-action" {}

variable "APP" {
  default = "st-reborn-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tiltedphoques/TiltedEvolution versioning=semver
  default = "1.8.4"
}

variable "LICENSE" {
  // upstream LICENSE text is GPL v3 "or any later version"
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/tiltedphoques/TiltedEvolution"
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
