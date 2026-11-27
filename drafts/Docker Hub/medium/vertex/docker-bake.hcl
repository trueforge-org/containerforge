target "docker-metadata-action" {}

variable "APP" {
  default = "vertex"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/vertex-app/vertex currentValue=master
  // pinned to the commit the upstream docker/Dockerfile was reviewed at; renovate proposes newer master commits
  default = "ec6fa1e6de502b8069ee0416d397ca419713473e"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/vertex-app/vertex"
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
