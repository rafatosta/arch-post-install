#!/usr/bin/env bash
set -Eeuo pipefail

install_aur_package() {
  local package="$1"
  local aur_url="https://aur.archlinux.org/${package}.git"
  local build_root="${XDG_CACHE_HOME:-$HOME/.cache}/arch-post-install/aur"
  local build_dir="$build_root/$package"

  if pacman -Q "$package" >/dev/null 2>&1; then
    echo "[OK] $package já está instalado"
    return 0
  fi

  echo "==> Instalando $package do AUR"
  mkdir -p "$build_root"
  rm -rf "$build_dir"
  git clone "$aur_url" "$build_dir"

  (
    cd "$build_dir"
    makepkg -si --needed --noconfirm
  )
}

install_flatpak() {
  local app_id="$1"

  if flatpak info "$app_id" >/dev/null 2>&1; then
    echo "[OK] $app_id já está instalado"
    return 0
  fi

  echo "==> Instalando Flatpak: $app_id"
  flatpak install --system -y --noninteractive flathub "$app_id"
}

echo "==> Instalando aplicativos de uso efetivo"

# Visual Studio Code oficial da Microsoft.
# O pacote 'code' dos repositórios oficiais do Arch é Code - OSS.
install_aur_package visual-studio-code-bin

# Aplicativos portados do fluxo Fedora e mantidos como Flatpak.
FLATPAK_APPS=(
  com.google.Chrome
  com.rtosta.zapzap
  com.spotify.Client
  com.jetbrains.IntelliJ-IDEA-Community
  org.onlyoffice.desktopeditors
  org.videolan.VLC
  com.valvesoftware.Steam
  com.github.tchx84.Flatseal
  net.nokyan.Resources
)

for app in "${FLATPAK_APPS[@]}"; do
  install_flatpak "$app"
done
