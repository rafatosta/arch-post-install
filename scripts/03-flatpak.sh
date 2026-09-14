#!/usr/bin/env bash
set -Eeuo pipefail

echo "==> Configurando Flathub para o usuário"
if flatpak remote-list --user --columns=name 2>/dev/null | grep -qx flathub; then
  echo "Flathub já está configurado para o usuário."
else
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "==> Atualizando runtimes Flatpak do usuário"
flatpak update --user -y || true

echo "Aplicativos Flatpak serão instalados no escopo do usuário, sem exigir autenticação administrativa."
