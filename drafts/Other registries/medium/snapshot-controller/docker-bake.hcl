target "docker-metadata-action" {}

variable "APP" {
  default = "snapshot-controller"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kubernetes-csi/external-snapshotter versioning=semver
  default = "v8.7.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/kubernetes-csi/external-snapshotter"
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
