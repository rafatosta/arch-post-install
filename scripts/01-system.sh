#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGES=(
  base-devel
  git
  curl
  wget
  networkmanager
  pipewire
  pipewire-alsa
  pipewire-pulse
  wireplumber
  bluez
  bluez-utils
  flatpak
)

echo "==> Atualizando o sistema"
sudo pacman -Syu --noconfirm

echo "==> Instalando componentes básicos"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Habilitando serviços básicos"
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service
