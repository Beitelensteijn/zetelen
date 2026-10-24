// Rekenkern van de zaal en de boog (component cohesie-pagina): volgorde van de fracties,
// plaats van de zetels en de vakken per fractie. Geen React, zodat het los te testen is.

export type Paar = { cohesie: number | null; gezamenlijk: number; teWeinig: boolean };
export type CohesieKaart = Map<string, Paar>; // sleutel: "fractieA|fractieB" (beide richtingen)

export const sleutel = (a: string, b: string) => `${a}|${b}`;

// Volgorde uit de data: eerste as van een klassieke schaling (MDS) op afstand = 1 - cohesie.
// Fracties die vaak hetzelfde stemmen, komen naast elkaar. Geen eigen links-rechtsindeling
// (besluit Niels, 24 oktober 2026). Ontbrekende paren krijgen de gemiddelde afstand.
// Richting: de grootste fractie komt rechts, zodat de volgorde stabiel blijft bij herladen.
export function volgorde(ids: string[], kaart: CohesieKaart, zetels: Map<string, number>): string[] {
  const n = ids.length;
  if (n < 3) return [...ids];
  const waarden: number[] = [];
  for (const a of ids) for (const b of ids) if (a < b) {
    const c = kaart.get(sleutel(a, b))?.cohesie;
    if (c != null) waarden.push(c);
  }
  const gemiddeld = waarden.length ? waarden.reduce((s, x) => s + x, 0) / waarden.length : 50;
  const d2 = ids.map((a) =>
    ids.map((b) => {
      if (a === b) return 0;
      const c = kaart.get(sleutel(a, b))?.cohesie ?? gemiddeld;
      const d = 1 - c / 100;
      return d * d;
    }),
  );
  // Dubbel centreren: B = -1/2 J D2 J
  const rij = d2.map((r) => r.reduce((s, x) => s + x, 0) / n);
  const totaal = rij.reduce((s, x) => s + x, 0) / n;
  const B = d2.map((r, i) => r.map((x, j) => -0.5 * (x - rij[i] - rij[j] + totaal)));
  // Grootste eigenvector met machtsiteratie (n is klein: hooguit een paar tientallen fracties)
  let v = ids.map((_, i) => 1 + i / n);
  for (let k = 0; k < 500; k++) {
    const w = B.map((r) => r.reduce((s, x, j) => s + x * v[j], 0));
    const norm = Math.hypot(...w) || 1;
    v = w.map((x) => x / norm);
  }
  const grootste = ids.reduce((g, id) => ((zetels.get(id) ?? 0) > (zetels.get(g) ?? 0) ? id : g), ids[0]);
  if (v[ids.indexOf(grootste)] < 0) v = v.map((x) => -x);
  return ids.map((id, i) => ({ id, x: v[i] })).sort((p, q) => p.x - q.x || p.id.localeCompare(q.id)).map((p) => p.id);
}

// Zaal: 150 zetels in zes rijen, hoefijzer van 220 graden (docs/ontwerp/HANDOVER.md)
export const RIJEN: Array<[number, number]> = [[150, 13], [205, 18], [260, 23], [315, 27], [370, 32], [425, 37]];
export const MIDDEN = { x: 500, y: 455 };
export const ZETELS_TOTAAL = 150;

export function punt(r: number, hoek: number) {
  const rad = (hoek * Math.PI) / 180;
  return { x: MIDDEN.x + r * Math.cos(rad), y: MIDDEN.y - r * Math.sin(rad) };
}

export type Zetel = { x: number; y: number; hoek: number; fractie: string | null };

// Zetels gesorteerd op hoek (van links naar rechts) en in volgorde aan de fracties toegekend,
// zodat elke fractie een wig is. Zetels die overblijven (vacatures) blijven leeg.
export function zetels(fracties: Array<{ id: string; zetels: number }>): Zetel[] {
  const alle: Zetel[] = [];
  for (const [r, n] of RIJEN) {
    for (let i = 0; i < n; i++) {
      const hoek = 200 - (220 * i) / (n - 1);
      alle.push({ ...punt(r, hoek), hoek, fractie: null });
    }
  }
  alle.sort((a, b) => b.hoek - a.hoek || a.x - b.x);
  let k = 0;
  for (const f of fracties) {
    for (let i = 0; i < f.zetels && k < alle.length; i++) alle[k++].fractie = f.id;
  }
  return alle;
}

// Vak per fractie: hoekbereik halverwege tussen de buren
export type Vak = { fractie: string; van: number; tot: number; midden: number };

export function vakken(zetelLijst: Zetel[], volgordeIds: string[]): Vak[] {
  const bereik = volgordeIds
    .map((id) => {
      const h = zetelLijst.filter((z) => z.fractie === id).map((z) => z.hoek);
      return h.length ? { id, max: Math.max(...h), min: Math.min(...h) } : null;
    })
    .filter((x): x is { id: string; max: number; min: number } => x !== null);
  return bereik.map((b, i) => {
    const van = i === 0 ? 203 : (bereik[i - 1].min + b.max) / 2;
    const tot = i === bereik.length - 1 ? -23 : (b.min + bereik[i + 1].max) / 2;
    return { fractie: b.id, van, tot, midden: (van + tot) / 2 };
  });
}

// SVG-pad van een ringsector tussen twee hoeken
export function sector(r1: number, r2: number, van: number, tot: number): string {
  const a = punt(r2, van), b = punt(r2, tot), c = punt(r1, tot), d = punt(r1, van);
  const groot = van - tot > 180 ? 1 : 0;
  const f = (n: number) => n.toFixed(1);
  return `M${f(a.x)},${f(a.y)} A${r2},${r2} 0 ${groot} 1 ${f(b.x)},${f(b.y)} L${f(c.x)},${f(c.y)} A${r1},${r1} 0 ${groot} 0 ${f(d.x)},${f(d.y)} Z`;
}
