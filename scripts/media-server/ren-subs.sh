#! /bin/bash

# This script renames subtitles in sub_dir to their corresponding
# movie name in mv_dir based on extracted episode index

if [ $# -ne 2 ]; then
    echo "Usage: $(basename $0) sub_dir mv_dir"
    exit 1
fi

test -d "$1" || { echo "'$1' is not a directory"; exit 1; }
test -d "$2" || { echo "'$2' is not a directory"; exit 1; }

declare -a MV_NAMES

# Note: use process substitution instead of pipe because pipe executes
# in a subshell
while IFS= read -r -d '' FILEPATH; do
    E_INDEX=$(echo "$FILEPATH" | sed -nE 's/.*[Ee]([0-9]+).*/\1/p' | \
              sed -n 's/^0*//p')
    test -z "$E_INDEX" && continue

    # get basename then strip file extension
    FILENAME=$(basename "$FILEPATH")
    MV_NAMES[$E_INDEX]="${FILENAME%.*}"
done < <(find "$2" -type f -depth 1 -print0)


while IFS= read -r -d '' FILEPATH; do
    E_INDEX=$(echo "$FILEPATH" | sed -nE 's/.*[Ee]([0-9]+).*/\1/p' | \
              sed -n 's/^0*//p')
    test -z "$E_INDEX" && continue
    test -z "${MV_NAMES[$E_INDEX]}" && \
            { echo "No episode index '$E_INDEX' in '$2'"; continue; }

    EXT="${FILEPATH##*.}"
    mv "$FILEPATH" "$(dirname "$FILEPATH")/${MV_NAMES[$E_INDEX]}.$EXT"
done < <(find "$1" -type f -depth 1 -print0)

