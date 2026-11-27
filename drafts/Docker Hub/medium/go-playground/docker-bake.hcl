target "docker-metadata-action" {}

variable "APP" {
  default = "go-playground"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=x1unix/go-playground versioning=semver
  // UNVERIFIED: 3.0.0 is a candidate tag; confirm it exists before merge
  default = "3.0.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/x1unix/go-playground"
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
