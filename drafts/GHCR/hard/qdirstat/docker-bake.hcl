target "docker-metadata-action" {}

variable "APP" {
  default = "qdirstat"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shundhammer/qdirstat versioning=loose
  // UNVERIFIED: the upstream release 2.0.1. The Ubuntu apt package version may differ; match it to the Dockerfile install.
  default = "2.0.1"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/shundhammer/qdirstat"
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
