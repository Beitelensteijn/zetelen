// Over de maker (E3-S7). Concepttekst van Claude; Niels keurt hem goed.
import type { Metadata } from "next";
import Link from "next/link";
import { Inhoud } from "@/components/Kader";
import { HeroKop, Label, SectieKop, Tekst } from "@/components/Typografie";
import { SITE } from "@/lib/site";

export const metadata: Metadata = {
  title: "Over",
  description: "Wie maakt Zetelen, met welke data, en hoe meld je een fout.",
};

export default function Over() {
  const sectie = { display: "flex", flexDirection: "column" as const, gap: "var(--r-4)" };
  return (
    <Inhoud>
      <section style={sectie}>
        <Label>Over</Label>
        <HeroKop>Over Zetelen</HeroKop>
        <Tekst>
          Zetelen is een onafhankelijk project van {SITE.maker}. Er zit geen organisatie of partij achter. Het doel is
          het stemgedrag in de Tweede Kamer inzichtelijk te maken met openbare data, en daarbij te laten zien dat
          een cijfer meer dan een lezing kent.
        </Tekst>
      </section>

      <section style={sectie}>
        <SectieKop>De data</SectieKop>
        <Tekst>
          Alle cijfers komen uit de open data van de Tweede Kamer. Een script haalt die elke dag op, rekent de
          analyses uit en controleert de uitkomst, onder meer tegen de officiële uitslagen. De broncode en de
          berekeningen zijn openbaar.
        </Tekst>
        <Tekst>
          <a href={SITE.broncode}>Bekijk de broncode op GitHub</a>
        </Tekst>
      </section>

      <section style={sectie}>
        <SectieKop>Een fout melden</SectieKop>
        <Tekst>
          Zie je een cijfer dat niet klopt? Mail <a href={`mailto:${SITE.contact}`}>{SITE.contact}</a> of meld het
          op <a href={`${SITE.broncode}/issues`}>GitHub</a>. Noem de pagina en wat je verwachtte. Elke
          correctie komt in het <Link href="/wijzigingen">wijzigingslog</Link>.
        </Tekst>
      </section>
    </Inhoud>
  );
}
