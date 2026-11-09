# Blitz demo deployment

Deploy the repository root and both services in `docker-compose.yml`:

- Frontend: `docker/frontend.Dockerfile`, HTTP port 5173, public path `/`.
- Backend: `docker/backend.Dockerfile`, HTTP port 5555, public path `/api`.
  Strip `/api` before forwarding to ASP.NET controllers. Alternatively send
  all traffic to the frontend, whose Vite proxy strips the API prefix.
- Keep the backend's `/data` directory on persistent storage. The image declares
  it as a volume; confirm it appears in the backend part's Files settings.
- No managed PostgreSQL, MariaDB, or Redis database is required.

The frontend uses `VITE_API_BASE_URL=/api`. `BACKEND_SERVICE` must point to the
backend part's internal HTTP address (default `http://backend:5555`). These
defaults are included in the frontend image and Compose configuration.

## Database initialization and recovery

The backend image contains a text SQL seed with the baseline tables, menus,
and built-in demo account, outside `/data`. On first startup it initializes
`/data/wms.db`, runs the existing additive schema reconciliation, and configures
ASP.NET to use that same path. It never copies the repository's SQLite WAL/SHM
files. `WMS_DB_PATH` can select another absolute path on persistent storage.

An empty database containing only empty tables from an earlier failed startup
can be initialized on the next boot. A populated database missing the base
schema, or a corrupt database, stops with an error rather than being replaced.
Back up such databases before attempting a separate repair.

For existing local Compose installations, the earlier host-file mount is not
automatically imported into the new named volume. Back up a working database
with SQLite's backup command, then restore it to the volume before startup if
you need to retain its data. Do not copy an active database without its WAL.

## Rollout

In Blitz, select the repository branch containing this fix and choose
"Get the newest code" (or wait for its connected GitHub automatic deployment).
Verify the backend part uses its image entrypoint with no old start-command
override. Startup should log "Initialized SQLite baseline" for a new database,
followed by "SQLite schema reconciled". Subsequent restarts only reconcile.

Verify `/api/warehouse/all` returns HTTP 401 while signed out, rather than an
HTML document or 502. Then test sign-in, warehouse lists, and persistence across
a restart. The seed uses the existing demo account (`admin` / `1`); use test
data only and configure appropriate access before sharing a public demo.

## Local verification

With Python 3, Bash, and the sqlite3 CLI installed:

```sh
python3 scripts/test-sqlite-bootstrap.py
docker compose up --build
```

The bootstrap check covers a fresh database, retries after an empty partial
initialization, restart preservation, and refusal to overwrite incompatible
populated or corrupt databases.
