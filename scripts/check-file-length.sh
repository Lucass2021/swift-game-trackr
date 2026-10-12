#!/bin/sh

MAX_LINES=200
BLOCK_COMMIT=false

too_long=false
for file in "$@"; do
    [ -f "$file" ] || continue
    lines=$(wc -l < "$file" | tr -d ' ')
    if [ "$lines" -gt "$MAX_LINES" ]; then
        echo "warning: $file has $lines lines (max $MAX_LINES)"
        too_long=true
    fi
done

if [ "$too_long" = true ] && [ "$BLOCK_COMMIT" = true ]; then
    exit 1
fi
