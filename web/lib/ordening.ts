// Volgorde en labels van de fracties in een periode: eerst de zaal (volgorde uit de data),
// dan de fracties die halverwege stopten. Dubbele afkortingen (een fractie die opnieuw begint,
// zoals Krol in 2020) krijgen het jaar van hun eerste stemming erachter, zodat ze in de URL uniek zijn.
import type { FractieInPeriode } from "./cohesie";
import { type CohesieKaart, volgorde } from "./zaal";

export function ordenFracties(fracties: FractieInPeriode[], kaart: CohesieKaart): FractieInPeriode[] {
  const telling = new Map<string, number>();
  for (const f of fracties) telling.set(f.afkorting, (telling.get(f.afkorting) ?? 0) + 1);
  const uniek = fracties.map((f) =>
    (telling.get(f.afkorting) ?? 0) > 1 ? { ...f, afkorting: `${f.afkorting} ${f.eerste.slice(0, 7)}` } : f,
  );
  const zaal = uniek.filter((f) => f.inZaal);
  const zetels = new Map(zaal.map((f) => [f.id, f.zetels]));
  const orde = volgorde(zaal.map((f) => f.id), kaart, zetels);
  const perId = new Map(zaal.map((f) => [f.id, f]));
  const rest = uniek.filter((f) => !f.inZaal).sort((a, b) => a.eerste.localeCompare(b.eerste));
  return [...orde.map((id) => perId.get(id)!), ...rest];
}
