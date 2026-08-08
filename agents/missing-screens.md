# Missing Screens

> Last checked: 2026-08-06. Both iOS and Android are in parity for existing screens.

---

## Screens that exist (iOS + Android, in parity)

### Auth stack (complete)
Splash, Welcome, Login, Register, Forgot Password, Verify OTP, Reset Password, Success

### App shell + internal screens (complete)
Home, Library, Community, Profile, Search, Notifications, Profile Menu,
Game Detail, Edit Profile, Stats, Settings, Change Password, About, Help,
Achievements, Game Achievements, User Profile, Community Detail, Post Detail,
Create Topic, Discover Communities

---

## Screens still missing

| # | Screen | Description | Backend ready? |
|---|--------|-------------|----------------|
| 1 | **Friends** | Friend list, pending requests, accept/decline/remove | No |
| 2 | **Messaging / Conversations** | Conversation list + 1-to-1 chat (realtime via Reverb) | No |
| 3 | **Physical Collection** | Catalog of physical items (consoles, peripherals, collectibles) with image upload | No |
| 4 | **New Releases (full list)** | "See All" screen from Home's new releases section | No (no Games endpoints) |
| 5 | **Most Anticipated (full list)** | "See All" screen from Home's most anticipated section | No (no Games endpoints) |
| 6 | **Game Lists** | User-curated lists (e.g. "Top 10 RPGs") | No |
| 7 | **Activity Feed** | Feed of friend activity ("Lucas completed Elden Ring") | No |

---

## Suggested build order (per CLAUDE.md roadmap phases)

1. **Friends** — phase 4 (profiles + friends). TODO.MD lists this as next.
2. **New Releases / Most Anticipated full lists** — phase 3 (discovery). Home sections already exist, just need the "see all" destination.
3. **Messaging** — phase 6 (realtime). Depends on Reverb setup.
4. **Collection** — phase 7.
5. **Game Lists + Activity Feed** — secondary features, no phase assigned.
