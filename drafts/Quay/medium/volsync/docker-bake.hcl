target "docker-metadata-action" {}

variable "APP" {
  default = "volsync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=backube/volsync versioning=semver
  default = "v0.17.0"
}

variable "RCLONE_VERSION" {
  // renovate: datasource=github-tags depName=rclone/rclone versioning=semver
  default = "v1.75.2"
}

variable "RCLONE_GIT_HASH" {
  default = "be8d6044eacb843b74d335db0c5fbe09222031fe"
}

variable "SYNCTHING_VERSION" {
  // renovate: datasource=github-releases depName=syncthing/syncthing versioning=semver
  default = "v1.30.0"
}

variable "SYNCTHING_GIT_HASH" {
  default = "0945304a79d6bbaeac7fc2cc1b06f57d3cf66622"
}

variable "DISKRSYNC_VERSION" {
  // renovate: datasource=github-tags depName=dop251/diskrsync versioning=semver
  default = "v1.3.0"
}

variable "DISKRSYNC_GIT_HASH" {
  default = "507805c4378495fc2267b77f6eab3d6bb318c86c"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/backube/volsync"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    RCLONE_VERSION = "${RCLONE_VERSION}"
    RCLONE_GIT_HASH = "${RCLONE_GIT_HASH}"
    SYNCTHING_VERSION = "${SYNCTHING_VERSION}"
    SYNCTHING_GIT_HASH = "${SYNCTHING_GIT_HASH}"
    DISKRSYNC_VERSION = "${DISKRSYNC_VERSION}"
    DISKRSYNC_GIT_HASH = "${DISKRSYNC_GIT_HASH}"
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
    "linux/amd64",
    "linux/arm64"
  ]
}
