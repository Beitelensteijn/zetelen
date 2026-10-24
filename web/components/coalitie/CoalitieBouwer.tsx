"use client";
// Coalitiebouwer (componenten coalitie-analyse en coalitie-pagina, E2-S8 en E2-S9).
// De bezoeker kiest fracties in de zaal; de pagina telt hun zetels en rekent op de stemmatrix
// van de periode uit bij wie de groep in het verleden een meerderheid haalde. Keuze in de URL.
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import type { FractieInPeriode } from "@/lib/cohesie";
import { getal, procent } from "@/lib/cohesie";
import { type Stemmatrix, bereken, zetelTabel } from "@/lib/coalitie";
import { schaalkleur } from "@/lib/kleur";
import { MIDDEN, punt, sector, vakken, zetels as zetelsVan } from "@/lib/zaal";
import { Data, Label, Tekst } from "@/components/Typografie";
import s from "@/components/cohesie/verkenner.module.css";

const MEERDERHEID = 76;

export function CoalitieBouwer({ fracties, soort, periode }: { fracties: FractieInPeriode[]; soort: string; periode: string }) {
  const router = useRouter();
  const pad = usePathname();
  const zoek = useSearchParams();
  const zaal = fracties.filter((f) => f.inZaal);
  const groep = (zoek.get("groep") ?? "").split(",").map((a) => zaal.find((f) => f.afkorting === a)?.id).filter((x): x is string => !!x);
  const [matrix, setMatrix] = useState<Stemmatrix | null>(null);
  const [fout, setFout] = useState<string | null>(null);
  const [hover, setHover] = useState<string | null>(null);

  useEffect(() => {
    let weg = false;
    setMatrix(null);
    setFout(null);
    fetch(`/api/stemmatrix?${new URLSearchParams({ soort, periode })}`)
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((m: Stemmatrix) => !weg && setMatrix(m))
      .catch(() => !weg && setFout("De stemmingen konden niet worden geladen. Probeer het over een paar minuten opnieuw."));
    return () => {
      weg = true;
    };
  }, [soort, periode]);

  const tabel = useMemo(() => (matrix ? zetelTabel(matrix) : null), [matrix]);
  const uitkomst = useMemo(() => (matrix && tabel && groep.length ? bereken(matrix, groep, tabel) : null), [matrix, tabel, groep.join(",")]); // eslint-disable-line react-hooks/exhaustive-deps
  const perPartner = new Map(uitkomst?.partners.map((p) => [p.id, p]) ?? []);
  const zetelsGroep = zaal.filter((f) => groep.includes(f.id)).reduce((t, f) => t + f.zetels, 0);

  function wissel(afkorting: string) {
    const huidig = groep.map((id) => zaal.find((f) => f.id === id)!.afkorting);
    const nieuw = huidig.includes(afkorting) ? huidig.filter((a) => a !== afkorting) : [...huidig, afkorting];
    const q = new URLSearchParams(zoek.toString());
    if (nieuw.length) q.set("groep", nieuw.join(","));
    else q.delete("groep");
    router.replace(`${pad}?${q.toString()}`, { scroll: false });
  }

  const zetelLijst = useMemo(() => zetelsVan(zaal.map((f) => ({ id: f.id, zetels: f.zetels }))), [zaal]);
  const vakLijst = useMemo(() => vakken(zetelLijst, zaal.map((f) => f.id)), [zetelLijst, zaal]);
  const perId = new Map(zaal.map((f) => [f.id, f]));
  const kleur = (id: string | null) => {
    if (!id) return null;
    if (groep.includes(id)) return "var(--koper)";
    const p = perPartner.get(id);
    return p && uitkomst?.eensgezind ? schaalkleur(p.aandeel) : null;
  };
  const tekort = MEERDERHEID - zetelsGroep;

  return (
    <div className={s.verkenner}>
      <svg viewBox="-60 -50 1120 555" className={s.zaal} role="img" aria-label={`Zaal; gekozen groep: ${zetelsGroep} zetels`}>
        {vakLijst.map((v, i) => {
          const f = perId.get(v.fractie)!;
          const inGroep = groep.includes(f.id);
          const p = perPartner.get(f.id);
          const l = punt(i % 2 ? 488 : 462, v.midden);
          const t1 = punt(447, v.midden);
          const t2 = punt((i % 2 ? 488 : 462) - 14, v.midden);
          return (
            <g key={f.id} className={s.vakGroep} onClick={() => wissel(f.afkorting)} onMouseEnter={() => setHover(f.id)} onMouseLeave={() => setHover(null)}>
              <path d={sector(132, 443, v.van, v.tot)} className={s.vak} data-gekozen={inGroep} data-aan={hover === f.id} />
              <line x1={t1.x} y1={t1.y} x2={t2.x} y2={t2.y} className={s.labellijn} />
              <text x={l.x} y={l.y} textAnchor={l.x < MIDDEN.x - 40 ? "end" : l.x > MIDDEN.x + 40 ? "start" : "middle"}
                dominantBaseline="middle" className={s.label} data-gekozen={inGroep}>
                {f.afkorting.replace(/^Groep /, "Gr. ")}{" "}
                <tspan className={s.labelwaarde}>{inGroep ? `${f.zetels}` : p && uitkomst?.eensgezind ? procent(p.aandeel) : ""}</tspan>
              </text>
            </g>
          );
        })}
        {zetelLijst.map((z, i) => {
          const k = kleur(z.fractie);
          return (
            <circle key={i} cx={z.x.toFixed(1)} cy={z.y.toFixed(1)} r={10.5}
              className={z.fractie == null ? s.leeg : s.zetel} style={{ fill: k ?? undefined }}
              onClick={() => { const f = z.fractie ? perId.get(z.fractie) : undefined; if (f) wissel(f.afkorting); }} />
          );
        })}
        <g className={s.uitlees} aria-hidden="true">
          <text x={MIDDEN.x} y={MIDDEN.y - 78} className={s.uitleesKlein}>{groep.length ? "Gekozen groep" : "Kies fracties"}</text>
          <text x={MIDDEN.x} y={MIDDEN.y - 26} className={s.uitleesGroot}>{groep.length ? `${zetelsGroep} zetels` : "0"}</text>
          <text x={MIDDEN.x} y={MIDDEN.y + 4} className={s.uitleesKlein}>
            {groep.length ? (tekort > 0 ? `${tekort} tekort voor een meerderheid` : `meerderheid, ${-tekort + 1} over`) : "klik op een fractie"}
          </text>
        </g>
      </svg>

      <div className={s.knoppen} role="group" aria-label="Stel een groep fracties samen">
        {zaal.map((f) => (
          <button key={f.id} type="button" aria-pressed={groep.includes(f.id)} onClick={() => wissel(f.afkorting)}>
            {f.afkorting}
            <span className={s.knopwaarde}>{f.zetels}</span>
          </button>
        ))}
      </div>

      <p className="verborgen" aria-live="polite">
        {groep.length ? `Gekozen groep: ${zetelsGroep} zetels.` : "Nog geen fracties gekozen."}
        {uitkomst ? ` Eensgezind in ${uitkomst.eensgezind} stemmingen, met een meerderheid in ${uitkomst.meerderheid}.` : ""}
      </p>

      {fout && <Tekst>{fout}</Tekst>}
      {!fout && groep.length > 0 && !uitkomst && <Data>Stemmingen laden…</Data>}
      {uitkomst && (
        <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
          <Label>Bij wie haalde deze groep een meerderheid? · {periode}</Label>
          {uitkomst.eensgezind < 25 ? (
            <Tekst>
              Deze groep stemde maar {uitkomst.eensgezind} keer eensgezind in deze periode: te weinig om iets over te zeggen.
            </Tekst>
          ) : (
            <>
              <Tekst>
                De groep stemde {getal(uitkomst.eensgezind)} keer eensgezind. Daarvan won de kant van de groep{" "}
                {getal(uitkomst.meerderheid)} keer ({procent((100 * uitkomst.meerderheid) / uitkomst.eensgezind)}), en{" "}
                {getal(uitkomst.zonderHulp)} keer op eigen kracht.
              </Tekst>
              <ol className={s.partners}>
                {uitkomst.partners.map((p) => (
                  <li key={p.id}>
                    <span>{p.afkorting}</span>
                    <span className={s.partnerBalk}>
                      <span style={{ width: `${p.aandeel}%`, background: schaalkleur(p.aandeel) }} />
                    </span>
                    <span className={s.knopwaarde}>meegestemd {procent(p.aandeel)}</span>
                    <span className={s.knopwaarde}>{getal(p.beslissend)} keer beslissend</span>
                  </li>
                ))}
              </ol>
              <Data>
                Meegestemd: hoe vaak de fractie dezelfde kant koos als de groep. Beslissend: de groep had de meerderheid, en zonder
                deze fractie niet meer. Zetels van het moment van de stemming.
              </Data>
            </>
          )}
        </section>
      )}
    </div>
  );
}
