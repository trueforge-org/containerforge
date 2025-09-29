target "docker-metadata-action" {}

variable "APP" {
  default = "jackett"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Jackett/Jackett
  default = "v0.23.87"
}

variable "SOURCE" {
  default = "https://github.com/Jackett/Jackett"
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
