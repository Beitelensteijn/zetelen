// Tests voor de methodiek en het wijzigingslog (component methodiek-betrouwbaarheid)
import { describe, expect, it } from "vitest";
import { MATEN } from "../lib/maten";
import { controleer } from "../lib/wijzigingen";

describe("methodiek", () => {
  it("elke maat heeft definitie, formule, keuzes en beperkingen", () => {
    for (const m of MATEN) {
      expect(m.definitie.length).toBeGreaterThan(50);
      expect(m.formule.length).toBeGreaterThan(20);
      expect(m.keuzes.length).toBeGreaterThan(0);
      expect(m.beperkingen.length).toBeGreaterThan(0);
    }
  });
  it("cohesie staat erin, met de drempel van 25", () => {
    expect(MATEN.find((m) => m.id === "cohesie")?.formule).toContain("25");
  });
});

describe("wijzigingslog", () => {
  it("toont een testcorrectie met datum, nieuwste eerst", () => {
    const lijst = controleer([
      { datum: "2026-10-20", pagina: "/verkenner", beschrijving: "Oudere correctie" },
      { datum: "2026-10-24", pagina: "/fracties/pvv", beschrijving: "Testcorrectie" },
    ]);
    expect(lijst[0]).toEqual({ datum: "2026-10-24", pagina: "/fracties/pvv", beschrijving: "Testcorrectie" });
  });
  it("weigert een correctie zonder datum", () => {
    expect(() => controleer([{ pagina: "/", beschrijving: "x" }])).toThrow(/datum/);
  });
});
