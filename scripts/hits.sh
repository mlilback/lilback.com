#!/bin/bash
# Query the blog_hits Analytics Engine dataset.
#
#   ./scripts/hits.sh "$(sed -n '/-- Top pages/,/LIMIT 20/p' scripts/queries.sql)"
#
# The token comes from CLOUDFLARE_ANALYTICS_TOKEN. If it isn't already in the
# environment, .env at the repo root is read -- that file is gitignored and is
# a 1Password "local env file" FIFO. A FIFO serves one reader at a time and can
# hand back an immediate EOF if something else is reading it, so the read is
# retried a few times rather than trusted once. The value is never echoed.
set -euo pipefail

ACCOUNT=afcb8daf0e8a3a88aa55f9fa67de8c75
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${CLOUDFLARE_ANALYTICS_TOKEN:-}" && -e "$ROOT/.env" ]]; then
  env_body=""
  for _ in 1 2 3 4 5; do
    env_body="$(timeout 15 cat "$ROOT/.env" || true)"
    [[ -n "$env_body" ]] && break
    sleep 1
  done
  if [[ -z "$env_body" ]]; then
    echo "hits.sh: .env gave back nothing -- is 1Password unlocked?" >&2
    exit 1
  fi
  set -a
  eval "$env_body"
  set +a
fi

if [[ -z "${CLOUDFLARE_ANALYTICS_TOKEN:-}" ]]; then
  echo "hits.sh: no CLOUDFLARE_ANALYTICS_TOKEN. Keys .env did define:" >&2
  printf '%s\n' "${env_body:-}" | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/  \1/p' >&2
  exit 1
fi

SQL="${1:?need a SQL string}"

curl -sS -X POST \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT/analytics_engine/sql" \
  -H "Authorization: Bearer $CLOUDFLARE_ANALYTICS_TOKEN" \
  --data "$SQL"
