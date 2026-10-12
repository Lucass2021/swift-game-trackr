# Connect API
# Refactor layers based on MVVM
# Improve caching
# Remove mocks
# Review arch
# Tests
# Code quality manual review
# Fix login error messages
# Foundation: constants, cleanup, test setup, fake repositories
# File length lint rule (200 lines)
# Data layer: repositories and constructor injection
# Screen by screen MVVM refactor with previews and tests
# Navigation and app shell
# Review community best practices
# Native features for UX (widgets, push notifications, shortcuts)
- Home screen widget "playing now" (WidgetKit)
- Push notifications for likes and comments (APNs, needs API support)
- App Intents, Shortcuts and Spotlight
- Live Activities
- Haptics
# Reusable styles (ViewModifier)
# Component organization rule
# System design review
- Image cache (SwiftUI AsyncImage has no disk cache)
- Feed cache TTL
- Offline mode (SwiftData)
- Token refresh
- Pagination
- Centralized error mapping
# Design system parity between apps
# Mocks A: Fake repositories for screens without API (phase 3)
# Mocks B: Previews use MockData sample objects (phase 3)
