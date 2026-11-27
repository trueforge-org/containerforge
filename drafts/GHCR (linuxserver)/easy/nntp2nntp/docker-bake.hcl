target "docker-metadata-action" {}

variable "APP" {
  default = "nntp2nntp"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=linuxserver/nntp2nntp versioning=loose
  default = "0.3"
}

variable "LICENSE" {
  default = "WTFPL"
}

variable "SOURCE" {
  default = "https://github.com/linuxserver/nntp2nntp"
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
