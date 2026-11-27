target "docker-metadata-action" {}

variable "APP" {
  default = "quassel-web"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/magne4000/quassel-webserver currentValue=master
  default = "019bfdc1e7c9cacdd76057072c0fa654b467439b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/magne4000/quassel-webserver"
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
