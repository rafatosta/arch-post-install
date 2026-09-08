#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ${EUID} -eq 0 ]]; then
  echo "Execute este script como usuário normal, não como root."
  exit 1
fi

if [[ ! -r /etc/arch-release ]]; then
  echo "Este instalador foi projetado para Arch Linux."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo não está instalado. Instale-o antes de continuar."
  exit 1
fi

echo "==> Arch post-install"
echo "    Usuário: ${USER}"
echo

# Solicita a senha uma única vez no início e mantém o timestamp do sudo
# válido durante toda a execução. Nenhuma senha é armazenada pelo script.
sudo -v
(
  while kill -0 "$$" 2>/dev/null; do
    sudo -n true 2>/dev/null || exit
    sleep 60
  done
) &
SUDO_KEEPALIVE_PID=$!

cleanup() {
  kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for script in \
  "$ROOT_DIR/scripts/01-system.sh" \
  "$ROOT_DIR/scripts/02-gnome.sh" \
  "$ROOT_DIR/scripts/03-flatpak.sh" \
  "$ROOT_DIR/scripts/04-apps.sh" \
  "$ROOT_DIR/scripts/05-development.sh" \
  "$ROOT_DIR/scripts/06-customization.sh" \
  "$ROOT_DIR/checks/verify.sh"; do
  echo
  echo "==> Executando $(basename "$script")"
  bash "$script"
done

echo
echo "Instalação concluída. Reinicie o sistema para entrar pelo GDM/GNOME."
