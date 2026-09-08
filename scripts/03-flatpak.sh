#!/usr/bin/env bash
set -Eeuo pipefail

echo "==> Configurando Flathub"
if flatpak remote-list --columns=name 2>/dev/null | grep -qx flathub; then
  echo "Flathub já está configurado."
else
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "==> Atualizando runtimes Flatpak existentes"
flatpak update -y || true

echo "Aplicativos Flatpak de usuário serão adicionados posteriormente."
