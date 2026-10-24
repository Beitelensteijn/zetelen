// Tests voor lib/api.ts: datumnotatie en gedrag als de database niet bereikbaar is (E3-S9)
import { afterEach, describe, expect, it, vi } from "vitest";
import { datumTekst, laatstBijgewerkt, leesApi } from "../lib/api";

afterEach(() => {
  vi.unstubAllEnvs();
  vi.unstubAllGlobals();
});

describe("datumTekst", () => {
  it("toont Nederlandse tijd", () => {
    expect(datumTekst(new Date("2026-10-24T04:31:00Z"))).toBe("24 oktober 2026 om 06:31");
  });
});

describe("leesApi", () => {
  it("geeft null zonder instellingen", async () => {
    vi.stubEnv("SUPABASE_URL", "");
    expect(await leesApi("kabinet")).toBeNull();
  });

  it("geeft null als de API niet bereikbaar is", async () => {
    vi.stubEnv("SUPABASE_URL", "https://nep.supabase.co");
    vi.stubEnv("SUPABASE_PUBLISHABLE_KEY", "sb_publishable_test");
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("netwerk weg")));
    expect(await leesApi("kabinet")).toBeNull();
  });

  it("stuurt het schema api en de sleutel mee, ook met /rest/v1 en spaties in de instelling", async () => {
    vi.stubEnv("SUPABASE_URL", " https://nep.supabase.co/rest/v1/ ");
    vi.stubEnv("SUPABASE_PUBLISHABLE_KEY", "sb_publishable_test");
    const nep = vi.fn().mockResolvedValue(new Response(JSON.stringify([{ laatst_bijgewerkt: "2026-10-24T04:31:00Z" }])));
    vi.stubGlobal("fetch", nep);
    expect((await laatstBijgewerkt())?.toISOString()).toBe("2026-10-24T04:31:00.000Z");
    const [url, opties] = nep.mock.calls[0];
    expect(url).toBe("https://nep.supabase.co/rest/v1/laatst_bijgewerkt");
    expect(opties.headers["Accept-Profile"]).toBe("api");
  });
});
