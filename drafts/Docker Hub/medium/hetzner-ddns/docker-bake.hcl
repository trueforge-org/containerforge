target "docker-metadata-action" {}

variable "APP" {
  default = "hetzner-ddns"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=kutzilla/docker-hetzner-ddns packageName=https://github.com/kutzilla/docker-hetzner-ddns currentDigest=511c9118d12c74f559a39cd0c5ced9ce9147bba2
  default = "511c9118d12c74f559a39cd0c5ced9ce9147bba2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/kutzilla/docker-hetzner-ddns"
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
