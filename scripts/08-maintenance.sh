#!/usr/bin/env bash
set -Eeuo pipefail

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
UPDATE_SCRIPT="$BIN_DIR/update-system"
DESKTOP_FILE="$APP_DIR/system-update.desktop"

echo "==> Criando atalho de atualização do sistema"
mkdir -p "$BIN_DIR" "$APP_DIR"

cat > "$UPDATE_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -o pipefail

echo "================================"
echo " Atualizando Arch Linux"
echo "================================"
if ! sudo pacman -Syu; then
  echo
  echo "[ERRO] Falha na atualização dos repositórios oficiais."
  read -rp "Pressione Enter para fechar..."
  exit 1
fi

echo
echo "================================"
echo " Atualizando AUR"
echo "================================"
if ! yay -Sua; then
  echo
  echo "[AVISO] A atualização do AUR apresentou falhas."
fi

echo
echo "================================"
echo " Atualizando Flatpaks"
echo "================================"
if ! flatpak update --user -y; then
  echo
  echo "[AVISO] A atualização dos Flatpaks apresentou falhas."
fi

echo
echo "================================"
echo " Atualização concluída"
echo "================================"
read -rp "Pressione Enter para fechar..."
EOF

chmod +x "$UPDATE_SCRIPT"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Atualizar Sistema
Comment=Atualiza Arch, AUR e Flatpak
Exec=ptyxis -- bash -lc "$UPDATE_SCRIPT"
Icon=software-update-available-symbolic
Terminal=false
Type=Application
Categories=System;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

echo "[OK] Atalho 'Atualizar Sistema' criado no menu de aplicativos."
