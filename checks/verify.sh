#!/usr/bin/env bash
set -Eeuo pipefail

status=0

check_cmd() {
  local cmd="$1"
  local label="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[OK] %s\n' "$label"
  else
    printf '[ERRO] %s\n' "$label"
    status=1
  fi
}

check_enabled() {
  local unit="$1"
  if systemctl is-enabled "$unit" >/dev/null 2>&1; then
    printf '[OK] %s habilitado\n' "$unit"
  else
    printf '[ERRO] %s não está habilitado\n' "$unit"
    status=1
  fi
}

run_gsettings() {
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    gsettings "$@"
  else
    dbus-run-session -- gsettings "$@"
  fi
}

echo "==> Verificação final"
check_cmd gnome-shell "GNOME Shell instalado"
check_cmd gnome-control-center "Configurações do GNOME instaladas"
check_cmd nautilus "Nautilus instalado"
check_cmd ptyxis "Ptyxis instalado"
check_cmd gnome-software "GNOME Software instalado"
check_cmd code "Visual Studio Code instalado"
check_cmd flatpak "Flatpak instalado"
check_enabled gdm.service
check_enabled NetworkManager.service

if pacman -Q nautilus-open-any-terminal >/dev/null 2>&1; then
  echo "[OK] Integração Ptyxis/Nautilus instalada"
else
  echo "[ERRO] Integração Ptyxis/Nautilus não instalada"
  status=1
fi

if pacman -Q adw-gtk-theme >/dev/null 2>&1; then
  echo "[OK] Tema adw-gtk3 instalado"
else
  echo "[ERRO] Tema adw-gtk3 não instalado"
  status=1
fi

configured_theme="$(run_gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || true)"
case "$configured_theme" in
  "'adw-gtk3'"|"'adw-gtk3-dark'")
    echo "[OK] Tema GTK3 configurado: ${configured_theme//\'/}"
    ;;
  *)
    echo "[ERRO] Tema GTK3 não está configurado como adw-gtk3/adw-gtk3-dark"
    status=1
    ;;
esac

if flatpak remote-list --columns=name 2>/dev/null | grep -qx flathub; then
  echo "[OK] Flathub configurado"
else
  echo "[ERRO] Flathub não configurado"
  status=1
fi

echo
if lspci 2>/dev/null | grep -qi nvidia; then
  echo "[INFO] GPU NVIDIA detectada. Este repositório ainda não altera o driver NVIDIA."
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "[OK] nvidia-smi disponível"
  else
    echo "[INFO] nvidia-smi não encontrado; revise o driver escolhido no archinstall."
  fi
else
  echo "[INFO] Nenhuma GPU NVIDIA detectada (esperado em muitas VMs)."
fi

exit "$status"
