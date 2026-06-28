#!/usr/bin/env bash
# Узнать свой chat_id, НЕ светя токен.
# Перед запуском: напиши своему боту любое сообщение в Telegram.
# Скрипт берёт токен из .env и печатает ТОЛЬКО chat_id (токен не выводит).

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

get_env() { grep -E "^$1=" "$ENV_FILE" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '\r'; }
TOKEN="$(get_env TELEGRAM_BOT_TOKEN)"

[ -n "$TOKEN" ] || { echo "Сначала впиши TELEGRAM_BOT_TOKEN в .env (в файл, не в чат)."; exit 1; }

resp="$(curl -sS --max-time 10 "https://api.telegram.org/bot${TOKEN}/getUpdates")"

# достаём chat id из последнего апдейта, без jq
chat_id="$(printf '%s' "$resp" | grep -oE '"chat":\{"id":-?[0-9]+' | grep -oE '\-?[0-9]+' | tail -n1)"

if [ -n "$chat_id" ]; then
  echo "Твой chat_id: $chat_id"
  echo "Впиши его в .env  ->  TELEGRAM_CHAT_ID=$chat_id"
else
  echo "Не нашёл chat_id. Напиши боту любое сообщение в Telegram и запусти скрипт снова."
fi
