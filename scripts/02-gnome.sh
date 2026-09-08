#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGES=(
  gnome-shell
  gnome-session
  gdm
  gnome-control-center
  nautilus
  nautilus-python
  ptyxis
  gnome-software
  gnome-keyring
  xdg-desktop-portal-gnome
  power-profiles-daemon
  switcheroo-control
)

echo "==> Instalando GNOME mínimo"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Instalando integração Ptyxis + Nautilus"
if ! pacman -Q nautilus-open-any-terminal >/dev/null 2>&1; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  git clone --depth=1 https://aur.archlinux.org/nautilus-open-any-terminal.git "$tmp_dir/nautilus-open-any-terminal"
  (
    cd "$tmp_dir/nautilus-open-any-terminal"

    # Este PKGBUILD gera pacotes separados para Nautilus e Caja.
    # `makepkg -si` tentaria instalar ambos e eles compartilham arquivos,
    # causando conflito. Compilamos tudo, mas instalamos somente o pacote
    # destinado ao Nautilus.
    makepkg -s --needed --noconfirm

    nautilus_pkg="$(find . -maxdepth 1 -type f -name 'nautilus-open-any-terminal-*.pkg.tar.*' -print -quit)"
    if [[ -z "$nautilus_pkg" ]]; then
      echo "[ERRO] Pacote nautilus-open-any-terminal não foi gerado."
      exit 1
    fi

    sudo pacman -U --needed --noconfirm "$nautilus_pkg"
  )

  rm -rf "$tmp_dir"
  trap - EXIT
fi

if gsettings list-schemas | grep -qx 'com.github.stunkymonkey.nautilus-open-any-terminal'; then
  gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal ptyxis
fi

echo "==> Habilitando o GDM"
sudo systemctl enable gdm.service

echo "==> Habilitando serviços úteis ao GNOME"
sudo systemctl enable power-profiles-daemon.service 2>/dev/null || true
sudo systemctl enable switcheroo-control.service 2>/dev/null || true

echo "==> A integração 'Abrir no terminal' estará disponível no Nautilus após reiniciar a sessão."
