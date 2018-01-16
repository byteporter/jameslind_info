#!/bin/sh

if [ ! -f ./.env.sh ]; then
  echo 'environment file (./.env.sh) required but not found.' >&2
  exit 1
fi

. ./.env.sh

if [ ! -x "$(command -v rsync)" ]; then
  echo 'rsync required but not found' >&2
  exit 1
fi

RSYNC_CMD="rsync${EXPANDED_IGNORE} -avzhe ssh --progress ./ ${DESTINATION_USER}@${DESTINATION_HOST}:${DESTINATION_DIR}"
echo $RSYNC_CMD
eval $RSYNC_CMD