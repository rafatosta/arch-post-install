#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGES=(
  python
  python-pip
  nodejs
  npm
  android-tools
)

echo "==> Instalando ferramentas de desenvolvimento"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
