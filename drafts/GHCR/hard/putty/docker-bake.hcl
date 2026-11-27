target "docker-metadata-action" {}

variable "APP" {
  default = "putty"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource, no PuTTY version feed is confirmed yet; set it before merge
  // UNVERIFIED: the upstream PuTTY release. The apt package version may differ, so match it to the Dockerfile install.
  default = "0.85"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://putty.software"
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
