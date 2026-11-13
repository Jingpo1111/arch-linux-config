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

## Select a region (Esc cancels)
REGION=$(slurp) || exit 0
[ -n "$REGION" ] || exit 0

## Capture to a temp file, removed when the script ends
TMP_FILE=$(mktemp --suffix=.png)
trap 'rm -f "$TMP_FILE"' EXIT
grim -g "$REGION" "$TMP_FILE" || exit 1

## Copy straight away. wl-copy stays running in the background to serve the
## clipboard, so it must not inherit the lock on fd 9 or the next screenshot
## would be blocked. The same applies to satty, which starts its own wl-copy.
wl-copy --type image/png < "$TMP_FILE" 9>&-

## Open the editor; Enter copies the edited image
"${SATTY_CMD[@]}" --filename "$TMP_FILE" --output-filename "$OUTPUT_FILE" \
    --copy-command wl-copy --actions-on-enter save-to-clipboard 9>&-
