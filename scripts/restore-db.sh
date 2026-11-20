#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: $0 <backup.sql.gz>" >&2
  exit 2
fi

echo "This replaces the current database contents."
printf "Type RESTORE to continue: "
read answer
if [ "$answer" != "RESTORE" ]; then
  echo "Restore cancelled."
  exit 1
fi

gzip -dc -- "$1" | docker compose exec -T db sh -c 'psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
echo "Database restore completed."
