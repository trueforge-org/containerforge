target "docker-metadata-action" {}

variable "APP" {
  default = "kasmvnc"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kasmtech/KasmVNC
  default = "1.4.0"
}

variable "KCLIENT_RELEASE" {
  // renovate: datasource=github-tags depName=linuxserver/kclient
  default = "0.4.1"
}

variable "KASMBINS_RELEASE" {
  default = "1.15.0"
}

variable "XORG_VER" {
  // renovate: datasource=gitlab-tags depName=xorg/xserver registryUrl=https://gitlab.freedesktop.org extractVersion=^xorg-server-(?<version>.+)$
  default = "21.1.14"
}

variable "KASM_NOVNC_VERSION" {
  // renovate: datasource=git-refs depName=kasmtech/noVNC packageName=https://github.com/kasmtech/noVNC currentDigest=46412d23aff1f45dffa83fafb04a683282c8db58
  default = "46412d23aff1f45dffa83fafb04a683282c8db58"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "null"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    KCLIENT_RELEASE = "${KCLIENT_RELEASE}"
    KASMBINS_RELEASE = "${KASMBINS_RELEASE}"
    XORG_VER = "${XORG_VER}"
    KASM_NOVNC_VERSION = "${KASM_NOVNC_VERSION}"
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
