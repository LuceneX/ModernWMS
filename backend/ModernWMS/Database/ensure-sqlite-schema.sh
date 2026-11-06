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
BEGIN;
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
CREATE TABLE IF NOT EXISTS global_unique_serial (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL DEFAULT '',
  prefix_char TEXT NOT NULL DEFAULT '',
  reset_rule TEXT NOT NULL DEFAULT '',
  current_no INTEGER NOT NULL DEFAULT 1,
  last_update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tenant_id INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS flowsetmain (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  menu TEXT NOT NULL DEFAULT '',
  flow_name TEXT NOT NULL DEFAULT '',
  creator TEXT NOT NULL DEFAULT '',
  create_time TEXT NOT NULL DEFAULT '0001-01-01 00:00:00',
  tenant_id INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS flowset (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  flowsetmain_id INTEGER NOT NULL DEFAULT 0,
  is_origin INTEGER NOT NULL DEFAULT 0,
  is_end INTEGER NOT NULL DEFAULT 0,
  node_guid TEXT NOT NULL DEFAULT '',
  node_name TEXT NOT NULL DEFAULT '',
  prev_node_guid TEXT NOT NULL DEFAULT '',
  FOREIGN KEY (flowsetmain_id) REFERENCES flowsetmain(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS flowsetusers (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  flowset_id INTEGER NOT NULL DEFAULT 0,
  flowsetmain_id INTEGER NOT NULL DEFAULT 0,
  node_guid TEXT NOT NULL DEFAULT '',
  user_id INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (flowset_id) REFERENCES flowset(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS flowsetfilter (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  flowset_id INTEGER NOT NULL DEFAULT 0,
  flowsetmain_id INTEGER NOT NULL DEFAULT 0,
  node_guid TEXT NOT NULL DEFAULT '',
  logic TEXT NOT NULL DEFAULT '且',
  c1 TEXT NOT NULL DEFAULT '',
  col_label TEXT NOT NULL DEFAULT '',
  col_name TEXT NOT NULL DEFAULT '',
  compare TEXT NOT NULL DEFAULT '等于',
  content TEXT NOT NULL DEFAULT '',
  c2 TEXT NOT NULL DEFAULT '',
  sort INTEGER NOT NULL DEFAULT 0,
  condition_group TEXT NOT NULL DEFAULT '',
  formulas TEXT NOT NULL DEFAULT '',
  assert_mode TEXT NOT NULL DEFAULT '',
  table_name TEXT NOT NULL DEFAULT '',
  scheme_name TEXT NOT NULL DEFAULT '',
  FOREIGN KEY (flowset_id) REFERENCES flowset(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS user_defined_print_solution (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  vue_path TEXT NOT NULL DEFAULT '',
  tab_page TEXT NOT NULL DEFAULT '',
  solution_name TEXT NOT NULL DEFAULT '',
  config_json TEXT,
  report_length REAL NOT NULL DEFAULT 0,
  report_width REAL NOT NULL DEFAULT 0,
  report_direction TEXT NOT NULL DEFAULT '',
  last_update_time TEXT NOT NULL DEFAULT '0001-01-01 00:00:00',
  tenant_id INTEGER NOT NULL DEFAULT 0
);
COMMIT;
SQL

add_column rolemenu menu_actions_authority "TEXT NOT NULL DEFAULT '[]'"
add_column menu menu_actions "TEXT NOT NULL DEFAULT '[]'"
add_column spu bar_code "TEXT NOT NULL DEFAULT ''"
add_column sku bar_code "TEXT NOT NULL DEFAULT ''"
add_column asn asnmaster_id "INTEGER NOT NULL DEFAULT 0"
add_column asn arrival_time "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column asn unload_time "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column asn unload_person_id "INTEGER NOT NULL DEFAULT 0"
add_column asn unload_person "TEXT NOT NULL DEFAULT ''"
add_column asn expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column asn price "TEXT NOT NULL DEFAULT '0'"
add_column asnsort putaway_qty "INTEGER NOT NULL DEFAULT 0"
add_column dispatchlist pick_checker_id "INTEGER NOT NULL DEFAULT 0"
add_column dispatchlist pick_checker "TEXT NOT NULL DEFAULT ''"
add_column dispatchpicklist picker_id "INTEGER NOT NULL DEFAULT 0"
add_column dispatchpicklist picker "TEXT NOT NULL DEFAULT ''"
add_column dispatchpicklist price "TEXT NOT NULL DEFAULT '0'"
add_column dispatchpicklist putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stock bar_code "TEXT NOT NULL DEFAULT ''"
add_column stock series_number "TEXT NOT NULL DEFAULT ''"
add_column stock expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stock putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
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
add_column stockprocessdetail series_number "TEXT NOT NULL DEFAULT ''"
add_column stockprocessdetail expiry_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"
add_column stockprocessdetail price "TEXT NOT NULL DEFAULT '0'"
add_column stockprocessdetail putaway_date "TEXT NOT NULL DEFAULT '0001-01-01 00:00:00'"

expected_tables=(
  action_log asn asnmaster asnsort category company customer dispatchlist
  dispatchpicklist flowset flowsetfilter flowsetmain flowsetusers freightfee
  global_unique_serial goodslocation goodsowner menu rolemenu sku
  sku_safety_stock spu stock stockadjust stockfreeze stockmove stockprocess
  stockprocessdetail stocktaking supplier user user_defined_print_solution
  userrole warehouse warehousearea
)
for table in "${expected_tables[@]}"; do
  if ! table_exists "$table"; then
    echo "SQLite schema reconciliation failed: missing table $table" >&2
    exit 1
  fi
done

# Older bundled SQLite snapshots were created before the statistics menus were
# persisted. The Vue views and API controllers still exist, so restore the
# official menu entries additively for every tenant represented by a user.
# INSERT OR IGNORE keeps this safe for databases that already contain them.
sqlite3 "$DB_PATH" <<'SQL'
INSERT INTO menu
  (menu_name, module, vue_path, vue_path_detail, vue_directory, sort, tenant_id, menu_actions)
SELECT 'saftyStock', 'statisticAnalysis ', 'saftyStock', '', 'statisticAnalysis/saftyStock', 4, tenant_id, '[]'
FROM "user" u
WHERE NOT EXISTS (SELECT 1 FROM menu m WHERE m.vue_path = 'saftyStock' AND m.tenant_id = u.tenant_id)
GROUP BY tenant_id;
INSERT INTO menu
  (menu_name, module, vue_path, vue_path_detail, vue_directory, sort, tenant_id, menu_actions)
SELECT 'asnStatistic', 'statisticAnalysis ', 'asnStatistic', '', 'statisticAnalysis/asnStatistic', 5, tenant_id, '[]'
FROM "user" u
WHERE NOT EXISTS (SELECT 1 FROM menu m WHERE m.vue_path = 'asnStatistic' AND m.tenant_id = u.tenant_id)
GROUP BY tenant_id;
INSERT INTO menu
  (menu_name, module, vue_path, vue_path_detail, vue_directory, sort, tenant_id, menu_actions)
SELECT 'deliveryStatistic', 'statisticAnalysis ', 'deliveryStatistic', '', 'statisticAnalysis/deliveryStatistic', 6, tenant_id, '[]'
FROM "user" u
WHERE NOT EXISTS (SELECT 1 FROM menu m WHERE m.vue_path = 'deliveryStatistic' AND m.tenant_id = u.tenant_id)
GROUP BY tenant_id;
INSERT INTO menu
  (menu_name, module, vue_path, vue_path_detail, vue_directory, sort, tenant_id, menu_actions)
SELECT 'stockageStatistic', 'statisticAnalysis ', 'stockageStatistic', '', 'statisticAnalysis/stockageStatistic', 7, tenant_id, '[]'
FROM "user" u
WHERE NOT EXISTS (SELECT 1 FROM menu m WHERE m.vue_path = 'stockageStatistic' AND m.tenant_id = u.tenant_id)
GROUP BY tenant_id;

INSERT INTO rolemenu
  (userrole_id, menu_id, authority, create_time, last_update_time, tenant_id, menu_actions_authority)
SELECT r.id, m.id, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, m.tenant_id, '["export"]'
FROM userrole r
JOIN menu m ON m.tenant_id = r.tenant_id
WHERE r.role_name = 'admin'
  AND m.menu_name IN ('saftyStock', 'asnStatistic', 'deliveryStatistic', 'stockageStatistic')
  AND NOT EXISTS (
    SELECT 1 FROM rolemenu existing
    WHERE existing.userrole_id = r.id AND existing.menu_id = m.id AND existing.tenant_id = m.tenant_id
  );
SQL

# The stock distribution creates the admin role with every menu, but older
# SQLite snapshots can contain empty action lists. That leaves the UI readable
# while disabling every save/edit/delete/confirm control. Keep the repair
# idempotent and scope it to the built-in admin role only; custom roles remain
# under administrator control in the role-menu screen.
sqlite3 "$DB_PATH" <<'SQL'
UPDATE rolemenu
SET menu_actions_authority = CASE (
  SELECT menu_name FROM menu WHERE menu.id = rolemenu.menu_id
)
  WHEN 'companySetting' THEN '["save","delete","export"]'
  WHEN 'userRoleSetting' THEN '["save","delete","export"]'
  WHEN 'userManagement' THEN '["save","delete","import","export","resetPwd"]'
  WHEN 'commodityCategorySetting' THEN '["save","delete","export"]'
  WHEN 'commodityManagement' THEN '["save","delete","export","saftyStock","printQrCode","printBarCode"]'
  WHEN 'supplier' THEN '["save","delete","import","export"]'
  WHEN 'print' THEN '["save","delete","export"]'
  WHEN 'warehouseSetting' THEN '["warehouse-save","warehouse-delete","warehouse-import","warehouse-export","area-save","area-delete","area-export","location-save","location-delete","location-export","location-printBarCode","location-printQrCode"]'
  WHEN 'ownerOfCargo' THEN '["save","delete","import","export"]'
  WHEN 'freightSetting' THEN '["save","delete","import","export"]'
  WHEN 'customer' THEN '["save","delete","import","export"]'
  WHEN 'stockAsn' THEN '["notice-save","notice-delete","notice-export","notice-printQrCode","putOnTheShelf-printQrCode","delivered-confirm","delivered-export","unloaded-confirm","unloaded-delete","unloaded-export","sorted-editCount","sorted-confirm","sorted-delete","sorted-export","putOnTheShelf-editArrival","putOnTheShelf-delete","putOnTheShelf-export","detail-export"]'
  WHEN 'stockManagement' THEN '["area-export","stock-export"]'
  WHEN 'warehouseProcessing' THEN '["split","group","confirmOpeartion","confirmAdjust","delete","export"]'
  WHEN 'warehouseMove' THEN '["save","delete","export","confirm"]'
  WHEN 'warehouseFreeze' THEN '["freeze","unfreeze","export"]'
  WHEN 'warehouseAdjust' THEN '["export"]'
  WHEN 'warehouseTaking' THEN '["save","delete","export","confirmOpeartion","confirmAdjust"]'
  WHEN 'deliveryManagement' THEN '["invoice-save","invoice-confirm","invoice-revoke","invoice-delete","invoice-export","invoice-printQrCode","picked-confirm","picked-revoke","picked-export","packaged-package","packaged-export","packaged-revoke","weighed-weigh","weighed-export","weighed-revoke","delivered-delivery","delivered-setCarrier","delivered-signIn","delivered-export","signedIn-export"]'
  ELSE menu_actions_authority
END
WHERE userrole_id IN (SELECT id FROM userrole WHERE role_name = 'admin');
SQL

echo "SQLite schema reconciled: $DB_PATH"
