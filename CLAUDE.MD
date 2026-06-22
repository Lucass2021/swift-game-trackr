# GameTrackr — Shared Project Context

> Single source of truth shared by **all clients** (Android, iOS, and the Vue web app).
> Platform-specific goals, architecture, and milestones live in each app's own
> `agents/PROJECT_GOALS.md`. This file describes **what** the product is and **what**
> the API exposes — not **how** any single client is built.

---

## Code style (all clients)

- **Avoid comments.** Write self-documenting code: clear names, small functions, and
  obvious structure instead of explanatory comments. Don't add comments that restate what
  the code already says, and don't leave `TODO`/placeholder comments in committed code.
  Only keep a comment when it explains *why* something non-obvious is done (a workaround, a
  protocol quirk, a deliberate deviation) — never *what* the code does.

---

## Product

**GameTrackr** is a social game-tracking app — think Backloggd / Letterboxd, but for video
games. A user can:

- Log the games they own and track their status (playing, completed, backlog, platinum, abandoned, wishlist)
- Rate games, log hours, start/finish dates, and write short reviews
- Discover games (new releases, most anticipated, trending)
- Build a public profile with stats (total games, hours, platinum rate)
- Add friends, visit profiles, and message in real time
- Join a light community (topics, comments, votes), optionally tied to a specific game
- Catalog their physical setup (consoles, peripherals, collectibles)

The mobile-native clients and the web client are **thin clients** over one backend.

---

## Team & ownership

| Area | Owner | Stack |
| --- | --- | --- |
| Backend API + realtime | Friend (Ireland) | Laravel, Sanctum, Laravel Reverb |
| Web frontend | Friend (Ireland) | Vue, Pinia, Vue Router |
| Android app | Lucas | Kotlin, Jetpack Compose |
| iOS app | Lucas | Swift, SwiftUI |

The goal of the project is **practice**: build the same product natively on two platforms
against a real shared backend, so the focus stays on learning Kotlin/Compose and
Swift/SwiftUI rather than re-learning business logic twice.

---

## External game data

Game metadata (covers, release dates, genres, hype, screenshots) comes from **IGDB** and/or
**RAWG**, cached **server-side** in the backend's own `games` table. Clients **never** call
IGDB/RAWG directly — they only ever talk to the GameTrackr API. The backend owns refreshing
and caching that data.

---

## Authentication model

- **Token-based** auth via **Laravel Sanctum** (Bearer token in `Authorization` header).
- Mobile stores tokens in **secure storage** — Keychain on iOS, EncryptedSharedPreferences / encrypted DataStore on Android. Never in plain UserDefaults / SharedPreferences.
- **Social login** (Google, Apple, Steam, Discord): OAuth is handled by the backend; the
  mobile client opens the provider flow (system browser / ASWebAuthenticationSession /
  Custom Tabs) and receives a GameTrackr token at the end.
- Whether refresh tokens are used (vs. long-lived Sanctum tokens) is **to be confirmed with backend** — see the open questions section.

> ⚠️ **PROPOSED CONTRACT BELOW — confirm every endpoint, field, and status code with the
> backend owner before implementing.** This section doubles as the alignment doc between the
> mobile and backend developers.

---

## Realtime

Powered by **Laravel Reverb** (Pusher protocol). Mobile consumes it with a Pusher-compatible
client (`pusher-websocket-java` on Android, `pusher-websocket-swift` / `PusherSwift` on iOS),
or a raw WebSocket if the team prefers.

Channels (proposed):

- `private-user.{id}` — notifications, friend requests
- `private-conversation.{id}` — direct messages
- `private-user.{id}.activity` — activity feed updates

---

## Domain model (core entities)

| Entity | Notes |
| --- | --- |
| `User` | account + auth |
| `Profile` | display name, avatar, bio, visibility (public/private), stats |
| `Game` | server-cached copy of IGDB/RAWG data |
| `LibraryEntry` | user ↔ game link: status, rating, hours, started/finished dates, short review |
| `Friendship` | request → pending → accepted; or block |
| `Conversation` / `Message` | 1-to-1 chat |
| `Topic` / `Post` | community forum-lite; topic optionally linked to a `Game` |
| `CollectionItem` | physical item (console, peripheral, collectible) with image |
| `Notification` | friend request, reply, message, etc. |
| `ActivityEvent` | "Lucas completed Elden Ring" — feed item |
| `GameList` | user-curated list (e.g. "Top 10 RPGs") |
| `Badge` | gamification (e.g. "Completed 50 games") |

**Status enum** (canonical, used by every client):
`playing` · `completed` · `backlog` · `platinum` · `abandoned` · `wishlist`

---

## Proposed REST contract

Base URL: `https://api.gametrackr.app` (prod) / configurable per build for local/staging.
All authenticated requests send `Authorization: Bearer <token>`.
JSON request/response. Pagination via `?page=` + `?per_page=` returning Laravel-style
`{ data, meta, links }`.

### Auth
- `POST /auth/register` — `{ username, email, password }` → user + token
- `POST /auth/login` — `{ email, password }` → user + token
- `POST /auth/logout` — invalidate current token
- `POST /auth/password/forgot` — `{ email }` → 204 (sends reset email)
- `POST /auth/password/reset` — `{ token, password }` → 204
- `POST /auth/email/verify` — `{ code }` → 204 (if email OTP is used)
- `POST /auth/social/{provider}` — provider in `google|apple|steam|discord` → token
- `GET  /me` — current user + profile

### Games (discovery)
- `GET /games/releases` — recent releases
- `GET /games/upcoming` — most anticipated (with hype/date)
- `GET /games/trending` — trending (server-computed from platform activity)
- `GET /games/search?q=` — search the cached catalog
- `GET /games/{slug}` — game detail

### Library
- `GET    /me/library?status=&platform=&sort=` — user's library, filterable
- `POST   /me/library` — `{ game_id, status }` — add a game
- `PATCH  /me/library/{id}` — update status, rating, hours, dates, review
- `DELETE /me/library/{id}` — remove
- `GET    /me/stats` — aggregated stats (totals, platinum rate, by genre/platform/year)

### Profiles & friends
- `GET  /users/{username}` — public profile + public library
- `GET  /users/{username}/stats`
- `POST /friends/requests` — `{ user_id }`
- `POST /friends/requests/{id}/accept`
- `POST /friends/requests/{id}/decline`
- `GET  /friends` — friend list
- `DELETE /friends/{id}`

### Messaging (realtime-backed)
- `GET  /conversations` — list
- `GET  /conversations/{id}/messages?before=` — paginated history
- `POST /conversations/{id}/messages` — `{ body }`
- `POST /conversations` — `{ user_id }` — start/find a 1-1 conversation

### Community
- `GET  /topics?game_id=&category=` — list
- `POST /topics` — `{ title, body, game_id? , category }`
- `GET  /topics/{id}` — topic + posts
- `POST /topics/{id}/posts` — `{ body }`
- `POST /posts/{id}/vote` — `{ value: 1 | -1 }`

### Collection (physical)
- `GET    /me/collection`
- `POST   /me/collection` — multipart: `{ category, name, description?, image? }`
- `PATCH  /me/collection/{id}`
- `DELETE /me/collection/{id}`

### Notifications & feed
- `GET  /notifications` — list
- `POST /notifications/{id}/read`
- `GET  /feed` — activity feed from friends

### Standard error responses
- `401` — unauthenticated / token invalid → send to login (or refresh, if used)
- `403` — forbidden (e.g. private profile)
- `404` — not found
- `409` — conflict (e.g. game already in library)
- `422` — validation error → `{ message, errors: { field: [..] } }`
- `429` — rate limited → `Retry-After` header

---

## Feature scope by phase (mobile)

Mobile follows the same roadmap as the web app but consumes the shared API. Suggested order:

1. **Auth** — welcome, login, sign up, forgot/reset password, (optional) email verify, social login. *(UI already designed in Stitch.)*
2. **Personal library** — add games, set status, filter list, edit entry details. **This is the core — ship it first.**
3. **Discovery / Home** — releases, upcoming, trending, search → game detail → add to library.
4. **Public profiles + stats + friends**.
5. **Community** (forum-lite).
6. **Messaging + realtime** (Reverb) + push notifications.
7. **Physical collection / setup** (image upload).

---

## Mobile MVP (first shippable slice)

The smallest version that proves the product on a device:

- Auth (login / register / token persistence)
- Search a game → add to library with a status
- View "My Library" with status filter
- Edit a library entry (status, rating, review)
- Basic profile screen with sign out

Everything else (discovery feeds, friends, chat, community, collection) layers on after.

---

## Open questions for the backend owner

- Long-lived Sanctum tokens vs. access + refresh token pair? If refresh: what's the endpoint and rotation behaviour?
- Email verification — required at signup? OTP code or magic link?
- Social login — does the client get a GameTrackr token directly, or a provider token to exchange?
- Image upload — direct multipart to the API, or pre-signed URL to object storage?
- Reverb auth endpoint and channel naming — confirm the exact channel names and the `/broadcasting/auth` flow.
- Pagination shape and default `per_page`.
- Date format (ISO 8601 with or without fractional seconds — affects decoders on both platforms).

---

## How to use this context with an AI

Always paste **this file together with the app's `PROJECT_GOALS.md`**, then add an instruction, e.g.:

> "Based on this context, model the `LibraryEntry` data layer and the `GET /me/library` call for [Android/iOS]."

> "Based on this context, the trending endpoint returns `{ data: [...] }` — implement the discovery feed for the Home screen."
