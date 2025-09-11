# RBIS Website — GitHub Pages Template

Push to `main` → auto-deploys to **GitHub Pages** via Actions.

## Pages
- `index.html` — overview and contact
- `trust.html` — Trust & Assurance Centre (CSV export and print-ready dossier)
- `legal.html` — Legal Hub
- `dashboards.html` — interactive executive dashboards (CSV export and Evidence Pack)

## Local preview

Run `npm install` to fetch dependencies, then `npm start` to launch the Express server with the `/api/contact` endpoint. The server expects SMTP configuration via environment variables (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`).
