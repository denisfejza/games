# Pip's World

Learning games for children aged 2–7 in Albanian and English, guided by Pip the fox.
Built with Flutter for Android, iOS and the web. The web build is hosted on GitHub Pages.

- Product rules and stack: [CLAUDE.md](CLAUDE.md)
- Build plan and progress: [PLAN.md](PLAN.md)
- Decisions: [docs/adr/](docs/adr/) · Dependencies: [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) · Changelog: [docs/CHANGELOG.md](docs/CHANGELOG.md)
- Web preview (after the first deploy): https://denisfejza.github.io/games/

## Development

Requires Flutter 3.47 (stable). All commands run in `app/`:

```sh
cd app
flutter pub get
flutter run -d chrome        # or an Android/iOS device
flutter analyze
flutter test                 # unit, widget and golden tests
flutter test --update-goldens  # after an intended visual change (render on Linux)
dart run build_runner build  # after changing lib/core/storage/database.dart
flutter build web --release --no-web-resources-cdn --base-href /games/
dart run tool/audit_dependencies.dart   # child-safety audit (also in CI)
dart run tool/release_check.dart        # what's left before a store release
```

Content tools (run in `app/`): `python3 tool/vocab_table.py` (pictures + names), `python3 tool/levels_table.py`
(all levels, docs/CURRICULUM.md), `dart run tool/gen_lookup.dart` (string lookup), `dart run
tool/gen_recording_script.dart` (docs/RECORDING_SCRIPT.md), `./tool/subset_emoji.sh` (placeholder picture font).

Build flags: `PIP_DEBUG_MENU=true` adds the Pip demo to the grown-up area; `PIP_UNLOCK_ALL=true` opens every level
(the GitHub Pages preview uses both).

## What's in the app

- Map with six worlds; Pip the fox (drawn placeholder until the Rive file arrives) who talks, reacts to pokes,
  tickles and food, and repeats what children say (web; native plugin pending).
- 42 levels / 163 games across Animals, Numbers, Letters (per language), Shapes & Colours and Board Games, built on
  15 engines (docs/ENGINES.md); Pip's House with costumes and a sticker book unlocked by stars.
- Episodes: intro → 3–5 games → companion moment → off-screen challenge → wind-down. Mastery-based unlocks.
- Grown-ups (behind a number-in-words gate): progress, language, bilingual mode, age band, daily play time with
  bedtime, sound, captions, less motion, extra-large buttons, microphone, full version, privacy.
- Nothing leaves the device: no accounts, ads, analytics or network use (checked in CI).

Adding content: drop a JSON file in `app/assets/content/games/<world>/` that matches
`app/assets/content/schema.json`. A new folder also needs a line under `assets:` in `app/pubspec.yaml`.

## Deploying

Every push to `main` runs analyze, tests and the web build, then publishes to GitHub Pages
(`.github/workflows/deploy.yml`). One-time setup: **Settings → Pages → Source: GitHub Actions**.

## Earlier prototype

`apps/`, `packages/` and the root `package.json` hold the first TypeScript/Phaser prototype
(Animal Memory). It's no longer built or deployed; `pairs_memory` (PLAN 2.5) replaces it.
