# 🚦 AI Status Light

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**[Русский](#русский)** · **[English](#english)**

Telegram-уведомления о состоянии твоего **ИИ-агента для кодинга** — как светофор.
Отошёл от компьютера, но всё равно знаешь, чем он занят. Только уведомления (без кнопок), крошечный, без зависимостей кроме `bash` + `curl`.

> 🟡 в работе · 🔴 ждёт тебя / ошибка · 🟢 готово

Готовая интеграция — для **Claude Code**. Ядро от агента не зависит, поэтому легко адаптируется под любого (Codex, Cursor, Aider и др.).

---

## Русский

### Как работает
Бот ловит события агента и шлёт цветное сообщение в Telegram. Готовый рецепт — для Claude Code:

| Сигнал | Что значит | Источник (Claude Code) |
|--------|-----------|------------------------|
| 🟡 | Работаю над задачей | хук `UserPromptSubmit` |
| 🔴 | Жду твоего подтверждения | хук `Notification` |
| 🔴 | Слишком долго не могу решить (затык) | фоновый сторож |
| 🟢 | Готово, свободен | хук `Stop` |

### Требования
- аккаунт Telegram
- оболочка с `bash` и `curl`:
  - **macOS / Linux** — работает из коробки
  - **Windows** — через **WSL** (рекомендуется) или **Git Bash**. Уведомления работают; фоновый сторож надёжнее под WSL.

### Установка (для Claude Code)
1. **Создай бота:** [@BotFather](https://t.me/BotFather) → `/newbot` → скопируй токен.
2. **Создай конфиг:** `cp .env.example .env`
3. **Впиши токен** в `.env` в поле `TELEGRAM_BOT_TOKEN=`. **Никогда не коммить `.env`.**
4. **Узнай chat_id:** напиши боту любое сообщение (`/start`), затем запусти
   `bash scripts/get_chat_id.sh` и впиши показанный id в `TELEGRAM_CHAT_ID=` в `.env`.
5. **Проверь:** `bash scripts/notify.sh green` — должно прийти сообщение.
6. **Включи хуки:** файл `.claude/settings.json` уже настроен. Перезапусти Claude Code (или набери `/hooks`), чтобы он их подхватил.
7. **Запусти сторож** (по желанию — для сигнала «затык»):
   `nohup bash scripts/watchdog.sh >/dev/null 2>&1 &`

### Другие агенты (Codex, Cursor, Aider…)
Ядро `scripts/notify.sh` ни от какого агента не зависит — это просто «отправь статус-сообщение в Telegram»:
```
bash scripts/notify.sh yellow   # начал работу
bash scripts/notify.sh red      # ждёт тебя
bash scripts/notify.sh green    # закончил
```
Чтобы подключить своего агента, нужно лишь дёрнуть эти команды на его событиях «начал / ждёт / закончил». Самый простой путь — **скормить этот репозиторий своему ИИ-агенту и попросить подцепить `notify.sh` к его механизму хуков/событий**. Бот, фразы и сторож при этом работают как есть.

### Настройка сообщений
Все фразы — в `phrases/*.txt` (одна строка = одна фраза, выбирается случайно).
Меняй тон и язык как захочешь.

**Хочешь свой приватный набор, который не перезапишется и не уйдёт в git?**
Положи файлы с теми же именами в `phrases/custom/` — у них приоритет, и они скрыты от git.

Тон — какой захочешь: хоть строгий, хоть с характером. Пример кастомного набора «с характером»:

<img src="assets/demo-personality.png" width="380" alt="Пример кастомного тона бота">


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

---

## English

Telegram notifications about your **AI coding agent**'s state — like a traffic light.
Step away from your machine and still know what it's doing. Notify-only (no buttons), tiny, zero dependencies beyond `bash` + `curl`.

> 🟡 working · 🔴 waiting for you / error · 🟢 done

Ready-made integration is for **Claude Code**. The core is agent-agnostic, so it adapts easily to any agent (Codex, Cursor, Aider, etc.).

### How it works
The bot catches your agent's events and sends a colored Telegram message. The ready-made recipe is for Claude Code:

| Signal | Meaning | Source (Claude Code) |
|--------|---------|----------------------|
| 🟡 | Working on your task | hook `UserPromptSubmit` |
| 🔴 | Waiting for your approval | hook `Notification` |
| 🔴 | Stuck on an error too long | background watchdog |
| 🟢 | Done, idle | hook `Stop` |

### Requirements
- A Telegram account
- A shell with `bash` and `curl`:
  - **macOS / Linux** — works out of the box
  - **Windows** — via **WSL** (recommended) or **Git Bash**. Notifications work fine; the background watchdog is more reliable under WSL.

### Install (for Claude Code)
1. **Create a bot:** open [@BotFather](https://t.me/BotFather) in Telegram → `/newbot` → copy the token it gives you.
2. **Create your config:** `cp .env.example .env`
3. **Add your token:** open `.env` and paste the token into `TELEGRAM_BOT_TOKEN=`. **Never commit `.env`.**
4. **Get your chat id:** send your bot any message (e.g. `/start`), then run
   `bash scripts/get_chat_id.sh` and paste the printed id into `TELEGRAM_CHAT_ID=` in `.env`.
5. **Test:** `bash scripts/notify.sh green` — you should receive a message.
6. **Enable hooks:** `.claude/settings.json` is already wired up. Restart Claude Code (or run `/hooks`) so it loads them.
7. **Start the watchdog** (optional — powers the “stuck” signal):
   `nohup bash scripts/watchdog.sh >/dev/null 2>&1 &`

### Other agents (Codex, Cursor, Aider…)
The core `scripts/notify.sh` doesn't depend on any agent — it just "sends a status message to Telegram":
```
bash scripts/notify.sh yellow   # started working
bash scripts/notify.sh red      # waiting for you
bash scripts/notify.sh green    # done
```
To wire up your own agent, just call these on its "started / waiting / done" events. The easiest path: **feed this repo to your own AI agent and ask it to hook `notify.sh` into its event/hook mechanism**. The bot, phrases, and watchdog all work as-is.

### Customize the messages
All phrases live in `phrases/*.txt` — one phrase per line, a random one is picked each time.
Edit them freely to change the tone or language.

**Want a private set that won't be overwritten or committed?** Drop files with the
same names into `phrases/custom/` — they take priority over the defaults and are gitignored.

Make the tone whatever you want — dry or full of personality. Example of a custom "personality" set (in Russian):

<img src="assets/demo-personality.png" width="380" alt="Custom bot tone example">


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
