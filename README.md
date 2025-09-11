# RBIS Website — GitHub Pages Template

Push to `main` → auto-deploys to **GitHub Pages** via Actions.

## Pages
- `index.html` — overview and contact
- `trust.html` — Trust & Assurance Centre (CSV export and print-ready dossier)
- `legal.html` — Legal Hub
- `dashboards.html` — interactive executive dashboards (CSV export and Evidence Pack)

## Optional build

Install dependencies and minify HTML/CSS into `dist/` for a production build:

```bash
npm install
npm run minify
```

The `dist/` directory will contain the optimized site output.

## Local preview

Open any HTML file directly in a browser or serve this repository with any static file server. Local preview works without running the optional build step or installing dependencies.
