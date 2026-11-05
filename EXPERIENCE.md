---
status: reconciled
updated: 2026-11-05
product: LuceneX Warehouse Operations
---

# LuceneX Warehouse Operations — experience contract

This document is the source of truth for how the refactored frontend behaves. Visual decisions are defined in [DESIGN.md](./DESIGN.md); reference its tokens as `{colors.accent}`, `{colors.paper}`, and so on.

## Foundation

- Surface: responsive web application for warehouse operators, supervisors, and administrators.
- Existing framework: Vue 3, Vue Router, Vuetify, Vuex, Vite.
- Preserve existing backend routes and domain workflows unless a refactor explicitly maps old behavior to a new interaction.
- Public routes: `/login`, `/licenses`.
- Authenticated routes: the home shell, operational modules, statistics, settings, and the visual warehouse.
- Development API target: `http://127.0.0.1:5555`; frontend development server: `http://127.0.0.1:5173`.

## Information Architecture

1. Login
2. Home / operational overview
3. Warehouse work
   - Receiving
   - Inventory moves
   - Inventory adjustment
   - Freezing and taking stock
4. Stock and delivery management
5. Statistics and analysis
6. Base settings
7. Visual warehouse
8. Account utilities
   - Change password
   - System log
   - Logout
9. Licenses

The navigation should expose the smallest useful label and preserve the existing authority-driven menu model. A missing permission must remove or disable the action; it must not create a dead-end route.

## Voice and Tone

- Direct, calm, operational, and respectful.
- Prefer “Choose a warehouse” over “Please select the warehouse you wish to use.”
- Prefer “No receiving tasks yet” plus a next step over “No data.”
- Use “Something went wrong while loading this view” when the technical cause is unknown.
- Do not expose raw keys such as `operation_failed` to users.
- Product-facing English uses “LuceneX Warehouse Operations”; Latvian uses clear warehouse terminology and preserves Latvian diacritics.

## Component Patterns

Visual rules belong to [DESIGN.md](./DESIGN.md); these are behavioral rules.

- Buttons must expose disabled, hover, pressed, focus, and loading states.
- Menus close on selection and Escape; focus returns to the trigger.
- Dialogs trap focus, have a clear title, and identify the destructive action.
- Tables support loading, empty, error, pagination, and selection states.
- Long-running operations show progress or a skeleton, not an indefinite spinner.
- Toasts are reserved for transient confirmation; persistent failures appear in the affected surface with a retry action.
- Login submits on Enter, preserves validation errors, and prevents duplicate submissions while awaiting the response.

## State Patterns

### Loading

Use layout-matching skeletons for pages and tables. During login, disable the submit button and label it “Signing in…” while preserving the form context.

### Empty

Explain what is empty, why it matters, and the next allowed action. Example: “No receiving tasks yet. Create an arrival notice to begin.”

### Error

Map common failures to actionable messages:

- Network unavailable: “The warehouse service is unreachable. Check that the backend is running, then retry.”
- Authentication failed: “The username or password is incorrect.”
- Permission failure: “Your account does not have access to this operation.”
- Schema/backend failure: “The warehouse service needs attention. Contact an administrator.” Never expose SQL exceptions in the UI.

Every error state includes Retry where retrying can help and a correlation/log reference where support needs to investigate.

### Permission

Do not render actions the current role cannot perform. If a route is reached through a stale bookmark, show a clear permission state and provide a safe route back to Home.

## Interaction Primitives

- Keyboard: all controls reachable in logical order; Escape closes transient UI; Enter submits focused forms.
- Pointer: primary actions respond with subtle tactile movement using `{colors.accent}` feedback.
- Motion: restrained 150–250ms transitions for navigation, menus, and route changes; no continuous decorative loops.
- Reduced motion: honor `prefers-reduced-motion` and remove nonessential movement.
- Refresh: preserve route and language where possible; do not silently discard unsaved form work.
- Language: available locales are English and Latvian only. Persist the selection and use `lv-lv` for backend culture when Latvian is active.

## Accessibility Floor

- WCAG AA contrast for body text, controls, focus indicators, and error text.
- Visible keyboard focus on every interactive control.
- Labels above inputs; never placeholder-only forms.
- Icon-only controls require accessible names and tooltips where appropriate.
- Use semantic headings in order and meaningful landmarks for navigation, main content, and footer/legal content.
- Do not communicate status through color alone; pair orange/red/green with text, icons, or shape.
- Authentication errors should be announced and associated with the relevant form region.

## Key Flows

### 1. Marta signs into the warehouse console

1. Marta opens `/login` and sees a branded LuceneX split screen.
2. She enters her username and password; labels remain visible.
3. She presses Enter or Login; the form enters a loading state and blocks duplicate submissions.
4. On success, the token and authority list load, then she lands on Home with the first useful operational view.
5. On failure, she receives a human-readable inline message and can retry without losing her username.

Climax: Marta reaches the operation queue without seeing implementation errors or a generic “operation_failed” key.

### 2. Andris diagnoses a backend outage

1. The frontend receives a timeout or 5xx response.
2. The affected screen shows that the warehouse service is unreachable and offers Retry.
3. The UI does not log the user out unless the token is actually invalid.
4. Support can inspect the backend log and correlation context.

Climax: Andris knows whether to retry the screen or restart the local backend; the app does not look frozen.

### 3. Ilze reviews legal acknowledgements

1. Ilze selects Licenses from the public login screen.
2. `/licenses` opens without authentication and lists LuceneX ownership plus third-party software acknowledgements.
3. She can return to sign in without losing the app context.

Climax: legal information is discoverable without mixing credits into the authentication experience.

## Runtime handoff notes

- The bundled SQLite database is `backend/ModernWMS/wms.db`.
- The local profile is intentionally SQLite (`backend/ModernWMS/appsettings.json` → `Database.db: SqlLite`) so a local run does not silently depend on an unavailable MySQL server.
- The code expects `rolemenu.menu_actions_authority`; the local database must contain that column with a default JSON value of `[]`.
- The compatibility database repair includes `action_log`, `asnmaster`, `asn.asnmaster_id`, stock traceability/price fields, and the expiry/series fields used by delivery and stock queries. Keep the committed database and backend entity model together; do not replace `wms.db` with an older dump.
- The backend must be started from the backend project so the relative SQLite path resolves correctly.
- On macOS 13 / .NET 7, build the backend project directly with node reuse disabled when the full solution build appears idle:
  `dotnet build ModernWMS/ModernWMS.csproj --no-restore -p:UseSharedCompilation=false -p:BuildInParallel=false /nodeReuse:false`
- Start the compiled backend from `backend/ModernWMS` with `./bin/Debug/net7.0/ModernWMS`; verify `lsof -nP -iTCP:5555 -sTCP:LISTEN` before starting the Vite frontend.
- Start the frontend from `frontend` with `npm run dev`; it serves on `127.0.0.1:5173` and proxies `/api` to `127.0.0.1:5555`.
- After changing schema or backend binaries, stop stale `ModernWMS` processes before relaunching. A resident process with no 5555 listener is not a healthy backend.
- Treat backend schema errors as service errors in the UI and record the remediation in the deployment runbook.

## Refactor acceptance criteria

- No visible ModernWMS name remains in the branded frontend.
- No stock image is used for the login or dashboard surfaces.
- No stock favicon is referenced; `/lucenex.svg` is the app icon.
- Orange is the only brand accent.
- English and Latvian are the only user-selectable locales.
- Login, licenses, home shell, navigation, tables, dialogs, empty states, loading states, and errors all follow the same token contract.
- The frontend can run against the local backend at `127.0.0.1:5555`.
