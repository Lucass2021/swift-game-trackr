# Missing Screens

> Last checked: 2026-08-10. Both iOS and Android are in parity for existing screens.

---

## Screens that exist (iOS + Android, in parity)

### Auth stack (complete)
Splash, Welcome, Login, Register, Forgot Password, Verify OTP, Reset Password, Success

### App shell + internal screens (complete)
Home, Library, Community, Profile, Search, Notifications, Profile Menu,
Game Detail, Edit Profile, Stats, Settings, Change Password, About, Help,
Achievements, Game Achievements, User Profile, Community Detail, Post Detail,
Create Topic, Discover Communities, **My Setup**, **New/Edit Setup**

---

## Screens still missing

| # | Screen | Description | Backend ready? |
|---|--------|-------------|----------------|
| 1 | **Friends** | Friend list, pending requests, accept/decline/remove | No |
| 2 | **Messaging / Conversations** | Conversation list + 1-to-1 chat (realtime via Reverb) | No |
| 3 | **New Releases (full list)** | "See All" screen from Home's new releases section | No (no Games endpoints) |
| 4 | **Most Anticipated (full list)** | "See All" screen from Home's most anticipated section | No (no Games endpoints) |
| 5 | **Game Lists** | User-curated lists (e.g. "Top 10 RPGs") | No |
| 6 | **Activity Feed** | Feed of friend activity ("Lucas completed Elden Ring") | No |

### Built but not persisted

| Screen | State | Blocker |
|--------|-------|---------|
| **My Setup** + **New/Edit Setup** | Shipped on both clients 2026-08-10. Real device photos (max 6, downsampled to 1200px), title, description, delete | No `/me/collection` endpoint — data is hoisted UI state and is **lost on app restart** |

This replaced the old "Physical Collection" row. The screens exist and work; only persistence is
missing, so it's an API task now, not a screen task.

---

## Suggested build order (per CLAUDE.md roadmap phases)

1. **Friends** — phase 4 (profiles + friends). TODO.MD lists this as next.
2. **New Releases / Most Anticipated full lists** — phase 3 (discovery). Home sections already exist, just need the "see all" destination.
3. **Messaging** — phase 6 (realtime). Depends on Reverb setup.
4. **Game Lists + Activity Feed** — secondary features, no phase assigned.

Phase 7 (**Collection**) is no longer a screen task — see *Built but not persisted* above.
