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

See `CLAUDE.md` → *Feature scope by phase* and *App navigation & screen flow* (the full flow the
team drew, `agents/app-flow.jpeg`). Auth screens are already designed and built (Welcome, Sign in
+ **Continue as guest**, Create account, Forgot/Reset password OTP flow, Success). The **app shell**
comes next: bottom tabs `Home · Library · Community · Profile` + a global header
(`Notifications · Search · Profile menu`). Build the **MVP slice** first (auth → library → profile),
then layer discovery, friends, community, messaging, and collection.

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

### 2026-07-02 — App shell: global header + custom bottom tab bar

First screens past auth. Built the **app shell** that hosts every authenticated/guest screen
(`Features/App/AppShell/`), matching the team's mockups.

- **`MainTabView`** — the shell: `AppHeader` on top, the selected tab's content in the middle,
  `AppTabBar` at the bottom, inside one `NavigationStack` (nav bar hidden). The header's three
  actions push `SearchPlaceholderView`, `NotificationsPlaceholderView`, and `ProfileMenuView`
  via `navigationDestination(isPresented:)`. `RootView` now shows `MainTabView` for `isInApp`.
- **`AppHeader`** — `logo-wordmark` on the left; three right-aligned icon buttons: **bell**
  (notifications), **magnifyingglass** (search), **gearshape** (profile menu). Reusable, takes
  three closures.
- **`AppTabBar`** — **custom** (not native `TabView`) to match the design and stay visually
  aligned with the Android app. Bound to `AppTab` (`enum { home, library, community, profile }`,
  with `icon`/`selectedIcon` SF Symbols). Selected tab tinted `appPrimary`; a top hairline
  (`appOutline`) and a background that bleeds under the home indicator. **Explore was dropped —
  Home *is* the explore/discovery screen** (4 tabs, not 5).
- **Tab screens** are thin placeholders over a reusable `ComingSoonView` (Home / Library /
  Community / Profile). Home greets the user/guest by name.
- **`ProfileMenuView`** — the "Profile menu" screen: an account header card + grouped option
  rows (Edit profile, My collection, My lists, Achievements · Settings, Help, About) + the
  **session actions moved out of Home** (guest → *Create an account* / *Exit guest mode*;
  signed-in → *Sign out*). Rows are placeholders pending the real destinations.
- **Note:** the profile-menu mockup didn't come through (the screenshot captured a file tree),
  so the menu options are sensible defaults — revisit when the real design lands.

### 2026-07-02 — Guest access + full app navigation flow mapped

The team drew the whole-app flow (`agents/app-flow.jpeg`) and added a **guest** entry point. Auth
is the last locked-in area; the app shell (Home / Library / Community / Profile) is next.

- **Session is now three-state, not a boolean.** `AuthStore` gained
  `enum SessionState { unauthenticated, guest, authenticated }` (was `isAuthenticated: Bool`).
  Derived flags: `isAuthenticated`, `isGuest`, `isInApp` (= guest **or** authenticated). `init`
  maps a stored Keychain token → `.authenticated`, else `.unauthenticated`. New `continueAsGuest()`
  sets `.guest` with no token/user; `authenticate(...)` → `.authenticated`; `logout()` →
  `.unauthenticated` (also the "exit guest" path — clearing an absent token is a no-op).
- **One app, not two.** `RootView` gates on `authStore.isInApp`, so guest and signed-in users
  render the **same** `Features/App` tree. **Do not** build a parallel "visitor app" — limitations
  are **capability checks at the point of the gated action** (read `authStore.isGuest`, prompt to
  create an account instead of calling the API). No gated actions exist yet (Home is a placeholder);
  the pattern lands with the first write feature (add-to-library).
- **UI:** `LoginView` got a lightweight **"Continue as guest"** text button (staggered index 7)
  calling `continueAsGuest()`. `HomePlaceholderView` adapts by session — guest sees
  "Welcome, guest!" + a **Create an account** / **Exit guest mode** pair (both `logout()` → back to
  Welcome); signed-in users keep the single **Sign out**.
- **Navigation flow** now documented in the shared `CLAUDE.md` (*App navigation & screen flow*):
  bottom tabs `Home · Library · Community · Profile`, a global header
  (`Notifications · Search · Profile menu`), Home → New Releases / New Anticipated, Community →
  My Community / Discover → Post details / Community details.

### 2026-06-29 — Password-reset wired to the real OTP backend + Remember-me removed

The backend shipped a real **3-step OTP** password reset (mobile branch). Replaced the mocks with
live `APIClient` calls and aligned the client to the verified contract. Full cross-client spec
(for the Android port) rewritten in **`agents/password-reset-flow.md`**.

- **Endpoints** (`Endpoint.swift`): `.forgotPassword` · `.verifyResetCode` · `.resetPassword`
  (all POST, no auth). Request models send **`client: "mobile"`** (`ForgotPasswordRequest`,
  `ResetPasswordRequest`) — without it the backend falls into the web email-link branch.
- **`AuthService`** real impls; signatures changed: `resetPassword(email:code:newPassword:)` (the
  old mocked `resetToken` is gone — the backend never returned one). `verifyResetCode` and
  `forgotPassword` now return `Void`. `MessageResponse` decodes `{ error?, message? }`.
- **Verify step is server-validated:** navigation to `ResetPassword` only happens after
  `verify-reset-code` returns 200, carrying `email`+`code` forward (not a token).
- **Error 400:** added `APIError.badRequest(String)` + a `case 400` in `APIClient.mapError` so the
  backend's `{ error: "Invalid code" | "Code expired" | "Code already used" }` surfaces as a real
  toast instead of "Unexpected error (code 400)".
- **Auto-login after reset:** `reset-password` returns **no token**, so `SuccessView`'s primary
  button calls `signInAfterReset(authStore:)` → `login` → `authStore.authenticate(...)` → Home.
  `AuthStore.authenticate`/`logout` now clear `isResetFlowActive` so the flag can't leak and
  re-trigger the reset flow on a later logout.
- **Password min = 6** on reset (backend `min:6`, aligned with register). Earlier 8-char rule
  reverted; `passwordTooShortReset` message removed.
- **Remember-me removed:** it was dead UI (never read; JWT in Keychain already persists the session).
  `RememberMeRow` → `ForgotPasswordRow` (keeps the "Forgot my password" link, trailing-aligned);
  `rememberMe` dropped from `LoginViewModel`.
- **Backend gotcha that bit us (resolved):** the `verified_at` column was added by *editing an
  already-applied migration*, so an existing DB needs `migrate:rollback` + `migrate` (a plain
  `migrate` shows nothing pending). Flagged to backend to use a fresh `ALTER` migration + to null
  `verified_at` when regenerating a code in `forgotPassword`.

### 2026-06-28 — Password-reset flow + success screen (auth UI completed, mocked)

Finished the remaining auth screens. The reset flow is **mocked client-side** because the
backend has no `password/forgot|reset` endpoints yet (see shared `CLAUDE.md`); structured so each
mock body swaps for a real `APIClient.request(...)` later. Full porting spec for the Android app:
**`agents/password-reset-flow.md`**.

- **New screens** (`Features/Auth/`): `ForgotPassword` (email → "Send code"), `VerifyResetCode`
  (6-digit OTP, auto-submits on the 6th digit, 30s resend countdown), `ResetPassword`
  (new + confirm password, reuses `PasswordStrengthMeter`). Generic reusable
  `Core/Components/SuccessView` (check badge, status card, **auto-redirect in 5s** + button)
  used both at the end of the reset flow and **after Register**.
- **New shared component:** `Core/Components/OTPField` (hidden `TextField` + digit boxes).
- **Mock service:** `AuthService` gained `forgotPassword` / `verifyResetCode` / `resetPassword`
  (artificial delay; any 6-digit code accepted; returns a fake reset token).
- **Navigation / pop-to-root:** the whole reset chain is gated by `AuthStore.isResetFlowActive`,
  which `LoginView`'s `navigationDestination(isPresented:)` is bound to. `SuccessView` sets it
  `false` to collapse the entire pushed chain back to Login. Reason: an `onChange` on a view that
  is **covered** in a `NavigationStack` does **not** fire — programmatic deep dismissal must be
  driven by an observable bound to the navigation, not local `@State` on the covered view.
- **Register success:** `signUp` now **defers** `authStore.authenticate(...)` — it stores the
  token/user, shows `SuccessView`, and authenticates only on the primary action (or auto-redirect),
  so the success screen is actually seen before Home swaps in.
- **Fixes found while polishing (all relevant to the Android port):**
  - `AuthScreenScaffold` bottom padding was invisible — `minHeight: geometry.size.height` made the
    `.padding(.bottom)` overflow below the scroll fold. Fixed with `minHeight: …height - bottomPadding`.
  - `ToastModifier` moved from `DispatchQueue.asyncAfter`(onAppear) to `.task(id: message)` so the
    timer **resets per message** and **cancels when the view disappears** (no "leaking"/lost toasts).
  - `ResetPassword` looked cramped with the keyboard up: removed the `Spacer` between form and
    button so title+form+button is one centered block (matches `create-new-password` ref).

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
