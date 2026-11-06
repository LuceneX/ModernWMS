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
| Company settings | save, delete, export | PARTIAL |
| User roles | save, delete, export | PARTIAL |
| Role-menu permissions | assign menus and action authorities | PARTIAL — admin action seed repaired; UI write test pending |
| User management | save, delete, import, export, reset password | PARTIAL |
| Commodity categories | save, delete, export | PASS for create |
| Commodity/SKU management | save, delete, export, safety stock, QR print, barcode print | PASS for create; remaining actions PARTIAL |
| Suppliers | save, delete, import, export | PASS for create |
| Print solutions | save, delete, export | PARTIAL |
| Warehouse settings | warehouse/area/location save, delete, import, export, barcode/QR print | PASS for warehouse/area/location create |
| Cargo owners | save, delete, import, export | PASS for create |
| Freight settings | save, delete, import, export | PASS for create and dispatch-rate use |
| Customers | save, delete, import, export | PASS for create and dispatch use |
| Receiving/ASN | notice save/delete/export/QR; arrival, unload, sort, putaway, confirm/cancel, export | PASS for create → arrival → unload → sort → putaway |
| Stock management | stock/location reads, stock export | PASS for read path and putaway-generated stock; export remains PARTIAL |
| Warehouse processing | split, group, confirm operation, confirm adjustment, delete, export | PARTIAL |
| Warehouse moves | save, delete, export, confirm | PASS for create → confirm; destination merge regression covered |
| Warehouse freeze | freeze, unfreeze, export | PASS for freeze → unfreeze |
| Warehouse adjustment | export and adjustment workflow | PASS for create → confirm; controller contract repaired |
| Stocktaking | save, delete, export, confirm operation, confirm adjustment | PASS for create → count confirm → adjustment confirm |
| Delivery/shipping | invoice save/confirm/revoke/delete/export/QR; pick, pack, weigh, deliver, carrier, sign-in and exports | PASS for dispatch → pick → pack → weigh → deliver → freight → sign |
| Statistics | ASN, delivery, stock-age, safety-stock exports | PARTIAL |
| Visual warehouse | spatial/3D view | BLOCKED — requires a warehouse fixture and localization audit |

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

The write path returned `isSuccess: true` at every step. These are test records,
not production data; retain or remove them deliberately when testing locally.

## Known failures and risks

- The original SQLite snapshot had all 19 admin menu rows but empty action
  authority arrays. The repair script now restores the built-in admin action
  set from the frontend registry. A fresh login is required after restart.
- The dispatch workflow is now fixture-backed through customer creation,
  allocation, picking, packaging, weighing, delivery, freight, and signature.
  Cancellation, import/export, and QR/print paths remain untested.
- The frontend dependency tree reports 54 npm audit findings during the
  container build, including 2 critical findings. They are inherited legacy
  dependencies and are not silently suppressed.
- The frontend build reports legacy `eval` usage in `yk-vue-plugin-hiprint`
  and several large bundles.
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

## How to extend this matrix

For each `PARTIAL` row, add a fixture-backed test that creates or selects a
record, performs the write action, verifies the response and database state,
then cleans up only records created by the test. Never use production data as
an implicit test fixture.

