target "docker-metadata-action" {}

variable "APP" {
  default = "fenrus"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/revenz/Fenrus currentValue=master
  default = "c52d4966e3e657b5d38415101985c2f4c10d36c7"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/revenz/Fenrus"
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
