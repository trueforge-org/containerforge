target "docker-metadata-action" {}

variable "APP" {
  default = "python-node"
}

variable "VERSION" {
  default = "3.13.7"
}

variable "NODE_VERSION" {
  default = "22.20.0"
}

variable "YARN_VERSION"{
  default = "1.22.22"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://hub.docker.com/_/node"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    NODE_VERSION = "${NODE_VERSION}"
    YARN_VERSION = "${YARN_VERSION}"
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
