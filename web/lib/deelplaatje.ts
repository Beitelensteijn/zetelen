// Inhoud van het deelplaatje per fractie (component deelplaatjes, E3-S5): alleen cijfers uit de
// database, nooit iets dat niet op de site staat. Los van de opmaak, zodat het te testen is.
import type { FractieInPeriode } from "./cohesie";
import { type CohesieKaart, sleutel } from "./zaal";

export type Regel = { afkorting: string; cohesie: number | null };
export type PlaatjeInhoud = { titel: string; regels: Regel[]; teWeinig: boolean };

export function plaatjeInhoud(afkorting: string, fracties: FractieInPeriode[] | null, kaart: CohesieKaart | null, aantal = 3): PlaatjeInhoud {
  const titel = `Met wie stemt ${afkorting} het vaakst hetzelfde?`;
  const ik = fracties?.find((f) => f.afkorting === afkorting);
  if (!ik || !kaart || !fracties) return { titel, regels: [], teWeinig: true };
  const regels = fracties
    .filter((f) => f.id !== ik.id)
    .map((f) => ({ afkorting: f.afkorting, p: kaart.get(sleutel(ik.id, f.id)) }))
    .filter((r) => r.p && !r.p.teWeinig && r.p.cohesie != null)
    .sort((a, b) => b.p!.cohesie! - a.p!.cohesie!)
    .slice(0, aantal)
    .map((r) => ({ afkorting: r.afkorting, cohesie: r.p!.cohesie! }));
  return { titel, regels, teWeinig: regels.length === 0 };
}
