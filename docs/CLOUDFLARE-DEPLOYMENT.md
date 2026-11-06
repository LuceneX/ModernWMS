# Cloudflare deployment plan

## Recommended topology

```text
Browser
  └─ Cloudflare Worker + Workers Static Assets
       ├─ /           → frontend/cloudflare-dist (Vue SPA)
       ├─ /unity/*    → R2 bucket (large Unity warehouse viewer files)
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

The command creates `frontend/cloudflare-dist` for Workers Static Assets and
keeps the large Unity bundle out of the Workers 25 MiB per-file limit. Unity
files are uploaded to the `modernwms-unity` R2 bucket and served through the
Worker. The Worker must route `/api/*` to the backend and strip the
`/api` prefix before forwarding, because the ASP.NET controllers are rooted at
`/login`, `/user`, `/stockprocess`, and similar paths.

The repository contains `wrangler.jsonc` and `workers/index.ts`. A deployment
requires Docker Buildx and a running Colima Docker engine because Wrangler
builds the backend image locally before publishing it. The command is:

```sh
CLOUDFLARE_ACCOUNT_ID=<LuceneX account id> \
  wrangler deploy --config wrangler.jsonc
```

## Deployment prerequisites

Before a real deployment, authenticate the Cloudflare CLI to the LuceneX
account and configure the target Worker/account ID. Authenticate GitHub as a
LuceneX repository maintainer before pushing the deployment changes. Neither
credential is stored in this repository.

## Current status

- Frontend API base-path support: implemented and buildable.
- Cloudflare SPA build: validated locally through the frontend build command.
- Unity viewer assets: uploaded to the remote `modernwms-unity` R2 bucket.
- Worker/static asset deployment: prepared; the Worker upload succeeds.
- Backend container image: requires Docker Buildx and enough local/Colima disk
  space to complete the image publish.
- Durable production database migration: required before treating the cloud
  deployment as production-ready.

## Known deployment limitation

The current backend image still uses SQLite. The Worker/container wiring is
appropriate for disposable QA, but it is not a production data design until
the EF provider is migrated to managed PostgreSQL/MySQL and the connection is
configured as a secret or approved Hyperdrive binding. Do not use the cloud
instance for real warehouse records until that migration is complete.
