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

  if flatpak info --user "$app_id" >/dev/null 2>&1; then
    echo "[OK] $app_id já está instalado para o usuário"
    return 0
  fi

  echo "==> Instalando Flatpak para o usuário: $app_id"
  flatpak install --user -y --noninteractive flathub "$app_id"
}

echo "==> Instalando aplicativos de uso efetivo"

# Helper AUR usado também pelo atalho de atualização do sistema.
install_aur_package yay

# Visual Studio Code oficial da Microsoft.
# O pacote 'code' dos repositórios oficiais do Arch é Code - OSS.
install_aur_package visual-studio-code-bin

# Codex Desktop para Linux.
# O pacote AUR reaproveita a distribuição Linux oficial e a integra ao Arch.
install_aur_package openai-codex-desktop

if [[ "${SKIP_FLATPAK_APPS:-0}" == "1" ]]; then
  echo "==> Aplicativos Flatpak ignorados por opção do instalador"
  exit 0
fi

# Aplicativos portados do fluxo Fedora e mantidos como Flatpak.
# São instalados no escopo do usuário para não depender de PolicyKit/senha administrativa.
FLATPAK_APPS=(
  com.google.Chrome
  com.rtosta.zapzap
  com.spotify.Client
  org.onlyoffice.desktopeditors
  org.videolan.VLC
  com.valvesoftware.Steam
  com.github.tchx84.Flatseal
  net.nokyan.Resources
  page.tesk.Refine
  com.boxy_svg.BoxySVG
  com.belmoussaoui.Obfuscate
  app.drey.Dialect
  io.github.fabrialberio.pinapp
  me.dusansimic.DynamicWallpaper
  com.mattjakeman.ExtensionManager
  it.mijorus.gearlever
  org.desktop_plus.desktop-plus
  org.virt_manager.virt-manager
  org.virt_manager.virt_manager.Extension.Qemu
)

for app in "${FLATPAK_APPS[@]}"; do
  install_flatpak "$app"
done
