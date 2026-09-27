# CLAUDE.md — Pip's World (educational game app, ages 2–7)

Read this file before every task. It defines the product, stack, and non-negotiable rules.

## What we are building
A cross-platform (iOS, Android, tablet-first) educational game app for children aged 2–7.
An animated animal companion, **Pip** (a fox), guides short 3–8 minute learning episodes.
The main menu is a map with **worlds**; each world has **levels**; each level has 3–5 mini-games.

Worlds (main menu): Animals · Numbers · Letters · Shapes & Colours · Board Games · Pip's House (companion play).

Languages: **Albanian (sq) and English (en)** from day one, plus a bilingual mode. All content is data-driven and localized; never hard-code strings or audio paths.

## Tech stack (do not change without asking)
- Flutter (stable) + **Flame** for games + **Rive** for Pip and interactive objects
- State: Riverpod. Local DB: Isar (or Drift). Localization: `flutter_localizations` + ARB files with ICU plurals.
- Audio: `audioplayers` (narration/SFX). Mic + pitch-shift + voice-activity detection via a small native plugin (Kotlin/Swift) behind a Dart interface.
- IAP: `in_app_purchase`. No third-party analytics, ads, attribution, or crash SDKs in the child-facing app.
- Tests: `flutter_test`, `flame_test`, golden tests for UI, integration tests for one full episode.

## Repo layout
The Flutter project lives in `app/` (run `flutter` commands there); `docs/` is at the repo root. See docs/adr/0002.
```
lib/
  app/            # app shell, routing, theme, locale
  core/           # audio, storage, parental gate, mastery tracker, voice service interfaces
  content/        # JSON activity/level definitions + loader + schema validation
  games/          # one folder per mini-game (Flame components)
  worlds/         # world maps, level select
  companion/      # Pip Rive controller, state machine bindings, reactions
  parent/         # parent dashboard, settings, timer, purchases
assets/
  rive/  audio/{en,sq}/  images/  content/{worlds,levels,games}/*.json  fonts/
test/
docs/             # this plan, design decisions (ADRs), curriculum map
```

## Hard rules (compliance & child safety)
1. **No personal data leaves the device.** No accounts for children. Child profile = nickname + avatar + age band, stored locally only.
2. **Microphone audio is processed in memory, played back, and discarded immediately.** Never write it to disk or send it anywhere. App must work fully with the mic off.
3. **Parental gate** (`core/parental_gate`) in front of: settings, purchases, external links, permission prompts, parent dashboard.
4. **No ads, no loot boxes, no random rewards, no timers or lose states for ages 2–5, no streak-loss, no "come back tomorrow", no autoplay into the next episode.** Rewards unlock by mastery only.
5. Pip never begs, shames, cries, or mentions purchases. Errors make Pip curious, never sad.
6. Every episode ends at a natural stopping point with a wind-down option.
7. Target stores: Apple Kids Category and Google Play Families. Assume every store rule applies.

## Pedagogy rules (apply to every mini-game)
- Score each game on the four pillars before shipping: **active, engaged, meaningful, socially interactive** (0–3 each). Minimum 2 on each. Record the score in the game's JSON.
- Scaffolding: show hint after 1 wrong tap at level 1, after 2 at level 2, never at level 3. Fade support as the child succeeds.
- Adaptive difficulty: 3 correct in a row → raise one parameter; 2 wrong → lower one and give a hint.
- Feedback within 100 ms of every touch. Specific praise ("You counted every duck!"), short celebration (< 2 s).
- Repetition with variation: the same concept must appear in at least 3 representations across a world.
- Each level ends with an **off-screen challenge** ("Hop like a rabbit and show a grown-up!").

## UI/UX rules
- Min touch target 2 cm (≈ 76 dp on phone, larger on tablet). Wide spacing. Reject palm touches (large contact area) and debounce repeat taps.
- Gestures allowed: tap, big drag, swipe. **Never**: pinch, long-press, double-tap, multi-finger, precise small drags.
- No text reliance for children. Every button has an icon and speaks its function on first tap. A "hear again" button on every screen.
- One focal animation at a time. No background animation while the child is deciding. Music ducks under narration.
- Reduced-motion mode, captions for narration, colour-blind-safe cues (never colour alone outside colour lessons).
- Age bands drive art and difficulty: **2–3**, **4–5**, **6–7**. Older kids must not see "baby" content.

## Localization rules
- Every user-visible string is an ARB key. Every narration line is an audio asset keyed `audio/{locale}/{key}.ogg`. Use ICU `plural` for counts. **Never concatenate sentence fragments** (Albanian nouns decline: qen/qeni).
- Albanian alphabet = 36 letters. The digraphs **dh, gj, ll, nj, rr, sh, th, xh, zh** are single letters: one tile, one tracing path, one sound. Letters/phonics content is per-language (`content/letters/{locale}.json`); English phonics order must not be reused for Albanian.
- Fonts must render ë, ç, Ë, Ç. Leave 30% extra width in buttons for Albanian text.
- Standard Albanian for all narration; record native voice actors. Speech recognition for Albanian is unreliable: use voice-activity detection ("child made a sound") and reward the attempt.

## Content data model (all games read from JSON)
```json
{
  "id": "animals.farm.l1.who_says_moo",
  "world": "animals", "level": 1, "game": "sound_match",
  "ageBands": ["2-3","4-5"],
  "skills": ["vocab.animals.farm", "listening"],
  "curriculum": {"eyfs": ["UW-NaturalWorld"], "ccss": [], "al": ["Fusha: Bota rreth nesh"]},
  "params": {"choices": 2, "items": ["cow","sheep","pig","hen"], "rounds": 5},
  "difficulty": {"raiseAfter": 3, "lowerAfter": 2, "steps": [{"choices":2},{"choices":3},{"choices":4}]},
  "pillars": {"active":2,"engaged":3,"meaningful":2,"social":2},
  "offscreen": "offscreen.walk_like_penguin"
}
```
Validate all JSON against `content/schema.json` in a test. A new level should require **zero Dart changes** if it uses an existing game type.

## Level & progression rules
- Each world: 6–10 levels. Each level: 3–5 mini-games + one companion moment + one off-screen challenge.
- Level unlock = mastery of the previous level's skills (≥ 80% independent completion), not time or currency.
- Stars are for mastery (1 = completed, 2 = completed with ≤ 2 hints, 3 = completed with no hints). Never show a 0-star or "failed" state.
- Rewards: stickers for Pip's House and Pip costumes, unlocked by stars.

## Working conventions for Claude Code
- Work in small PR-sized tasks. Each task in PLAN.md has acceptance criteria; run `flutter analyze` and `flutter test` before finishing.
- New mini-game = new folder under `lib/games/<name>/` with `<name>_game.dart`, `<name>_config.dart` (parses JSON params), `<name>_test.dart`, and a golden.
- Use `ContentLoader` for all content; use `AudioService.say(key)` for all narration; use `MasteryTracker.record(skill, correct, hintsUsed)` after every round.
- Placeholder art/audio: generate simple vector shapes and TTS-free beeps; mark with `// TODO(asset)`. Never ship placeholders.
- Do not add packages without listing them in `docs/DEPENDENCIES.md` with a note that they are child-safe (no ads/analytics/network).
- When unsure about pedagogy or compliance, stop and ask instead of guessing.
