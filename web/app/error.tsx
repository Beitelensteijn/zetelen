"use client";
// Foutpagina (E3-S9): geen technische details voor de bezoeker
import { FoutStaat, Inhoud, knopKlasse } from "@/components/Kader";

export default function Fout({ reset }: { error: Error; reset: () => void }) {
  return (
    <Inhoud>
      <FoutStaat
        titel="De cijfers konden niet worden geladen"
        uitleg="De gegevens zijn nu waarschijnlijk niet bereikbaar. Probeer het over een paar minuten opnieuw."
        kinderen={
          <button type="button" className={knopKlasse} onClick={() => reset()}>
            Probeer opnieuw
          </button>
        }
      />
    </Inhoud>
  );
}
