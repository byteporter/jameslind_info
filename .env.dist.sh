#!/bin/sh

expandPattern()
{
  find . |
  grep -i "$1" |
  cut -d / -f 2- |
  # awk -F/ '{print; while(/\//) {sub("/[^/]*$", ""); print}}' |
  cat -
}

IGNORE_PATTERNS=""
IGNORE_PATTERNS="${IGNORE_PATTERNS} .git/"
IGNORE_PATTERNS="${IGNORE_PATTERNS} .gitignore"
IGNORE_PATTERNS="${IGNORE_PATTERNS} .*dist$"
  
for PATTERN in ${IGNORE_PATTERNS}; do
  if [ $(echo "$PATTERN" | grep -i '.*/$') ]; then
    continue
  fi

  expandPattern $PATTERN;
done