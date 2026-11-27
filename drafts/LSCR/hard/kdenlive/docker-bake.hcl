target "docker-metadata-action" {}

variable "APP" {
  default = "kdenlive"
}

variable "VERSION" {
  // renovate: none confirmed; this is an apt pin (4:${VERSION}-0ubuntu1.1 in the Dockerfile)
  default = "25.12.3"
}

variable "LICENSE" {
  // UNVERIFIED: confirm from https://github.com/KDE/kdenlive before merging
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/KDE/kdenlive"
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
