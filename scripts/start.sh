#!/usr/bin/env bash
set -euo pipefail

N=19
PROJECT="docker-homework-${N}"
PORT=$((8000 + N))
NETWORK="${PROJECT}"
VOLUME="${PROJECT}-data"
FRONTEND="${PROJECT}-frontend"
BACKEND="${PROJECT}-backend"
FRONTEND_IMAGE="${PROJECT}-frontend:v${N}"
BACKEND_IMAGE="${PROJECT}-backend:v${N}"

FRONTEND_INTERNAL_PORT="${FRONTEND_INTERNAL_PORT:-80}"

cd "$(dirname "$0")/.."

docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create --driver bridge "$NETWORK"
docker volume inspect "$VOLUME" >/dev/null 2>&1 || docker volume create "$VOLUME"

docker run --rm -v "${VOLUME}:/data" alpine:3.22 \
  sh -c '[ -f /data/message.txt ] || echo "Первое сообщение из volume" > /data/message.txt'

docker build -t "$BACKEND_IMAGE" backend
docker build -t "$FRONTEND_IMAGE" frontend

docker rm -f "$FRONTEND" "$BACKEND" >/dev/null 2>&1 || true

docker run -d \
  --name "$BACKEND" \
  --network "$NETWORK" \
  --network-alias backend \
  --cpus 0.5 \
  --memory 128m \
  -v "${VOLUME}:/data" \
  "$BACKEND_IMAGE"

docker run -d \
  --name "$FRONTEND" \
  --network "$NETWORK" \
  --network-alias frontend \
  --cpus 0.5 \
  --memory 64m \
  -p "${PORT}:${FRONTEND_INTERNAL_PORT}" \
  "$FRONTEND_IMAGE"

echo "Стенд запущен на: http://localhost:${PORT}/"
