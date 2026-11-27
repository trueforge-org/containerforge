target "docker-metadata-action" {}

variable "APP" {
  default = "tasmocompiler"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=benzino77/tasmocompiler versioning=semver
  default = "14.0.3"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/benzino77/tasmocompiler"
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

// UNVERIFIED: arm64 PlatformIO toolchains were not checked.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
