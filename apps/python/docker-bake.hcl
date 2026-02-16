target "docker-metadata-action" {}

variable "APP" {
  default = "python"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/python
  default = "3.13.12"
}

variable "PIP_VERSION" {
  // renovate: datasource=pypi depName=pip
  default = "26.0.1"
}

variable "SETUPTOOLS_VERSION" {
  // renovate: datasource=pypi depName=setuptools
  default = "82.0.0"
}

variable "WHEEL_VERSION" {
  // renovate: datasource=pypi depName=wheel
  default = "0.46.3"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://python.org"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PIP_VERSION = "${PIP_VERSION}"
    SETUPTOOLS_VERSION = "${SETUPTOOLS_VERSION}"
    WHEEL_VERSION = "${WHEEL_VERSION}"
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
