# Testing Community + Posts Integration

Step-by-step guide to test the real API integration on both iOS and Android.

> Last updated: 2026-08-10.

---

## 1. Start the backend

```bash
cd ~/Projetos/game-trackr-api
docker compose up -d
```

Wait for both containers (`app` and `db`) to be healthy. Verify:

```bash
curl http://localhost:8000/api/communities
# Should return: {"data":[], "current_page":1, ...}
```

If the database hasn't been migrated yet:

```bash
docker compose exec app php artisan migrate
```

---

## 2. Seed test data (optional but recommended)

Login or create an account first:

```bash
# Register a test user
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"TestUser","email":"test@test.com","password":"password","password_confirmation":"password"}'
```

Save the `token` from the response. Then create a community and a post:

```bash
TOKEN="<paste-token-here>"

# Create a community
curl -X POST http://localhost:8000/api/communities \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"EldenRingFans","description":"Discussing all things Elden Ring"}'

# Create a post (use the community_id from the response above)
curl -X POST http://localhost:8000/api/posts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"First post!","description":"Testing the community integration","community_id":1}'
```

---

## 3. Test on iOS

### Prerequisites
- Xcode with iPhone 17 Pro simulator
- Backend running on localhost:8000

### Steps

1. Open `GameTrackr.xcodeproj` in Xcode
2. Run on iPhone 17 Pro simulator
3. Log in with the test account (test@test.com / password)
4. Navigate to the **Community** tab

### What to verify

| Action | Expected |
|--------|----------|
| Open Community tab | Feed loads from API (or shows empty state if no posts) |
| Switch to Discover | Search field, category chips, then "All communities" — all loaded from API. There is **no** Featured carousel (removed 2026-08-10) |
| Type in the Discover search / pick a chip | The single list filters; nothing above it stays unfiltered |
| Tap a community | Detail view opens, posts load from API, members load |
| Tap Join on a community | Button toggles instantly, API call syncs in background |
| Tap the Like button on a post | Count updates instantly, syncs with API |
| Open post detail | Comments load from API |
| Type a comment and submit | Comment appears in list, sent to API |
| Tap "New post" (FAB) | Create topic form shows joined communities from API |
| Submit a new post | Post appears at top of feed, created via API |

### If API is down
- Feed and communities fall back to mock data
- Like/join/comment actions will optimistic-update then revert on failure

### Config
iOS connects to `http://localhost:8000/api` by default (see `Config.swift`).
The iOS Simulator shares the Mac's network — no special config needed.

---

## 4. Test on Android

### Prerequisites
- Android Studio with emulator
- Backend running on localhost:8000

### Steps

1. Open `kotlin-gametrackr` in Android Studio
2. Run on emulator
3. Log in with the test account
4. Navigate to the **Community** tab

### Same verification checklist as iOS above

### Config
Android Emulator uses `10.0.2.2` to reach the host's localhost.
This is already set in **`config/debug.properties`** (repo root, not `app/`), which
`app/build.gradle.kts` reads into `BuildConfig.API_BASE_URL`.

If using a **physical device** instead of emulator, override it with your Mac's local IP in the
gitignored local file — it's loaded *after* the build-type file, so it wins:
```
# config/local.properties  (copy from config/local.properties.example)
API_BASE_URL=http://192.168.x.x:8000/api
```

---

## 5. Debugging

### Check API calls in Xcode
iOS: Filter the console for `[APIClient]` or check the Network tab in Instruments.

### Check API calls in Android Studio
Android: The `HttpLoggingInterceptor` logs all requests/responses in Logcat (filter: `OkHttp`).

### Common issues

| Issue | Fix |
|-------|-----|
| `401 Unauthorized` on community/post endpoints | Token expired. Log out and log in again. |
| Empty feed | No posts created yet. Seed data per step 2 above. |
| `Network failure` on iOS | Backend not running. Check `docker compose ps`. |
| `Connection refused` on Android | Using `localhost` instead of `10.0.2.2`. Check build config. |
| Like count doesn't update | The `likes` field in the API response returns the likes relationship, not the count after toggle. Check API response shape. |
