target "docker-metadata-action" {}

variable "APP" {
  default = "minecraft-bedrock"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=itzg/docker-minecraft-bedrock-server versioning=loose
  default = "2026.11.1"
}

variable "SET_PROPERTY_VERSION" {
  // renovate: datasource=github-releases depName=itzg/set-property versioning=loose
  default = "0.2.0"
}

variable "SET_PROPERTY_SHA256" {
  default = "UNVERIFIED"
}

variable "MC_SERVER_RUNNER_VERSION" {
  // renovate: datasource=github-releases depName=itzg/mc-server-runner versioning=loose
  default = "1.17.0"
}

variable "MC_SERVER_RUNNER_SHA256" {
  default = "UNVERIFIED"
}

variable "MC_MONITOR_VERSION" {
  // renovate: datasource=github-releases depName=itzg/mc-monitor versioning=loose
  default = "1.21.0"
}

variable "MC_MONITOR_SHA256" {
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // licence of the software in the image: upstream scripts and helpers (MIT). The Mojang server is not shipped.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/itzg/docker-minecraft-bedrock-server"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SET_PROPERTY_VERSION = "${SET_PROPERTY_VERSION}"
    SET_PROPERTY_SHA256 = "${SET_PROPERTY_SHA256}"
    MC_SERVER_RUNNER_VERSION = "${MC_SERVER_RUNNER_VERSION}"
    MC_SERVER_RUNNER_SHA256 = "${MC_SERVER_RUNNER_SHA256}"
    MC_MONITOR_VERSION = "${MC_MONITOR_VERSION}"
    MC_MONITOR_SHA256 = "${MC_MONITOR_SHA256}"
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
  // UNVERIFIED: arm64 needs box64, not in this draft; amd64 only until tested
  platforms = [
    "linux/amd64"
  ]
}
