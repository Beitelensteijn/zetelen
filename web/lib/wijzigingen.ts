// Publiek wijzigingslog (E7-S3), uit web/content/wijzigingen.json (binnen web/: de site kan geen bestanden daarbuiten importeren)
import bestand from "../content/wijzigingen.json";

export type Wijziging = { datum: string; pagina: string; beschrijving: string };

export function controleer(lijst: unknown): Wijziging[] {
  if (!Array.isArray(lijst)) throw new Error("wijzigingen moet een lijst zijn");
  return lijst.map((w, i) => {
    const { datum, pagina, beschrijving } = w as Record<string, unknown>;
    if (typeof datum !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(datum)) throw new Error(`wijziging ${i}: datum JJJJ-MM-DD ontbreekt`);
    if (typeof pagina !== "string" || typeof beschrijving !== "string" || !beschrijving) throw new Error(`wijziging ${i}: pagina of beschrijving ontbreekt`);
    return { datum, pagina, beschrijving };
  }).sort((a, b) => b.datum.localeCompare(a.datum));
}

export const WIJZIGINGEN = controleer(bestand.wijzigingen);
