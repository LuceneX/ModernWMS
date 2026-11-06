# ModernWMS feature and test matrix

This is the working acceptance record for the LuceneX fork. It uses the
official ModernWMS release README as the deployment baseline and the frontend
menu/action registry as the functional inventory. A feature is not considered
complete because its route loads: its list, permissions, validation, and
write-path must also be exercised.

Official baseline: [fjykTec/ModernWMS](https://github.com/fjykTec/ModernWMS)

## Test legend

- `PASS` — exercised against the Colima stack and returned the expected result.
- `PARTIAL` — the route or read path works, but a write or sub-flow is still untested.
- `FAIL` — reproduced failure with evidence recorded below.
- `BLOCKED` — cannot safely test without an explicit business fixture or user decision.

## Functional inventory

| Area | Implemented functions | Current status |
| --- | --- | --- |
| Company settings | save, delete, export | PASS for create → read → update → delete; export remains PARTIAL |
| User roles | save, delete, export | PASS for create → read → update → delete; export remains PARTIAL |
| Role-menu permissions | assign menus and action authorities | PASS for create → read → update → authority readback → delete |
| User management | save, delete, import, export, reset password | PASS for create → read → update → reset password → delete and isolated import/delete; export remains PARTIAL |
| Commodity categories | save, delete, export | PASS for create |
| Commodity/SKU management | save, delete, export, safety stock, QR print, barcode print | PASS for create; remaining actions PARTIAL |
| Suppliers | save, delete, import, export | PASS for create |
| Print solutions | save, delete, export | PASS for create → read → update → get-by-path → delete; export remains PARTIAL |
| Warehouse settings | warehouse/area/location save, delete, import, export, barcode/QR print | PASS for warehouse/area/location create |
| Cargo owners | save, delete, import, export | PASS for create |
| Freight settings | save, delete, import, export | PASS for create and dispatch-rate use |
| Customers | save, delete, import, export | PASS for create and dispatch use |
| Receiving/ASN | notice save/delete/export/QR; arrival, unload, sort, putaway, confirm/cancel, export | PASS for create → arrival → unload → sort → putaway |
| Stock management | stock/location reads, stock export | PASS for read path and putaway-generated stock; export remains PARTIAL |
| Warehouse processing | split, group, confirm operation, confirm adjustment, delete, export | PASS for fixture create → process-confirm → adjustment-confirm; split/group/delete/export remain PARTIAL |
| Warehouse moves | save, delete, export, confirm | PASS for create → confirm; destination merge regression covered |
| Warehouse freeze | freeze, unfreeze, export | PASS for freeze → unfreeze |
| Warehouse adjustment | export and adjustment workflow | PASS for create → confirm; controller contract repaired |
| Stocktaking | save, delete, export, confirm operation, confirm adjustment | PASS for create → count confirm → adjustment confirm |
| Delivery/shipping | invoice save/confirm/revoke/delete/export/QR; pick, pack, weigh, deliver, carrier, sign-in and exports | PASS for dispatch → pick → pack → weigh → deliver → freight → sign, cancellation, and import/delete; export and QR/print remain PARTIAL |
| Statistics | ASN, delivery, stock-age, safety-stock exports | PASS for ASN, delivery, stock-age, and safety-stock list paths; browser export remains PARTIAL |
| Visual warehouse | spatial/3D view | PASS after iframe sizing fix; Unity scene and LuceneX warehouse KPI panel load. Latvian/Chinese Unity-internal labels still require a dedicated asset/localization pass |
| Approval-flow configuration | flow definition, nested map, approvers, conditions | PASS for isolated create → map traversal → list → exact delete; transaction-specific approval execution remains PARTIAL |

## Verified against Colima

On 2026-11-06, the following authenticated list calls returned HTTP 200 and
`isSuccess: true` using the seeded `admin` account and the same POST pagination
payload used by the frontend:

- `/stockmove/list`
- `/stockadjust/list`
- `/stocktaking/list`
- `/asn/asnmaster/list`
- `/stock/stock-list`
- `/dispatchlist/advanced-list`

The frontend container returned HTTP 200, the backend login returned a token,
anonymous `/warehouse/all` returned HTTP 401, authenticated `/warehouse/all`,
`/rolemenu/menus`, and `/stockmove/all` returned HTTP 200, and the SQLite
reconciliation script completed on backend startup. The local Vue production
build also passed.

## Fixture-backed write verification

The following clearly labeled local QA records were created on 2026-11-06 and
remain available for continued manual testing:

- warehouse `Codex QA 1793922121`, area `QA Receiving`, location `QA-RCV-01`;
- category `Codex QA Category`, supplier `Codex QA Supplier`, owner `Codex QA Owner`;
- SKU `QA-SKU-004` under `QA-SPU-004`;
- an ASN using that SKU, successfully advanced through arrival, unload, sorting,
  and putaway.
- a stocktaking record for the generated stock, successfully advanced through
  count confirmation and adjustment confirmation.
- destination location `QA-STAGE-02`, customer `Codex QA Customer`, and freight
  rate `Codex QA Carrier` were added for outbound testing.
- a QA stock movement was created and confirmed, then a freeze and unfreeze were
  applied successfully.
- a manual stock adjustment was created and confirmed; its generated job number
  and stock increase were verified in SQLite.
- dispatch `20261106-0001` was created and advanced through pick confirmation,
  packaging, weighing, delivery, freight assignment, and customer signature.
- a second QA movement into an occupied destination was confirmed and verified
  to merge into the existing stock row instead of creating a duplicate.
- dispatch cancellation was exercised for `20261106-0003`; the order returned to
  the cancelled state and its pick-list rows were removed.
- dispatch import was exercised with import group `902`; the created order was
  read back by its generated number and then deleted by that exact number.
- user management was exercised with an isolated user: create, read, update,
  password reset, and exact delete all returned success. A separate isolated
  import record was created, read back from `/user/list`, and exact-deleted.
- delivery statistics and stock-age statistics initially reproduced
  `operation_failed` on SQLite. The backend was corrected to avoid decimal
  aggregation in SQLite and to calculate stock age after materialization; both
  endpoints now return populated successful responses from the rebuilt Colima
  container.
- approval-flow configuration was exercised with an isolated two-node tenant
  fixture. Create, nested map traversal, list, exact delete, and post-delete
  not-found verification all passed. The flow-tree recursion defect and the
  missing controller/request contract were corrected before this test.
- warehouse processing jobs `20261106-0001` through `20261106-0003` were used
  for processing checks. A corrected fixture with `process_status=false`
  completed process confirmation and adjustment confirmation; SQLite verified
  the source quantity decreased and the destination quantity increased.
- a temporary role-menu fixture was created, updated from one menu to another,
  read back through both the role-menu and authority endpoints, and deleted.
- temporary company and print-solution fixtures completed CRUD; the print
  solution also passed the `get-by-path` lookup.
- browser-level verification opened the processing QR dialog and visibly
  rendered a QR image for `20261106-0003`; the print action invoked the browser
  print surface and was dismissed after verification. The processing export
  control produced `/Users/ernissmal/Downloads/Warehouse Processing.xlsx`.
- the visual-warehouse route was opened from the sidebar. The Unity iframe was
  initially only 4px high; after the CSS sizing fix it filled the 724px
  workspace and the LuceneX warehouse scene/KPI panel loaded.

The write path returned `isSuccess: true` at every step. These are test records,
not production data; retain or remove them deliberately when testing locally.

## Known failures and risks

- The original SQLite snapshot had all 19 admin menu rows but empty action
  authority arrays. The repair script now restores the built-in admin action
  set from the frontend registry. A fresh login is required after restart.
- The dispatch workflow is now fixture-backed through customer creation,
  allocation, picking, packaging, weighing, delivery, freight, signature,
  cancellation, and import/delete. Export and QR/print interaction still need
  browser-level verification.
- QR preview, browser print invocation, and XLSX export were exercised from
  the warehouse-processing UI. Physical printer output is not claimed because
  no printer was attached to this local environment.
- The processing service previously matched expiry, price, and putaway fields
  against the series-number expression. That reproducible schema/identity bug
  was corrected and the rebuilt container passed the fixture workflow.
- The frontend contract requires new processing jobs to send
  `process_status=false`; omitting it lets the backend default to true and
  makes process confirmation report `status_changed`.
- The frontend dependency tree reports 54 npm audit findings during the
  container build, including 2 critical findings. They are inherited legacy
  dependencies and are not silently suppressed.
- The frontend build reports legacy `eval` usage in `yk-vue-plugin-hiprint`
  and several large bundles.
- User, warehouse-master, receiving, inventory, dispatch, and statistics
  exports are generated by the browser-side XLSX helper. They still need a
  browser download assertion for every individual screen; API success alone
  does not prove a file was downloaded.
- Approval workflow entities and a service exist in the backend, but this fork
  now have tenant-scoped configuration endpoints and a frontend API module.
  The actual operation-specific approval execution/decision screens are not
  implemented in the upstream schema exposed by this fork, so that portion
  remains PARTIAL rather than being represented as complete.
- Individual menu action permissions are still client-side data; backend
  endpoints enforce authentication and tenant scoping but do not yet enforce
  each `menu_actions_authority` code. This is a security limitation requiring
  a dedicated authorization policy pass.
- The application targets .NET 7, which is out of mainstream support. This is
  a deployment/security risk and should be tracked separately from functional
  reconciliation.
- Colima initially reported a containerd metadata `input/output error` while
  rebuilding the frontend image. Restarting Colima cleared the condition and
  the combined `docker compose up --build -d` completed successfully.
- SKU creation initially failed with `NOT NULL constraint failed: spu.bar_code`,
  followed by `table sku has no column named bar_code`. The backend models and
  the SQLite repair script now explicitly include both compatibility columns.
- The host filesystem reached 99% usage and caused containerd failures. The
  obsolete Homebrew cache was cleaned; this is an environment prerequisite,
  not an application defect.
- The visual warehouse is a Unity WebGL scene under `frontend/public/unity`.
  Its iframe sizing is now fixed and the scene loads, but the embedded Unity
  asset is not covered by the Vue i18n catalog. Any remaining Chinese labels
  inside that binary asset require a Unity source/asset localization change.

## How to extend this matrix

For each `PARTIAL` row, add a fixture-backed test that creates or selects a
record, performs the write action, verifies the response and database state,
then cleans up only records created by the test. Never use production data as
an implicit test fixture.

