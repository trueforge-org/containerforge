target "docker-metadata-action" {}

variable "APP" {
  default = "alienswarm-reactivedrop"
}

// ContainerForge build version. The Steam game has no published version, so it is not tracked here.
variable "VERSION" {
  default = "0.1.0"
}

// UNVERIFIED: the game is proprietary Valve content. Confirm the label with the maintainer.
variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
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
    "linux/amd64"
  ]
}
