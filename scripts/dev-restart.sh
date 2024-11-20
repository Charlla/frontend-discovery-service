#!/bin/bash
set -e

echo "Restarting local environment..."
./scripts/dev-stop.sh
./scripts/dev-start.sh 