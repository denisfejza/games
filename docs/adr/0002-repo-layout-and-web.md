# ADR 0002 — Flutter app in `app/`, web build on GitHub Pages

- Status: accepted (2026-09-27)

## Context

The repo already contained an earlier TypeScript/Phaser prototype (`apps/`, `packages/`, root `package.json`).
The Flutter project could not be generated at the repo root without touching those files.

## Decision

- The Flutter project lives in `app/`. The CLAUDE.md layout (`lib/`, `assets/`, `test/`) applies inside `app/`;
  `docs/` stays at the repo root.
- GitHub Pages serves the Flutter web build (`flutter build web --base-href /games/ --no-web-resources-cdn`).
  It's a preview of the app for testing in a browser; the stores get the Android/iOS builds.
- The TypeScript prototype is no longer built or deployed. Its code is still in the repo until the owner decides to delete it.

## Consequences

- Run Flutter commands from `app/` (`cd app && flutter test`).
- Web limitations to keep in mind: no in-app purchases, no native mic plugin (talk-back must degrade gracefully),
  and Safari has limited `.ogg` support, so narration format needs checking before release (see PLAN 6.1).
