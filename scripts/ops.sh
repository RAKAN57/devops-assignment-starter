#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  echo "Usage: $0 {up|down|status|logs|smoke}" >&2
  exit 2
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
action=$1
base_url="${BASE_URL:-http://localhost:${PORT:-8080}}"

case "$action" in
  up)
    docker compose up --build -d ||
      fail "Could not start the stack. Check Docker Desktop and .env."
    ;;
  down)
    docker compose down ||
      fail "Could not stop the stack."
    ;;
  status)
    docker compose ps ||
      fail "Could not read service status. Is Docker Desktop running?"
    ;;
  logs)
    docker compose logs --follow --tail=100 api ||
      fail "Could not read API logs."
    ;;
  smoke)
    curl --fail --silent --show-error "$base_url/health" >/dev/null ||
      fail "Health check failed. Start the stack with: $0 up"
    curl --fail --silent --show-error "$base_url/users" >/dev/null ||
      fail "GET /users failed."
    echo "Smoke checks passed: /health and /users"
    ;;
  *)
    usage
    ;;
esac