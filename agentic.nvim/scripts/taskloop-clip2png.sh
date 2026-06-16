#!/usr/bin/env bash
# Save the current clipboard image to $1 as PNG. Exit 0 on success, 1 if the clipboard
# holds no image. Used by taskloop.nvim to attach screenshots to feedback. Cross-platform:
# macOS (pngpaste / osascript), Wayland (wl-paste), X11 (xclip) — tries whatever is present.
OUT="$1"; [ -n "$OUT" ] || { echo "usage: taskloop-clip2png.sh OUT.png" >&2; exit 2; }
mkdir -p "$(dirname "$OUT")"

# Fast path: pngpaste if available (macOS).
if command -v pngpaste >/dev/null 2>&1; then
  pngpaste "$OUT" >/dev/null 2>&1 && [ -s "$OUT" ] && exit 0
fi

# Linux/Wayland: wl-paste (wl-clipboard).
if command -v wl-paste >/dev/null 2>&1; then
  if wl-paste --list-types 2>/dev/null | grep -qi 'image/png'; then
    wl-paste --type image/png > "$OUT" 2>/dev/null && [ -s "$OUT" ] && exit 0
  fi
fi

# Linux/X11: xclip.
if command -v xclip >/dev/null 2>&1; then
  if xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -qi 'image/png'; then
    xclip -selection clipboard -t image/png -o > "$OUT" 2>/dev/null && [ -s "$OUT" ] && exit 0
  fi
fi

# Below here is macOS-only (osascript / sips). Bail cleanly if osascript is absent (Linux).
command -v osascript >/dev/null 2>&1 || { rm -f "$OUT" 2>/dev/null; exit 1; }

# osascript: try a PNG on the clipboard.
osascript >/dev/null 2>&1 <<EOF
try
  set theData to (the clipboard as «class PNGf»)
  set fh to open for access POSIX file "$OUT" with write permission
  set eof of fh to 0
  write theData to fh
  close access fh
end try
EOF
[ -s "$OUT" ] && exit 0

# Fallback: TIFF on the clipboard -> convert with sips.
TMP="${OUT%.png}.tiff"
osascript >/dev/null 2>&1 <<EOF
try
  set theData to (the clipboard as «class TIFF»)
  set fh to open for access POSIX file "$TMP" with write permission
  set eof of fh to 0
  write theData to fh
  close access fh
end try
EOF
if [ -s "$TMP" ]; then
  sips -s format png "$TMP" --out "$OUT" >/dev/null 2>&1
  rm -f "$TMP"
  [ -s "$OUT" ] && exit 0
fi
rm -f "$OUT" 2>/dev/null
exit 1
