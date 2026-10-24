// Voorpagina (E3-S1). De eerste conclusie komt na akkoord van Niels.
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
        <Label>Verkenner</Label>
        <SectieKop>Elke fractie tegenover elke andere</SectieKop>
        <Tekst>
          Kies een fractie in de zaal en zie hoe vaak de andere fracties met haar meestemden, per kabinet of per
          Kamerperiode. De site is in aanbouw en niet vindbaar in zoekmachines; de eerste conclusie volgt.
        </Tekst>
        <Link href="/verkenner" className={knopKlasse}>
          Naar de verkenner
        </Link>
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
