#!/usr/bin/env bash
# Only one screenshot at a time: ignore extra presses
pgrep -x slurp >/dev/null && exit 0
pgrep -x satty >/dev/null && exit 0
exec 9>/tmp/satty.lock; flock -n 9 || exit 0

## Create directory if it doesn't exist
mkdir -p "$HOME/Pictures/Screenshots"

## Output filename with timestamp
OUTPUT_FILE="$HOME/Pictures/Screenshots/Screenshot-$(date '+%Y%m%d-%H%M%S').png"

## Determine whether to use native satty or flatpak
if command -v satty &>/dev/null; then
    SATTY_CMD=(satty)
else
    SATTY_CMD=(flatpak run org.satty.Satty)
fi

## Run grim/slurp pipeline
grim -g "$(slurp)" - | "${SATTY_CMD[@]}" --filename - --output-filename "$OUTPUT_FILE"
