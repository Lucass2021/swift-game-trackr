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
- Same color/theme source in both apps, no hardcoded colors
# Mocks A: Fake repositories for screens without API (phase 3)
# Mocks B: Previews use MockData sample objects (phase 3)
# Standardize error display (toast vs inline field errors)
# Post detail: show comments inline below the post (Reddit-like) instead of a bottom sheet
# Security review
# Performance review
# Strict typing review (no Any or untyped data)
# E2E tests with tester-army/e2e
# Cache and refetch strategy (TanStack Query-like)
# Map partially implemented features (e.g. save posts)
# Remove personal placeholders (e.g. "lucasdias" in edit profile)
