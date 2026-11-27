target "docker-metadata-action" {}

variable "APP" {
  default = "nvidia-gpu-exporter"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=utkuozdemir/nvidia_gpu_exporter versioning=semver
  default = "1.19.0"
}

variable "LICENSE" {
  // UNVERIFIED: the README names no SPDX id. Replace once the LICENSE file is read.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/utkuozdemir/nvidia_gpu_exporter"
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
