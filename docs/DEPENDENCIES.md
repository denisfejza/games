# Dependencies

Every package in `app/pubspec.yaml` must be listed here with a child-safety note
(CLAUDE.md: no ads, analytics, attribution, crash reporting or network use in the
child-facing app). Update this file in the same change that adds a package.

## Runtime

| Package | Version | License | Why | Child-safety note |
| --- | --- | --- | --- | --- |
| `flame` | ^1.38.2 | MIT | 2D game engine for the mini-games | No network, ads or analytics. |
| `rive` (+ `rive_native`) | ^0.14.11 | MIT | Pip and interactive animations | Prebuilt native libraries are downloaded at **build time**. **On the web, the runtime would download its WebAssembly from cdn.jsdelivr.net** unless built with `--dart-define=RIVE_NATIVE_WASM_HOST=<our path>`; `pip_rive.dart` refuses to start Rive on the web without it (falls back to the drawn Pip). Rive files must embed their images/fonts — CDN-hosted Rive assets are not allowed. |
| `flutter_riverpod` | ^3.4.3 | MIT | App state | Pure Dart. |
| `drift`, `drift_flutter` | ^2.35.0, ^0.3.1 | MIT | On-device database (mastery, profiles). Chosen over Isar, see [ADR 0001](adr/0001-drift-instead-of-isar.md). | Local SQLite only. On web it needs `app/web/sqlite3.wasm` (from sqlite3.dart 3.5.2) and `app/web/drift_worker.js` (from drift 2.35.0), served from our own site. **Update both files whenever `sqlite3` or `drift` is upgraded.** |
| `audioplayers` | ^6.8.1 | MIT | Narration, sound effects, music | Pulls in `http` for URL sources. We only ever use `AssetSource` (bundled files). The 5.4 audit should flag any `UrlSource`. |
| `in_app_purchase` | ^3.3.1 | BSD-3-Clause | One-time full unlock (PLAN 5.2) | Talks only to the App Store / Google Play billing, and only after the parental gate. No web support; the purchase UI must be hidden on web. |
| `flutter_localizations`, `intl` | SDK, ^0.20.3 | BSD-3-Clause | en/sq strings, ICU plurals | Pure Dart. |
| `json_schema` | ^5.2.2 | BSL-1.0 | Validates content JSON against `assets/content/schema.json` | Pulls in `http` to fetch remote `$ref`s; our schema has none, so it never fetches anything. |
| `web` | ^1.1.1 | BSD-3-Clause | Browser microphone for talk-back (Web Audio, MediaRecorder) | Dart team package. Audio stays in memory (Blob), is played back once and discarded; nothing is uploaded or stored. Mic permission is only requested from the parent area. |
| `clock` | ^1.1.3 | Apache-2.0 | Testable time for tap debouncing | Pure Dart (Dart team). |
| `cupertino_icons` | ^1.0.8 | MIT | Flutter template default | Font only. |

## Development only (not shipped)

`flutter_test`, `flutter_lints`, `flame_test`, `drift_dev`, `build_runner`, `fake_async`.

## Other bundled assets

| Asset | License | Note |
| --- | --- | --- |
| PipEmoji font (`app/assets/fonts/PipEmoji.ttf`) | SIL OFL 1.1 (`NotoColorEmoji-OFL.txt`) | **Placeholder art.** A 250 KB subset of Noto Color Emoji built by `tool/subset_emoji.sh`, so pictures look the same on every device until the illustrations arrive. |
| Sounds (`app/assets/audio/{sfx,babble,music}/*.mp3`) | Generated here | Synthesized by `app/tool/make_sounds.py` (numpy/scipy/soundfile, dev machine only): interface effects, cartoon animal noises, Pip's babble voice (a stand-in while narration isn't recorded, not TTS) and the meadow music loop. Recordings and a real score replace them later. |
| Nunito font (`app/assets/fonts/`) | SIL OFL 1.1 (`OFL.txt`) | Static Regular/ExtraBold instances cut from the Google Fonts variable font. Covers ë, ç, Ë, Ç. |

## Build flags

- Web builds use `--no-web-resources-cdn`, so Flutter's renderer (CanvasKit) is
  served from our own site instead of Google's CDN.
