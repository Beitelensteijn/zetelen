# Component: ontwerpsysteem

Status: gebouwd en getest (24 oktober 2026); Niels heeft de voorbeeldpagina bekeken en goedgekeurd
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../../ontwerp/HANDOVER.md`

## Doel

Een vastgelegd ontwerpsysteem (kleuren, typografie, grafiekstijl, spacing) zodat elke pagina en elk component er hetzelfde uitziet. Stijl: "nacht met koperlicht", een diepe, koele donkere basis met warm licht op wat de bezoeker kiest, journalistiek in toon en typografie. Eigen palet, geen merkelementen van een krant. Het ontwerp staat in `../../ontwerp/` (besluit Niels, 23 oktober 2026).

## Laag

Frontend

## Interface

Biedt:
- Een ontwerpbestand met tokens (kleuren, typografie, spacing), overgenomen uit `../../ontwerp/HANDOVER.md` en `../../ontwerp/boards/Ontwerpsysteem.dc.html`
- Basiscomponenten (tekst, kop, kaart, tabel, grafiekkader, lezingenblok-opmaak)
- Een grafiekstijl voor de zaal, de boog, de matrix en latere grafieken

Verwacht: de eerste frontendrepo-structuur uit `repo-ci`.

## Afhankelijkheden

`repo-ci`.

## Stories

**E3-S2 Ontwerpsysteem.** Als beheerder wil ik een vastgelegd ontwerpsysteem.
- Kleuren, typografie, grafiekstijl en spacing zijn vastgelegd in een bestand en in tokens
- Het palet is eigen en volgt het ontwerp in `../../ontwerp/`, zonder merkelementen van The Economist of een andere krant over te nemen
- Contrast voldoet aan WCAG AA
- Er staan geen partijlogo's en geen partijkleuren in het ontwerpsysteem of op de site in R1; partijen worden getoond met naam en afkorting in het eigen palet

## Testen

- Contrastcontrole van alle kleurcombinaties tegen WCAG AA
- Een voorbeeldpagina met alle basiscomponenten, bekeken op een telefoon en op een groot scherm
- Controle dat er geen logo's, lettertypes of kleurcodes van het voorbeeldmerk in staan

## Waar het plan voor het ontwerp gaat

Het ontwerp is gemaakt op een eerdere versie van de design-prompt. Op deze vier punten geldt het plan, niet het ontwerp:

| Punt | In het ontwerp | Geldt (bron) |
|---|---|---|
| Periodes | Zittingsperiode, laatste 12 maanden, laatste 3 maanden | Kabinet (standaard) en Kamerperiode (`../STATUS.md`, besluit periodesoorten) |
| Schakelaar | Ontbreekt | "Alle stemmingen / Alleen verdeelde stemmingen", in de URL (`../STATUS.md`, besluit cohesie) |
| Drempel te weinig data | n < 60 | 25 gezamenlijke stemmingen per variant (`../STATUS.md`, besluit cohesie) |
| Naam | "Sitenaam" | Zetelen (`../STATUS.md`, besluit naam) |

## Aandachtspunten

- De kleurenschaal voor de matrix moet leesbaar zijn voor kleurenblinde bezoekers (zie `cohesie-pagina`); de schaal in het ontwerp is daarop gecontroleerd volgens `HANDOVER.md`, maar niet in een browser bekeken
- De borden zijn geen productiecode: neem tokens, opmaak en de logica uit `renderVals()` over, niet de inline stijlen
- Prestatie: korrel, gloed en de golf door de zaal mogen de norm uit `prestatie-audit` (E3-S8) niet breken; meet dat vroeg
- Een design-skill voor frontend is op Niels' laptop beschikbaar; gebruik die waar het past
- Letterwoordmerk Zetelen in Newsreader, kleine kapitalen, zonder logo. De toon van de microcopy staat in `../claude-design-prompt.md`

## Gebouwd (24 oktober 2026)

Keuzes (akkoord Niels, 24 oktober 2026): Next.js 16 met TypeScript in `web/`; tokens als CSS-variabelen in `web/styles/tokens.css` en CSS Modules per component, geen Tailwind; lettertypes via `next/font` (bij het bouwen meegeleverd, geen verbinding met Google voor bezoekers); geen grafiekbibliotheek, de zaal, boog en matrix worden eigen SVG (sluit het open punt "grafiekbibliotheek" voor R1).

- `web/styles/tokens.css`, `web/lib/kleur.ts` (contrast, cohesieschaal, tekstkleur in een cel)
- `web/components/`: koppen, tekst, label, datalabel, cijfer, woordmerk, kaart, segmentkeuze, uitleesvak, tabel, grafiekkader met bron, lezingenblok, schaallegenda, cohesiecel met arcering, korrel
- `/ontwerpsysteem`: voorbeeldpagina met alle componenten, niet geindexeerd
- CI: job `web` (installeren, testen, bouwen)

## Getest (24 oktober 2026)

- 24 tests: alle tekstkleuren op alle achtergronden halen 4,5; de schaal wordt monotoon lichter; tekst in elke schaalcel haalt 4,5; tokens in CSS en code zijn gelijk
- Bekeken op 1280 en 375 px: geen horizontale scroll op de telefoon, knoppen 44 px, segmentkeuze werkt
- Bevinding: `lijn-licht` haalt 3:1 op nacht-950, -900 en -800, niet op nacht-700 (2,81). Regel vastgelegd in de tokens en een test
- Bevinding: Next.js zet bij elke build willekeurige sleutels in `web/.next` (niet in git). Meenemen in de buildtest van `site-shell`

## Schatting

Middel, ca. 6 tot 10 uur van Niels (vooral kiezen en beoordelen). Grove schatting, niet gemeten. Het palet is gekozen, dus dit valt waarschijnlijk lager uit; bijstellen na het component.
