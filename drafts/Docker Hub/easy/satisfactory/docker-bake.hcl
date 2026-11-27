target "docker-metadata-action" {}

variable "APP" {
  default = "satisfactory"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=robtme/satisfactory-server versioning=semver
  // draft version; v1.10.0 is newer, a maintainer should choose the version
  default = "1.9.11"
}

variable "LICENSE" {
  // UNVERIFIED: the game server is proprietary and SteamCMD is under Valve's license; confirm with a maintainer
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://github.com/robtme/satisfactory-server"
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
