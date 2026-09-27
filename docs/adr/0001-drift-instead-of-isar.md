# ADR 0001 — Drift instead of Isar for local storage

- Status: accepted (2026-09-27)
- Context: CLAUDE.md allows "Isar (or Drift)". The app must also run in the browser (GitHub Pages).

## Findings

- `isar` 3.1.0 (last release April 2023) requires Dart `<3.0.0`, so it doesn't resolve with Flutter 3.47 / Dart 3.13.
- `isar_community` 3.3.2 is maintained, but pub.dev lists no web support.
- `drift` + `drift_flutter` support Android, iOS, desktop and web (SQLite compiled to WebAssembly, stored in OPFS/IndexedDB).

## Decision

Use Drift. Mastery stats and child profiles sit behind small interfaces
(`MasteryStore`, `ProfileRepository`), so the storage engine can be swapped without touching games.

## Consequences

- The schema lives in `lib/core/storage/database.dart`. Run `dart run build_runner build` after changing it and commit the regenerated `database.g.dart`.
- Web needs `web/sqlite3.wasm` and `web/drift_worker.js`, whose versions must match the packages (see DEPENDENCIES.md).
