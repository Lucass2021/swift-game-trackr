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
| `agents/api-integration-status.md` | Which endpoints exist, which are wired, which are missing |
| `agents/missing-screens.md` | Screen-by-screen parity checklist against Android |
| `agents/testing-community-integration.md` | How to run the backend and test the live Community/Posts integration |
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

The simulator shares the Mac's network, so `http://localhost:8000/api` works with no extra config.
See `agents/testing-community-integration.md` for the full walkthrough.

## Current state

Auth and Community/Posts talk to the real API. Everything else — Home/discovery, Library, Stats,
Notifications, Achievements, My Setup — renders from **mock data**, because those endpoints don't
exist yet. `agents/api-integration-status.md` is the authority on which is which.
