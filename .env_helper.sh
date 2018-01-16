#!/bin/sh

expandRegexPattern()
{
  find . |
  grep -i "$1" |
  cut -d/ -f2-
}

IGNORE=""
IGNORE="${IGNORE} /.git/"
IGNORE="${IGNORE} .gitignore"

IGNORE_PATTERNS=""
IGNORE_PATTERNS="${IGNORE_PATTERNS} .*dist\$"
IGNORE_PATTERNS="${IGNORE_PATTERNS} ^./.*sh\$"

EXPANDED_IGNORE=""
  
for PATTERN in ${IGNORE}; do
  EXPANDED_IGNORE="${EXPANDED_IGNORE} --exclude='${PATTERN}'"
done

for MATCH in $(expandRegexPattern ${IGNORE_PATTERNS}); do
  # EXPANDED_IGNORE="${EXPANDED_IGNORE} --exclude='$(expandRegexPattern ${MATCH})'"
  EXPANDED_IGNORE="${EXPANDED_IGNORE} --exclude='${MATCH}'"
done

# echo $EXPANDED_IGNORE