# Backend route, authority, and SQLite reconciliation

Updated: 2026-11-06

This is a backend-only inventory and test plan for the LuceneX fork of ModernWMS. The local backend is based on the upstream ModernWMS route/entity structure and runs against `backend/ModernWMS/wms.db` when `appsettings.json` selects `SqlLite`.

## Route/entity inventory

| Area | Route root | Entity/table coverage |
| --- | --- | --- |
| Authentication | `/login`, `/refresh-token` | `user`, `userrole` |
| Administration | `/user`, `/userrole`, `/company`, `/rolemenu`, `/actionlog` | user, role, company, role-menu, audit log |
| Catalog | `/category`, `/spu` | category, SPU, SKU, SKU safety stock, supplier |
| Warehouse master data | `/warehouse`, `/warehousearea`, `/goodslocation`, `/goodsowner` | warehouse, area, location, goods owner |
| Receiving | `/asn` | ASN master, ASN details, ASN sorting |
| Inventory | `/stock`, `/stockmove`, `/stockadjust`, `/stockfreeze`, `/stocktaking`, `/stockprocess` | stock and all inventory operation tables |
| Dispatch | `/dispatchlist` | dispatch order and pick-list tables |
| Commercial/support | `/customer`, `/supplier`, `/freightfee`, `/PrintSolution` | customer, supplier, freight, print solution |
| Approval infrastructure | service-level `flowset*` entities | approval workflow tables |

Controller route methods should be enumerated from `[Route]`, `[HttpGet]`, `[HttpPost]`, `[HttpPut]`, and `[HttpDelete]` attributes when adding a new endpoint. Every new scalar entity property must have a corresponding SQLite column and an additive repair entry.

## Permission/action authority findings

1. `BaseController` had `[Authorize]` commented out. The login token was generated, but inherited WMS controllers did not require it. It is now enabled, and the MVC pipeline also applies a global `AuthorizeFilter` so controllers that do not inherit the base class are protected as well. Account login, refresh, and user registration remain explicitly anonymous.
2. The custom `ApiResponseHandler` ended in `NotImplementedException` after token parsing. It now returns a successful authentication ticket for a valid token and `NoResult` for an absent token. Normal JWT bearer validation remains the default authentication scheme.
3. Menu/action authority is represented by `menu.menu_actions` and `rolemenu.menu_actions_authority`. The bundled SQLite copy was missing `menu_actions`, so role-menu queries could fail with `operation_failed`; the repair script now adds it with `[]` as the safe default.
4. The SQLite snapshot also drifted from the EF model: `spu.bar_code` was required but absent from the model, and `sku.bar_code` was required by the model but absent from SQLite. Both are now represented in the models and repaired additively by `ensure-sqlite-schema.sh`.
5. Action authority is currently delivered as data to the client; there are no backend attributes enforcing individual menu-action names. This is an identified follow-up boundary, not silently treated as server-side authorization.

## `operation_failed` diagnostic map

- SQL/schema failure: inspect the latest NLog file, run `./ModernWMS/Database/ensure-sqlite-schema.sh`, then retry the endpoint.
- Authentication failure: expect HTTP 401 after the base authorization fix; verify the bearer token and `/login` result.
- Authorization failure: expect HTTP 403 when an authenticated policy denies access. Individual menu actions are not yet server-enforced.
- Service-level failure: inspect the endpoint service return path; several inventory and dispatch operations intentionally translate failed writes into `operation_failed`.

## Smoke-test plan

1. Run the idempotent schema repair and verify every expected table exists.
2. Build the backend with node reuse disabled on macOS:

   ```bash
   cd backend
   dotnet build ModernWMS/ModernWMS.csproj --no-restore \
     -p:UseSharedCompilation=false -p:BuildInParallel=false /nodeReuse:false
   ```

3. Start the API from `backend/ModernWMS` and verify port `5555`.
4. Anonymous checks: `/swagger/v1/swagger.json`, invalid `/login`, and `/hello-world`.
5. Auth checks: valid `/login`, then one read endpoint from each group: `/warehouse/all`, `/rolemenu/menus`, `/stockmove/all`, `/stockadjust/list`, `/stocktaking/list`, `/asn/asnmaster/list`, `/dispatchlist/list`.
6. Negative auth checks: call a protected route without a bearer token and expect HTTP 401; call it with a malformed/expired token and expect HTTP 401.
7. After each smoke run, search logs for `SQLite Error`, `no such column`, `no such table`, `operation_failed`, and unhandled exceptions.

## Current environment result

- SQLite repair: pass.
- Backend compilation: pass when dependencies are available locally.
- Colima/Docker endpoint tests: backend is running and the following checks pass on 2026-11-06: anonymous `/warehouse/all` returns HTTP 401; valid admin login returns a bearer token; authenticated `/warehouse/all`, `/rolemenu/menus`, and `/stockmove/all` return HTTP 200. POST list workflows still require payload-specific fixture tests.
- Fixture-backed receiving test: warehouse, area, location, category, supplier, cargo owner, SPU/SKU, ASN creation, arrival, unload, sort, and putaway all returned `isSuccess: true` on 2026-11-06.
