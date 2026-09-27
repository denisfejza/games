# PLAN.md — Pip's World build plan for Claude Code

Execute phases in order. Each task is one Claude Code session. Start every session with:
> "Read CLAUDE.md and PLAN.md. Do task X.Y. Run analyze + tests. Summarize what changed and what's left."

Tick tasks off here as they land. Estimates assume a solo dev + contract artist/voice; halve them for a team.

---

## Phase 0 — Foundation (Week 1–2)

**0.1 Scaffold**
Create the Flutter project (`pips_world`), add Flame, Rive, Riverpod, Isar, flutter_localizations, audioplayers, in_app_purchase. Create the repo layout from CLAUDE.md. Add `docs/DEPENDENCIES.md`.
- ✅ `flutter run` shows an empty map screen on iOS and Android; `flutter analyze` clean.
> ✔ Done 2026-09-27. Project is in `app/` ([ADR 0002](docs/adr/0002-repo-layout-and-web.md)); Drift instead of Isar ([ADR 0001](docs/adr/0001-drift-instead-of-isar.md)). Map screen verified in tests and in the web build; **not yet run on an iOS/Android device** (no emulator here).

**0.2 Locales + fonts**
Configure `en` and `sq` locales with ARB files; add a rounded child-friendly font that renders ë/ç; add a `LocaleSwitcher` in a debug menu.
- ✅ A test asserts every ARB key in `en` exists in `sq`; sample screen shows "Përshëndetje, Pip!" correctly.
> ✔ Done 2026-09-27. Font: Nunito (OFL). `LocaleSwitcher` is in the parent area (`lib/parent/parent_area.dart`), behind the parental gate.

**0.3 Content engine**
`ContentLoader` reads `assets/content/**/*.json`, validates against `content/schema.json`, exposes worlds → levels → games. Include the JSON example from CLAUDE.md as the first fixture.
- ✅ Unit tests: schema rejects a bad file; loader builds the world tree; adding a JSON level needs no Dart change.
> ✔ Done 2026-09-27. Levels come from the games' `world` + `level` fields; there is no `levels/` file type yet. Each new content folder needs one line in `pubspec.yaml` (Flutter assets aren't recursive).

**0.4 Core services**
`AudioService` (narration queue, music ducking, "hear again"), `MasteryTracker` (per skill: attempts, correct, hints; local Isar store), `ChildProfile` (nickname, avatar, age band, locale), `ParentalGate` widget (type a three-digit number spoken as words).
- ✅ Tests for mastery math and gate logic; gate cannot be bypassed by back navigation.
> ✔ Done 2026-09-27. The gate shows the number as words for the grown-up to read; no audio yet. `minAttemptsForMastery = 5` is a placeholder awaiting the educator (TODO(pedagogy)).

**0.5 Design tokens + kid widgets**
`BigButton` (≥ 76 dp, icon + spoken label on first tap), `PalmRejectingGestureDetector`, reduced-motion flag, caption bar, colour tokens for the three age bands.
- ✅ Golden tests for `BigButton` in en/sq at phone and tablet sizes.
> ✔ Done 2026-09-27. Goldens are rendered on Linux (matches CI); regenerate with `flutter test --update-goldens`.

---

## Phase 1 — Companion + Main Menu (Week 3–5)

**1.1 Pip Rive integration**
Load `assets/rive/pip.riv` with a state machine: `idle, listening, talking, happy, thinking, sleepy, celebrate`. `PipController` maps game events → inputs. Placeholder .riv with simple shapes until the artist delivers.
- ✅ Demo screen cycles all states; talking state lip-flaps from audio amplitude.
> ✔ Done 2026-09-27 with placeholder art: `PipController` + drawn fox; `RivePip` binds `mood`/`mouth` view-model numbers once `assets/rive/pip.riv` exists (spec: docs/PIP_RIVE_SPEC.md). Lip-flap is timed, not amplitude-driven, until recordings exist (TODO(asset)). Demo: parent area → Pip demo.

**1.2 Poke & react**
Tap Pip's nose/ears/belly/feet → named body part narration + reaction. Tickle = fast repeated taps → giggle. Feed = drag an item to mouth.
- ✅ Every tap responds < 100 ms; body-part names come from ARB + audio keys.
> ✔ Done 2026-09-27. Nose/ears/belly/feet/hands/mouth named from ARB + audio keys; 3 quick belly taps = tickle; drag food onto Pip to feed. Visual + sound response on the same frame as the tap.

**1.3 Talk-back (mic)**
Native plugin: record to memory buffer, pitch-shift +6 semitones, play back, discard buffer. Voice-activity detection exposes `onChildSpoke`. Permission is requested only via the parent area.
- ✅ No file written to disk (test asserts); app works with permission denied; buffer cleared after playback.
> ◐ Dart logic + web implementation done 2026-09-27 (VAD, +6 st playback, buffer discarded after playback, test asserts no file access, works with mic off/denied; permission only from the parent area). **Native Kotlin/Swift plugin not built yet** — Android/iOS report "not available".

**1.4 World map (main menu)**
Scrollable map with big world icons: Animals, Numbers, Letters, Shapes & Colours, Board Games, Pip's House. Pip narrates each world on first tap; second tap enters. Locked worlds show only as "coming soon" in the parent area, never as padlocks on the map.
- ✅ Map usable with no text; works in both locales; golden tests at 3 age-band themes.
> ✔ Done 2026-09-27: colour-stripe map, first tap names, second enters; goldens for all 3 age bands × en/sq. Not a scrolling illustrated map yet (needs art).

**1.5 Level select + episode runner**
Level path inside a world (1…N), stars per level, `EpisodeRunner` that plays: intro (Pip) → 3–5 games → companion moment → off-screen challenge → wind-down/stop screen. No autoplay into the next level.
- ✅ Integration test runs a full episode with stub games and records mastery.
> ✔ Done 2026-09-27: level path with stars, unlock by mastery (≥ 80% independent, min 5 rounds — TODO(pedagogy)), `EpisodeScreen` runs intro → 3–5 games → companion → off-screen → wind-down; integration test with stub games.

**1.6 Wind-down + parent timer**
Parent-set daily limit; at the limit Pip yawns and goes to bed; a friendly "all done" screen. No nagging.
- ✅ Timer persists across restarts; child cannot dismiss without the gate.
> ✔ Done 2026-09-27: daily limit in the parent area, counted while the app is in front, persisted per day; bedtime screen blocks play (back can't close it) until a grown-up passes the gate (+10/+30 min or settings). During an episode it waits for the wind-down.

---

## Phase 2 — Reusable game engines (Week 6–9)

Build generic Flame game types; every world's levels are JSON on top of these.

**2.1 `sound_match`** — hear a sound/word, tap the right picture (2–6 choices).
**2.2 `drag_to_target`** — drag items to zones (food → animal, animal → habitat, shape → hole).
**2.3 `tap_count`** — tap each object once; counts aloud; one-to-one correspondence.
**2.4 `trace_path`** — trace a numeral/letter/shape along a guided path with generous tolerance and arrows; reused for all 36 Albanian letters incl. digraph tiles.
**2.5 `pairs_memory`** — memory matching grid (2×2 → 4×4); pairs can be picture/picture, picture/sound, letter/picture.
**2.6 `sequence_pattern`** — complete the pattern (red-blue-red-?).
**2.7 `sort_bins`** — sort many items into 2–3 bins (big/small, land/water, letters starting with /s/).
**2.8 `blend_tiles`** — drag sound tiles together to form a word; word animates into its picture.

Each engine: `_config.dart` parses `params`, supports the adaptive `difficulty.steps`, emits `MasteryTracker` events, has a test and a golden. Hints appear after the number of errors set by level.
- ✅ Every engine passes a "no text needed" review, works in en/sq, and has ≥ 2 pillars scored ≥ 2 in its fixture JSON.
> ✔ All eight engines done 2026-09-27 (docs/ENGINES.md): shared RoundController (adaptive steps, hints by step, mastery per round), GameHost feedback, Flame card kit. Each has config parsing/validation, a playthrough test and goldens in `app/test/games/`. Pillar scores live in the content JSON (Phase 3).

---

## Phase 3 — World content (Week 10–16)

Use the curriculum map in `docs/CURRICULUM.md` (educator-owned). Each world = JSON levels + assets. Age bands drive which levels a child sees.

**3.1 Animals (8 levels)**
Farm → Pets → Jungle → Ocean → Arctic → Baby & Mummy → Animal Homes → Animal Echo (talk-back vocab). Games: sound_match, drag_to_target (feed/habitat), pairs_memory, sort_bins, tap_count (count animals).
- Albanian names: qen, mace, lopë, dele, derr, pulë, elefant, luan, majmun, peshk, pinguin…

**3.2 Numbers (10 levels)**
1–3 → 1–5 → 1–10 → Subitising (dots/ten-frames) → Compare more/less → Trace 0–9 → Share fairly → Bonds to 5 → Bonds to 10 → Add/subtract within 10 (6–7 only).
- Counting audio in both languages (një…dhjetë); ICU plurals for every count sentence.

**3.3 Letters (per language, 10 levels)**
`content/letters/en.json`: s a t p i n → m d g o c k → … → CVC blending → first words.
`content/letters/sq.json`: educator-defined order over all 36 letters; digraphs as single tiles; blending early because spelling is phonetic (e.g., m-a-c-e → mace).
Games: sound_match (letter sound → picture), trace_path, sort_bins (starts with /sh/), blend_tiles, pairs_memory (letter/picture).

**3.4 Shapes & Colours (6 levels)**
Circle/square/triangle → more shapes → colour names → colour mixing paint pots (dress Pip) → patterns → shapes in the world.

**3.5 Pip's House**
Sticker book and costumes unlocked by stars; feeding, tickling, talk-back; a "bedtime" that mirrors wind-down.

- ✅ For each world: all levels load, all audio keys exist in en and sq, every game JSON has pillar scores, an educator has signed off `docs/CURRICULUM.md`.
> ◐ Content drafted 2026-09-27 (`app/tool/levels_table.py` → 150 games, 34 levels: Animals 8, Numbers 10, Letters 10 per language, Shapes & Colours 6) plus Pip's House (feeding, tickling, talk-back, costumes and stickers unlocked by stars, bedtime). Tests: every level loads, every game's engine validates and starts in each language, every narration line has en+sq text, pillar scores ≥ 2. **Not done:** educator sign-off of docs/CURRICULUM.md (draft), native review of Albanian, and the recordings themselves (docs/RECORDING_SCRIPT.md lists every line); colour-mixing engine for Shapes L4.

---

## Phase 4 — Board Games world (Week 17–20)

Digital versions of classic kids' board games, redesigned for touch and no losing. All support **pass-and-play with a grown-up or sibling** (this is the socially-interactive pillar) and a solo mode vs Pip who plays gently.

**4.1 `roll_and_move` engine** — tap a big dice, count the pips aloud, move along a path.
- **Jungle Race** (3–7): snakes-and-ladders style; "helpers" (vines up) and "slides" (down) are both fun, nobody loses; landing squares trigger a tiny question (an animal sound, a number).
**4.2 Animal Dominoes** (4–7): match pictures or dot counts end-to-end; later match numeral to dots.
**4.3 Picture Bingo** (3–7): Pip calls an animal/letter/number; tap it on your card; first full row wins a sticker, everyone finishes.
**4.4 Memory Pairs table** (2–7): the pairs_memory engine as a 2-player board with turn indicator.
**4.5 Tic-Tac-Zoo** (5–7): tic-tac-toe with animal tokens; Pip plays imperfectly so children can win.
**4.6 Jigsaw** (2–5): 4→12 piece puzzles with snap-to-place, generous tolerance.
**4.7 Spot the Difference / I Spy** (4–7): tap what's different; vocab-driven "Gjej diçka të kuqe!" ("Find something red!").
**4.8 Feed the Animals dice race** (3–6): roll, count that many berries into the animal — counting drill disguised as a race.

Rules for this world: turns are narrated, no timers, a "winner" screen always celebrates everyone, games end in ≤ 8 minutes.
- ✅ Each game playable by a 3-year-old with an adult and by a 6-year-old alone; integration test for 2-player turn flow.
> ✔ Done 2026-09-27 with placeholder art: all eight board games (4.1–4.8) as engines + 8 Board Games levels; chooser (two friends / with Pip), narrated turns, gentle Pip (Tic-Tac-Zoo Pip blocks only sometimes), no timers, everyone celebrated. Tests: 2-player turn-flow integration test, a full playthrough of each game, goldens. **Not verified:** real play sessions with a 3-year-old + adult and a 6-year-old alone (playtests, PLAN 6.3).

---

## Phase 5 — Parent area, monetization, compliance (Week 21–23)

**5.1 Parent dashboard** (behind gate): skills mastered per world, time played, today's off-screen suggestion, daily timer, mic on/off, locale + bilingual mode, age band, reduced motion, captions.
**5.2 Purchases**: free sampler (first 2 levels of every world) + one-time full unlock; optional family subscription later. Price shown upfront; Pip never mentions it.
**5.3 Privacy**: plain-language + child-friendly privacy policy screens; data-retention note ("nothing stored off-device"); store listings for Apple Kids Category and Google Play Families; complete both data-safety forms.
**5.4 SDK audit**: script that fails CI if any dependency touches network, ads, or analytics.
- ✅ Legal review checklist in `docs/COMPLIANCE.md` fully ticked before store submission.
> ◐ Code done 2026-09-27: dashboard (stars, levels, skills mastered per world, today's off-screen idea, games left unfinished), settings incl. bilingual mode and extra-large buttons; free sampler (first 2 levels) + one-time unlock via in_app_purchase with price shown up front, only in the parent area; plain-language privacy page (en/sq) + docs/PRIVACY_POLICY.md; docs/STORE_LISTINGS.md drafts; `tool/audit_dependencies.dart` in CI and tests (fails on ads/analytics packages or network use; Rive CDN blocked on web). **Not done (people):** legal review, store products and forms — docs/COMPLIANCE.md has 11 open items.

---

## Phase 6 — Polish, testing with kids, launch (Week 24–28)

**6.1 Asset swap**: replace all `TODO(asset)` placeholders with final Rive, art, and native voice recordings (en + sq). Test that no placeholder remains.
**6.2 Performance**: 60 fps on a budget Android tablet; cold start < 3 s; install < 150 MB with worlds as on-demand asset packs.
**6.3 Playtests**: 5–8 children per age band, both languages, every 2 weeks; log mis-taps, hints used, abandon points; fix top 5 issues per round.
**6.4 Accessibility pass**: reduced motion, captions, switch-access large-target mode, left-handed tracing.
**6.5 Soft launch**: Albania/Kosovo + one diaspora market (e.g., Germany or Italy) + UK/US English. Track only aggregate, opt-in, on-device metrics.

> ◐ Phase 6 prepared 2026-09-27: `tool/release_check.dart` fails until every placeholder, recording and sign-off is done; docs/RELEASE.md covers performance budgets and how to measure, the playtest protocol (on-device hints/unfinished counts in the dashboard), accessibility status (reduced motion, captions, non-colour cues, +30% targets done; screen-reader check open) and the soft-launch plan. Asset swap, device performance runs, playtests and launch need people and devices.
---

## Backlog (post-launch ideas)
- Bilingual mode variants: sq + de, sq + it, sq + el.
- Emotions & social-emotional world; Music & rhythm world (clap the syllables).
- Seasonal board games (Bajram/Christmas/summer) as free updates.
- School/nursery edition with a teacher dashboard and classroom pass-and-play.
- Efficacy study with a university partner after 12 months.

## Definition of Done (every task)
- `flutter analyze` and `flutter test` pass; new code has tests.
- Works in en and sq; no hard-coded strings or audio paths.
- Usable without reading; touch targets ≥ 2 cm; no forbidden gestures.
- Complies with the hard rules in CLAUDE.md; changelog line added to `docs/CHANGELOG.md`.
