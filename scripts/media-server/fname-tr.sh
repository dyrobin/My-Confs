#! /bin/bash

# This script accepts a list of file names/paths seperated by '\0'

# Check 'tr' arguments
echo | tr "$@" >/dev/null 2>&1 || { echo "Invalid arguments. Check command 'tr' usage."; exit 1; }

while IFS= read -r -d '' FILEPATH; do
    test ! -f "$FILEPATH" && continue
    FILENAME=$(basename "$FILEPATH")
    
    # strip file extension then translate
    NNAME=$(echo "${FILENAME%.*}" | tr "$@")
    EXT="${FILEPATH##*.}"
    mv "$FILEPATH" "$(dirname "$FILEPATH")/$NNAME.$EXT"
done
