target "docker-metadata-action" {}

variable "APP" {
  default = "promcord"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/nimarion/promcord currentValue=master
  // UNVERIFIED: replace "master" with a pinned commit SHA before the first build (plan section 1). Renovate tracks master.
  default = "master"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/nimarion/promcord"
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
