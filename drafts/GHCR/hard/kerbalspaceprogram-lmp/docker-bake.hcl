target "docker-metadata-action" {}

variable "APP" {
  default = "kerbalspaceprogram-lmp"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=LunaMultiplayer/LunaMultiplayer versioning=semver
  default = "0.29.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/LunaMultiplayer/LunaMultiplayer"
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
    "linux/amd64"
  ]
}
