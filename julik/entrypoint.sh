#!/bin/bash
# Docker entrypoint script for Phoenix Gateway application.

echo "[Julik] Inside entrypoint.sh script"

# Start phoenix server
exec mix phx.server
