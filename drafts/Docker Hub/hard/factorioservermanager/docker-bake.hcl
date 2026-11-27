target "docker-metadata-action" {}

variable "APP" {
  default = "factorioservermanager"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=OpenFactorioServerManager/factorio-server-manager versioning=semver
  default = "0.10.1"
}

variable "FSM_SHA256" {
  // sha256 of factorio-server-manager-linux-${VERSION}.zip, computed locally (upstream publishes no checksum).
  // Bump together with VERSION.
  default = "c0777636aa521d71700bb8fd69a496b8f4964c0d495ba87c292f293f1003bde7"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/OpenFactorioServerManager/factorio-server-manager"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    FSM_SHA256 = "${FSM_SHA256}"
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
  // amd64 only: the FSM binary and Factorio headless have no arm64 build.
  platforms = [
    "linux/amd64"
  ]
}
