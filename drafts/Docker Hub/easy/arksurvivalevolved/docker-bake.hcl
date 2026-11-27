target "docker-metadata-action" {}

variable "APP" {
  default = "arksurvivalevolved"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=arkmanager/ark-server-tools extractVersion=^v(?<version>.+)$
  default = "1.6.69"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/arkmanager/ark-server-tools"
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
  // The ARK server and SteamCMD binaries are x86 only.
  platforms = [
    "linux/amd64"
  ]
}
