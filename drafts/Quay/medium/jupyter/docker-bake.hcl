target "docker-metadata-action" {}

variable "APP" {
  default = "jupyter"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=notebook versioning=pep440
  default = "7.6.5"
}

variable "JUPYTERLAB_VERSION" {
  // renovate: datasource=pypi depName=jupyterlab versioning=pep440
  default = "4.6.6"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/jupyter/notebook"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    JUPYTERLAB_VERSION = "${JUPYTERLAB_VERSION}"
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
