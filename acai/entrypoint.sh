#!/bin/bash
# Docker entrypoint script for Phoenix Gateway application.

echo "[Acai] Inside entrypoint.sh script"

# Start phoenix server
exec mix phx.server
