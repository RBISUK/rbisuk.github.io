// instrumentation-client.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  // Performance (RUM)
  tracesSampleRate: 1,

  // Replay (if you use it)
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,

  // Turn on SDK debug logs in non-prod (shows in console; not a network “send logs” feature)
  debug: process.env.NODE_ENV !== "production",

  // Capture console.warn/error as Sentry breadcrumbs/events
  integrations: [
    Sentry.captureConsoleIntegration({
      levels: ["warn", "error"], // or ["log","info","warn","error"] if you want everything
    }),
  ],
});
