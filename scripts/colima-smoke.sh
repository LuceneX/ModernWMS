#!/usr/bin/env bash
set -euo pipefail

# Lightweight checks for the local Colima deployment. This intentionally uses
# read/list operations only; it never creates or deletes warehouse records.
BASE_URL="${BASE_URL:-http://127.0.0.1:5555}"
USERNAME="${USERNAME:-admin}"
PASSWORD="${PASSWORD:-1}"

login_json="$(curl -fsS -X POST "$BASE_URL/login" \
  -H 'Content-Type: application/json' \
  --data "{\"user_name\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")"
access_token="$(printf '%s' "$login_json" | sed -nE 's/.*"access_token"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p')"

if [[ -z "$access_token" ]]; then
  echo "FAIL login: no access_token returned" >&2
  exit 1
fi

assert_status() {
  local label="$1"
  local expected="$2"
  shift 2
  local actual
  actual="$(curl -sS -o /dev/null -w '%{http_code}' "$@")"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL $label: expected HTTP $expected, got $actual" >&2
    exit 1
  fi
  echo "PASS $label: HTTP $actual"
}

assert_status "frontend" 200 http://127.0.0.1:5173/
assert_status "anonymous protection" 401 "$BASE_URL/warehouse/all"

for route_path in /warehouse/all /rolemenu/menus /stockmove/all; do
  assert_status "authenticated $route_path" 200 \
    -H "Authorization: Bearer $access_token" "$BASE_URL$route_path"
done

for route_path in /stockadjust/list /stocktaking/list /asn/asnmaster/list \
  /stock/stock-list /dispatchlist/advanced-list; do
  response_file="$(mktemp)"
  trap 'rm -f "$response_file"' EXIT
  http_code="$(curl -sS -X POST -o "$response_file" -w '%{http_code}' \
    -H "Authorization: Bearer $access_token" \
    -H 'Content-Type: application/json' \
    --data '{"page":1,"limit":20}' "$BASE_URL$route_path")"
  if [[ "$http_code" != 200 ]] || ! grep -q '"isSuccess"[[:space:]]*:[[:space:]]*true' "$response_file"; then
    echo "FAIL $route_path: HTTP $http_code or isSuccess=false" >&2
    exit 1
  fi
  echo "PASS $route_path: HTTP 200 and isSuccess=true"
done

echo "Smoke checks passed. Write workflows remain fixture-dependent; see docs/FEATURE-TEST-MATRIX.md."
