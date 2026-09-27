# Changelog

## Unreleased

- Phase 2: eight game engines (sound_match, drag_to_target, tap_count, trace_path, pairs_memory,
  sequence_pattern, sort_bins, blend_tiles) on a shared Flame kit; docs/ENGINES.md.
- Phase 1: Pip companion (moods, event mapping, placeholder full-body fox, Rive adapter per docs/PIP_RIVE_SPEC.md,
  lip-flap while narrating); poke/tickle/feed reactions; talk-back (VAD, +6 semitone echo, in-memory only, web
  implementation, native pending); level path with stars and mastery-based unlocks (faded, never padlocked);
  episode runner (intro → games → companion → off-screen → wind-down); daily play limit with bedtime screen that only
  a grown-up can dismiss; parent area replaces the debug menu; settings persist on the device.
- Content foundations: vocab table (118 items), generated string lookup, PipEmoji placeholder font, placeholder
  audio, recording script.
- More colourful map: one patterned colour stripe per world, sticker-style world tiles with drawn pictures,
  ribbon title, wavy ground with a placeholder Pip (tap him to hear the greeting); world screens use their
  world's colour. Glossy `BigButton`, new sticker style; goldens regenerated.
- 0.1 Flutter project `pips_world` in `app/` with Flame, Rive, Riverpod, Drift, flutter_localizations, audioplayers,
  in_app_purchase; map screen; `docs/DEPENDENCIES.md`; GitHub Pages deploys the web build.
- 0.2 en/sq ARB files with ICU plurals, Nunito font (ë/ç), `LocaleSwitcher` in the gated debug menu; test that en and sq
  have the same keys and placeholders.
- 0.3 `ContentLoader` + `assets/content/schema.json`; six worlds and the CLAUDE.md example game as the first fixture.
- 0.4 `AudioService` (queue, ducking, hear again, captions), `MasteryTracker` (Drift store), `ChildProfile`
  repository, `ParentalGate` (three-digit number written as words in en/sq).
- 0.5 `BigButton`, `PalmRejectingGestureDetector`, reduced-motion flag, `CaptionBar`, age-band colour tokens, golden
  tests for `BigButton` in en/sq at phone and tablet sizes.
