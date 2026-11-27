target "docker-metadata-action" {}

variable "APP" {
  default = "headlamp"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=headlamp-k8s/headlamp versioning=semver
  default = "v0.46.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/headlamp-k8s/headlamp"
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
