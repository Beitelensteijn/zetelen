// Tijdelijke voorpagina; de echte voorpagina bouwt component site-shell (E3-S1)
import { HeroKop, Label, Tekst } from "@/components/Typografie";

export default function Voorpagina() {
  return (
    <main style={{ maxWidth: "var(--pagina-max)", margin: "0 auto", padding: "var(--r-8) var(--pagina-marge)", display: "flex", flexDirection: "column", gap: "var(--r-5)" }}>
      <Label>In aanbouw</Label>
      <HeroKop>Zetelen</HeroKop>
      <Tekst>Hoe vaak stemmen fracties in de Tweede Kamer hetzelfde? Deze site is in aanbouw.</Tekst>
    </main>
  );
}
