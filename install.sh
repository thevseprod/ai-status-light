#!/usr/bin/env bash
# AI Status Light — interactive installer.
# Creates .env (bot token + chat id) and sends a test message.

set -u
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"
EXAMPLE="$ROOT_DIR/.env.example"

say() { printf '%s\n' "$*"; }
err() { printf 'Error: %s\n' "$*" >&2; }

# 0) dependencies
for cmd in curl awk grep; do
  command -v "$cmd" >/dev/null 2>&1 || { err "'$cmd' is required but not installed."; exit 1; }
done

set_env() { # set_env KEY VALUE  (replace line or append)
  key="$1"; val="$2"; tmp="$(mktemp)"
  awk -v k="$key" -v v="$val" '
    BEGIN{done=0}
    $0 ~ "^"k"=" {print k"="v; done=1; next}
    {print}
    END{if(!done) print k"="v}
  ' "$ENV_FILE" > "$tmp" && mv "$tmp" "$ENV_FILE"
  chmod 600 "$ENV_FILE" 2>/dev/null
}
get_env() { grep -E "^$1=" "$ENV_FILE" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '\r'; }

say "🚦 AI Status Light — setup"
say ""

# 1) .env
[ -f "$ENV_FILE" ] || { cp "$EXAMPLE" "$ENV_FILE"; say "Created .env from template."; }
chmod 600 "$ENV_FILE" 2>/dev/null

# 2) token (hidden input)
say "1) In Telegram, create a bot via @BotFather (/newbot) and copy the token."
printf "   Paste the bot token (input hidden, Enter to skip): "
stty -echo 2>/dev/null; read -r TOKEN; stty echo 2>/dev/null; printf '\n'
if [ -n "${TOKEN:-}" ]; then set_env TELEGRAM_BOT_TOKEN "$TOKEN"; say "   Token saved."; fi

# 3) chat id
say ""
say "2) Send your bot ANY message in Telegram (e.g. /start), then press Enter."
read -r _
TOK="$(get_env TELEGRAM_BOT_TOKEN)"
if [ -n "$TOK" ]; then
  resp="$(curl -sS --max-time 10 "https://api.telegram.org/bot${TOK}/getUpdates")"
  CHAT_ID="$(printf '%s' "$resp" | grep -oE '"chat":\{"id":-?[0-9]+' | grep -oE '\-?[0-9]+' | tail -n1)"
  if [ -n "$CHAT_ID" ]; then
    set_env TELEGRAM_CHAT_ID "$CHAT_ID"; say "   chat id detected and saved."
  else
    err "Could not detect chat id. Message the bot, then re-run — or set TELEGRAM_CHAT_ID in .env manually."
  fi
else
  err "No token in .env — re-run and paste the token."
fi

# 4) test
say ""
say "3) Sending a test message…"
bash "$ROOT_DIR/scripts/notify.sh" green && say "   ✅ Sent. Check Telegram for a 🟢 message."

# 5) next steps
say ""
say "Done. Next:"
say "  • Enable hooks: restart Claude Code or run /hooks (.claude/settings.json is preconfigured)."
say "  • Optional 'stuck' watchdog: nohup bash scripts/watchdog.sh >/dev/null 2>&1 &"
say ""
say "🚦 Enjoy your status light."
