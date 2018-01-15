#!/bin/sh

. ./.env.dist.sh

if [ ! -x "$(command -v rsync)" ]; then
  echo 'rsync required but not found' >&2
  exit 1
fi

