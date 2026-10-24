// Coalitiebouwer (componenten coalitie-analyse en coalitie-pagina). CONCEPT: de definitie is nog niet
// goedgekeurd door Niels; de pagina staat daarom niet in het menu en niet in de sitemap.
import type { Metadata } from "next";
import { Suspense } from "react";
import { CoalitieBouwer } from "@/components/coalitie/CoalitieBouwer";
import { Bronregel } from "@/components/cohesie/Bronregel";
import { PeriodeKeuze } from "@/components/cohesie/PeriodeKeuze";
import { Inhoud, LegeStaat } from "@/components/Kader";
import { Kaart } from "@/components/Onderdelen";
import { Label, SectieKop, Tekst } from "@/components/Typografie";
import { cohesieIn, fractiesIn, keuzeUitUrl, perioden } from "@/lib/cohesie";
import { ordenFracties } from "@/lib/ordening";

export const metadata: Metadata = {
  title: "Coalitiebouwer",
  description: "Stel zelf een groep fracties samen en zie bij wie die groep in het verleden een meerderheid haalde.",
  robots: { index: false, follow: false },
};

type Props = { searchParams: Promise<Record<string, string | string[] | undefined>> };

export default async function Coalitie({ searchParams }: Props) {
  const lijst = await perioden();
  const { soort, periode } = keuzeUitUrl(await searchParams, lijst);
  const [fracties, kaart] = periode ? await Promise.all([fractiesIn(soort, periode.naam), cohesieIn(soort, periode.naam, "alle")]) : [null, null];
  return (
    <Inhoud>
      <section style={{ display: "flex", flexDirection: "column", gap: "var(--r-4)" }}>
        <Label>Coalitiebouwer · concept</Label>
        <SectieKop>Bij wie haal je een meerderheid?</SectieKop>
        <Tekst>
          Kies fracties in de zaal en stel zo een (fictief) kabinet samen. Je ziet hun zetels, en bij welke andere fracties
          die groep in de gekozen periode een meerderheid haalde.
        </Tekst>
        <PeriodeKeuze perioden={lijst} soort={soort} periode={periode?.naam ?? null} pad="/coalitie" />
      </section>
      <Kaart>
        <Label>Terugkijken, geen voorspelling</Label>
        <Tekst>
          Dit telt hoe er in het verleden echt is gestemd. Het zegt niets over hoe fracties in de toekomst zouden stemmen, en
          het is geen advies over welke samenwerking goed of wenselijk is.
        </Tekst>
      </Kaart>
      {!periode || !fracties?.length || !kaart ? (
        <LegeStaat label="Geen stemmingen" titel="Geen stemmingen in deze periode" uitleg="Kies een andere periode." />
      ) : (
        <Suspense>
          <CoalitieBouwer fracties={ordenFracties(fracties, kaart)} soort={soort} periode={periode.naam} />
        </Suspense>
      )}
      {periode && <Bronregel toelichting={`${periode.naam} · eigen berekening, zie de methodiek`} />}
    </Inhoud>
  );
}
