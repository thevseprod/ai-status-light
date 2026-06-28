# 🚦 Claude Code Traffic-Light Notifier

Get Telegram notifications about your **Claude Code** agent's state — like a traffic light.
Step away from your machine and still know what your agent is doing.

> 🟡 working · 🔴 waiting for you / error · 🟢 done & idle

Notify-only (no buttons), tiny, zero dependencies beyond `bash` + `curl`.

---

## English

### How it works
The bot hooks into Claude Code events and sends you a colored Telegram message:

| Signal | Meaning | Source |
|--------|---------|--------|
| 🟡 | Working on your task | hook `UserPromptSubmit` |
| 🔴 | Waiting for your approval | hook `Notification` |
| 🔴 | Stuck on an error too long | background watchdog |
| 🟢 | Done, idle | hook `Stop` |

### Requirements
- macOS or Linux, with `bash` and `curl` (preinstalled on both)
- A Telegram account

### Install
1. **Create a bot:** open [@BotFather](https://t.me/BotFather) in Telegram → `/newbot` → copy the token it gives you.
2. **Create your config:** `cp .env.example .env`
3. **Add your token:** open `.env` and paste the token into `TELEGRAM_BOT_TOKEN=`. **Never commit `.env`.**
4. **Get your chat id:** send your bot any message (e.g. `/start`), then run
   `bash scripts/get_chat_id.sh` and paste the printed id into `TELEGRAM_CHAT_ID=` in `.env`.
5. **Test:** `bash scripts/notify.sh green` — you should receive a message.
6. **Enable hooks:** `.claude/settings.json` is already wired up. Restart Claude Code (or run `/hooks`) so it loads them.
7. **Start the watchdog** (optional — powers the “stuck” signal):
   `nohup bash scripts/watchdog.sh >/dev/null 2>&1 &`

### Customize the messages
All phrases live in `phrases/*.txt` — one phrase per line, a random one is picked each time.
Edit them freely to change the tone or language.

**Want a private set that won't be overwritten or committed?** Drop files with the
same names into `phrases/custom/` — they take priority over the defaults and are gitignored.

### Configuration
- `STUCK_THRESHOLD_MINUTES` in `.env` — how many minutes "stuck" before the 🔴 alert (default `5`).

### Security
- Your token and chat id live **only** in `.env`, which is gitignored. Only `.env.example`
  (fake placeholders) is committed.
- If your token ever leaks, revoke it in [@BotFather](https://t.me/BotFather) (`/revoke`) and put a new one in `.env`.

### Turn it off
Remove the hooks (edit `.claude/settings.json` or use `/hooks`) and stop the watchdog:
`pkill -f watchdog.sh`.

### License
[MIT](LICENSE) — use it, change it, ship it.

---

## Русский

Telegram-бот, который шлёт тебе **статус агента Claude Code** — как светофор.
Отошёл от компьютера, но всё равно в курсе, чем агент занят. Только уведомления (без кнопок).

### Как работает
Бот цепляется к событиям Claude Code и шлёт цветное сообщение в Telegram:

| Сигнал | Что значит | Источник |
|--------|-----------|----------|
| 🟡 | Работаю над задачей | хук `UserPromptSubmit` |
| 🔴 | Жду твоего подтверждения | хук `Notification` |
| 🔴 | Слишком долго не могу решить (затык) | фоновый сторож |
| 🟢 | Готово, свободен | хук `Stop` |

### Требования
- macOS или Linux, `bash` и `curl` (уже стоят)
- аккаунт Telegram

### Установка
1. **Создай бота:** [@BotFather](https://t.me/BotFather) → `/newbot` → скопируй токен.
2. **Создай конфиг:** `cp .env.example .env`
3. **Впиши токен** в `.env` в поле `TELEGRAM_BOT_TOKEN=`. **Никогда не коммить `.env`.**
4. **Узнай chat_id:** напиши боту любое сообщение (`/start`), затем запусти
   `bash scripts/get_chat_id.sh` и впиши показанный id в `TELEGRAM_CHAT_ID=` в `.env`.
5. **Проверь:** `bash scripts/notify.sh green` — должно прийти сообщение.
6. **Включи хуки:** файл `.claude/settings.json` уже настроен. Перезапусти Claude Code (или набери `/hooks`), чтобы он их подхватил.
7. **Запусти сторож** (по желанию — для сигнала «затык»):
   `nohup bash scripts/watchdog.sh >/dev/null 2>&1 &`

### Настройка сообщений
Все фразы — в `phrases/*.txt` (одна строка = одна фраза, выбирается случайно).
Меняй тон и язык как захочешь.

**Хочешь свой приватный набор, который не перезапишется и не уйдёт в git?**
Положи файлы с теми же именами в `phrases/custom/` — у них приоритет, и они скрыты от git.

### Конфиг
- `STUCK_THRESHOLD_MINUTES` в `.env` — через сколько минут затыка слать 🔴 (по умолчанию `5`).

### Безопасность
- Токен и chat_id хранятся **только** в `.env` (скрыт от git). В репозиторий уходит лишь
  `.env.example` с фейковыми значениями.
- Утёк токен — отзови в [@BotFather](https://t.me/BotFather) (`/revoke`) и впиши новый в `.env`.

### Выключить
Убери хуки (через `/hooks` или `.claude/settings.json`) и останови сторож:
`pkill -f watchdog.sh`.

### Лицензия
[MIT](LICENSE) — бери, меняй, используй.
