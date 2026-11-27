target "docker-metadata-action" {}

variable "APP" {
  default = "fastcom-mqtt"
}

variable "VERSION" {
  // renovate: datasource=npm depName=fast-cli
  default = "6.0.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/simonjenny/fastcom-mqtt"
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
  // UNVERIFIED: arm64 is likely blocked (no Chrome for Testing build confirmed for linux-arm64).
  // amd64 only until an arm64 run proves otherwise.
  platforms = [
    "linux/amd64"
  ]
}
