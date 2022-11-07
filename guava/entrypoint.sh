#!/bin/bash
# Docker entrypoint script for Phoenix Gateway application.

echo "[Guava] Inside entrypoint.sh script"

# Environment variables (from docker-compose.yml)
echo "[Guava] ERLANG_COOKIE: " $ERLANG_COOKIE
echo "[Guava] RELEASE_NODE: " $RELEASE_NODE

# Start phoenix server with Node name (--name) from env variable
# And all cluster nodes must have same Erlang Cookie (from env variable too)
elixir --no-halt --name $RELEASE_NODE --cookie $ERLANG_COOKIE -S mix phx.server
