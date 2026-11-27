target "docker-metadata-action" {}

variable "APP" {
  default = "anope"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=anope/anope versioning=loose
  // UNVERIFIED: Dockerfile pins the apt package 2.0.17-1.1 (upstream release is 2.0.21).
  // Renovate will propose 2.0.21, which the apt check rejects. Resolve before merge.
  default = "2.0.17"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/anope/anope"
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
