#!/usr/bin/env sh
set -eu

TARGET_DIR="${HOME}/.gemini/config/agents/minimal-coder"
TARGET="$TARGET_DIR/agent.md"

if [ -f "$TARGET" ]; then
  rm -f "$TARGET"
  rmdir "$TARGET_DIR" 2>/dev/null || true
  printf 'Removed %s\n' "$TARGET"
else
  printf 'Not installed: %s\n' "$TARGET"
fi
