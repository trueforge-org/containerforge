target "docker-metadata-action" {}

variable "APP" {
  default = "imgpush"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=hauxir/imgpush packageName=https://github.com/hauxir/imgpush currentDigest=9a44956c12da164d6198dfd932830e7a5a4c4adf
  default = "9a44956c12da164d6198dfd932830e7a5a4c4adf"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/hauxir/imgpush"
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
