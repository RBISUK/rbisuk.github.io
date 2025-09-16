export const GA_TRACKING_ID = process.env.NEXT_PUBLIC_GA_ID || "";

export const pageview = (url: string) => {
  if (typeof window !== "undefined" && GA_TRACKING_ID) {
    (window as any).gtag("config", GA_TRACKING_ID, { page_path: url });
  }
};

export const event = (name: string, params: Record<string, any> = {}) => {
  if (typeof window !== "undefined" && GA_TRACKING_ID) {
    (window as any).gtag("event", name, params);
  }
};
