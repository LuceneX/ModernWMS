#!/usr/bin/env bash
set -euo pipefail

DB_PATH="${WMS_DB_PATH:-/data/wms.db}"
mkdir -p "$(dirname "$DB_PATH")"

# Refuse to silently replace a populated or damaged database.
if [[ "$(sqlite3 "$DB_PATH" 'PRAGMA quick_check;')" != "ok" ]]; then
  echo "SQLite integrity check failed: $DB_PATH. Restore a verified backup." >&2
  exit 1
fi
if [[ "$(sqlite3 "$DB_PATH" "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='rolemenu';")" == 0 ]]; then
  while IFS= read -r table; do
    escaped="${table//\"/\"\"}"
    if [[ "$(sqlite3 "$DB_PATH" "SELECT count(*) FROM \"$escaped\";")" != 0 ]]; then
      echo "Missing base schema in a populated database: $DB_PATH. Back up and migrate it explicitly." >&2
      exit 1
    fi
  done < <(sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
  sqlite3 -bail "$DB_PATH" < /app/seed-sqlite.sql
  echo "Initialized SQLite baseline: $DB_PATH"
fi

bash /app/ensure-sqlite-schema.sh "$DB_PATH"
export ConnectionStrings__SqlLiteConn="Data Source=$DB_PATH"
cd /app
exec dotnet /app/ModernWMS.dll "$@"
