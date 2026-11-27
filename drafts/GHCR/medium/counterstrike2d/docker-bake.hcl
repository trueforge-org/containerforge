target "docker-metadata-action" {}

variable "APP" {
  default = "counterstrike2d"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource fits the vendor download page. Update by hand and say so in the PR.
  default = "1.0.1.8"
}

variable "LICENSE" {
  // UNVERIFIED: vendor freeware terms not read yet. Resolve before merging.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.cs2d.com/"
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
  // amd64 only until the ARM64 zip is tested
  platforms = [
    "linux/amd64"
  ]
}
