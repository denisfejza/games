# Pip Rive file — spec for the artist

The app draws a placeholder fox until `app/assets/rive/pip.riv` exists. Once the file is there (and `- assets/rive/`
is added under `assets:` in `app/pubspec.yaml`), the app switches to it automatically.

## File contract

- **Artboard:** the default artboard, portrait, about 1 : 1.2 (width : height). Pip stands, full body, feet at the bottom.
- **State machine:** named `Pip`.
- **View model** (data binding, auto-bound to the default instance) with two numbers:

| Property | Values | Meaning |
| --- | --- | --- |
| `mood` | 0 idle · 1 listening · 2 talking · 3 happy · 4 thinking · 5 sleepy · 6 celebrate | The app sets this; blend between states in the state machine. |
| `mouth` | 0–100 | Mouth opening while talking (lip-flap). Only meaningful while `mood` = 2. |

## Moods

| Mood | When the app uses it | Notes |
| --- | --- | --- |
| idle | Default, and while a child is choosing | **Must be still or nearly still** (no looping motion while a child decides: CLAUDE.md). A blink every few seconds is fine. |
| listening | Talk-back: the child is speaking | Ears up, looking at the child. |
| talking | Narration is playing | Mouth driven by `mouth`. |
| happy | Right answer, poke, feeding, tickle | One short hop (< 1 s), then back to idle. |
| thinking | Wrong answer | Curious, head tilt. **Never sad, never disappointed** (hard rule 5). |
| sleepy | Bedtime / daily limit reached | Eyes closed, "z z", slow breathing allowed. |
| celebrate | End of a game or level | Arms up, one jump (< 2 s). |

## Tap areas

The app handles taps itself (not in Rive), using these regions as fractions of the artboard width,
so keep the body parts roughly here:

| Part | Region (left, top, right, bottom) |
| --- | --- |
| nose | 0.38, 0.36, 0.62, 0.50 |
| mouth (feeding) | 0.34, 0.50, 0.66, 0.62 |
| ears | 0.02–0.36 and 0.64–0.98, from −0.02 to 0.24 |
| belly (tickle) | 0.30, 0.66, 0.70, 1.04 |
| hands | 0.06–0.30 and 0.70–0.94, from 0.68 to 1.00 |
| feet | 0.20, 1.04, 0.80, 1.20 |

## Export rules (privacy)

- Export with **all assets embedded** (images, fonts). Rive can otherwise load assets from its CDN, which the app
  must never do.
- Web builds must self-host the Rive WebAssembly: copy the `@rive-app/flutter-native-wasm` files to `app/web/rive/`
  and build with `--dart-define=RIVE_NATIVE_WASM_HOST=./rive/`. Without it the web build keeps the drawn Pip.

## Style

Friendly orange fox, cream muzzle and belly, dark ear tips, thick white outline (sticker look) so Pip reads on
every world colour. No text inside the file. Keep the file small (target < 300 KB).
