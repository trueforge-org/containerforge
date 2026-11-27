target "docker-metadata-action" {}

variable "APP" {
  default = "v-rising"
}

variable "VERSION" {
  // UNVERIFIED: no release datasource tracks the Steam build id of app 1829350.
  // Record the build id from the first SteamCMD run here.
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // UNVERIFIED: proprietary Steam/Stunlock EULA, review before shipping
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://playvrising.com/"
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
  // amd64 only: the V Rising server is Windows-only, so there is no arm64 build
  platforms = [
    "linux/amd64"
  ]
}
