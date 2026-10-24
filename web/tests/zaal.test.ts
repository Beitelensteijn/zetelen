// Tests voor de rekenkern van de zaal (lib/zaal.ts)
import { describe, expect, it } from "vitest";
import { type CohesieKaart, sleutel, vakken, volgorde, zetels } from "../lib/zaal";

function kaart(paren: Record<string, number>): CohesieKaart {
  const k: CohesieKaart = new Map();
  for (const [p, c] of Object.entries(paren)) {
    const [a, b] = p.split("-");
    const v = { cohesie: c, gezamenlijk: 100, teWeinig: false };
    k.set(sleutel(a, b), v);
    k.set(sleutel(b, a), v);
  }
  return k;
}

describe("volgorde", () => {
  it("zet fracties die vaak samen stemmen naast elkaar", () => {
    // A en B lijken op elkaar, C en D ook, de twee groepen niet
    const k = kaart({ "A-B": 95, "C-D": 95, "A-C": 20, "A-D": 25, "B-C": 22, "B-D": 20 });
    const z = new Map([["A", 10], ["B", 5], ["C", 30], ["D", 8]]);
    const v = volgorde(["A", "B", "C", "D"], k, z);
    expect(Math.abs(v.indexOf("A") - v.indexOf("B"))).toBe(1);
    expect(Math.abs(v.indexOf("C") - v.indexOf("D"))).toBe(1);
    // De grootste fractie (C) staat aan de rechterkant
    expect(v.indexOf("C")).toBeGreaterThan(v.indexOf("A"));
  });

  it("geeft dezelfde volgorde bij herhalen", () => {
    const k = kaart({ "A-B": 80, "A-C": 40, "B-C": 50 });
    const z = new Map([["A", 1], ["B", 2], ["C", 3]]);
    expect(volgorde(["A", "B", "C"], k, z)).toEqual(volgorde(["A", "B", "C"], k, z));
  });
});

describe("zetels", () => {
  it("telt 150 zetels en kent ze in volgorde toe", () => {
    const z = zetels([{ id: "A", zetels: 100 }, { id: "B", zetels: 47 }]);
    expect(z).toHaveLength(150);
    expect(z.filter((x) => x.fractie === "A")).toHaveLength(100);
    expect(z.filter((x) => x.fractie === null)).toHaveLength(3); // vacatures blijven leeg
    // A zit links van B: alle hoeken van A zijn groter
    const minA = Math.min(...z.filter((x) => x.fractie === "A").map((x) => x.hoek));
    const maxB = Math.max(...z.filter((x) => x.fractie === "B").map((x) => x.hoek));
    expect(minA).toBeGreaterThanOrEqual(maxB);
  });

  it("vakken sluiten op elkaar aan", () => {
    const z = zetels([{ id: "A", zetels: 70 }, { id: "B", zetels: 80 }]);
    const [a, b] = vakken(z, ["A", "B"]);
    expect(a.tot).toBe(b.van);
    expect(a.van).toBeGreaterThan(a.tot);
  });
});
