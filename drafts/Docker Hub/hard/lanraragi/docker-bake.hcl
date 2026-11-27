target "docker-metadata-action" {}

variable "APP" {
  default = "lanraragi"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Difegue/LANraragi versioning=loose extractVersion=^v\.(?<version>.+)$
  default = "0.9.82"
}

variable "LICENSE" {
  // UNVERIFIED: MIT is from the draft; confirm against the LICENSE file at the tag.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Difegue/LANraragi"
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
