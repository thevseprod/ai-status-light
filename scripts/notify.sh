#!/usr/bin/env bash
# Светофор-ДПСник — отправка статуса в Telegram.
# Использование: scripts/notify.sh <yellow|red|red_error|red_stuck|green>
# Токен и chat_id берутся из .env. Токен НИКОГДА не печатается.
# Любой сбой — тихо в лог, основную работу не роняем (always exit 0).

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
PHRASES_DIR="$ROOT_DIR/phrases"
LOG_FILE="$ROOT_DIR/state/notify.log"

log_err() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE" 2>/dev/null; }

mood="${1:-}"
case "$mood" in
  yellow|red|red_error|red_stuck|green) ;;
  *) log_err "bad arg: '$mood'"; exit 0 ;;
esac

[ -f "$ENV_FILE" ] || { log_err ".env missing"; exit 0; }

# читаем только нужные ключи, не исполняя файл и не печатая значения
get_env() { grep -E "^$1=" "$ENV_FILE" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '\r'; }
TOKEN="$(get_env TELEGRAM_BOT_TOKEN)"
CHAT_ID="$(get_env TELEGRAM_CHAT_ID)"

[ -n "$TOKEN" ] && [ -n "$CHAT_ID" ] || { log_err "token/chat_id empty in .env"; exit 0; }

# приоритет: пользовательские фразы (phrases/custom/, не трекаются git) > дефолтные
if [ -s "$PHRASES_DIR/custom/$mood.txt" ]; then
  PHRASE_FILE="$PHRASES_DIR/custom/$mood.txt"
else
  PHRASE_FILE="$PHRASES_DIR/$mood.txt"
fi
[ -s "$PHRASE_FILE" ] || { log_err "phrases missing: $mood"; exit 0; }

# случайная непустая строка — переносимо (без bash4-only mapfile)
message="$(awk 'BEGIN{srand()} !/^[[:space:]]*$/{a[++n]=$0} END{if(n>0) print a[int(rand()*n)+1]}' "$PHRASE_FILE")"
[ -n "$message" ] || { log_err "empty phrase: $mood"; exit 0; }

# отправка (токен в URL не печатаем; вывод глушим; ошибки тихо в лог)
curl -sS --max-time 10 \
  "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${message}" \
  >/dev/null 2>>"$LOG_FILE" || log_err "curl failed: $mood"

exit 0
