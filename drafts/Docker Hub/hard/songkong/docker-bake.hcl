target "docker-metadata-action" {}

variable "APP" {
  default = "songkong"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource exists for jthink.net, so bump this by hand.
  default = "12.11"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.jthink.net/songkong/"
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
  // UNVERIFIED arm64: keep amd64 only until an arm64 Linux build is confirmed
  platforms = [
    "linux/amd64"
  ]
}
