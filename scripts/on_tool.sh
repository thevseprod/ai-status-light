#!/usr/bin/env bash
# Хук PostToolUse: ведёт «метку застревания» для сторожа.
# Ошибка инструмента → ставим метку (если ещё нет). Успех → снимаем метку.
# Событие читаем со stdin (JSON). Ничего не печатаем. Always exit 0.
# Мгновенных уведомлений тут НЕТ (вариант А) — серьёзный затык ловит watchdog.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FLAG="$ROOT_DIR/state/stuck.flag"
NOTIFIED="$ROOT_DIR/state/stuck.notified"

payload="$(cat 2>/dev/null)"

# грубый детектор ошибки инструмента в событии (точность доводится тестами)
if printf '%s' "$payload" | grep -qiE '"is_error"[[:space:]]*:[[:space:]]*true'; then
  # ошибка: фиксируем момент начала «возни», если метки ещё нет
  [ -f "$FLAG" ] || date +%s > "$FLAG"
else
  # успех: возня прервана — снимаем метку и сброс «уже уведомил»
  rm -f "$FLAG" "$NOTIFIED" 2>/dev/null
fi
exit 0
