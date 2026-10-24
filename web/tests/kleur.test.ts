// Contrastcontrole van het ontwerpsysteem tegen WCAG AA (story E3-S2)
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { SCHAAL, TOKENS, contrast, luminantie, schaalkleur, tekstOp } from "../lib/kleur";

const ACHTERGRONDEN = ["nacht-950", "nacht-900", "nacht-800", "nacht-700"] as const;

describe("contrast van tekst", () => {
  for (const voorgrond of ["tekst", "tekst-zacht", "koper", "goud"] as const) {
    for (const achtergrond of ACHTERGRONDEN) {
      it(`${voorgrond} op ${achtergrond} haalt 4,5`, () => {
        expect(contrast(TOKENS[voorgrond], TOKENS[achtergrond])).toBeGreaterThanOrEqual(4.5);
      });
    }
  }
});

describe("grafische vormen", () => {
  // Grafieken (zaal, boog, matrix) staan op nacht-950, nacht-900 of nacht-800
  for (const achtergrond of ["nacht-950", "nacht-900", "nacht-800"] as const) {
    it(`lijn-licht op ${achtergrond} haalt 3`, () => {
      expect(contrast(TOKENS["lijn-licht"], TOKENS[achtergrond])).toBeGreaterThanOrEqual(3);
    });
  }
  // Vastgelegde regel: lijn-licht niet gebruiken op nacht-700 (contrast 2,81)
  it("lijn-licht op nacht-700 haalt 3 niet", () => {
    expect(contrast(TOKENS["lijn-licht"], TOKENS["nacht-700"])).toBeLessThan(3);
  });
});

describe("cohesieschaal", () => {
  it("begint en eindigt op de stops", () => {
    expect(schaalkleur(0)).toBe(SCHAAL[0][1]);
    expect(schaalkleur(100)).toBe(SCHAAL[3][1]);
  });

  it("wordt steeds lichter van 0 naar 100 procent", () => {
    for (let p = 1; p <= 100; p++) {
      expect(luminantie(schaalkleur(p))).toBeGreaterThan(luminantie(schaalkleur(p - 1)));
    }
  });

  it("tekst in elke cel haalt 4,5", () => {
    for (let p = 0; p <= 100; p++) {
      const achtergrond = schaalkleur(p);
      expect(contrast(tekstOp(achtergrond), achtergrond)).toBeGreaterThanOrEqual(4.5);
    }
  });
});

describe("tokens", () => {
  it("de CSS-tokens zijn gelijk aan de waarden in lib/kleur.ts", () => {
    const css = readFileSync(new URL("../styles/tokens.css", import.meta.url), "utf8").toLowerCase();
    for (const [naam, hex] of Object.entries(TOKENS)) {
      expect(css).toContain(`--${naam}: ${hex.toLowerCase()};`);
    }
  });
});
