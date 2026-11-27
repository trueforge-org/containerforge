target "docker-metadata-action" {}

variable "APP" {
  default = "filebot"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource tracks FileBot 5.3.0 (github-releases tracks the wrapper only). Choose a custom manager or update by hand.
  default = "5.3.0"
}

variable "LICENSE" {
  // UNVERIFIED: FileBot license and key requirement not confirmed. Resolve before merging.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.filebot.net/"
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
