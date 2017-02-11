#! /bin/bash

# This script is same as 'tr' command but accepts a list of
# file names/paths seperated by '\0'
# An example of usage is replacing spaces in filenames with other char.
# Note: only regular file will be processed

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
