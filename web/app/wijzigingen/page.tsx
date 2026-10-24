// Wijzigingslog (E7-S3): elke inhoudelijke correctie, met datum
import type { Metadata } from "next";
import { Inhoud } from "@/components/Kader";
import { Data, HeroKop, Label, Tekst } from "@/components/Typografie";
import { WIJZIGINGEN } from "@/lib/wijzigingen";

export const metadata: Metadata = { title: "Wijzigingen", description: "Alle inhoudelijke correcties op Zetelen, met datum." };

export default function Wijzigingen() {
  return (
    <Inhoud>
      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
        <Label>Wijzigingslog</Label>
        <HeroKop>Wat er is gecorrigeerd</HeroKop>
        <Tekst>
          Elke inhoudelijke correctie van een cijfer of tekst staat hier, met datum. Dagelijkse verversingen van de data
          staan er niet in; die zijn geen correctie.
        </Tekst>
      </section>
      {WIJZIGINGEN.length === 0 ? (
        <Tekst>Er zijn nog geen correcties.</Tekst>
      ) : (
        <ol style={{ listStyle: "none", margin: 0, padding: 0, display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
          {WIJZIGINGEN.map((w) => (
            <li key={`${w.datum}-${w.pagina}-${w.beschrijving.slice(0, 20)}`} style={{ display: "flex", flexDirection: "column", gap: 4 }}>
              <Data>{new Date(w.datum).toLocaleDateString("nl-NL", { day: "numeric", month: "long", year: "numeric" })} · {w.pagina}</Data>
              <Tekst>{w.beschrijving}</Tekst>
            </li>
          ))}
        </ol>
      )}
    </Inhoud>
  );
}
