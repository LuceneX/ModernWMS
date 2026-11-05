# ModernWMS backend — local SQLite runbook

The local backend uses the bundled SQLite database at `ModernWMS/wms.db`. It does not require MySQL for local testing.

## Start

From this directory:

```bash
cd ModernWMS
./Database/ensure-sqlite-schema.sh
dotnet build ModernWMS/ModernWMS.csproj --no-restore \
  -p:UseSharedCompilation=false \
  -p:BuildInParallel=false \
  /nodeReuse:false
./bin/Debug/net7.0/ModernWMS
```

The API listens on `http://127.0.0.1:5555`. Verify the listener before starting the frontend:

```bash
lsof -nP -iTCP:5555 -sTCP:LISTEN
```

## Schema reconciliation

`ModernWMS/Database/ensure-sqlite-schema.sh` is idempotent and additive. It repairs legacy database copies by creating every backend entity table and adding columns introduced after the original database snapshot. It does not delete or rewrite warehouse data. Run it after pulling backend changes and before every first launch against an unfamiliar database.

The repair covers the operational tables, approval workflow tables (`flowset*`), serial allocation, print solutions, and traceability fields used by receiving, dispatch, stock, stock-process, and cycle-count queries.

If the database is replaced, run the script with an explicit path:

```bash
./Database/ensure-sqlite-schema.sh /path/to/wms.db
```

## Troubleshooting

- A resident process without a TCP listener on port 5555 is not a healthy backend; stop it and start the compiled binary again.
- If a request reports `operation_failed`, inspect the latest NLog file under `ModernWMS/bin/Debug/net7.0/` and rerun the schema script.
- Do not restore an older `wms.db` over the committed database without running the reconciliation script.
