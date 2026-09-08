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

echo "==> Instalando aplicativos de terceiros"

# Visual Studio Code oficial da Microsoft.
# O pacote 'code' dos repositórios oficiais do Arch é a build open-source
# (Code - OSS). Para manter o VS Code oficial, usamos visual-studio-code-bin.
install_aur_package visual-studio-code-bin
