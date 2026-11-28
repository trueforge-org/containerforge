target "docker-metadata-action" {}

variable "APP" {
  default = "couchpotato"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bassings/CouchPotatoServer versioning=loose
  default = "3.312.0"
}

variable "LICENSE" {
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/bassings/CouchPotatoServer"
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
