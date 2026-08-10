# Code quality
- Better var name eg: StarRatingView
- **Unify the chip components** — there are 6 independent implementations:
  `GameInfoChip` + `GameGenreChip` (GameDetail), `LibraryFilterChips`, `SearchFilterChips`,
  `AchievementFilterChips`, `CommunityChipRow`. Only the last one is shared.
- Two Functions/components in the same file
- **Improve Share game function** — `ShareLink` now exists on game detail, profile, stats,
  community detail and post detail, but every one shares **plain text only**. Real sharing needs a
  canonical URL per entity from the backend/web app (and ideally a preview image).
- Tests — still the Xcode template (`GameTrackrTests.swift` is 17 lines of boilerplate)
- `CommunityEmptyState` is used outside Community (Library, My Setup) — rename to `AppEmptyState`
- `CommunityEmptyState` top padding is asymmetric on iOS (`.padding(.top, 60)`) but symmetric on
  Android (`vertical = 60.dp`), so centering it needs different code per platform

# API integration (blocked — no backend yet)
- Games / Discovery (needs IGDB/RAWG server-side)
- Library (core MVP — no controller exists)
- Profile update (only GET /profile/me, no PATCH)
- Stats (no aggregation endpoint)
- Notifications
- Change password (in-app flow, not OTP reset)
- Achievements
- **My Setup / Collection** — UI is done on both clients but data is in-memory only and lost on
  restart. Needs `GET/POST/PATCH/DELETE /me/collection` + image upload. Swap points are the
  hoisted state holders in `MainTabView` / `MainTabScreen`.

# Missing screens (no backend either)
- Friends
- Messaging / Conversations
- New Releases (full list from Home)
- Most Anticipated (full list from Home)
- Game Lists
- Activity Feed

# Implement 
- https://youtu.be/In-QCYl06_Q?si=b7pouWVxatm475v4
- https://youtu.be/XdhI-Dnnrmg?si=kLwRgOv0hyxc4gN6
