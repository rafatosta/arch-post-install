#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGES=(
  base-devel
  git
  curl
  wget
  pciutils
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

echo "==> Verificando integração Snapper + pacman"
if pacman -Q snapper >/dev/null 2>&1; then
  if sudo snapper list-configs 2>/dev/null | awk 'NR > 2 {print $1}' | grep -qx root; then
    echo "[OK] Snapper configurado pelo sistema"
    sudo pacman -S --needed --noconfirm snap-pac
  else
    echo "[AVISO] Snapper está instalado, mas nenhuma configuração 'root' foi encontrada."
    echo "[AVISO] snap-pac não será instalado automaticamente para evitar uma configuração incompleta."
  fi
else
  echo "[INFO] Snapper não está instalado/configurado; integração com snap-pac ignorada."
fi
