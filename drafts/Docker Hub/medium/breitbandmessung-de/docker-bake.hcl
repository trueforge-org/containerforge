target "docker-metadata-action" {}

variable "APP" {
  default = "breitbandmessung-de"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/shneezin/breitbandmessung-node versioning=loose
  // UNVERIFIED: renovate git-refs may need currentValue=master to track a bare commit SHA
  default = "4cd4038a826b01ff433534f36f6a130fb7ac9635"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/shneezin/breitbandmessung-node"
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
