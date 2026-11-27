target "docker-metadata-action" {}

variable "APP" {
  default = "openaudible"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=openaudible/openaudible versioning=loose extractVersion=^v(?<version>.+)$
  default = "5.3"
}

variable "LICENSE" {
  default = "LicenseRef-OpenAudible-Proprietary"
}

variable "SOURCE" {
  default = "https://openaudible.org/"
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

// Deviation: the vendor only ships an amd64 .deb, so this is amd64-only.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
