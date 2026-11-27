target "docker-metadata-action" {}

variable "APP" {
  default = "theforest"
}

variable "VERSION" {
  // renovate: UNVERIFIED no datasource for the game version. This is the apps/steamcmd base version
  // (deb datasource) until a game feed is found. Re-check the value against apps/steamcmd/docker-bake.hcl.
  default = "20180105-5build1"
}

// UNVERIFIED: the game license is closed (Steam). Set LICENSE to the image's own license after checking the repo.
variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/242760/"
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
  // amd64 only: the upstream base is amd64 (bullseye_amd64) and the server is a Windows binary under Wine.
  platforms = [
    "linux/amd64"
  ]
}
