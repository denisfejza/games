# Release preparation (PLAN phase 6)

## 6.1 Asset swap

Run `cd app && dart run tool/release_check.dart`. It fails until nothing placeholder is left:

- `TODO(asset)` markers in `app/lib/` (drawn Pip, emoji pictures, blip for missing narration, timed lip-flap…)
- missing narration recordings (the full list is in `docs/RECORDING_SCRIPT.md`)
- `assets/rive/pip.riv` not yet added (spec: `docs/PIP_RIVE_SPEC.md`)
- draft curriculum and unticked compliance items

Recordings: `app/assets/audio/{en,sq}/<ARB key>.ogg` and `app/assets/audio/sfx/<name>.ogg`. **Check Safari/iOS web
support for Ogg** before release; ship AAC/M4A as well if needed (the file name convention stays the same).

## 6.2 Performance budgets

| Budget | Target | How to check |
| --- | --- | --- |
| Frame rate | 60 fps on a budget Android tablet | `flutter run --profile` + DevTools performance page |
| Cold start | < 3 s | `flutter run --profile --trace-startup` |
| Install size | < 150 MB | `flutter build appbundle --analyze-size` |
| Web first load | keep `main.dart.js` < 4 MB | `du -h app/build/web/main.dart.js` (≈ 2.6 MB now) |

Nothing animates while a child is deciding, which also keeps idle CPU use low. World assets can move to
on-demand asset packs once the illustrated art arrives.

## 6.3 Playtests

Every two weeks, 5–8 children per age band, in both languages:

1. A grown-up sets the age band and language in the grown-up area.
2. Observe one episode per child; note mis-taps, confusion, and where they stop.
3. Afterwards, open **Grown-ups → Progress**: hints used per skill and "games often left unfinished" are recorded on
   the device only (no data leaves the tablet); copy them into the playtest notes by hand.
4. Fix the top five issues before the next round.

## 6.4 Accessibility

- [x] Reduced motion (parent setting, and the system setting): no bounces, flips or glides
- [x] Captions for all narration
- [x] Colour never the only cue (rings, ticks, lift, shapes)
- [x] Extra-large buttons (+30%) for switch access and motor needs
- [x] Tracing works for left- and right-handed children (no required direction of approach beyond stroke order)
- [ ] Screen-reader labels checked on devices (TalkBack / VoiceOver)

## 6.5 Soft launch

Albania/Kosovo + one diaspora market (e.g. Germany or Italy) + UK/US English. There are no analytics by design; use
store statistics, reviews and the playtest notes. Any in-app metrics must stay aggregate, opt-in and on-device.
