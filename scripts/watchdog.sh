#!/usr/bin/env bash
# Фоновый сторож застревания. Раз в 30 сек проверяет метку state/stuck.flag.
# Если «возня» висит дольше STUCK_THRESHOLD_MINUTES (по умолч. 5) и ещё не
# уведомляли — шлёт red_stuck ОДИН раз (анти-спам). Always alive.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
FLAG="$ROOT_DIR/state/stuck.flag"
NOTIFIED="$ROOT_DIR/state/stuck.notified"

get_env() { grep -E "^$1=" "$ENV_FILE" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '\r'; }

while true; do
  threshold="$(get_env STUCK_THRESHOLD_MINUTES)"; threshold="${threshold:-5}"
  if [ -f "$FLAG" ] && [ ! -f "$NOTIFIED" ]; then
    started="$(cat "$FLAG" 2>/dev/null)"
    now="$(date +%s)"
    case "$started" in
      ''|*[!0-9]*) : ;;  # пустая/битая метка — пропускаем
      *)
        if [ $(( now - started )) -ge $(( threshold * 60 )) ]; then
          "$SCRIPT_DIR/notify.sh" red_stuck
          date +%s > "$NOTIFIED"
        fi
        ;;
    esac
  fi
  sleep 30
done
