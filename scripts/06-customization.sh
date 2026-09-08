#!/usr/bin/env bash
set -Eeuo pipefail

run_gsettings() {
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    gsettings "$@"
  else
    dbus-run-session -- gsettings "$@"
  fi
}

echo "==> Instalando tema adw-gtk3 para aplicativos GTK3 legados"
sudo pacman -S --needed --noconfirm adw-gtk-theme

echo "==> Instalando temas adw-gtk3 para aplicativos Flatpak"
flatpak install -y flathub \
  org.gtk.Gtk3theme.adw-gtk3 \
  org.gtk.Gtk3theme.adw-gtk3-dark

echo "==> Configurando tema GTK3 conforme o esquema de cores do GNOME"
color_scheme="$(run_gsettings get org.gnome.desktop.interface color-scheme)"

if [[ "$color_scheme" == "'prefer-dark'" ]]; then
  theme="adw-gtk3-dark"
else
  theme="adw-gtk3"
fi

run_gsettings set org.gnome.desktop.interface gtk-theme "$theme"

configured_theme="$(run_gsettings get org.gnome.desktop.interface gtk-theme)"
if [[ "$configured_theme" != "'$theme'" ]]; then
  printf 'ERRO: Falha ao configurar o tema GTK3: %s\n' "$theme" >&2
  exit 1
fi

echo "[OK] Tema GTK3 configurado: $theme"
