#!/usr/bin/env bash

set -euo pipefail

# Validate command is either start or stop
if [ "${1:-}" != "start" ] && [ "${1:-}" != "stop" ]; then
  echo "Error: Only 'start' and 'stop' commands are supported" >&2
  exit 1
fi

# Check required environment variables
if [ -z "${PGDATA:-}" ]; then
  echo "Error: PGDATA environment variable is not set" >&2
  exit 1
fi

if [ -z "${PGLOG:-}" ]; then
  echo "Error: PGLOG environment variable is not set" >&2
  exit 1
fi

if [ -z "${PGPORT:-}" ]; then
  echo "Error: PGPORT environment variable is not set" >&2
  exit 1
fi

# Run pg_ctl with required env vars
exec pg_ctl "$1" -l "$PGLOG"
