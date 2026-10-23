# Component: ontwerpsysteem

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`

## Doel

Een vastgelegd ontwerpsysteem (kleuren, typografie, grafiekstijl, spacing) zodat elke pagina en elk component er hetzelfde uitziet. Stijl: journalistiek, sober en strak, in de geest van The Economist maar met een eigen kleurpalet en zonder merkelementen over te nemen.

## Laag

Frontend

## Interface

Biedt:
- Een ontwerpbestand met tokens (kleuren, typografie, spacing)
- Basiscomponenten (tekst, kop, kaart, tabel, grafiekkader, lezingenblok-opmaak)
- Een grafiekstijl voor de matrix en latere grafieken

Verwacht: de eerste frontendrepo-structuur uit `repo-ci`.

## Afhankelijkheden

`repo-ci`.

## Stories

**E3-S2 Ontwerpsysteem.** Als beheerder wil ik een vastgelegd ontwerpsysteem.
- Kleuren, typografie, grafiekstijl en spacing zijn vastgelegd in een bestand en in tokens
- Het palet is eigen: de stijl is journalistiek en sober in de geest van The Economist, zonder diens merkelementen over te nemen
- Contrast voldoet aan WCAG AA
- Er staan geen partijlogo's en geen partijkleuren in het ontwerpsysteem of op de site in R1; partijen worden getoond met naam en afkorting in het eigen palet

## Testen

- Contrastcontrole van alle kleurcombinaties tegen WCAG AA
- Een voorbeeldpagina met alle basiscomponenten, bekeken op een telefoon en op een groot scherm
- Controle dat er geen logo's, lettertypes of kleurcodes van het voorbeeldmerk in staan

## Aandachtspunten

- De kleurenschaal voor de matrix moet leesbaar zijn voor kleurenblinde bezoekers (zie `cohesie-pagina`)
- Het palet is nog niet gekozen. Dat is een ontwerpkeuze van Niels; leg minstens twee voorstellen voor
- Een design-skill voor frontend is op Niels' laptop beschikbaar; gebruik die waar het past
- Letterwoordmerk Zetelen in Newsreader, kleine kapitalen, zonder logo. De toon van de microcopy staat in `../claude-design-prompt.md`

## Schatting

Middel, ca. 6 tot 10 uur van Niels (vooral kiezen en beoordelen). Grove schatting, niet gemeten.
