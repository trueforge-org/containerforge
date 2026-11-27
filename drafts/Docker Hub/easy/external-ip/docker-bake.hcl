target "docker-metadata-action" {}

variable "APP" {
  default = "external-ip"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/xavier-hernandez/docker-external-ip currentValue=main
  default = "3be417fe91ba6ab1be2eeb1c2ee218d01470a185"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/xavier-hernandez/docker-external-ip"
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
