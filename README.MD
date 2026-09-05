# GameTrackr — iOS

Native **Swift + SwiftUI** client for GameTrackr, a social game-tracking app (think Backloggd /
Letterboxd, but for video games). This repo is the **iOS half**; an Android app is built in
parallel against the same backend, and a Vue web app + Laravel API are built by a collaborator.

The point of the project is **practice** — building the same product natively on two platforms
against one real backend, so the focus stays on idiomatic SwiftUI rather than re-inventing
business logic.

## Docs

| File | What's in it |
|------|--------------|
| `CLAUDE.MD` | **Shared** product + API contract. Identical in the Android repo — edit both together |
| `agents/PROJECT_GOALS.ios.md` | iOS stack, architecture, milestones, and the progress log |
| `TODO.MD` | Backlog |

## Stack

- Swift 5.9+, SwiftUI (no UIKit), `NavigationStack`
- MVVM with `@Observable` view models + a service layer
- Networking: native `URLSession` + `Codable` — no third-party libraries
- Auth: **JWT** (tymon/jwt-auth), token in the **Keychain** (`ThisDeviceOnly`), single-flight
  refresh on `401`
- Config: API base URL from `.xcconfig` (`Debug` / `Release` / gitignored `Local.xcconfig`)
- Icons: Phosphor, via a shared `AppIcon` token
- Type: Sora (headlines) + Inter (body), mirrored on Android
- Tooling: SwiftFormat, SwiftLint, Lefthook

## Running it

```bash
open GameTrackr.xcodeproj
```

Build and run on a simulator. The app boots to Welcome; you can sign in, register, or
**continue as guest** (read-only, no token, no backend call).

For the live Community/Posts integration you need the backend running locally:

```bash
cd ~/Projetos/game-trackr-api && docker compose up -d
```

The simulator shares the Mac's network, so `http://localhost:8000/api` works with no extra config —
including for Google sign-in, whose redirect URI is registered as `http://localhost:8000`.

### Sign in with Google

The backend owns the OAuth flow; the app just opens a browser and catches a JWT off the
`gametrackr://auth/callback` deep link. It needs three keys in the API's `.env`
(`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REDIRECT`) from a **Web application** OAuth
client in the Google Cloud Console, and your account added under *Test users* — otherwise Google
answers `403 access_denied`.

⚠️ `config/jwt.php` defaults `JWT_TTL` to **1 minute**, so if the API's `.env` doesn't set it, local
sessions expire almost immediately — that is the environment, not the app. Set `JWT_TTL=60` there
(and remove it when you want to exercise the refresh path). See the refresh notes in
`agents/PROJECT_GOALS.ios.md`.

## Current state

Auth (including **Sign in with Google**), **Home/discovery** (New Releases, Most Anticipated,
global catalog search, API-driven platform filters, game detail), **Community/Posts** — including
creating and deleting a community — and **Edit profile** talk to the real API. As of 2026-09-05
**every route the API exposes is wired**; what is missing is missing server-side.

Library, Stats, Notifications, Achievements and My Setup still render from **mock data** because
those endpoints don't exist: there is no `/me/library` route at all, and `/me/collection` was never
built. On the Edit profile screen, `bio` and `visibility` are the two fields that still don't
survive a restart — the API has no column for either. `CLAUDE.MD` marks each route with its real
status.
