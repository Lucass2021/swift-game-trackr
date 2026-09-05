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

### Micro-animations (mobile clients)

Two shared looping helpers, mirrored on iOS (`SubtleBounce` / `SubtlePulse`) and Android
(`subtleBounce` / `subtlePulse`). They are **not interchangeable** — pick by intent:

- **`subtleBounce`** (gentle vertical bob) → attract attention on *idle / persistent*
  elements: hero art and empty-state icons (Welcome hero, notifications bell).
- **`subtlePulse`** (breathing scale + glow) → *confirm / celebrate a result* on terminal
  moments: the Success screen check, and future achievement badges. Never bob a success
  check — a bouncing checkmark reads as "loading"; the pulse reads as "done".

When pairing `subtlePulse` with a blurred `glow`, keep the glow on a **separate sibling
layer behind** the pulsing element. An animated `alpha` forces an offscreen buffer clipped
to the node's bounds, which clips the glow into a hard, flickering square (hit on Android).

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

### Guest access

Users can enter the app **without an account** via **"Continue as guest"** on the Login screen.
A guest reaches the **same app shell and routes** as a signed-in user — there is **no separate
"visitor" app**. Guests get **read-only discovery**: browse Home / discovery feeds, search, and
open game/community detail. Any action that writes to a user (add to library, rate/review,
friend requests, messaging, posting/voting, collection) is **gated**: the client detects the
guest session at the point of the action and prompts to create an account instead of calling the
API. Leaving guest mode or tapping a gated CTA returns the user to the Welcome / auth flow.

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
- **Guest sessions are client-only** — no token, no backend call. The client tracks a
  three-state session (`unauthenticated` / `guest` / `authenticated`) and only guest + authenticated
  reach the app shell (see *Guest access*). Guests only hit **public read endpoints**.

> ✅ **VERIFIED AGAINST THE RUNNING BACKEND (2026-06-27, updated 2026-06-29).** The text above is
> the original *proposal*; the points below were confirmed with `curl` against the local backend and
> **take precedence** where they differ:
> - Auth is **JWT (tymon/jwt-auth), NOT Sanctum.** ⚠️ `config/jwt.php` is `env('JWT_TTL', 1)` and the
>   local `.env` **does not set `JWT_TTL`** — so tokens live **1 minute**, not 60 (re-checked
>   2026-08-25). Great for exercising the refresh path, confusing when a session seems to drop for
>   no reason. `JWT_REFRESH_TTL` 14 days.
> - Refresh = **single-token rotation**: on `401`, `POST /auth/refresh` with the *current* token in
>   the header (no body) → returns a new token, blacklists the old one. **No separate refresh token.**
> - Verified endpoints differ from the proposed list below: `POST /auth/register` ·
>   `POST /auth/login` · `POST /auth/refresh` · `POST /auth/validate` · `POST /auth/logout` ·
>   `GET /profile/me` (not `GET /me`).
> - 🔴 **Never bootstrap the session with `POST /auth/validate` — use `GET /profile/me`.**
>   `auth/validate` sits *outside* `auth:api`, so an expired token gets **200 + `{"user": null}`**
>   instead of a 401. No 401 means no refresh, and the client resolves to "logged in, but nobody":
>   on iOS that silently hid every owner-only control, on Android it logged the user out at random.
>   `profile/me` is behind `auth:api` and answers a real 401 (found 2026-08-25).
> - 🔴 **Public routes still personalise from the token, and never 401.** `GET /communities` fills
>   `is_member` from `auth()->id()` while sitting outside `auth:api`: with an expired token it
>   answers **200 with `is_member: false` for everything**, so a joined community renders as "Join"
>   until something else triggers a refresh. Both clients therefore **refresh proactively** when the
>   stored JWT is already expired, before the request goes out (iOS `JWT.isExpired` in `APIClient`,
>   Android `isJwtExpired` + `TokenRefresher` in `AuthInterceptor`) — a reactive 401 handler alone
>   cannot see this class of bug.
> - **Password reset NOW EXISTS as a 3-step OTP flow for mobile (added 2026-06-29).** Clients must
>   send **`client: "mobile"`** on forgot/reset to get the code flow (the default `"web"` branch
>   sends an email link instead). Endpoints: `POST /auth/forgot-password` `{ email, client:"mobile" }`
>   → 200 generic message + emails a **6-digit code** (15-min TTL). `POST /auth/verify-reset-code`
>   `{ email, code }` → 200 or **400 `{error}`**. `POST /auth/reset-password`
>   `{ email, code, password, password_confirmation, client:"mobile" }` → 200 (**no token** — the
>   client must auto-login after). Both clients implement this; the old
>   `agents/password-reset-flow.md` blueprint no longer exists in either repo.
> - `register` body is **`{ name, email, password, password_confirmation }`** (Laravel `confirmed`
>   rule) — the field is **`name`**, not `username`.
> - Token storage on Android is **DataStore (Preferences)**, not EncryptedSharedPreferences
>   (the Jetpack Security Crypto lib is deprecated). iOS still uses the Keychain.

> ⚠️ **PROPOSED CONTRACT BELOW — confirm every endpoint, field, and status code with the
> backend owner before implementing.** This section doubles as the alignment doc between the
> mobile and backend developers. (See the ✅ verified note above for what's already confirmed.)

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
| `CollectionItem` | physical item (console, peripheral, collectible) with image — surfaced on mobile as **"My Setup"**, see below |
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
> ⚠️ Proposed shape below; see the ✅ **verified** note under *Authentication model* for what the
> running backend actually exposes (JWT, `name`+`password_confirmation`, `auth/refresh`,
> `auth/validate`, `profile/me`). The lines below are kept as the original team proposal.

- `POST /auth/register` — `{ username, email, password }` → user + token *(verified: `{ name, email, password, password_confirmation }`)*
- `POST /auth/login` — `{ email, password }` → user + token
- `POST /auth/logout` — invalidate current token
- `POST /auth/password/forgot` — `{ email }` → 204 (sends reset email) *(verified: real endpoint is `POST /auth/forgot-password` `{ email, client:"mobile" }` → 200 + 6-digit OTP email; shipped on both clients)*
- `POST /auth/password/reset` — `{ token, password }` → 204 *(verified: real flow is `POST /auth/verify-reset-code` then `POST /auth/reset-password` with `client:"mobile"`, code-based not token-based)*
- `POST /auth/email/verify` — `{ code }` → 204 (if email OTP is used)
- `POST /auth/social/{provider}` — provider in `google|apple|steam|discord` → token
- `GET  /me` — current user + profile *(verified: `GET /profile/me`; also `POST /auth/refresh` + `POST /auth/validate`)*

> **Sign-up form (shared by all clients).** The Create-account / sign-up screen collects
> **Name → `username`**, **Email**, **Password**, **Confirm password**, plus a **required**
> Terms of Use / Privacy Policy acceptance. Client-side validation is identical on every
> client: name ≥ 3 chars, email contains `@` and `.`, password ≥ 6 chars, confirm must match,
> terms must be checked. Field errors surface only **after the first submit**. A
> password-strength meter (weak / medium / strong) is shown as the user types. Social sign-up
> currently exposes **Continue with Google** only — Apple / Steam / Discord are deferred.

### Games (discovery)
> ✅ **PARTIALLY IMPLEMENTED (2026-08-19).** The backend now proxies IGDB via `IgdbService`
> (Twitch OAuth credentials in the API's `.env`). Only the New Releases feed exists; the routes
> below that are *not* in the verified list remain proposals.
>
> - `GET /home/new-releases?limit=` → `{ message, data: [game] }` — the Home slider.
> - `GET /home/new-releases/all?page=&per_page=` → adds
>   `meta: { page, per_page, total, last_page, has_more }` — the "View all" screen.
> - `POST /igdb/auth` — **server-internal**, refreshes the Twitch token. Clients never call it.
>
> Both `/home/*` routes are **public** (outside `auth:api`), so guests get the real feed.
>
> **Decoding gotchas** (both clients hit all of these):
> - The field is **`name`**, not `title`.
> - `first_release_date` is a **Unix timestamp in seconds**, not ISO 8601.
> - `meta` is **nested** and keyed `page` — unlike the flat Laravel `current_page` shape the
>   community endpoints return. Map it onto the shared paginated model before paginating.
> - IGDB **omits** absent keys instead of sending `null` (a game with no art has no `cover` key).
> - Real platform slugs are `ps4--1`, `switch-2`, `series-x-s` — not the obvious spellings.
> - The query has no category filter, so the feed is mostly obscure indie titles. See
>   `TODO-BACKEND.MD`.
>
> **Cover placeholder semantics** (`GameCoverArt`, both clients). The three states are visually
> distinct on purpose: **loading** is a flat neutral `appSurfaceCard` with no icon; **no artwork**
> (missing `cover`, or the download failed) is the vivid palette gradient plus the brand icon;
> **loaded** is the image. Never use the gradient as the loading state — it is indistinguishable
> from real content and reads as fake data while the covers download.

- `GET /games/releases` — recent releases *(superseded by `/home/new-releases`)*
- `GET /games/upcoming` — most anticipated *(superseded by `/home/most-anticipated` + `/all`; ✅ wired
  on both clients 2026-08-24 — same shapes and same `?search=`/`?platform[]=` params as new-releases,
  only `sort hypes desc` + `first_release_date > now` differ)*
- `GET /games/trending` — trending (server-computed from platform activity) *(⚠️ still missing)*
- `GET /games/search` — global catalog search *(✅ **wired on both clients 2026-09-05.** Public,
  paginated with the same nested `meta` as the `/home/*` routes and the same `?search=`/`?platform[]=`
  params, so it decodes into the existing paginated model unchanged. Base filter is
  `name != null & cover != null`, sorted `total_rating_count desc` — so with no query it is the
  **popular** list (GTA V, Witcher 3, Portal 2…), not recent releases; the Search header therefore
  reads "Popular" instead of the old "Recent Releases". The **magnifying glass in the global header**
  (scope `.all`) uses this route; the two Home "View all" targets keep their feed endpoints.)*
- `GET /platforms` — platform list for the filter chips *(✅ **fixed and wired on both clients
  2026-09-05.** The old `category = (1,5,6)` filter always returned `[]` because IGDB v4 renamed the
  field to `platform_type`; the backend now falls back to a curated `POPULAR_PLATFORM_IDS` list and
  answers 6 platforms — Switch, PC, PS4, PS5, Xbox One, Series X|S — each with `slug`, `abbreviation`
  and `platform_logo`. `?all=true` returns 200 raw IGDB rows including junk like Amiga and Apple II,
  and Xbox has **no `platform_family`**, so grouping by family server-side is not viable. Also
  exposed at the older `GET /igdb/platforms`.)*

> ✅ **`GET /games/{slug}` — SHIPPED on both clients 2026-08-24.** Public route, so guests can open it.
> One request fills the whole screen: hero (first **screenshot**, then artwork, then cover — artworks
> are sometimes solid black, so screenshots win), title, year, rating, platform chips, genres+themes
> chips, real screenshots, `summary`, and a Specifications list (Developer / Publisher / Released /
> Engine / Modes / Perspective — only the ones IGDB returns), rendered as **one full-width card per
> row** on both clients; the old 2-column grid was dropped because the two platforms equalised row
> heights differently. Notes:
> - The rating is IGDB's **0–100** `total_rating` (→ `aggregated_rating` → `rating`); both clients
>   divide by 10 and **hide the chip** when the game has none (unreleased titles have no rating).
> - The **System Requirements** section was deleted from both clients — IGDB has no such data and it
>   was pure invention. Don't reintroduce it without a real source.
> - Unknown slug → **404 `{ message }`**, rendered as "Couldn't load this game."
> - Screens reached from mock surfaces (Library, Profile favorites, Most Anticipated) pass **no slug**
>   and keep rendering `GameDetailMockData`; only Home's New Releases and Search pass a real one.

### Library
> 🔴 **NOTHING BELOW EXISTS.** Verified against `php artisan route:list` on 2026-08-24: the API has no
> library route, controller, or model at all. The **Add to library** sheet on both clients is UI-only —
> "Save to library" just dismisses, and nothing is stored anywhere (not even in memory). This is the
> single biggest gap between the product description and the running backend.

- `GET    /me/library?status=&platform=&sort=` — user's library, filterable
- `POST   /me/library` — `{ game_id, status }` — add a game
- `PATCH  /me/library/{id}` — update status, rating, hours, dates, review
- `DELETE /me/library/{id}` — remove
- `GET    /me/stats` — aggregated stats (totals, platinum rate, by genre/platform/year)

### Profiles & friends
> ✅ **`PATCH /profile` + `GET /profile/colors` — SHIPPED on both clients 2026-09-05.** The Edit
> profile screen now persists. Notes:
> - `PATCH /profile` (auth) takes `{ name, username, profile_color }` — all `sometimes|required`,
>   `username` unique — and answers `{ message, user }`. Send the username **without** the `@`.
> - `GET /profile/colors` (auth) returns 12 curated `{ key, name, hex }`. **A single hex per color**,
>   not a gradient pair: both clients derive the avatar/banner gradient as `hex → hex darkened 28%`,
>   so `Profile` stores `avatarHex` and computes `avatarStart`/`avatarEnd`.
> - `username` and `profile_color` are **auto-generated at registration** (slugified name, random
>   color), so every user has them before ever opening the screen.
> - 🔴 **`bio` and `visibility` stay mock** — the API has no column for either. They are the two
>   fields on that screen that still do not survive an app restart.
> - The old hardcoded `AvatarPalette` (7 named gradients) was **renamed to `SetupPalette`** and moved
>   to the setup feature on both clients — it is still the local palette for My Setup cards, which
>   has nothing to do with the profile color.

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
> ✅ **Real routes are `communities` + `posts`, not `topics`.** The proposed shape below never
> existed; `POST /posts/{id}/vote` is moot (the schema has a `likes` column, so the design's heart
> is correct). **Creating and deleting a community shipped on both clients 2026-08-25** — the last
> two community routes that were still unwired:
> - `POST /communities` (auth) — `{ title, description }` → **201** `{ community, message }`.
>   `avatar`/`cover` are accepted as multipart but **neither client sends them**, because no screen
>   renders a community image yet (icons are palette gradients). Wire the upload when the UI needs it.
> - `DELETE /communities/{id}` (auth) — 200 `{ message }` · **401** when you are not the author
>   (not 403!) · 404 unknown id.
>
> **Two backend behaviours the clients have to absorb:**
> - `store` runs `str_replace(' ', '', $title)`, so the stored title loses every space while the
>   `slug` is computed from the raw text *before* that. Both clients therefore send a **handle**
>   (the typed name minus whitespace) and show it live under the field — "Listed as `RetroShmupClub`".
>   Don't filter the field's text as it's typed: on iOS a SwiftUI `TextField` keeps rejected input,
>   and deferring the fix races the keyboard and eats characters.
> - `CommunityRequest` has **no `unique` rule** while the column does, so a duplicate name is a
>   **500 with the raw SQL error**, not a 422. Both clients map 500-on-create to "That name may
>   already be taken." Adding `'unique:communities,title'` to the request would turn it into a
>   normal 422 — worth asking the backend owner for.
>
> **`DELETE` answers 401 for "not the author" — and so does an expired token.** Tell them apart by
> the body, never by the endpoint: Laravel's auth middleware returns `{ message: "Unauthenticated." }`,
> a controller denying an action returns `{ error: ... }`. Both clients branch on that
> (iOS maps 401→`APIError.forbidden` when `error` is present, Android `ErrorMapper` →
> `ApiError.Forbidden`, and `TokenAuthenticator` peeks the body to skip a pointless refresh).
> An earlier attempt opted the whole endpoint out of refresh and was **wrong**: with a short
> `JWT_TTL` an expired token then read as "only the owner can delete it" and never recovered.

- `GET  /topics?game_id=&category=` — list *(never existed — see `GET /communities`)*
- `POST /topics` — `{ title, body, game_id? , category }` *(never existed — see `POST /posts`)*
- `GET  /topics/{id}` — topic + posts *(never existed — see `GET /communities/{id}`)*
- `POST /topics/{id}/posts` — `{ body }` *(never existed — see `POST /posts`)*
- `POST /posts/{id}/vote` — `{ value: 1 | -1 }` *(never existed — likes, not votes)*

### Collection (physical) — "My Setup"
> ⚠️ **Not implemented in the backend.** No route, controller, or model exists yet (verified
> 2026-08-10 against `game-trackr-api/routes/api.php`). Both mobile clients ship the feature
> **client-side only** in the meantime — see below.

- `GET    /me/collection`
- `POST   /me/collection` — multipart: `{ category, name, description?, image? }`
- `PATCH  /me/collection/{id}`
- `DELETE /me/collection/{id}`

**How mobile ships it today (2026-08-10).** The Profile tab has a **My Setup** section →
a **My Setup** list screen → an **add/edit** form. A setup is `{ id, title, description,
photos[], palette }`, where `photos` are **real images picked from the device** (iOS
`PhotosPicker`, Android `PickVisualMedia` — neither needs a runtime permission) and `palette`
only supplies the placeholder gradient when a setup has no photo. **Nothing persists**: the list
is hoisted UI state (`MainTabView` / `MainTabScreen`) and is lost on app restart, matching how
the rest of the app fakes data. Max **6 photos** per setup, downsampled to 1200px on import.
When the endpoints land, the swap points are those two state holders — the screens already take
a plain list plus callbacks. The category/`CollectionItem` split above is **not** modelled on the
client yet.

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

## App navigation & screen flow

The whole-app flow the team drew (see `agents/app-flow.jpeg`). Applies to every client.

**Auth stack** (unauthenticated):

- **Welcome** → **Login** and **Create account** (Login ↔ Create account cross-link).
- **Login** → **Forgot password** → **Confirm OTP code** → **New password** → **Home**.
- **Login** → **Continue as guest** → **Home** (guest session; see *Guest access*).
- **Login** / **Create account** → **Home** on success.

**App shell** (authenticated *or* guest) — a bottom tab bar with a global header:

- **Tabs:** `Home` · `Library` · `Community` · `Profile`.
- **Global header** (present across tabs): `Notifications` · `Search` · `Profile menu`.
- **Home** → `New Releases` and `New Anticipated` (Most Anticipated) screens.
  - Both sliders are real IGDB data since 2026-08-24 and both "View all" targets reuse the **Search**
    screen with a scope — the scope picks the endpoint (`.mostAnticipated` → `/home/most-anticipated/all`,
    `.newReleases` → `/home/new-releases/all`, `.all` → `/games/search`, the whole catalog). Cards differ by intent: New Releases is a portrait cover,
    Most Anticipated is a **larger 170×227 portrait** of the same cover with a **year badge**
    (`appPrimary` when dated, `appSecondary` when `TBA`). It was a 260×150 landscape crop until
    2026-09-05 — the feed payload carries **only `cover`** (portrait 3:4), so a landscape box could
    only ever crop it, and titles like Fable lost half the art. Don't reintroduce the landscape card
    unless the endpoint starts returning `artworks`/`screenshots`. The old "not available yet" state is gone.
  - There is no "Can't find a game?" / *Explore Community* banner under the results — it was
    removed 2026-08-19 because the list is now infinite, so a dead end below it made no sense.
    Feeds are cached in memory per `FeedKey(scope, search, platform)` for **5 minutes**
    (`FeedCache` + `PaginationSnapshot`, mirrored on both clients). A key that is still fresh is
    restored from the snapshot with **no request and no spinner**, so re-tapping a chip you already
    visited and coming back from Game detail are both instant. `HomeFeed.load(force:)` follows the
    same rule: the `.task` / `LaunchedEffect` on Home skips a refetch once loaded, and only
    pull-to-refresh or the retry button pass `force`.
    The search field and the platform chips filter **server-side** since 2026-08-24 — both
    clients send `?search=` and repeated `?platform[]=` (IGDB slugs) to `/home/new-releases/all`
    and reset the pagination. The chips come from **`GET /platforms`** since 2026-09-05 — each chip is one
    real platform and filters by its own slug, so there is no hardcoded platform data left on either
    client (`GamePlatform` is a plain `{id, slug, name}` decoded from the API, and the request
    failing just renders no chips). The trade-off: the backend's curated list is 6 entries, so
    PS3/Switch 2 are not filterable until it grows. The query is debounced 300 ms —
    **only when the typed text changed**, never on a chip tap — and stale responses are dropped by a
    generation counter plus a cancellation guard on both the view and the view model. The result count in the header is
    `meta.total`, not the number of rows loaded so far.
- **Community** → `My Community` and `Discover new Communities`.
  - `My Community` → `Post details` → `Community details`.
  - `Discover new Communities` → `Community details`.
  - `Discover` is **search field → category chips → All communities**. There is no "Featured"
    carousel — it was removed 2026-08-10 because it duplicated the first three rows of the list
    below it and ignored the chip filter.
  - The `+` FAB is present on **both** segments and changes intent with the segment: `Feed` → **New
    post**, `Discover` → **New community** (2026-08-25). Creating one pushes straight into its
    `Community details`, already joined. Deleting lives behind the `…` on `Community details` and
    is rendered **only for the author** (`community.authorId == currentUser.id`) — the API's own
    check answers 401, which is a bad thing to surface, so the button is gated client-side too.
- **Profile** → `Stats`, `Edit profile`, and `My Setup` → `New setup` / `Edit setup`.

Guests land on the same shell; write actions inside it are gated (see *Guest access*).

### Overflow (`…`) menus

A three-dot button must always open a menu. Audited 2026-08-10 — the ones that exist are
**Notifications** (Mark all read / Clear all), **Post detail on your own post** (Delete post), and
**Community detail on a community you created** (Delete community, added 2026-08-25).
Dead `…` buttons were removed from Community detail, Post detail on someone else's post, the
User profile top bar, and the community post card. Don't reintroduce one as a placeholder: put
the affordance in when its menu exists.

---

## Feature scope by phase (mobile)

Mobile follows the same roadmap as the web app but consumes the shared API. Suggested order:

1. **Auth** — welcome, login, sign up, forgot/reset password, (optional) email verify, social login. *(UI already designed in Stitch.)*
2. **Personal library** — add games, set status, filter list, edit entry details. **This is the core — ship it first.**
3. **Discovery / Home** — releases, upcoming, trending, search → game detail → add to library.
   *Shipped on both clients: New Releases (2026-08-19), then server-side search/platform filters,
   game detail and Most Anticipated (2026-08-24). Only **trending** still waits on an endpoint —
   and "add to library" waits on the whole Library API (see below).*
4. **Public profiles + stats + friends**.
5. **Community** (forum-lite).
6. **Messaging + realtime** (Reverb) + push notifications.
7. **Physical collection / setup** (image upload). *UI shipped 2026-08-10 as **My Setup**, local-only
   — see the Collection section of the REST contract. Waiting on the backend to persist.*

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
