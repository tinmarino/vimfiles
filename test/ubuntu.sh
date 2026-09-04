#!/usr/bin/env bash
# Runner local: construye la imagen Ubuntu y corre el test dentro del container.
# Contexto de build = ~/.vim (para poder COPIAR la config local sin el remoto/token).
# Uso: bash test/ubuntu.sh   (desde cualquier lado; resolvemos rutas absolutas)

set -u

# Raiz de vimfiles = carpeta padre de este script
here="$( cd "$(dirname "$0")" && pwd -P )"
root="$( cd "$here/.." && pwd -P )"
img="vimfiles-ubuntu"

echo "[*] vimfiles root: $root"

# Verificamos docker disponible y con permiso
if ! command -v docker >/dev/null 2>&1; then
  echo "[-] docker no esta instalado. Corriendo fallback local..." >&2
  bash "$here/ubuntu_local_fallback.sh"
  exit $?
fi
if ! docker info >/dev/null 2>&1; then
  echo "[-] docker sin permiso o daemon caido. Corriendo fallback local..." >&2
  bash "$here/ubuntu_local_fallback.sh"
  exit $?
fi

echo "[*] docker build ..."
docker build -f "$root/test/ubuntu.dockerfile" -t "$img" "$root" || exit 1

echo "[*] docker run ..."
docker run --rm "$img"
