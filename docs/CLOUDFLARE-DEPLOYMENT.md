# Cloudflare deployment plan

## Recommended topology

```text
Browser
  └─ Cloudflare Worker + Workers Static Assets
       ├─ /           → frontend/dist (Vue SPA)
       └─ /api/*      → ModernWMS ASP.NET container
                         └─ durable external SQL database
```

The frontend now accepts `VITE_API_BASE_URL`. Local Colima builds continue to
use the existing `VITE_BASE_PATH` and `VITE_SERVER_PORT` values; the Cloudflare
build uses the same-origin `/api` path.

## Important persistence decision

The current backend uses SQLite at `backend/ModernWMS/wms.db`. A Cloudflare
Container's local filesystem is not a durable database boundary across
restarts or instance changes. Do not deploy the live WMS database as a
container-local SQLite file for production. Migrate the EF provider and schema
to a managed PostgreSQL/MySQL database reachable through an approved origin
(Hyperdrive is the Cloudflare connection option), or treat a SQLite container
deployment as disposable QA only.

## Build validation

From the repository root:

```sh
npm --prefix frontend run build:cloudflare
```

The resulting `frontend/dist` directory is the static asset input for a
Cloudflare Worker. The Worker must route `/api/*` to the backend and strip the
`/api` prefix before forwarding, because the ASP.NET controllers are rooted at
`/login`, `/user`, `/stockprocess`, and similar paths.

## Deployment prerequisites

Before a real deployment, authenticate the Cloudflare CLI to the LuceneX
account and configure the target Worker/account ID. Authenticate GitHub as a
LuceneX repository maintainer before pushing the deployment changes. Neither
credential is stored in this repository.

## Current status

- Frontend API base-path support: implemented and buildable.
- Cloudflare SPA build: validated locally through the frontend build command.
- Backend container image: already builds under Colima.
- Durable production database migration: required before treating the cloud
  deployment as production-ready.
