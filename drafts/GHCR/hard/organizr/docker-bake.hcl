target "docker-metadata-action" {}

variable "APP" {
  default = "organizr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=causefx/Organizr versioning=loose
  default = "1.601"
}

variable "LICENSE" {
  // UNVERIFIED: no license is named in the fetched sources. Replace with the SPDX id once confirmed.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/causefx/Organizr"
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
