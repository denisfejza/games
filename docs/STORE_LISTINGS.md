# Store listings and data-safety answers (draft)

*TODO(legal/marketing): final copy, screenshots, age rating questionnaires. Answers below reflect the code as of this
commit; re-check against `docs/COMPLIANCE.md` before each submission.*

## Apple App Store — Kids Category

- Category: Education; Kids Category, age band **5 and under** plus **6–8** (TODO: choose; the app spans 2–7).
- App Privacy ("nutrition label"): **Data Not Collected**.
- Kids Category rules: no third-party analytics or advertising ✔; no links out of the app ✔; purchases and settings
  behind a parental gate ✔ (`app/lib/core/parental_gate/`).
- In-app purchase: one non-consumable, `pips_world_full_unlock` (TODO: create in App Store Connect).

## Google Play — Families

- Target audience: ages 5 and under, 6–8 (TODO: confirm).
- Data safety form: **No data collected**, **no data shared**. Data is not encrypted in transit because none is sent.
- Families policy: Families-certified SDKs only — the app has no ad or analytics SDKs ✔; no device identifiers used ✔.
- Permissions: `RECORD_AUDIO` only if the native talk-back plugin is shipped (TODO(native)); requested only from the
  grown-up area.
- In-app product: `pips_world_full_unlock` (TODO: create in the Play Console).

## Short description (draft)

EN: Learn animals, numbers, letters, shapes and colours with Pip the fox — in Albanian and English.
SQ: Mëso kafshët, numrat, shkronjat, format dhe ngjyrat me dhelprën Pip — në shqip dhe anglisht.
