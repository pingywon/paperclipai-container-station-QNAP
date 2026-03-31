#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${PAPERCLIP_CONTAINER_NAME:-paperclip}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker CLI is required but not found in PATH." >&2
  exit 1
fi

if [ "$#" -lt 1 ]; then
  cat >&2 <<USAGE
Usage:
  $(basename "$0") <hostname-or-ip> [additional-hostname-or-ip ...]

Examples:
  $(basename "$0") 192.168.13.13
  $(basename "$0") qnap.local paperclip.local 192.168.13.13

Optional env:
  PAPERCLIP_CONTAINER_NAME=paperclip-custom
USAGE
  exit 1
fi

for host in "$@"; do
  echo "Allowing hostname on ${CONTAINER_NAME}: ${host}"
  docker exec -it "$CONTAINER_NAME" pnpm paperclipai allowed-hostname "$host"
done

echo "Done. Restarting ${CONTAINER_NAME} to apply changes..."
docker restart "$CONTAINER_NAME" >/dev/null

echo "Success. Allowed hostnames: $*"
