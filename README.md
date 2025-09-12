# RBIS UK Website

Static information hub built with **TypeScript** and styled using **Tailwind CSS** via CDN. The site features a 3D rotating cube and smooth-scrolling navigation to deliver a professional experience without external build tools.

## Development

Interactive behavior is authored in `main.ts` and compiled to JavaScript with:

```bash
npm run build
```

Open `index.html` in any modern browser to view the site.

GitHub Pages is configured to serve from the `docs/` directory, so the built assets are duplicated there to prevent 404s in production.

## Testing

Run simple structural checks:

```bash
npm test
```
