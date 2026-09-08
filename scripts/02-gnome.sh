#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGES=(
  gnome-shell
  gnome-session
  gdm
  gnome-control-center
  nautilus
  ptyxis
  gnome-software
  gnome-keyring
  xdg-desktop-portal-gnome
  power-profiles-daemon
  switcheroo-control
)

echo "==> Instalando GNOME mínimo"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Habilitando o GDM"
sudo systemctl enable gdm.service

echo "==> Habilitando serviços úteis ao GNOME"
sudo systemctl enable power-profiles-daemon.service 2>/dev/null || true
sudo systemctl enable switcheroo-control.service 2>/dev/null || true
