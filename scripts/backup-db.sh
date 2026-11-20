#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [output-file]" >&2
  exit 2
fi

mkdir -p backups
timestamp=$(date -u +%Y%m%dT%H%M%SZ)
output=${1:-"backups/notifications-${timestamp}.sql.gz"}
umask 077
docker compose exec -T db sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB"' | gzip > "$output"
echo "Database backup written to $output"
