# ModernWMS — LuceneX fork

ModernWMS is a warehouse management application with a Vue web interface, an ASP.NET Core API, and a local SQLite database. This repository is the LuceneX fork of [fjykTec/ModernWMS](https://github.com/fjykTec/ModernWMS).

The instructions below run the current source directly on your computer. Docker is optional; no external database or Nginx server is needed for local development.

## What is available

| Area | Implemented functionality |
| --- | --- |
| Administration | Companies, users, password resets, roles, menu permissions, and server-side action authorization |
| Master data | Commodity categories, SPUs/SKUs, safety-stock settings, suppliers, cargo owners, customers, freight rates, warehouses, areas, and locations |
| Receiving | ASN notices, arrival, unloading, sorting, putaway, confirmation, and cancellation |
| Inventory | Stock and location views, moves, freeze/unfreeze, adjustments, split/group processing, and stocktaking |
| Shipping | Dispatch orders, picking, packing, weighing, delivery, carrier assignment, customer signature, and cancellation |
| Reporting | Receiving, shipment, stock-age, and safety-stock reports; browser XLSX exports |
| Labels and printing | QR/barcode previews and print-solution management |
| Visual warehouse | Embedded Unity WebGL warehouse scene and warehouse KPI panel |
| Languages | Latvian and English interface resources |
| Approval configuration | Backend configuration endpoints and frontend API module for flow definitions, nodes, approvers, and conditions |

Availability does not mean every action has been independently verified. [The feature test matrix](docs/FEATURE-TEST-MATRIX.md) records the fixture-backed checks and remaining gaps. In particular:

- Transaction-specific approval execution and decision screens are not implemented.
- Physical printer output has not been verified; browser previews and print invocation have been exercised.
- Some labels inside the Unity asset remain outside the Vue translation catalog.
- Custom-role workflow permissions still need broader verification.
- The local API host does not start the Hangfire background-job server.

## Run directly on your computer

### 1. Install prerequisites

- Git.
- **.NET 7 SDK**, including the ASP.NET Core 7 runtime. The backend targets `net7.0`; a newer SDK alone does not supply that runtime.
- Node.js and npm. The checked-in frontend Dockerfile uses **Node 18** as its compatibility baseline.
- Bash and the **sqlite3 command-line tool** for database initialization and reconciliation.
- Internet access for the initial NuGet and npm dependency downloads.

The commands below use Bash on Linux, macOS, or Windows through WSL. Install these tools inside WSL if using that route. .NET 7 and Node 18 are legacy, end-of-life versions; these instructions describe the repository's current stack.

Check the installed tools:

```bash
git --version
dotnet --list-sdks
dotnet --list-runtimes
node --version
npm --version
sqlite3 --version
```

### 2. Get the source

```bash
git clone https://github.com/LuceneX/ModernWMS.git
cd ModernWMS
```

### 3. Prepare SQLite and start the backend

In your first terminal, from the repository root:

```bash
cd backend/ModernWMS

# Initialize only if the local database file does not exist.
if [ ! -f wms.db ]; then
  sqlite3 -bail wms.db < Database/seed-sqlite.sql
fi

# Reconcile the database before launching, including after pulling changes.
bash Database/ensure-sqlite-schema.sh wms.db

dotnet restore ModernWMS.csproj
dotnet build ModernWMS.csproj --no-restore
dotnet bin/Debug/net7.0/ModernWMS.dll
```

Keep this terminal running. Start the DLL from `backend/ModernWMS` as shown: configuration, NLog configuration, and the default relative database path are resolved from the working directory.

The API listens on **http://localhost:5555**. Its Swagger interface is at **http://localhost:5555/**. `Program.cs` sets port 5555 explicitly; the 5056 value in the launch profile is not the API port used by this setup.

The default configuration is `Database:db = SqlLite` and `SqlLiteConn = Data Source = wms.db` in [appsettings.json](backend/ModernWMS/appsettings.json). MySQL, SQL Server, and PostgreSQL provider branches also exist in the code, but they are not needed for this SQLite runbook.

The reconciliation script adds compatibility tables/columns, restores missing menus, and repairs built-in administrator action permissions. It expects the base schema: it does not initialize a blank database by itself. If an existing database fails reconciliation, back it up and investigate rather than importing the seed over it.

### 4. Start the frontend

Open a second terminal at the repository root:

```bash
cd frontend
npm install --legacy-peer-deps
npm run dev -- --host 127.0.0.1 --port 5173 --strictPort
```

Use `npm install --legacy-peer-deps`, matching the current Dockerfile. The committed npm lockfile predates the package manifest, so `npm ci` is not the documented first-install path. Installation may update `package-lock.json`.

Open **http://127.0.0.1:5173/** and sign in with the seeded demo account:

- Username: `admin`
- Password: `1`

The development environment uses `VITE_BASE_API=/api`. Vite forwards `/api/*` to `http://127.0.0.1:5555` and removes the `/api` prefix. You do not need to edit an IP address into the frontend or configure CORS for this local route. To use another backend address, set `BACKEND_SERVICE` before starting Vite.

### 5. Verify and stop

With both services running:

```bash
# Expected: HTTP 401 when signed out, confirming the protected API is reachable.
curl -i http://127.0.0.1:5555/warehouse/all

# Expected: the same HTTP 401 through the frontend proxy.
curl -i http://127.0.0.1:5173/api/warehouse/all
```

After signing in, open warehouse and stock lists to check authenticated access. Stop each service with **Ctrl+C** in its terminal.

Your local data remains in `backend/ModernWMS/wms.db`. The bundled database may contain demonstration or QA records. Use SQLite's backup facility before experimenting with existing data:

```bash
# Run from backend/ModernWMS; choose a new backup filename.
sqlite3 wms.db ".backup 'wms-backup.db'"
```

Use test data and change the demo credentials before sharing an instance. The API binds to all interfaces on port 5555 by default, so local network access also depends on your computer's firewall.

## Optional: run with Docker Compose

From the repository root, with Docker and Compose installed:

```bash
docker compose up --build -d
docker compose logs -f backend frontend
```

Open **http://localhost:5173/** with the same demo credentials. The API remains on port 5555. The backend initializes and reconciles SQLite automatically in the `modernwms-data` named volume at `/data/wms.db`; this is separate from the source checkout's database.

```bash
docker compose down
```

Stopping with `down` retains the named volume. `docker compose down -v` deletes it and its database.

## Build and troubleshooting

- **Frontend build:** run `npm run build` from `frontend`; it performs Vue/TypeScript checking and creates `frontend/dist`. The Vite dev server above supplies the local API proxy; serving built files requires a separately configured API route.
- **Connection refused or proxy error:** check the backend terminal and confirm port 5555 has a listener. A running process without a listener is not a healthy API.
- **Missing tables/columns or `operation_failed`:** stop the API, back up SQLite, rerun the reconciliation script from `backend/ModernWMS`, and inspect NLog output under the build directory.
- **Missing admin controls after repair:** restart the backend and sign out/in to refresh permissions.
- **Frontend install/build warnings:** the feature matrix records inherited dependency audit findings, print-library `eval` warnings, and large bundles. These are existing limitations.
- **Database bootstrap regression check:** with Python 3, Bash, and sqlite3 installed, run `python3 scripts/test-sqlite-bootstrap.py` from the repository root. It checks initialization and preservation/refusal behavior using temporary databases; it does not start the API.

## Repository guide

| Path | Contents |
| --- | --- |
| [frontend/](frontend/) | Vue 3.2.45, TypeScript 4.9.3, Vuetify 3.3.12, and Vite 4.0.0 application |
| [backend/](backend/) | .NET 7 API, core services, WMS logic, and SQLite assets |
| [docs/FEATURE-TEST-MATRIX.md](docs/FEATURE-TEST-MATRIX.md) | Recorded acceptance checks and known limitations |
| [docs/BLITZ-DEPLOYMENT.md](docs/BLITZ-DEPLOYMENT.md) | Container deployment and database recovery details |
| [docs/CLOUDFLARE-DEPLOYMENT.md](docs/CLOUDFLARE-DEPLOYMENT.md) | Cloudflare deployment plan and persistence limitations |
| [DESIGN.md](DESIGN.md), [EXPERIENCE.md](EXPERIENCE.md) | Design and experience notes |

Cloud deployment files are included, but the deployment notes identify additional prerequisites and persistence work. They are not required to run locally.

## License

[Apache License 2.0](LICENSE). See the upstream project for the original ModernWMS history.
