// Overzicht van de fracties (component cohesie-pagina): nu in de Kamer, en eerdere sinds 2010
import type { Metadata } from "next";
import Link from "next/link";
import { Inhoud, LegeStaat } from "@/components/Kader";
import { Data, Label, SectieKop, Tekst } from "@/components/Typografie";
import { alleFracties, perioden, slug } from "@/lib/cohesie";
import s from "@/components/cohesie/fractie.module.css";

export const metadata: Metadata = {
  title: "Fracties",
  description: "Alle fracties in de Tweede Kamer sinds 2010, met per fractie met wie ze het vaakst hetzelfde stemde.",
};

export default async function Fracties() {
  const [lijst, alle] = await Promise.all([perioden(), alleFracties()]);
  if (!alle || !lijst.length) {
    return (
      <Inhoud>
        <LegeStaat label="Niet bereikbaar" titel="De fracties konden niet worden geladen" uitleg="Probeer het over een paar minuten opnieuw." />
      </Inhoud>
    );
  }
  const nieuwste = lijst.find((p) => p.soort === "kabinet");
  const nu = alle
    .map((f) => ({ f, p: f.perioden.find((p) => p.soort === "kabinet" && p.periode === nieuwste?.naam && p.inZaal) }))
    .filter((x) => x.p)
    .sort((a, b) => b.p!.zetels - a.p!.zetels);
  const eerder = alle.filter((f) => !nu.some((x) => x.f.afkorting === f.afkorting));
  return (
    <Inhoud>
      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
        <Label>Fracties</Label>
        <SectieKop>Met wie stemt een fractie het vaakst hetzelfde?</SectieKop>
        <Tekst>Kies een fractie voor haar cohesie met elke andere fractie, per kabinet of per Kamerperiode.</Tekst>
      </section>
      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
        <Label>Nu in de Kamer · kabinet-{nieuwste?.naam}</Label>
        <ul className={s.raster}>
          {nu.map(({ f, p }) => (
            <li key={f.afkorting}>
              <Link href={`/fracties/${slug(f.afkorting)}`} className={s.tegel}>
                <span className={s.tegelNaam}>{f.afkorting}</span>
                <Data>{f.naam !== f.afkorting ? `${f.naam} · ` : ""}{p!.zetels} zetels</Data>
              </Link>
            </li>
          ))}
        </ul>
      </section>
      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
        <Label>Eerder, sinds 2010</Label>
        <ul className={s.raster}>
          {eerder.map((f) => (
            <li key={f.afkorting}>
              <Link href={`/fracties/${slug(f.afkorting)}`} className={s.tegel}>
                <span className={s.tegelNaam}>{f.afkorting}</span>
                <Data>{f.naam !== f.afkorting ? f.naam : " "}</Data>
              </Link>
            </li>
          ))}
        </ul>
      </section>
    </Inhoud>
  );
}
