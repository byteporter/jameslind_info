#!/bin/sh

while [ "$1" != "" ]; do
  case $1 in
    -y )  shift
          CONFIRM=y
          ;;
  esac

  if [ "$#" -gt 0 ]; then shift; fi
done

if [ ! -f ./.env.sh ]; then
  echo 'environment file (./.env.sh) required but not found.' >&2
  exit 1
fi

. ./.env.sh

if [ ! -x "$(command -v rsync)" ]; then
  echo 'rsync required but not found' >&2
  exit 1
fi

RSYNC_CMD="rsync${EXPANDED_IGNORE} -avzhe ssh --progress --delete ./ ${DESTINATION_USER}@${DESTINATION_HOST}:${DESTINATION_DIR}"
echo $RSYNC_CMD
eval "${RSYNC_CMD} -n"

if [ "${CONFIRM}" = "y" ]; then
  eval "${RSYNC_CMD}"
else
  echo "Run again with -y command line switch to confirm."
fi