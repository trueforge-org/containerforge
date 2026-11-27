target "docker-metadata-action" {}

variable "APP" {
  default = "firezone"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=firezone/firezone versioning=loose allowedVersions=/^0\.7\.\d+$/
  default = "0.7.36"
}

variable "ELIXIR_VERSION" {
  default = "1.14.3"
}

variable "OTP_VERSION" {
  default = "25.2.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/firezone/firezone"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ELIXIR_VERSION = "${ELIXIR_VERSION}"
    OTP_VERSION = "${OTP_VERSION}"
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
