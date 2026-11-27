target "docker-metadata-action" {}

variable "APP" {
  default = "jupyter-minimal"
}

variable "VERSION" {
  // renovate: datasource=docker depName=quay.io/jupyter/minimal-notebook versioning=loose
  default = "notebook-7.6.5"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/jupyter/docker-stacks"
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
