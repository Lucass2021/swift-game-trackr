# GameTrackr — Testing Strategy (iOS)

> Companion to `CLAUDE.md` (shared product/API context) and `agents/PROJECT_GOALS.ios.md`.
> The Android repo carries the mirrored version of this file at the same path.
> **Written 2026-09-05**, right before the big refactor, so the tests exist *before* the code moves.

---

## Why now

Every route the API exposes is wired on both clients. The next step is a refactor — which is
exactly the moment a codebase without tests silently regresses. The goal here is **not** a
coverage number; it is a **safety net shaped like the bugs this project actually had**.

Baseline at the time of writing: **0 real tests** (only the Xcode template stubs).

---

## Principle: test by risk, not by file

The instinct — "one unit test per component" — produces a lot of tests that assert a `Text` is on
screen and catch nothing. Instead, every test in this project should be traceable to one of:

1. **A bug that already happened** (they are all catalogued in `CLAUDE.md`).
2. **A contract with a backend we don't own** (IGDB shapes, Laravel error bodies).
3. **A state machine** (loading / loaded / error / paginating).

If a test doesn't fit one of those three, it's probably not worth writing.

### The bug catalogue → the test list

These are real regressions this project shipped. Each one becomes a test:

| Bug that happened | Test that would have caught it |
| --- | --- |
| `auth/validate` returned `200 {"user": null}` on an expired token → "logged in as nobody" | Session bootstrap must use `/profile/me` and must log out on 401 |
| Public routes personalise from the token and never 401 → joined community rendered as "Join" | Expired JWT triggers a proactive refresh *before* the request goes out |
| `DELETE /communities/{id}` answers **401 for "not the author"** — same code as an expired token | 401 **with** an `error` key → `.forbidden`; 401 **without** → `.unauthorized` |
| Page 1 duplicated while paginating | Reset path sets loading; scroll effect can't fire on an empty layout |
| IGDB omits absent keys instead of sending `null` | Decode a payload with no `cover` / no `first_release_date` |
| `first_release_date` is a Unix timestamp, not ISO 8601 | DTO → domain date mapping |
| `meta` is nested and keyed `page` (unlike the flat Laravel `current_page`) | Both paginated shapes decode into the same model |
| Duplicate community name → **500 with raw SQL**, not 422 | 500-on-create maps to "That name may already be taken." |

---

## The five layers

### Layer 1 — Pure logic · target 90–100%

No network, no UI, runs in milliseconds. **Start here.**

- `JWT.isExpired` — leeway, malformed token, missing `exp`, base64url padding
- `APIError.init(statusCode:)` and the 401-with-`error` branch
- `Game.init(dto:)` / `GameDetail.init(dto:)` — missing keys, Unix timestamps, platform slugs
- `PaginatedResponse` decoding — both the nested `meta.page` and flat `current_page` shapes
- `PaginationState` — `canLoadMore`, `append`, `reset`, `restore`, index guards
- `FeedCache` — 5-minute TTL, key identity (scope + search + platform)
- ViewModel validation (`nameError`, `emailError`, `passwordError`, `confirmPasswordError`, `termsError`)
- `EditProfileModel` — username charset, length limits, `hasChanges`
- Community handle derivation (the whitespace-stripping the backend does)

### Layer 2 — ViewModels against a fake service · target ~80%

Assert **state transitions**, not pixels: `isLoading` → data → `failed`, the `force` guard, the
pagination reset on filter change, the optimistic like/join rollback on error.

Every ViewModel takes its service through `init` (see *Phase 0* below), so the test injects a fake.

### Layer 3 — Contract / decoding tests ⭐

The highest-value non-unit layer for this project, because the API is owned by someone else and
IGDB shapes are hostile.

- Real JSON captured from the running API lives in `GameTrackrTests/Fixtures/`.
- A `URLProtocol` stub replays it — no network, no backend running, safe in CI.
- `APIClient` takes an injected `URLSession` and `baseURL`, so the whole stack
  (request building → status mapping → decoding) is under test.
- Refresh-on-401 and refresh-on-expired-JWT are tested here, including the single-flight guard
  (two concurrent 401s must produce **one** refresh call).

**Re-capture the fixtures whenever the backend changes.** A stale fixture is worse than no test.

### Layer 4 — Snapshot tests · ~20 components

The cheap replacement for E2E, and the actual safety net for the refactor.

- **swift-snapshot-testing** (Point-Free), via SPM.
- Cover only shared components with real states: `GameCoverArt` (the three states: loading /
  no-artwork gradient / loaded), post card, platform chips, profile header, empty states.
- **Do not snapshot** whole screens, or anything animated — `SubtleBounce` / `SubtlePulse` make
  snapshots flake. Pin one device + one OS version in CI.

### Layer 5 — What we deliberately do NOT test

- **E2E / XCUITest flows** — rejected: too slow, too flaky, too expensive to maintain for a
  practice project. Layer 4 covers the visual regression risk at ~1% of the cost.
- DI wiring, design tokens, `#Preview` bodies, one-line extensions.
- Anything mock-backed that has no API yet (Library, My Setup) — it will be rewritten when the
  endpoints land. Test it *after* it talks to the backend.

Exclude all of the above from the coverage metric, or the number lies.

---

## Coverage

- Measure with `xcodebuild -enableCodeCoverage YES`, report via `xccov`.
- **Phase 1 and 2: measure, don't gate.** Get a real number first.
- Gate only once it's stable, and gate by area, not globally:
  - `Core/` (Network, Auth, Pagination, Models) → **90%**
  - `Features/*/ViewModel` → **80%**
  - Views → **not measured**
- Coverage is a smoke detector, not a goal. A 100% covered `EditProfileModel` with no assertion
  about the username charset is worth less than one test that checks it.

---

## Benchmarks — capture the baseline BEFORE the refactor

iOS has weaker tooling than Android here. Keep it small and honest.

- `XCTApplicationLaunchMetric` — cold start, in the UI test target.
- `measure { }` in a unit test — decoding a 100-game payload, and `Game.init(dto:)` over it.
  This one is fast, stable, and the most likely to actually regress in a refactor.

**Rules so the numbers mean something:**

- Always the **same physical device**, never the Simulator — Simulator variance (30%+) makes the
  number noise.
- Record results in `agents/BASELINE.md` with date, device, OS and app version.
- **Never gate CI on a benchmark.** Use it as a manual before/after comparison.
- ⚠️ `FeedCache`'s 5-minute TTL will falsify any feed benchmark — the second run makes no request.
  Call `invalidate()` in the setup, or pass `force: true`.

---

## Roadmap

| Phase | What | Status |
| --- | --- | --- |
| **0** | Dependency injection so ViewModels/services are constructible with fakes | ✅ done 2026-09-05 |
| 1 | Layer 1 tests + coverage measurement (no gate) | |
| 2 | Benchmark baseline recorded in `agents/BASELINE.md` | |
| 3 | Layers 2 and 3 (ViewModels + contract/fixtures) | |
| 4 | Layer 4 snapshots of shared components | |
| 5 | The refactor itself, with the net in place; turn the coverage gate on after | |

---

## Phase 0 — the iOS-specific prerequisite

Android got this for free: Koin already injects through the constructor
(`HomeViewModel(private val api: GameApi)`). iOS did not — ViewModels reached for singletons
(`GameService.shared`, `APIClient.shared`, `KeychainHelper` statics), so **no iOS ViewModel was
constructible with a fake**.

Phase 0 makes every seam injectable **without changing production behaviour**, by following the
convention `AuthService` already used: a protocol + a `static let live` + a defaulted `init`
parameter. Production call sites stay identical because the default *is* the live instance.

The seams:

| Seam | Protocol | Live instance | Why it matters for tests |
| --- | --- | --- | --- |
| Token storage | `TokenStorage` | `KeychainTokenStorage()` | The Keychain is unavailable/flaky in unit tests |
| HTTP | `APIClient(session:tokenStorage:baseURL:)` | `.shared` | Lets a `URLProtocol` stub drive Layer 3 |
| Games | `GameServicing` | `GameService.live` | Fakes for `HomeViewModel`, `SearchViewModel`, `GameDetailViewModel` |
| Community | `CommunityServicing` | `CommunityService.live` | Fake for `CommunityViewModel` |
| Profile | `ProfileServicing` | `ProfileService.live` | Fake for `EditProfileModel` |
| Google sign-in | `GoogleAuthenticating` | `GoogleAuthService.shared` | `ASWebAuthenticationSession` can't run headless |
| Clock | `FeedCache(now:)` | `Date.init` | Test the 5-min TTL without sleeping 5 minutes |

### What Phase 0 shipped

Every seam above is injectable, the app builds unchanged, and **23 tests** run in ~0.1 s:

```
GameTrackrTests/
  Support/
    InMemoryTokenStorage.swift   TokenStorage backed by a dictionary
    StubURLProtocol.swift        FIFO canned HTTP responses + recorded paths/headers
    Fakes.swift                  FakeGameService / FakeAuthService / FakeGoogleAuth,
                                 CallRecorder, TestData builders
  Core/
    APIClientTests.swift         decoding, IGDB's missing keys, 401→forbidden vs.
                                 401→refresh+replay, 422 first message
    FeedCacheTests.swift         TTL either side of 5 min, key identity, invalidate
    AuthStoreTests.swift         session bootstrap from storage, guest, logout
  Features/
    HomeViewModelTests.swift     load, failure, the force guard, retry after failure
    LoginViewModelTests.swift    errors only after submit, token persisted, Google cancel
```

Two things worth remembering when adding more:

- **`@Suite(.serialized)` is mandatory for any suite using `StubURLProtocol`.** Swift Testing
  runs tests in parallel by default, and the stub's response queue is static — without it the
  suites steal each other's responses and fail at random.
- **`FeedCache.init` is `nonisolated`.** Default arguments are evaluated in the *caller's*
  isolation, so a `@MainActor` initialiser used as a default (`cache: FeedCache = FeedCache()`)
  doesn't compile under Swift 6. Marking the init `nonisolated` (with a `@Sendable` clock) keeps
  the seam readable.

**Known debt Phase 0 does not fix:** several Views call `CommunityService` directly
(`CommunityDetailView`, `PostDetailView`, `PostCommentsSheet`, `CreateTopicView`). That network
code belongs in a ViewModel, but moving it is a behaviour-affecting refactor — it belongs to
Phase 5, not here.
