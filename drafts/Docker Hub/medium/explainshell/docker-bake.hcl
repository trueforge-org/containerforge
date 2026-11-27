target "docker-metadata-action" {}

variable "APP" {
  default = "explainshell"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=idank/explainshell packageName=https://github.com/idank/explainshell currentDigest=827ebe38da9822a10e89946551e377330a9de35e
  default = "827ebe38da9822a10e89946551e377330a9de35e"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/idank/explainshell"
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
