#!/usr/bin/env bash
# Хук Stop: я закончил ответ — снимаем метку застревания и шлём зелёный.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

rm -f "$ROOT_DIR/state/stuck.flag" "$ROOT_DIR/state/stuck.notified" 2>/dev/null
"$SCRIPT_DIR/notify.sh" green
exit 0
