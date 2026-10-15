#!/usr/bin/env bash
set -euo pipefail

PROJECT="docker-homework-19"

docker rm -f "${PROJECT}-frontend" "${PROJECT}-backend" 2>/dev/null || true

docker network rm "$PROJECT" 2>/dev/null || true
if [ "${REMOVE_VOLUME:-0}" = "1" ]; then
  docker volume rm "${PROJECT}-data" 2>/dev/null || true
fi
