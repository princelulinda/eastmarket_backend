#!/bin/sh
set -e

MEDUSA=/app/node_modules/.bin/medusa

# Les migrations tournent à chaque démarrage ; RUN_MIGRATIONS=false permet de les sauter.
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
  echo "Running database migrations..."
  # Sans REDIS_URL : avec les modules Redis (workers BullMQ), db:migrate ne rend jamais la main.
  env -u REDIS_URL "$MEDUSA" db:migrate --execute-safe-links
fi

exec "$MEDUSA" start
