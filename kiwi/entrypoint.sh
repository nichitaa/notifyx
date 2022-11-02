#!/bin/bash
# Docker entrypoint script for Phoenix Gateway application.

echo "[Kiwi] Inside entrypoint.sh script"

set -e

# Install the app's dependencies
mix deps.get

# Wait for Postgres to become available.
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done
echo "\nPostgres is available: continuing with database setup..."

# Will create the database if not already created and then
# perform migrations
mix ecto.setup

echo "\n [Kiwi] Launching Phoenix web server..."

# Start phoenix server
mix phx.server
