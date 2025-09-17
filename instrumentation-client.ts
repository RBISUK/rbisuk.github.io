// instrumentation-client.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1, // Performance (RUM)

  // Replay (browser-only). Keep or remove as needed:
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,

  // SDK debug logs in non-prod (to the browser console):
  debug: process.env.NODE_ENV !== "production",

  // Capture console messages in Sentry:
  integrations: [
    Sentry.captureConsoleIntegration({
      levels: ["warn", "error"], // widen to ["log","info","warn","error"] if desired
    }),
  ],
});
