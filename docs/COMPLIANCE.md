# Compliance checklist (PLAN 5.3–5.4)

Legal review must tick every box before store submission. **Code** items are done and tested in this repo;
**People** items need a named person to check them.

## Child data (CLAUDE.md hard rule 1)

- [x] Code: no accounts; profile = nickname + avatar + age band + locale, stored on-device (Drift)
- [x] Code: no network use in app code; CI audit fails on HttpClient/http/UrlSource/web addresses (`tool/audit_dependencies.dart`)
- [x] Code: Flutter web build serves its renderer from our own site (`--no-web-resources-cdn`)
- [x] Code: Rive never starts on the web unless its WebAssembly is self-hosted (`RIVE_NATIVE_WASM_HOST`), so no CDN fetch
- [ ] People: when `pip.riv` arrives, check it embeds all its assets and confirm no requests in the browser network tab
- [ ] People: privacy policy (docs/PRIVACY_POLICY.md) reviewed and published; contact details filled in

## Microphone (hard rule 2)

- [x] Code: talk-back keeps audio in memory, plays once, discards (test asserts no file access)
- [x] Code: app works with the mic off or denied; permission requested only from the parent area
- [ ] People: native Android/iOS plugin reviewed for the same guarantees (not built yet)

## Parental gate (hard rule 3)

- [x] Code: gate in front of settings, purchases, the dashboard and permission prompts; back can't bypass it
- [x] Code: no external links in the app
- [ ] People: gate difficulty acceptable for Apple/Google reviewers (number written as words, 3 digits)

## No manipulative design (hard rules 4–6)

- [x] Code: no ads, loot boxes or random rewards (stickers and costumes unlock in a fixed order by stars)
- [x] Code: no timers or lose states; board games celebrate everyone; mistakes make Pip curious, never sad
- [x] Code: no streaks, no "come back tomorrow", no autoplay into the next episode; every episode ends with a wind-down
- [x] Code: Pip never mentions purchases; children never see locked levels or prices
- [ ] People: playtest review that nothing feels like pressure (PLAN 6.3)

## Stores (hard rule 7)

- [ ] People: Apple Kids Category and Google Play Families forms completed (docs/STORE_LISTINGS.md drafts)
- [ ] People: in-app product created in both stores; purchase + restore tested on devices
- [ ] People: age ratings questionnaires

## Content

- [ ] People: educator sign-off of docs/CURRICULUM.md (draft)
- [ ] People: native Albanian review of `app/lib/l10n/app_sq.arb`
- [ ] People: all recordings made (docs/RECORDING_SCRIPT.md) and placeholder art replaced (`tool/release_check.dart`)
