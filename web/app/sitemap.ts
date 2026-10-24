import type { MetadataRoute } from "next";
import { PAGINAS, siteUrl } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  return PAGINAS.map((pad) => ({ url: new URL(pad, siteUrl()).toString() }));
}
