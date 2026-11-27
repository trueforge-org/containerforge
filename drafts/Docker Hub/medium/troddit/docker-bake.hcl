target "docker-metadata-action" {}

variable "APP" {
  default = "troddit"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/burhan-syed/troddit currentValue=main
  default = "eafe83d592014e68efb9b038ef9dd9a27cb69cc4"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/burhan-syed/troddit"
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
