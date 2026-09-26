# Ellena

Flutter chat app. Streams Gemini replies, stores chats in Hive, and syncs them to a history server keyed by install id.

## Setup

```bash
# .env is gitignored
echo 'GEMINI_API_KEY=' > .env
flutter pub get
flutter run --dart-define-from-file=.env
```

Debug loads `assets/config/dev.json`. Release loads `assets/config/prod.json`. The key is a compile-time define from `.env`. It is not stored in those JSON files.

History server:

```bash
cd server && npm install && npm start
```

Open `http://localhost:8787`. Paste the install id from Account. On Android, `localhost` and `127.0.0.1` are rewritten to `10.0.2.2`.

## Architecture

```
lib/
  presentation/   screens, widgets, Riverpod notifiers, go_router, theme
  data/           Dio, Gemini SSE, Hive, history queue
  core/           models, Result, AppConfig, constants
```

`presentation` may import `data` and `core`. `data` may import `core`. `core` imports neither.

`server/` is one Express process. It serves the page and `/api`, and writes chats to `server/data/db.json`.

Chat text uses the model selected in the app (`gemini-3.5-flash-lite`, `gemini-3.5-flash`, or `gemini-3.1-pro-preview`). Both config files default to Flash-Lite. Titles always call Flash-Lite on the first user message.

## Priorities

1. Stop keeps the text that already arrived. A killed app reopens that reply as stopped or failed.
2. API and storage failures return `Result`. The thread shows the failure inline, with Retry.
3. Hive writes stay off the token path: debounce about 400ms, flush on send, stop, complete, and fail.
4. Settings can switch to a local mock stream, so the UI runs without a Gemini key.

## Trade-offs

| Chose | Over | Why |
| --- | --- | --- |
| Manual Riverpod `Notifier`s | codegen, Bloc | state changes stay in one class |
| Dio and a handwritten SSE parser | the Gemini SDK | one HTTP client, failures stay typed |
| `Result` at API and storage | thrown exceptions | the screen chooses the message |
| Debounced Hive | a write per token | disk stays off the stream |
| Blank composer on cold start | restoring the last thread | reopen is a new chat |
| One Node process and a JSON file | serverless functions | the file stays on the machine. Render keeps it. Free Vercel functions do not. |

## ADRs

**Streaming persistence.** Each token wrote Hive with the bubble update. A profile Timeline showed disk work on every chunk. Chunks stay in memory, Hive waits ~400ms, and a flush runs on send, stop, complete, and fail. Load turns a leftover `streaming` row into stopped or failed. Writing every token hit the frame path. Writing only at the end lost the reply on a kill. A force-kill inside the 400ms window can drop the newest tokens. `StreamEventGate` keeps text and metadata on one generation, so an old meta cannot land on the next reply. See `_scheduleStreamPersist` and the remap in `chat_storage`.

**Streaming UI.** A full `chatProvider` watch rebuilt every bubble per token, and fences had no copy, dark chrome, or horizontal scroll. The screen watches message ids. Each bubble selects its own `Message`, so siblings skip the rebuild. Fences use `AppColors.code*`, a language label, Copy, and horizontal scroll. The live bubble still reparses its own text. See `ChatScreen`, `MessageBubble`, and `_MarkdownCodeBlock`.

**Cache invalidation.** The list and the open chat were one memory copy, updated in place, so a rename never marked the list stale. `ChatCache` reads memory, then Hive, then `ChatRemote` on a miss. Rename, pin, delete, and send drop that chat and the list. Delete and send also drop its messages. The next read refills from Hive. See `invalidateRecord`, `invalidateList`, and `invalidateMessages`.

**Later update wins.** On pull, the chat with the later `updatedAt` is kept. Equal times keep the phone copy. A chat with a queued edit is skipped until that edit is sent. Taking the server copy would drop an offline rename. Merging titles has no rule for which words to keep. See `preferLater` and `_pullUnlocked`.

## Known issues

- A force-kill can drop the newest tokens from the last ~400ms.
- The history API has no auth. Knowing the install id is enough to read and write that user's chats.
- `prod.json` leaves `HISTORY_BASE_URL` empty, so a release build does not sync.
- Scheduled tasks, Knowledge, Mail, Data controls, Cloud Browser, Connectors, Integrations, and Create a skill only show "Mocked for this trial."

## Next steps

- Set `HISTORY_BASE_URL` in `prod.json` once the history server has a host.
- Put a check in front of `/api` so an install id alone cannot read chats.
- Replace the mocked Account rows, or remove them.
