#!/bin/sh
set -e

MEDUSA=/app/node_modules/.bin/medusa

# Les migrations tournent à chaque démarrage ; RUN_MIGRATIONS=false permet de les sauter.
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
  echo "Running database migrations..."
  # --skip-scripts : le loader socket (src/modules/socket/loaders/socket.ts) attend l'instance
  # io créée par instrumentation.ts, qui n'existe qu'au `medusa start` ; db:migrate:scripts
  # resterait donc bloqué indéfiniment. Sans REDIS_URL pour que la commande rende la main.
  env -u REDIS_URL "$MEDUSA" db:migrate --execute-safe-links --skip-scripts
fi

exec "$MEDUSA" start
