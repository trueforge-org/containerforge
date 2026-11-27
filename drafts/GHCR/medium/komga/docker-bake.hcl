target "docker-metadata-action" {}

variable "APP" {
  default = "komga"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gotson/komga versioning=semver
  default = "1.30.2"
}

variable "JAR_SHA256" {
  // sha256 of komga-1.30.2.jar from the release checksums_sha256.txt (from the plan, not re-fetched)
  default = "a5736468b0847eb319bf8628760f7853cecb8e52dd23e23855fabebf3e04a43b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/gotson/komga"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    JAR_SHA256 = "${JAR_SHA256}"
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
