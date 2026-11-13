#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LANG_ARG="${1:-}"

if [ -z "$LANG_ARG" ]; then
  if [ -t 0 ]; then
    printf 'Select minimal-coder prompt language:\n'
    printf '  [1] English (en) [default]\n'
    printf '  [2] Simplified Chinese (zh-CN)\n'
    printf '  [3] Traditional Chinese (zh-TW)\n'
    printf 'Enter choice (1/2/3): '
    IFS= read -r LANG_ARG || LANG_ARG="en"
  else
    LANG_ARG="en"
  fi
fi

if [ -z "$LANG_ARG" ]; then
  LANG_ARG="en"
fi

LOWER_ARG="$(printf '%s' "$LANG_ARG" | tr '[:upper:]_' '[:lower:]-')"
case "$LOWER_ARG" in
  1|en) LANG_DIR="en" ;;
  2|zh-cn) LANG_DIR="zh-CN" ;;
  3|zh-tw) LANG_DIR="zh-TW" ;;
  *)
    printf '[ERROR] Unsupported language option: %s. Use en, zh-CN, or zh-TW.\n' "$LANG_ARG" >&2
    exit 1
    ;;
esac

SRC="$SCRIPT_DIR/agents/$LANG_DIR/minimal-coder/agent.md"
TARGET_DIR="${HOME}/.gemini/config/agents/minimal-coder"
TARGET="$TARGET_DIR/agent.md"

if [ ! -f "$SRC" ]; then
  printf '[ERROR] Source file not found: %s\n' "$SRC" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SRC" "$TARGET"
printf 'Installed minimal-coder (%s) to %s\n' "$LANG_DIR" "$TARGET"
