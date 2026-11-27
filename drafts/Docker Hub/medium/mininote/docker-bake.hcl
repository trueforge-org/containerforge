target "docker-metadata-action" {}

variable "APP" {
  default = "mininote"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/muety/mininote currentValue=master
  // UNVERIFIED: short commit SHA from the plan; replace with the full 40-character SHA once resolved
  default = "e9d24b5"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/muety/mininote"
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
