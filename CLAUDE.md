# GameTrackr iOS (Swift / SwiftUI)

## Context
## This project is for learning SwiftUI; keep the code simple, small and easy to read
## The Android twin lives in ~/Projetos/Kotlin-gametrackr (Jetpack Compose); every refactor batch is done in both projects with the same scope
## Keep the exact same names in both projects (files, types, functions, properties, folders); differ only where a language convention requires it (e.g. Kotlin const SCREAMING_CASE, Swift PascalCase folders)
## Product context, screens and history live in sessions/ and agents/PROJECT_GOALS.ios.md; reference designs in agents/screens-base-design/
## UX references: Reddit for community features (feed, posts, comments)

## Workflow
## Read the latest sessions/AAAA-MM-DD.md before starting; read older ones if needed
## Update the progress of each session in sessions/AAAA-MM-DD.md; these files must not be committed
## Never put credentials, tokens, keys, personal e-mails or private URLs in sessions/ or any committed file
## Work in small batches; propose design choices and the batch scope to the user and get an explicit ok before coding
## Never unstage or alter changes the user staged
## Create stashes as backups when needed

## Batch review flow
## When a batch is done in both apps, run the batch-reviewer agent (~/.claude/agents/batch-reviewer.md) with both repo paths and the approved batch scope; it has no shared context on purpose
## For UI batches, capture the affected screens first (Android: adb exec-out screencap -p; iOS: xcrun simctl io booted screenshot) and pass the screenshot paths and reference designs to the reviewer
## The reviewer answers APPROVED or a list of findings; fix the findings and review again; after 2 rounds without approval, stop and ask the user
## Once approved, stage and commit the batch (one commit per batch) and record the reviewer report in sessions/
## At the end of each phase, build an interactive HTML review page for the user (in Portuguese) in ~/Projetos/gametrackr-reviews/ with the phase changes and the reviewer reports; it lives outside both repos and is never committed
## The user does the final review of the whole refactor before the merge

## Git
## Commit only through the batch review flow or with explicit permission; always work on new branches for commits and pull requests
## Do not push without permission
## Follow the project pattern for branch names (feat/, fix/, refactor/, chore/, test/) and commits (conventional commits, lowercase, in English)
## Avoid large commits; one commit per batch
## Do not mention Claude or AI anywhere; never add "Co-Authored-By: Claude" or similar lines
## Do not commit sessions/
## Do not modify CLAUDE.md or TODO.MD without permission; keep TODO.MD short, details go in sessions/

## Architecture (MVVM)
## View: XView.swift receives its ViewModel/state and forwards user actions; it never calls services or APIClient
## ViewModel: XViewModel.swift is an @Observable @MainActor class with the screen state and plain functions for user actions (submit, onEmailChange...)
## Model: repositories (protocol + implementation) own network/cache; DTOs and mappers stay in the data layer; domain models in Models/
## Mocks for screens without API live as Fake repositories (FakeXRepository + XMockData) and are reused by previews and tests
## Dependencies are injected through init; no .shared singletons inside ViewModels
## Screen folders: Features/<Area>/<Screen>/ with XView, XViewModel and Components/
## Keep files under ~200 lines; extract components into Components/ when a file grows past that
## Every component and screen has a #Preview
## Follow the project architecture and existing patterns whenever possible

## Code style
## Do not add comments
## All text must be in English: code, UI strings, commits, CLAUDE.md, TODO.MD, sessions/ and any other .md file
## Avoid magic numbers; use named constants (private enum Constants with static let, or shared spacing/time tokens)
## Use the theme tokens Spacing, Radius and Durations (Core/Theme); off-scale values round to the nearest token (ties round down); one-off sizes become named private constants in their file
## Avoid hardcoded colors like Color(hex: "#E36E1C"); add missing colors to Core/Extensions/Color+App.swift
## Form submit buttons are always enabled; on tap, validate and show what is missing instead of disabling the button

## API
## The backend lives in ~/Projetos/game-trackr-api; use it only as reference, never change its code (Docker setup excepted, with permission)
## Always run git fetch --all in the backend before analyzing it, to see the latest code
## The API runs locally via Docker on port 8000; the simulator reaches it at localhost (override in Config/Local.xcconfig)

## Tests
## Keep one unit test for each ViewModel, mapper and component logic
## Every bug fix comes with a regression test that reproduces the fixed scenario
## Respect the lefthook pre-commit hooks (swiftformat, swiftlint and tests); fix failures instead of skipping them

## Tools
## If claude-in-chrome is used, do not modify anything sensitive (e.g. Figma)
