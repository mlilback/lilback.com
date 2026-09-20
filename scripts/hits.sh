#!/bin/bash
# Query the blog_hits Analytics Engine dataset.
#
#   ./scripts/hits.sh "$(sed -n '/-- Top pages/,/LIMIT 20/p' scripts/queries.sql)"
#
# The token comes from CLOUDFLARE_ANALYTICS_TOKEN. If it isn't already in the
# environment, .env at the repo root is sourced -- that file is gitignored and
# holds a single CLOUDFLARE_ANALYTICS_TOKEN=... line. It may be a FIFO, so it
# is read exactly once here and never echoed.
set -euo pipefail

ACCOUNT=afcb8daf0e8a3a88aa55f9fa67de8c75
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${CLOUDFLARE_ANALYTICS_TOKEN:-}" && -e "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/.env"
  set +a
fi

: "${CLOUDFLARE_ANALYTICS_TOKEN:?no token -- set it, or put it in .env}"
SQL="${1:?need a SQL string}"

curl -sS -X POST \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT/analytics_engine/sql" \
  -H "Authorization: Bearer $CLOUDFLARE_ANALYTICS_TOKEN" \
  --data "$SQL"
