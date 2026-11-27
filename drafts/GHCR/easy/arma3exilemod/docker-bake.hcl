target "docker-metadata-action" {}

variable "APP" {
  default = "arma3exilemod"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: the Arma 3 server EULA and the ExileMod license are not confirmed (LicenseRef-Arma3-EULA proposed in the plan)
  default = "UNVERIFIED"
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
