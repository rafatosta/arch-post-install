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

echo "==> Verificação final"
check_cmd gnome-shell "GNOME Shell instalado"
check_cmd gnome-control-center "Configurações do GNOME instaladas"
check_cmd nautilus "Nautilus instalado"
check_cmd ptyxis "Ptyxis instalado"
check_cmd gnome-software "GNOME Software instalado"
check_cmd flatpak "Flatpak instalado"
check_enabled gdm.service
check_enabled NetworkManager.service

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
