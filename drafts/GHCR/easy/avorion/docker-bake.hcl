target "docker-metadata-action" {}

variable "APP" {
  default = "avorion"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // UNVERIFIED: placeholder pinned to the steamcmd base version until the Avorion build id is decided.
  default = "20180105-5build1"
}

// UNVERIFIED: Avorion license not yet read; set once checked against the Valve/Avorion EULA.
variable "LICENSE" {
  default = "NONE"
}

variable "SOURCE" {
  default = "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
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
