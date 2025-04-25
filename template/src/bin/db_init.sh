#!/usr/bin/env bash
set -eou pipefail

# Parse arguments
CHECK_ONLY=0
if [ "${1:-}" = "--check" ]; then
  CHECK_ONLY=1
fi

# Check if required environment variables are set
if [ -z "${PGDATA:-}" ]; then
  if [ $CHECK_ONLY -eq 1 ]; then
    echo "PostgreSQL PostgreSQL Status: PGDATA environment varible is not set"
    exit 0
  fi
  echo "Error: PGDATA environment variable is not set" >&2
  exit 1
fi

if [ -z "${DB_USER:-}" ]; then
  if [ $CHECK_ONLY -eq 1 ]; then
    echo "PostgreSQL Status: DB_USER environment varible is not set"
    exit 0
  fi
  echo "PostgreSQL Error: DB_USER environment variable is not set" >&2
  exit 1
fi

# Check if database directory exists and has been initialized
if [ ! -f "${PGDATA}/PG_VERSION" ]; then
  if [ $CHECK_ONLY -eq 1 ]; then
    echo "PostgreSQL Status: Database not created in ${PGDATA}"
    exit 0
  fi

  echo "Initializing PostgreSQL database in ${PGDATA}..."
  mkdir -p "${PGDATA}"
  initdb -D "${PGDATA}"

  # Start PostgreSQL temporarily to create the user
  pg_ctl -D "${PGDATA}" -l "${PGDATA}/initlog" start

  # Create user without superuser privileges
  echo "Creating user ${DB_USER}..."
  createuser -S "${DB_USER}"

  # Stop PostgreSQL after setup
  pg_ctl -D "${PGDATA}" stop

  echo "PostgreSQL initialization complete."
else
  # Database exists, check if it's running
  if pg_ctl -D "${PGDATA}" status >/dev/null 2>&1; then
    if [ $CHECK_ONLY -eq 1 ]; then
      echo "Status: Database created and running"
      exit 0
    fi
    echo "PostgreSQL is already running."
  else
    if [ $CHECK_ONLY -eq 1 ]; then
      echo "PostgreSQL Status: Database created but not running"
      exit 0
    fi

    echo "PostgreSQL database already initialized but not running."
    if [ $CHECK_ONLY -eq 0 ]; then
      echo "Note: Use db_ctl start to start the database."
    fi
  fi
fi
