// Voorpagina (E3-S1). De eerste conclusie en de zaal komen na cohesie-pagina en na akkoord van Niels.
import Link from "next/link";
import { Inhoud, knopKlasse } from "@/components/Kader";
import { Kaart } from "@/components/Onderdelen";
import { HeroKop, Label, SectieKop, Tekst } from "@/components/Typografie";

export default function Voorpagina() {
  return (
    <Inhoud>
      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-5)", maxWidth: 860 }}>
        <Label>Cohesie</Label>
        <HeroKop>Hoe vaak stemmen fracties hetzelfde?</HeroKop>
        <Tekst>
          Zetelen telt op hoeveel stemmingen in de Tweede Kamer twee fracties dezelfde kant kozen, sinds 2010, per
          kabinet en per Kamerperiode. Bij elke uitkomst staan twee lezingen naast elkaar, zodat je zelf kunt
          oordelen wat een percentage betekent.
        </Tekst>
      </section>

      <Kaart>
        <Label>In aanbouw</Label>
        <SectieKop>De zaal komt hier</SectieKop>
        <Tekst>
          Kies straks een fractie in de zaal en zie hoe vaak de andere fracties met haar meestemden. Tot die tijd
          is deze site in aanbouw en niet vindbaar in zoekmachines.
        </Tekst>
      </Kaart>

      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
        <Label>Over</Label>
        <Tekst>Wie maakt dit, met welke data, en hoe meld je een fout?</Tekst>
        <Link href="/over" className={knopKlasse}>
          Over Zetelen
        </Link>
      </section>
    </Inhoud>
  );
}
