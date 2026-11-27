target "docker-metadata-action" {}

variable "APP" {
  default = "palworld"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  // The server is installed by SteamCMD at start, so VERSION tracks the steamcmd base image tag.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: proprietary server downloaded from Steam. Confirm the repo convention before merging.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.pocketpair.jp/"
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
