import type { MetadataRoute } from "next";
export default function sitemap(): MetadataRoute.Sitemap {
  const base = "https://www.rbisintelligence.com";
  const routes = ["","/main","/main/value","/main/trust","/main/dashboards",
                  "/hdr","/hdr/pricing","/hdr/what-it-does","/hdr/trust","/hdr/value"];
  return routes.map((r)=>({ url: `${base}${r}`, changeFrequency: "weekly", priority: r ? 0.7 : 1 }));
}
