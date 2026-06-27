# PROJECT_GOALS — GameTrackr iOS (Swift / SwiftUI)

> Read this together with `CLAUDE.md` (shared product + API contract).
> This file covers only the **iOS-specific** stack, architecture, and milestones.

## Developer context

Frontend/mobile developer with solid experience in React Native, Expo, and TypeScript,
expanding into native development toward senior level. Already comfortable with the mobile
release lifecycle (CI/CD, store publishing). This app is the **iOS half** of GameTrackr; the
Android app is built in parallel against the same backend (see the Android repo).

The backend (Laravel + Reverb) and the Vue web app are built by a collaborator. This repo
consumes that API — no business logic is invented here. (The structure here intentionally
mirrors the developer's existing `swift-url-shortener-app` so patterns carry over.)

---

## Project goal

Build a native iOS app in **Swift + SwiftUI** that consumes the GameTrackr API. Full focus on
**learning idiomatic SwiftUI** with good practices: `@Observable` MVVM, a native `URLSession`
networking layer, Keychain token storage, and modern Swift Concurrency.

---

## Stack

- **Language:** Swift (5.9+)
- **UI:** SwiftUI (no UIKit), `NavigationStack`
- **Architecture:** MVVM with `@Observable` view models + a service/repository layer
- **Networking:** native `URLSession` + `Codable` (no external libs) — the same approach as the URL-shortener app
- **Async:** async/await, `Task`, `MainActor`
- **Secure storage:** Keychain (via a `KeychainHelper`), items stored `ThisDeviceOnly`
- **Images:** `AsyncImage` (or a small custom cache)
- **Realtime:** `PusherSwift` (Reverb / Pusher protocol)
- **Config:** API base URL from `.xcconfig` files (`Debug`/`Release`, gitignored `Local.xcconfig`), read via a `Config` enum — same pattern as the URL-shortener app
- **Testing:** Swift Testing; `URLProtocol` stub for the networking/refresh flow
- **Tooling:** SwiftFormat, SwiftLint, Lefthook hooks, GitHub Actions CI

---

## Expected screens

See `CLAUDE.md` → *Feature scope by phase*. Auth screens are already designed
(Welcome, Sign in, Create account, Forgot/Reset password, Verify email, Success). Build the
**MVP slice** first (auth → library → profile), then layer discovery, friends, community,
messaging, and collection.

---

## Technical requirements

### Secure storage
- Access token (and refresh token, if used) in the **Keychain**, `ThisDeviceOnly`. Never UserDefaults.
- Logout clears tokens from the Keychain.

### Automatic token refresh
- An `APIClient` that detects `401` and (if the backend uses refresh tokens) calls the refresh
  endpoint, with a queue/actor guard so parallel requests trigger a **single** refresh.
- If refresh fails, route to login. If the backend uses long-lived tokens, just route to login on `401`.

### Networking
- Centralized layer with `URLSession`; an `Endpoint` enum and typed `APIError`.
- `Codable` decoding; ISO 8601 date decoding tolerant of fractional-seconds (confirm format with backend).

### Architecture
- **MVVM** — clear View / ViewModel / Model separation.
- ViewModels with `@Observable` (Swift 5.9+).
- Services per feature (`AuthService`, `LibraryService`, …); `KeychainHelper` isolated.

### UI / UX
- Pure SwiftUI. Loading / empty / error states on every async screen.
- Pull-to-refresh on lists; swipe actions where the design allows.
- User-friendly error messages (no raw technical detail).
- Keep components neutral/cross-platform so the iOS and Android UIs stay visually aligned
  (avoid iOS-only patterns the Android app can't mirror).

---

## What to learn here

1. **SwiftUI** — views, modifiers, `NavigationStack`, state & bindings
2. **`@Observable` MVVM** — modern observation in Swift
3. **URLSession** — native networking without external libraries
4. **Keychain** — secure token storage on iOS
5. **Token refresh** — a native interceptor equivalent (actor-guarded single-flight)
6. **Swift Concurrency** — async/await, `Task`, `MainActor`, cancellation
7. **PusherSwift / Reverb** — consuming Laravel Reverb channels
8. **Swift Testing + `URLProtocol` stubs** — testing the networking/refresh flow

---

## Milestones

| #  | Deliverable | Estimate |
| --- | --- | --- |
| 1 | Xcode project, MVVM folders, `KeychainHelper`, `.xcconfig` config | a few hours |
| 2 | Networking: `URLSession` + `Codable` + `Endpoint` + `APIError` | half a day |
| 3 | Auth screens wired to real API (login, register, token persistence) | a weekend |
| 4 | Token refresh with single-flight guard (if backend uses refresh) | + half a day |
| 5 | Library: list with status filter, add game, edit entry | + 1 day |
| 6 | Game search + detail → add to library | + 1 day |
| 7 | Profile + stats + sign out | + half a day |
| 8 | Discovery feeds (releases / upcoming / trending) | + 1 day |
| 9 | Friends + public profiles | + 1 day |
| 10 | Realtime messaging via Reverb + push notifications | + 2 days |
| 11 | Community + physical collection (image upload) | + 2 days |
| 12 | Polish: states, animations, app icon, CI | + 1 day |

---

## Progress log

### 2026-06-27 — Auth networking slice + cross-platform decisions (milestones 2–4)

Wired the auth UI to the real backend on iOS, then ported the same slice to Android. Recording
the verified backend facts and the **cross-platform divergences** so the two repos + the shared
`CLAUDE.md` stay consistent.

- **Verified backend (with `curl`):** auth is **JWT (tymon/jwt-auth), not Sanctum**. Refresh is
  **single-token rotation** (`POST /auth/refresh`, current token in header, no body → new token,
  old one blacklisted). Endpoints: `auth/register` (`{ name, email, password, password_confirmation }`),
  `auth/login`, `auth/refresh`, `auth/validate`, `auth/logout`, `GET /profile/me`.
  `password/forgot|reset` don't exist yet. See the ✅ verified note in the shared `CLAUDE.md`.
- **iOS as built (matches this doc):** `URLSession` `APIClient` (actor) with 401→refresh
  (retry-once + single-flight + network≠auth), Keychain token storage (`ThisDeviceOnly`),
  base URL from `.xcconfig` (`Debug`/`Release`/gitignored `Local`). Custom `SplashView` (animated,
  dismissed when animation **and** `validate()` both finish) + `ToastModifier` for errors.
- **Android port — intentional divergences** (kept behavior-equivalent):
  - **DI: Koin, not Hilt.** Hilt's Gradle plugin is incompatible with the Android project's
    **AGP 9.0.0**; Koin needs no Gradle plugin, so it works there.
  - **Token storage: DataStore (Preferences)**, not Keychain-equivalent encryption —
    EncryptedSharedPreferences (Jetpack Security Crypto) is deprecated. Less secure at rest than
    the iOS Keychain; flagged in the Android goals.
  - The iOS `Config/.xcconfig` pattern was mirrored on Android with a repo-root `config/`
    properties folder (`debug`/`release`/gitignored `local` + `.example`) → `BuildConfig.API_BASE_URL`.
  - Splash + toast were re-created natively in Compose to match this app's `SplashView`/`ToastModifier`.

### 2026-06-24 — Auth UI: Sign-up screen is the cross-platform reference

The SwiftUI **Register (sign-up)** screen is the **design reference** the Android app mirrors
component-for-component (Lucas builds both halves for parity practice).

- `Features/Auth/Register/`:
  - `RegisterView` (screen + back button), `RegisterViewModel` (`@Observable`, validation only
    after `signUp()`).
  - `Components/`: `RegisterFormSection`, `TermsAcceptanceRow`, `RegisterBottomSection`,
    `SocialLoginSection`.
- Shared `Core/Components/`: `AuthScreenScaffold`, `AuthTextField`, `AuthLabeledField`,
  `TitleWithSubtitle`, `PasswordStrengthMeter` (+ `PasswordStrength`), `PrimaryButton`,
  `PressableButtonStyle`, `StaggeredAppear`. Validation copy lives in `Core/ValidationMessage`.
- **Field naming:** the UI label is **"Name"** but maps to `username` in `POST /auth/register`
  — keep iOS, Android, and the API aligned (see shared `CLAUDE.md`).
- Social sign-up currently shows **Continue with Google** only; Apple / Steam / Discord deferred.
- The Android port (Kotlin/Compose) now matches this structure 1:1 — when you change one
  platform's auth UX, update the other to keep them in sync.

---

## Folder structure (suggested)

```
GameTrackr/
├── App/
│   └── GameTrackrApp.swift        # @main, dependency injection
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift        # centralized URLSession + refresh
│   │   ├── APIError.swift
│   │   └── Endpoint.swift
│   ├── Auth/
│   │   └── KeychainHelper.swift
│   ├── Realtime/
│   │   └── ReverbClient.swift
│   ├── Config/
│   │   └── Config.swift           # reads base URL from .xcconfig
│   └── Extensions/
├── Features/
│   ├── Auth/                      # views + view models
│   ├── Library/
│   ├── Discovery/
│   ├── Profile/
│   ├── Friends/
│   ├── Messaging/
│   ├── Community/
│   └── Collection/
└── Models/                        # Game, LibraryEntry, User, AuthTokens, …
```

---

## How to use this context with an AI

Paste **`CLAUDE.md` + this file**, then add an instruction, e.g.:

> "Based on this context, configure the Xcode project with the MVVM structure, `KeychainHelper`, and `.xcconfig`-based `Config`."

> "Based on this context, I'm on milestone 5. Implement `LibraryService`, a `@Observable` `LibraryViewModel`, and the SwiftUI list with a status filter and pull-to-refresh."

> "Based on this context, review this view model and point out what a senior iOS dev would change."
