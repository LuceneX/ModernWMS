#!/usr/bin/env bash
set -euo pipefail

# Run from backend/ModernWMS before starting the compiled backend.
# This repairs the legacy bundled database without replacing any warehouse data.
DB_PATH="${1:-wms.db}"

table_exists() {
  sqlite3 "$DB_PATH" "SELECT 1 FROM sqlite_master WHERE type='table' AND name='$1';" | grep -q 1
}

column_exists() {
  sqlite3 "$DB_PATH" "SELECT 1 FROM pragma_table_info('$1') WHERE name='$2';" | grep -q 1
}

add_column() {
  local table="$1"
  local column="$2"
  local definition="$3"
  if ! column_exists "$table" "$column"; then
    sqlite3 "$DB_PATH" "ALTER TABLE [$table] ADD COLUMN [$column] $definition;"
  fi
}

sqlite3 "$DB_PATH" <<'SQL'
CREATE TABLE IF NOT EXISTS action_log (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  vue_path TEXT NOT NULL DEFAULT '',
  user_name TEXT NOT NULL DEFAULT '',
  action_content TEXT NOT NULL DEFAULT '',
  action_time TEXT NOT NULL,
  tenant_id INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS asnmaster (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  asn_no TEXT NOT NULL DEFAULT '',
  asn_batch TEXT NOT NULL DEFAULT '',
  estimated_arrival_time TEXT NOT NULL DEFAULT '0001-01-01 00:00:00',
  asn_status INTEGER NOT NULL DEFAULT 0,
  weight TEXT NOT NULL DEFAULT '0',
  volume TEXT NOT NULL DEFAULT '0',
  goods_owner_id INTEGER NOT NULL DEFAULT 0,
  goods_owner_name TEXT NOT NULL DEFAULT '',
  creator TEXT NOT NULL DEFAULT '',
  create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tenant_id INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS sku_safety_stock (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  sku_id INTEGER NOT NULL DEFAULT 0,
  warehouse_id INTEGER NOT NULL DEFAULT 0,
  safety_stock_qty INTEGER NOT NULL DEFAULT 0
);
SQL

add_column rolemenu menu_actions_authority "TEXT NOT NULL DEFAULT '[]'"
add_column asn asnmaster_id "INTEGER NOT NULL DEFAULT 0"
add_column asn expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column asn price "TEXT NOT NULL DEFAULT '0'"
add_column stock bar_code "TEXT NOT NULL DEFAULT ''"
add_column stock series_number "TEXT NOT NULL DEFAULT ''"
add_column stock expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stock price "TEXT NOT NULL DEFAULT '0'"
add_column stockadjust series_number "TEXT NOT NULL DEFAULT ''"
add_column stockadjust expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stockadjust price "TEXT NOT NULL DEFAULT '0'"
add_column stockadjust putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stockmove series_number "TEXT NOT NULL DEFAULT ''"
add_column stockmove expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stockmove price "TEXT NOT NULL DEFAULT '0'"
add_column stockmove putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stockfreeze series_number "TEXT NOT NULL DEFAULT ''"
add_column stockfreeze expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stockfreeze price "TEXT NOT NULL DEFAULT '0'"
add_column stockfreeze putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stocktaking series_number "TEXT NOT NULL DEFAULT ''"
add_column stocktaking expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stocktaking price "TEXT NOT NULL DEFAULT '0'"
add_column stocktaking putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"

echo "SQLite schema reconciled: $DB_PATH"
