# Component: site-shell

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`, `ontwerpsysteem.md`

## Doel

De basis van de Next.js-site: navigatie, voorpagina, over-de-maker-pagina, delen en zoekmachines, en lege- en foutstaten.

## Laag

Frontend

## Interface

Biedt:
- Paginastructuur en navigatie
- De voorpagina met een doorklik naar de verkenner
- Een over-de-maker-pagina
- Standaard titel, beschrijving en deelafbeelding per pagina, en een sitemap
- Een standaard lege staat en foutstaat

Verwacht: de tokens en basiscomponenten van `ontwerpsysteem`, de "laatst bijgewerkt"-datum van `bewaking` (view `api.laatst_bijgewerkt`, kolom `laatst_bijgewerkt`, via de Data API met de publieke sleutel; zie `rechten.md`).

## Afhankelijkheden

`ontwerpsysteem`. Voor de "laatst bijgewerkt"-datum: `bewaking` (kan met een tijdelijke waarde starten).

## Stories

**E3-S1 Voorpagina.** Als bezoeker wil ik een korte verhalende voorpagina met een eerste vondst en een doorklik naar de verkenner.
- De voorpagina bevat minstens een door Niels goedgekeurde conclusie met bron
- Een "laatst bijgewerkt"-datum staat zichtbaar
- Overgenomen van `rechten` (E1-S6): een test op de gebouwde frontend zoekt naar de `service_role`- of secret-sleutel en naar alles wat op een geheim lijkt, en faalt als er iets gevonden wordt
- Een link naar de cohesie-verkenner en naar de methodiekpagina

**E3-S4 Delen en zoekmachines.** Elke publieke pagina kan gedeeld worden en is vindbaar.
- Elke publieke pagina heeft een eigen URL, titel, beschrijving en voorbeeldafbeelding voor delen
- Er is een sitemap

**E3-S7 Over de maker.** Als bezoeker wil ik weten wie de site maakt.
- Een pagina toont de maker onder eigen naam, het doel van de site, en hoe fouten gemeld worden

**E3-S9 Lege en foutstaten.** Als bezoeker wil ik een duidelijke melding als er niets te tonen is of iets misgaat.
- Een periode of fractie zonder data toont een uitleg en geen lege grafiek
- Als de database onbereikbaar is, toont de site de laatst bekende goede versie (indien beschikbaar) of een nette foutpagina

## Testen

- Controleer per pagina titel, beschrijving en deelafbeelding
- Open een periode zonder data: er staat een uitleg
- Zet de database tijdelijk uit (in een testomgeving): de site toont de foutpagina of de laatste goede versie
- De sitemap bevat alle publieke pagina's

## Aandachtspunten

- De inhoud van de voorpagina (de eerste conclusie) bestaat pas als de cohesie-analyse draait en Niels hem heeft goedgekeurd; bouw eerst het raamwerk
- Over-de-maker bevat alleen wat Niels wil publiceren; neem geen persoonlijke gegevens over uit andere bronnen

## Schatting

Middel, ca. 8 tot 14 uur van Niels. Grove schatting, niet gemeten.
