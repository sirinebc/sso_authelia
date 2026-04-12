#!/bin/sh
set -eu

if [ "$(id -u)" -eq 0 ] && [ -f /usr/local/share/ca-certificates/rootCA.crt ]; then
  update-ca-certificates
fi

if [ "$#" -eq 0 ]; then
  set -- apache2-foreground
fi

exec /entrypoint.sh "$@"