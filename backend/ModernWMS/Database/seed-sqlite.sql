-- Baseline schema and built-in demo account; no warehouse records.
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" TEXT NOT NULL CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY,
    "ProductVersion" TEXT NOT NULL
);
INSERT INTO "__EFMigrationsHistory" VALUES('20230106043721_InitialCreate','7.0.1');
CREATE TABLE IF NOT EXISTS action_log (id INTEGER NOT NULL CONSTRAINT PK_action_log PRIMARY KEY AUTOINCREMENT, vue_path TEXT NOT NULL DEFAULT '', user_name TEXT NOT NULL DEFAULT '', action_content TEXT NOT NULL DEFAULT '', action_time TEXT NOT NULL, tenant_id INTEGER NOT NULL DEFAULT 1);
CREATE TABLE IF NOT EXISTS "asn" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_asn" PRIMARY KEY AUTOINCREMENT,
    "asn_no" TEXT NOT NULL,
    "asn_status" INTEGER NOT NULL,
    "spu_id" INTEGER NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "asn_qty" INTEGER NOT NULL,
    "actual_qty" INTEGER NOT NULL,
    "sorted_qty" INTEGER NOT NULL,
    "shortage_qty" INTEGER NOT NULL,
    "more_qty" INTEGER NOT NULL,
    "damage_qty" INTEGER NOT NULL,
    "weight" TEXT NOT NULL,
    "volume" TEXT NOT NULL,
    "supplier_id" INTEGER NOT NULL,
    "supplier_name" TEXT NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "goods_owner_name" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
, asnmaster_id INTEGER NOT NULL DEFAULT 0, expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', price TEXT NOT NULL DEFAULT '0', [arrival_time] TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', [unload_time] TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', [unload_person_id] INTEGER NOT NULL DEFAULT 0, [unload_person] TEXT NOT NULL DEFAULT '');
CREATE TABLE IF NOT EXISTS asnmaster (
  id INTEGER NOT NULL CONSTRAINT PK_asnmaster PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE IF NOT EXISTS "asnsort" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_asnsort" PRIMARY KEY AUTOINCREMENT,
    "asn_id" INTEGER NOT NULL,
    "sorted_qty" INTEGER NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
, series_number TEXT NOT NULL DEFAULT '', [putaway_qty] INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS "category" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_category" PRIMARY KEY AUTOINCREMENT,
    "category_name" TEXT NOT NULL,
    "parent_id" INTEGER NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "company" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_company" PRIMARY KEY AUTOINCREMENT,
    "company_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "manager" TEXT NOT NULL,
    "contact_tel" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "customer" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_customer" PRIMARY KEY AUTOINCREMENT,
    "customer_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "manager" TEXT NOT NULL,
    "contact_tel" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "dispatchlist" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_dispatchlist" PRIMARY KEY AUTOINCREMENT,
    "dispatch_no" TEXT NOT NULL,
    "dispatch_status" INTEGER NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "customer_name" TEXT NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL,
    "weight" TEXT NOT NULL,
    "volume" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "damage_qty" INTEGER NOT NULL,
    "lock_qty" INTEGER NOT NULL,
    "picked_qty" INTEGER NOT NULL,
    "intrasit_qty" INTEGER NOT NULL,
    "package_qty" INTEGER NOT NULL,
    "weighing_qty" INTEGER NOT NULL,
    "actual_qty" INTEGER NOT NULL,
    "sign_qty" INTEGER NOT NULL,
    "package_no" TEXT NOT NULL,
    "package_person" TEXT NOT NULL,
    "package_time" TEXT NOT NULL,
    "weighing_no" TEXT NOT NULL,
    "weighing_person" TEXT NOT NULL,
    "weighing_weight" TEXT NOT NULL,
    "waybill_no" TEXT NOT NULL,
    "carrier" TEXT NOT NULL,
    "freightfee" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
, [pick_checker_id] INTEGER NOT NULL DEFAULT 0, [pick_checker] TEXT NOT NULL DEFAULT '');
CREATE TABLE IF NOT EXISTS "dispatchpicklist" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_dispatchpicklist" PRIMARY KEY AUTOINCREMENT,
    "dispatchlist_id" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "goods_location_id" INTEGER NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "pick_qty" INTEGER NOT NULL,
    "picked_qty" INTEGER NOT NULL,
    "is_update_stock" INTEGER NOT NULL,
    "last_update_time" TEXT NOT NULL, series_number TEXT NOT NULL DEFAULT '', expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', [picker_id] INTEGER NOT NULL DEFAULT 0, [picker] TEXT NOT NULL DEFAULT '', [price] TEXT NOT NULL DEFAULT '0', [putaway_date] TEXT NOT NULL DEFAULT '0001-01-01 00:00:00',
    CONSTRAINT "FK_dispatchpicklist_dispatchlist_dispatchlist_id" FOREIGN KEY ("dispatchlist_id") REFERENCES "dispatchlist" ("id") ON DELETE CASCADE
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
CREATE TABLE IF NOT EXISTS flowsetmain (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  menu TEXT NOT NULL DEFAULT '',
  flow_name TEXT NOT NULL DEFAULT '',
  creator TEXT NOT NULL DEFAULT '',
  create_time TEXT NOT NULL DEFAULT '0001-01-01 00:00:00',
  tenant_id INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS flowsetusers (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  flowset_id INTEGER NOT NULL DEFAULT 0,
  flowsetmain_id INTEGER NOT NULL DEFAULT 0,
  node_guid TEXT NOT NULL DEFAULT '',
  user_id INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (flowset_id) REFERENCES flowset(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "freightfee" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_freightfee" PRIMARY KEY AUTOINCREMENT,
    "carrier" TEXT NOT NULL,
    "departure_city" TEXT NOT NULL,
    "arrival_city" TEXT NOT NULL,
    "price_per_weight" TEXT NOT NULL,
    "price_per_volume" TEXT NOT NULL,
    "min_payment" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
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
CREATE TABLE IF NOT EXISTS "goodslocation" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_goodslocation" PRIMARY KEY AUTOINCREMENT,
    "warehouse_id" INTEGER NOT NULL,
    "warehouse_name" TEXT NOT NULL,
    "warehouse_area_name" TEXT NOT NULL,
    "warehouse_area_property" INTEGER NOT NULL,
    "location_name" TEXT NOT NULL,
    "location_length" TEXT NOT NULL,
    "location_width" TEXT NOT NULL,
    "location_heigth" TEXT NOT NULL,
    "location_volume" TEXT NOT NULL,
    "location_load" TEXT NOT NULL,
    "roadway_number" TEXT NOT NULL,
    "shelf_number" TEXT NOT NULL,
    "layer_number" TEXT NOT NULL,
    "tag_number" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "warehouse_area_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "goodsowner" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_goodsowner" PRIMARY KEY AUTOINCREMENT,
    "goods_owner_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "manager" TEXT NOT NULL,
    "contact_tel" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "menu" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_menu" PRIMARY KEY AUTOINCREMENT,
    "menu_name" TEXT NOT NULL,
    "module" TEXT NOT NULL,
    "vue_path" TEXT NOT NULL,
    "vue_path_detail" TEXT NOT NULL,
    "vue_directory" TEXT NOT NULL,
    "sort" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
, [menu_actions] TEXT NOT NULL DEFAULT '[]');
INSERT INTO "menu" VALUES(20,'companySetting','baseModule','companySetting','','base/companySetting',1,1,'[]');
INSERT INTO "menu" VALUES(21,'userRoleSetting','baseModule','userRoleSetting','','base/userRoleSetting',2,1,'[]');
INSERT INTO "menu" VALUES(22,'roleMenu','baseModule','roleMenu','','base/roleMenu',3,1,'[]');
INSERT INTO "menu" VALUES(23,'userManagement','baseModule','userManagement','','base/userManagement',4,1,'[]');
INSERT INTO "menu" VALUES(24,'commodityCategorySetting','baseModule','commodityCategorySetting','','base/commodityCategorySetting',5,1,'[]');
INSERT INTO "menu" VALUES(25,'commodityManagement','baseModule','commodityManagement','','base/commodityManagement',6,1,'[]');
INSERT INTO "menu" VALUES(26,'supplier','baseModule','supplier','','base/supplier',7,1,'[]');
INSERT INTO "menu" VALUES(27,'warehouseSetting','baseModule','warehouseSetting','','base/warehouseSetting',8,1,'[]');
INSERT INTO "menu" VALUES(28,'ownerOfCargo','baseModule','ownerOfCargo','','base/ownerOfCargo',9,1,'[]');
INSERT INTO "menu" VALUES(29,'freightSetting','baseModule','freightSetting','','base/freightSetting',10,1,'[]');
INSERT INTO "menu" VALUES(30,'customer','baseModule','customer','','base/customer',12,1,'[]');
INSERT INTO "menu" VALUES(31,'stockManagement','','stockManagement','','wms/stockManagement',12,1,'[]');
INSERT INTO "menu" VALUES(32,'warehouseProcessing','warehouseWorkingModule','warehouseProcessing','','warehouseWorking/warehouseProcessing',13,1,'[]');
INSERT INTO "menu" VALUES(33,'warehouseMove','warehouseWorkingModule','warehouseMove','','warehouseWorking/warehouseMove',14,1,'[]');
INSERT INTO "menu" VALUES(34,'warehouseFreeze','warehouseWorkingModule','warehouseFreeze','','warehouseWorking/warehouseFreeze',15,1,'[]');
INSERT INTO "menu" VALUES(35,'warehouseAdjust','warehouseWorkingModule','warehouseAdjust','','warehouseWorking/warehouseAdjust',16,1,'[]');
INSERT INTO "menu" VALUES(36,'warehouseTaking','warehouseWorkingModule','warehouseTaking','','warehouseWorking/warehouseTaking',17,1,'[]');
INSERT INTO "menu" VALUES(37,'stockAsn','','stockAsn','','wms/stockAsn',18,1,'[]');
INSERT INTO "menu" VALUES(38,'deliveryManagement','deliveryManagement','deliveryManagement','','deliveryManagement/deliveryManagement',19,1,'[]');
CREATE TABLE IF NOT EXISTS "rolemenu" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_rolemenu" PRIMARY KEY AUTOINCREMENT,
    "userrole_id" INTEGER NOT NULL,
    "menu_id" INTEGER NOT NULL,
    "authority" INTEGER NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
, menu_actions_authority TEXT NOT NULL DEFAULT '[]');
INSERT INTO "rolemenu" VALUES(1,1,20,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","export"]');
INSERT INTO "rolemenu" VALUES(2,1,21,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","export"]');
INSERT INTO "rolemenu" VALUES(3,1,22,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'[]');
INSERT INTO "rolemenu" VALUES(4,1,23,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","import","export","resetPwd"]');
INSERT INTO "rolemenu" VALUES(5,1,24,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","export"]');
INSERT INTO "rolemenu" VALUES(6,1,25,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","export","saftyStock","printQrCode","printBarCode"]');
INSERT INTO "rolemenu" VALUES(7,1,26,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","import","export"]');
INSERT INTO "rolemenu" VALUES(8,1,27,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["warehouse-save","warehouse-delete","warehouse-import","warehouse-export","area-save","area-delete","area-export","location-save","location-delete","location-export","location-printBarCode","location-printQrCode"]');
INSERT INTO "rolemenu" VALUES(9,1,28,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","import","export"]');
INSERT INTO "rolemenu" VALUES(10,1,29,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","import","export"]');
INSERT INTO "rolemenu" VALUES(11,1,30,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","import","export"]');
INSERT INTO "rolemenu" VALUES(12,1,31,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["area-export","stock-export"]');
INSERT INTO "rolemenu" VALUES(13,1,32,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["split","group","confirmOpeartion","confirmAdjust","delete","export"]');
INSERT INTO "rolemenu" VALUES(14,1,33,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","export","confirm"]');
INSERT INTO "rolemenu" VALUES(15,1,34,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["freeze","unfreeze","export"]');
INSERT INTO "rolemenu" VALUES(16,1,35,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["export"]');
INSERT INTO "rolemenu" VALUES(17,1,36,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["save","delete","export","confirmOpeartion","confirmAdjust"]');
INSERT INTO "rolemenu" VALUES(18,1,37,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["notice-save","notice-delete","notice-export","notice-printQrCode","putOnTheShelf-printQrCode","delivered-confirm","delivered-export","unloaded-confirm","unloaded-delete","unloaded-export","sorted-editCount","sorted-confirm","sorted-delete","sorted-export","putOnTheShelf-editArrival","putOnTheShelf-delete","putOnTheShelf-export","detail-export"]');
INSERT INTO "rolemenu" VALUES(19,1,38,1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1,'["invoice-save","invoice-confirm","invoice-revoke","invoice-delete","invoice-export","invoice-printQrCode","picked-confirm","picked-revoke","picked-export","packaged-package","packaged-export","packaged-revoke","weighed-weigh","weighed-export","weighed-revoke","delivered-delivery","delivered-setCarrier","delivered-signIn","delivered-export","signedIn-export"]');
CREATE TABLE IF NOT EXISTS "sku" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_sku" PRIMARY KEY AUTOINCREMENT,
    "spu_id" INTEGER NOT NULL,
    "sku_code" TEXT NOT NULL,
    "sku_name" TEXT NOT NULL,
    "weight" TEXT NOT NULL,
    "lenght" TEXT NOT NULL,
    "width" TEXT NOT NULL,
    "height" TEXT NOT NULL,
    "volume" TEXT NOT NULL,
    "unit" TEXT NOT NULL,
    "cost" TEXT NOT NULL,
    "price" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    CONSTRAINT "FK_sku_spu_spu_id" FOREIGN KEY ("spu_id") REFERENCES "spu" ("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS sku_safety_stock (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, sku_id INTEGER NOT NULL DEFAULT 0, warehouse_id INTEGER NOT NULL DEFAULT 0, safety_stock_qty INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS "spu" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_spu" PRIMARY KEY AUTOINCREMENT,
    "spu_code" TEXT NOT NULL,
    "spu_name" TEXT NOT NULL,
    "category_id" INTEGER NOT NULL,
    "spu_description" TEXT NOT NULL,
    "bar_code" TEXT NOT NULL,
    "supplier_id" INTEGER NOT NULL,
    "supplier_name" TEXT NOT NULL,
    "brand" TEXT NOT NULL,
    "origin" TEXT NOT NULL,
    "length_unit" INTEGER NOT NULL,
    "volume_unit" INTEGER NOT NULL,
    "weight_unit" INTEGER NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "stock" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stock" PRIMARY KEY AUTOINCREMENT,
    "sku_id" INTEGER NOT NULL,
    "goods_location_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "is_freeze" INTEGER NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
, series_number TEXT NOT NULL DEFAULT '', expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', bar_code TEXT NOT NULL DEFAULT '', price TEXT NOT NULL DEFAULT '0', [putaway_date] TEXT NOT NULL DEFAULT '0001-01-01 00:00:00');
CREATE TABLE IF NOT EXISTS "stockadjust" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stockadjust" PRIMARY KEY AUTOINCREMENT,
    "job_code" TEXT NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "goods_location_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "is_update_stock" INTEGER NOT NULL,
    "job_type" INTEGER NOT NULL,
    "source_table_id" INTEGER NOT NULL
, series_number TEXT NOT NULL DEFAULT '', expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', price TEXT NOT NULL DEFAULT '0', putaway_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00');
CREATE TABLE IF NOT EXISTS "stockfreeze" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stockfreeze" PRIMARY KEY AUTOINCREMENT,
    "job_code" TEXT NOT NULL,
    "job_type" INTEGER NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "goods_location_id" INTEGER NOT NULL,
    "handler" TEXT NOT NULL,
    "handle_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
, series_number TEXT NOT NULL DEFAULT '', expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', price TEXT NOT NULL DEFAULT '0', putaway_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00');
CREATE TABLE IF NOT EXISTS "stockmove" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stockmove" PRIMARY KEY AUTOINCREMENT,
    "job_code" TEXT NOT NULL,
    "move_status" INTEGER NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "orig_goods_location_id" INTEGER NOT NULL,
    "dest_googs_location_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "handler" TEXT NOT NULL,
    "handle_time" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
, series_number TEXT NOT NULL DEFAULT '', expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', price TEXT NOT NULL DEFAULT '0', putaway_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00');
CREATE TABLE IF NOT EXISTS "stockprocess" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stockprocess" PRIMARY KEY AUTOINCREMENT,
    "job_code" TEXT NOT NULL,
    "job_type" INTEGER NOT NULL,
    "process_status" INTEGER NOT NULL,
    "processor" TEXT NOT NULL,
    "process_time" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "stockprocessdetail" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stockprocessdetail" PRIMARY KEY AUTOINCREMENT,
    "stock_process_id" INTEGER NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "goods_location_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "is_source" INTEGER NOT NULL,
    "is_update_stock" INTEGER NOT NULL, [series_number] TEXT NOT NULL DEFAULT '', [expiry_date] TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', [price] TEXT NOT NULL DEFAULT '0', [putaway_date] TEXT NOT NULL DEFAULT '0001-01-01 00:00:00',
    CONSTRAINT "FK_stockprocessdetail_stockprocess_stock_process_id" FOREIGN KEY ("stock_process_id") REFERENCES "stockprocess" ("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "stocktaking" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_stocktaking" PRIMARY KEY AUTOINCREMENT,
    "job_code" TEXT NOT NULL,
    "job_status" INTEGER NOT NULL,
    "sku_id" INTEGER NOT NULL,
    "goods_owner_id" INTEGER NOT NULL,
    "goods_location_id" INTEGER NOT NULL,
    "book_qty" INTEGER NOT NULL,
    "counted_qty" INTEGER NOT NULL,
    "difference_qty" INTEGER NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "handler" TEXT NOT NULL,
    "handle_time" TEXT NOT NULL
, series_number TEXT NOT NULL DEFAULT '', expiry_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00', price TEXT NOT NULL DEFAULT '0', putaway_date TEXT NOT NULL DEFAULT '0001-01-01 00:00:00');
CREATE TABLE IF NOT EXISTS "supplier" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_supplier" PRIMARY KEY AUTOINCREMENT,
    "supplier_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "manager" TEXT NOT NULL,
    "contact_tel" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "user" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_user" PRIMARY KEY AUTOINCREMENT,
    "user_num" TEXT NOT NULL,
    "user_name" TEXT NOT NULL,
    "contact_tel" TEXT NOT NULL,
    "user_role" TEXT NOT NULL,
    "sex" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "auth_string" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
INSERT INTO "user" VALUES(1,'admin','admin','','admin','male',1,'c4ca4238a0b923820dcc509a6f75849b','7908990404@qq.com','admin','2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1);
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
CREATE TABLE IF NOT EXISTS "userrole" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_userrole" PRIMARY KEY AUTOINCREMENT,
    "role_name" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
INSERT INTO "userrole" VALUES(1,'admin',1,'2023-01-06 14:14:34.3281933','2023-01-06 14:14:34.3281933',1);
CREATE TABLE IF NOT EXISTS "warehouse" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_warehouse" PRIMARY KEY AUTOINCREMENT,
    "warehouse_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "manager" TEXT NOT NULL,
    "contact_tel" TEXT NOT NULL,
    "creator" TEXT NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "warehousearea" (
    "id" INTEGER NOT NULL CONSTRAINT "PK_warehousearea" PRIMARY KEY AUTOINCREMENT,
    "warehouse_id" INTEGER NOT NULL,
    "area_name" TEXT NOT NULL,
    "parent_id" INTEGER NOT NULL,
    "create_time" TEXT NOT NULL,
    "last_update_time" TEXT NOT NULL,
    "is_valid" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "area_property" INTEGER NOT NULL
);
CREATE INDEX "IX_dispatchpicklist_dispatchlist_id" ON "dispatchpicklist" ("dispatchlist_id");
CREATE INDEX "IX_sku_spu_id" ON "sku" ("spu_id");
CREATE INDEX "IX_stockprocessdetail_stock_process_id" ON "stockprocessdetail" ("stock_process_id");
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('menu',38);
INSERT INTO "sqlite_sequence" VALUES('user',1);
INSERT INTO "sqlite_sequence" VALUES('userrole',1);
INSERT INTO "sqlite_sequence" VALUES('rolemenu',19);
INSERT INTO "sqlite_sequence" VALUES('spu',1);
INSERT INTO "sqlite_sequence" VALUES('sku',1);
INSERT INTO "sqlite_sequence" VALUES('customer',1);
INSERT INTO "sqlite_sequence" VALUES('dispatchlist',5);
COMMIT;
