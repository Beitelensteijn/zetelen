// Rekenkern van de coalitiebouwer (component coalitie-analyse, E2-S7 en E2-S8).
// VOORSTEL VOOR DE DEFINITIE, nog niet goedgekeurd door Niels (zie docs/plan/08-componenten/coalitie-analyse.md):
//   eensgezind   elke fractie in de groep stemde voor of tegen, allemaal hetzelfde
//   zetels       de fractiegrootte op het moment van de stemming
//   meerderheid  de zetels aan de kant van de groep zijn meer dan de zetels aan de andere kant
//   meegestemd   een fractie buiten de groep stemde hetzelfde als de groep
//   beslissend   de groep had de meerderheid, en zonder de zetels van die fractie niet meer

export type Stemmatrix = {
  fracties: Array<{ id: string; afkorting: string }>;
  stemmen: string[]; // per besluit: per fractie V, T of -
  zetels: Array<Array<[number, number]>>; // per fractie: [besluitnummer, zetels] bij elke wijziging
};

export type Partner = { id: string; afkorting: string; meegestemd: number; beslissend: number; aandeel: number };
export type Uitkomst = {
  eensgezind: number;
  meerderheid: number;
  zonderHulp: number; // meerderheid met alleen de eigen zetels
  partners: Partner[];
};

// Zetels per fractie per besluit, uit de lijst met wijzigingen
export function zetelTabel(m: Stemmatrix): Int16Array[] {
  return m.zetels.map((reeks) => {
    const t = new Int16Array(m.stemmen.length);
    let i = 0;
    let huidig = reeks.length ? reeks[0][1] : 0;
    for (let b = 0; b < m.stemmen.length; b++) {
      while (i < reeks.length && reeks[i][0] <= b) huidig = reeks[i++][1];
      t[b] = huidig;
    }
    return t;
  });
}

export function bereken(m: Stemmatrix, groep: string[], zetels = zetelTabel(m)): Uitkomst {
  const idx = groep.map((id) => m.fracties.findIndex((f) => f.id === id)).filter((i) => i >= 0);
  const n = m.fracties.length;
  const mee = new Array<number>(n).fill(0);
  const doorslag = new Array<number>(n).fill(0);
  let eensgezind = 0, meerderheid = 0, zonderHulp = 0;
  if (idx.length) {
    for (let b = 0; b < m.stemmen.length; b++) {
      const regel = m.stemmen[b];
      const stem = regel[idx[0]];
      if (stem === "-" || idx.some((i) => regel[i] !== stem)) continue;
      eensgezind++;
      let voor = 0, tegen = 0, eigen = 0;
      for (let f = 0; f < n; f++) {
        const s = regel[f];
        if (s === "-") continue;
        if (s === stem) voor += zetels[f][b];
        else tegen += zetels[f][b];
      }
      for (const i of idx) eigen += zetels[i][b];
      const gewonnen = voor > tegen;
      if (gewonnen) meerderheid++;
      if (eigen > tegen + (voor - eigen)) zonderHulp++;
      for (let f = 0; f < n; f++) {
        if (idx.includes(f) || regel[f] !== stem) continue;
        mee[f]++;
        if (gewonnen && voor - zetels[f][b] <= tegen) doorslag[f]++;
      }
    }
  }
  const partners = m.fracties
    .map((fr, f) => ({ id: fr.id, afkorting: fr.afkorting, meegestemd: mee[f], beslissend: doorslag[f], aandeel: eensgezind ? (100 * mee[f]) / eensgezind : 0 }))
    .filter((p) => !groep.includes(p.id))
    .sort((a, b) => b.beslissend - a.beslissend || b.meegestemd - a.meegestemd);
  return { eensgezind, meerderheid, zonderHulp, partners };
}
