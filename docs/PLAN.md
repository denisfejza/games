# Children's Games — Project Plan

## Goals

- A collection of small, safe games for young children (target ages 3–7).
- **Cross-platform from one codebase**: runs in any modern browser (desktop,
  tablet, phone) and can later be packaged as iOS/Android/desktop apps.
- **Hosted free on GitHub Pages**: every push to `main` builds and deploys.
- Kid-safe by design: no ads, no accounts, no tracking, no external links,
  works offline once loaded.

## Tech stack (recommended)

| Concern | Choice | Why |
| --- | --- | --- |
| Language | TypeScript | Type safety, good tooling, easy to grow |
| Build tool | [Vite](https://vitejs.dev) | Fast dev server, static output that GitHub Pages can serve |
| Game engine | [Phaser 3](https://phaser.io) | Mature 2D engine; handles touch + mouse, scaling, sprites, audio, tweens |
| Offline / install | PWA (`vite-plugin-pwa`) | "Add to Home Screen" on tablets/phones, works offline |
| Native apps (later) | [Capacitor](https://capacitorjs.com) | Wraps the same web build as iOS/Android apps with no rewrite |
| Hosting | GitHub Pages via GitHub Actions | Free, automatic deploy on push |
| Tests | Vitest (logic) + Playwright (smoke test in browser) | Game logic stays testable apart from rendering |

Alternatives considered: plain Canvas/DOM (fine for very simple games, but
we'd end up rebuilding scaling, input and audio), Godot/Unity web exports
(big downloads, slow first load on tablets, overkill for 2D kids' games),
Flutter/React Native (weaker fit for game-style rendering and GitHub Pages).

## Repository layout

The repo holds several games, so it uses npm workspaces:

```
games/
├── apps/
│   ├── launcher/          # landing page listing all games (site root)
│   └── memory-match/      # first game
├── packages/
│   └── shared/            # common UI (big buttons, home button), audio helper,
│                          # scaling config, colour palette, asset loader
├── .github/workflows/
│   └── deploy.yml         # build all apps → publish to GitHub Pages
├── docs/PLAN.md
└── package.json           # workspaces + shared scripts
```

Published URLs (project Pages site):

- `https://denisfejza.github.io/games/` → launcher
- `https://denisfejza.github.io/games/memory-match/` → first game

Each Vite app sets `base` to its sub-path so assets resolve correctly on Pages.

## First app: "Animal Memory Match"

A picture-matching game. It's a good first game because it's simple to build,
needs no reading, suits a wide age range, and covers everything later games
will need (touch input, sound, scenes, progress, responsive layout).

### Gameplay

1. Start screen: a big "Play" button (icon, no text needed) and a difficulty
   choice shown as 2×2, 2×3 and 3×4 grids of card backs.
2. Cards are placed face-down. The child taps two cards to flip them.
3. Match: the cards stay up, the animal "speaks" (moo, woof), and there's a
   little bounce/confetti.
   No match: the cards flip back after ~1 second. No penalty, no timer, no
   "wrong" buzzer.
4. All pairs found: a celebration screen with stars, then "Play again" or "Home".

### Kid-friendly UX rules (these apply to every game)

- Touch targets at least 64 px; nothing depends on hover or double-tap.
- Landscape and portrait both work, and the layout scales to fill the screen.
- Only positive feedback; no losing, no timers at the easiest levels.
- Icons and voice instead of text wherever possible.
- A parent-only area (press-and-hold for 3 s) holds sound on/off and fullscreen.
- Input is locked while cards animate so fast double-taps don't break the game.

### Scenes (Phaser)

`Boot` (preload assets) → `Menu` (play + difficulty) → `Game` (board) →
`Win` (celebration) → back to `Menu`.

### Game logic, kept separate from rendering

`packages/shared` / `apps/memory-match/src/logic/` holds pure TypeScript:

- `createDeck(pairs, rng)`: shuffled pairs (seeded RNG so tests are repeatable)
- `flip(state, index)`: returns the new state (`idle → oneUp → checking → matched/reset`)
- `isComplete(state)`

This part is covered by Vitest unit tests; the Phaser scene only draws the state.

### Assets

- Animal art: CC0 packs (e.g. Kenney.nl "Animal Pack"), with the licence noted
  in `ASSETS.md`.
- Sounds: CC0 animal sounds plus UI pops (Kenney, freesound CC0), kept small
  (`.ogg` + `.mp3` fallback).
- Aim for less than 5 MB total so the first load on tablets is quick.

## Deployment (GitHub Pages)

1. `.github/workflows/deploy.yml`: on push to `main`, run `npm ci`, then
   `npm run build` (builds the launcher and every game into one `dist/`), then
   `actions/upload-pages-artifact`, then `actions/deploy-pages`.
2. One-time repo setting: **Settings → Pages → Source: GitHub Actions**.
3. PR builds run lint, tests and build (no deploy) so a broken `main` never ships.

## Milestones

| # | Milestone | Done when |
| --- | --- | --- |
| M0 | Scaffold | Workspaces, Vite + Phaser + TS, lint/format, empty launcher, Pages deploy works with a "Hello" page |
| M1 | Core logic | Deck, flip and match logic with unit tests |
| M2 | Playable game | Board renders, taps flip cards, matching works on desktop and touch |
| M3 | Polish | Sounds, animations, win screen, difficulty levels, responsive layout |
| M4 | PWA | Installable and works offline; tested on an iPad/Android tablet |
| M5 | (Optional) Native | Capacitor wrap for Android/iOS builds |

## Ideas for later games (reusing `packages/shared`)

- Colour & shape sorter (drag and drop)
- Counting balloons (pop 1–10, spoken numbers)
- Letter tracing (finger drawing)
- Simple jigsaw puzzles (4–9 pieces)
- Animal sounds piano / music maker

## Open questions

1. Target age range: is 3–7 right? It affects difficulty and how much text we use.
2. Theme for the first game: animals (proposed), or something else (vehicles,
   dinosaurs, family photos)?
3. Languages: English only, or other languages too? This decides whether
   we need voice-over and i18n from the start.
4. Do native app-store builds matter soon, or is browser/PWA enough for now?
