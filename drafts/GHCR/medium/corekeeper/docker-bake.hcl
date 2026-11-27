target "docker-metadata-action" {}

variable "APP" {
  default = "corekeeper"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

// UNVERIFIED: upstream ich777/docker-steamcmd-server has no license set. The
// image ships SteamCMD (AGPL-3.0-or-later); confirm the value in the PR.
variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

// UNVERIFIED: Steam app ID 1963720 comes from the TrueCharts values.yaml, not a fetched store page.
variable "SOURCE" {
  default = "https://store.steampowered.com/app/1963720"
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
