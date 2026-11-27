target "docker-metadata-action" {}

variable "APP" {
  default = "ersatztv"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ErsatzTV/ErsatzTV versioning=semver extractVersion=^v(?<version>.+)$
  default = "26.3.0"
}

variable "LICENSE" {
  default = "Zlib"
}

variable "SOURCE" {
  default = "https://github.com/ErsatzTV/ErsatzTV"
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
