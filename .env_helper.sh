#!/bin/sh

expandRegexPattern()
{
  find . |
  grep -i "$1" |
  cut -d/ -f2- |
  tr '\n' ' '
}

IGNORE="/.git/ .gitignore /images/resume/app/source_resources/"

IGNORE_PATTERNS=".*\\.dist\$ ^\\./.*\\.sh\$"

EXPANDED_IGNORE=""
  
for PATTERN in ${IGNORE}; do
  EXPANDED_IGNORE="${EXPANDED_IGNORE} --exclude='${PATTERN}'"
done

for PATTERN in ${IGNORE_PATTERNS}; do
  for MATCH in $(expandRegexPattern $PATTERN) ; do
    EXPANDED_IGNORE="${EXPANDED_IGNORE} --exclude='${MATCH}'"
  done
done

# echo $EXPANDED_IGNORE