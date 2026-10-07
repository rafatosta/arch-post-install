#!/usr/bin/env bash
set -Eeuo pipefail

run_gsettings() {
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    gsettings "$@"
  else
    dbus-run-session -- gsettings "$@"
  fi
}

warn() {
  printf '[AVISO] %s\n' "$*" >&2
}

safe_gsettings_set() {
  if ! run_gsettings set "$@"; then
    warn "Falha ao aplicar configuração GNOME: $*"
  fi
}

echo "==> Instalando tema adw-gtk3 para aplicativos GTK3 legados"
sudo pacman -S --needed --noconfirm adw-gtk-theme || warn "Não foi possível instalar adw-gtk-theme."

echo "==> Instalando temas adw-gtk3 para aplicativos Flatpak do usuário"
flatpak install --user -y flathub \
  org.gtk.Gtk3theme.adw-gtk3 \
  org.gtk.Gtk3theme.adw-gtk3-dark || warn "Não foi possível instalar os temas GTK3 via Flatpak."

echo "==> Configurando tema GTK3 conforme o esquema de cores do GNOME"
color_scheme="$(run_gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"

if [[ "$color_scheme" == "'prefer-dark'" ]]; then
  theme="adw-gtk3-dark"
else
  theme="adw-gtk3"
fi

safe_gsettings_set org.gnome.desktop.interface gtk-theme "$theme"

configured_theme="$(run_gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || true)"
if [[ "$configured_theme" == "'$theme'" ]]; then
  echo "[OK] Tema GTK3 configurado: $theme"
else
  warn "Não foi possível confirmar o tema GTK3: $theme"
fi

echo "==> Aplicando preferências pessoais do GNOME"
safe_gsettings_set org.gnome.desktop.interface gtk-enable-primary-paste true
safe_gsettings_set org.gnome.desktop.search-providers disable-external true
safe_gsettings_set org.gnome.desktop.privacy remember-app-usage false
safe_gsettings_set org.gnome.desktop.privacy remember-recent-files false
safe_gsettings_set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
safe_gsettings_set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
safe_gsettings_set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
safe_gsettings_set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800
safe_gsettings_set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'

echo "[OK] Preferências do GNOME aplicadas"

echo "==> Instalando tema de ícones LinuxMidnight"
ICON_REPO="https://github.com/rafatosta/LinuxMidnight-icon-theme.git"
ICON_THEME="LinuxMidnight"
ICON_TMP="$(mktemp -d)"
trap 'rm -rf -- "$ICON_TMP"' EXIT

if git clone --depth=1 "$ICON_REPO" "$ICON_TMP/LinuxMidnight-icon-theme"; then
  if bash "$ICON_TMP/LinuxMidnight-icon-theme/install.sh"; then
    if run_gsettings list-schemas 2>/dev/null | grep -Fxq org.gnome.desktop.interface; then
      safe_gsettings_set org.gnome.desktop.interface icon-theme "$ICON_THEME"
      configured_icons="$(run_gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || true)"

      if [[ "$configured_icons" == "'$ICON_THEME'" ]]; then
        echo "[OK] Tema de ícones configurado: $ICON_THEME"
      else
        warn "Tema LinuxMidnight instalado, mas não foi possível confirmar sua ativação."
      fi
    else
      warn "Tema LinuxMidnight instalado, mas o schema do GNOME não está disponível."
    fi
  else
    warn "Falha ao instalar o tema LinuxMidnight."
  fi
else
  warn "Falha ao baixar o tema LinuxMidnight."
fi

rm -rf -- "$ICON_TMP"
trap - EXIT
