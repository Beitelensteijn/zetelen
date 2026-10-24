// Bron en verversingsdatum bij elke grafiek (E7-S1)
import { Data } from "@/components/Typografie";
import { datumTekst, laatstBijgewerkt } from "@/lib/api";
import { SITE } from "@/lib/site";

export async function Bronregel({ toelichting }: { toelichting: string }) {
  const ververst = await laatstBijgewerkt();
  return (
    <Data>
      Bron: <a href={SITE.bron}>Tweede Kamer open data</a>, eigen berekening · {toelichting} · Laatst ververst:{" "}
      {ververst ? datumTekst(ververst) : "onbekend"}
    </Data>
  );
}
