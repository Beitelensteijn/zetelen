import type { MetadataRoute } from "next";
import { LIVE, siteUrl } from "@/lib/site";

// Tot de livegang: alles uitsluiten
export default function robots(): MetadataRoute.Robots {
  return LIVE
    ? { rules: { userAgent: "*", allow: "/", disallow: "/ontwerpsysteem" }, sitemap: new URL("/sitemap.xml", siteUrl()).toString() }
    : { rules: { userAgent: "*", disallow: "/" } };
}
