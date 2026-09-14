#!/usr/bin/env bash
set -Eeuo pipefail

if ! lspci 2>/dev/null | grep -Eiq '(VGA compatible controller|3D controller|Display controller):.*NVIDIA'; then
  echo "==> Nenhuma GPU NVIDIA detectada; configuração NVIDIA ignorada."
  exit 0
fi

echo "==> GPU NVIDIA detectada"
lspci | grep -Ei '(VGA compatible controller|3D controller|Display controller):.*NVIDIA' || true

# A pilha oficial atual do Arch usa os módulos abertos para GPUs Turing e mais novas.
# O DKMS é usado aqui para não amarrar o pós-install a um único kernel.
PACKAGES=(
  dkms
  nvidia-open-dkms
  nvidia-utils
  nvidia-settings
  nvidia-prime
  libva-nvidia-driver
)

# Instala os headers correspondentes aos kernels oficiais encontrados.
KERNEL_HEADER_MAP=(
  "linux:linux-headers"
  "linux-lts:linux-lts-headers"
  "linux-zen:linux-zen-headers"
  "linux-hardened:linux-hardened-headers"
)

found_kernel=0
for entry in "${KERNEL_HEADER_MAP[@]}"; do
  kernel="${entry%%:*}"
  headers="${entry##*:}"

  if pacman -Q "$kernel" >/dev/null 2>&1; then
    found_kernel=1
    PACKAGES+=("$headers")
  fi
done

if [[ $found_kernel -eq 0 ]]; then
  echo "[AVISO] Nenhum kernel oficial conhecido (linux/linux-lts/linux-zen/linux-hardened) foi detectado."
  echo "[AVISO] nvidia-open-dkms será instalado, mas um kernel personalizado exige seus headers correspondentes."
fi

echo "==> Instalando pilha NVIDIA"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Gerando módulos DKMS"
sudo dkms autoinstall

echo "[OK] Pilha NVIDIA instalada. A ativação completa ocorrerá após reiniciar o sistema."
