# games

Kid-safe games for ages 3–7, in English and Albanian (Shqip). They run in the
browser (hosted on GitHub Pages) and will also be packaged as Android/iOS apps.

- Plan: [docs/PLAN.md](docs/PLAN.md)
- Live site (after the first deploy): https://denisfejza.github.io/games/

## Games

| Game | Folder | Status |
| --- | --- | --- |
| Animal Memory / Kujtesa e Kafshëve | `apps/memory-match` | Playable (placeholder art) |

## Development

Requires Node 22+.

```sh
npm install
npm run dev          # play Animal Memory at http://localhost:5173
npm run dev:launcher # the games home page
npm test             # unit tests (game logic, i18n)
npm run typecheck
npm run build        # everything into dist/ (what GitHub Pages serves)
npm run preview      # serve dist/ locally
```

## Deploying

Every push to `main` builds and publishes `dist/` to GitHub Pages
(`.github/workflows/deploy.yml`). One-time setup: **Settings → Pages →
Build and deployment → Source: GitHub Actions**.
