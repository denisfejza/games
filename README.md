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
```

Adding content: drop a JSON file in `app/assets/content/games/<world>/` that matches
`app/assets/content/schema.json`. A new folder also needs a line under `assets:` in `app/pubspec.yaml`.

## Deploying

Every push to `main` runs analyze, tests and the web build, then publishes to GitHub Pages
(`.github/workflows/deploy.yml`). One-time setup: **Settings → Pages → Source: GitHub Actions**.

## Earlier prototype

`apps/`, `packages/` and the root `package.json` hold the first TypeScript/Phaser prototype
(Animal Memory). It's no longer built or deployed; `pairs_memory` (PLAN 2.5) replaces it.
