# Component: bewaking

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`

## Doel

Zorgen dat de dagelijkse verversing niet stilletjes stopt, en dat Niels een runbook heeft voor de bekende storingen.

## Laag

Backend

## Interface

Biedt:
- Een melding als er na een bepaald aantal dagen geen succesvolle verversing is geweest
- Een runbook van een pagina in `docs/`
- Een bron voor de "laatst bijgewerkt"-datum op de site (bijvoorbeeld een tabel met de laatste succesvolle run)

Verwacht: de workflow en het logboek van `ingest`.

## Afhankelijkheden

`ingest`.

## Stories

**E1-S7 Bewaking en runbook.** Als beheerder wil ik weten wanneer de verversing uitblijft.
- Er is een melding als er na een bepaald aantal dagen geen succesvolle run is geweest (drempel: voorstel 2 dagen)
- Er is een runbook van een pagina: een workflow heractiveren, een pauzering van Supabase opheffen, een mislukte run herhalen
- De site toont een "laatst bijgewerkt"-datum (zie E3-S1 in `site-shell`)

## Testen

- Simuleer een uitgeschakelde workflow (zet hem uit) en controleer dat de melding komt binnen de gekozen drempel
- Loop het runbook stap voor stap door op een testbranch of testproject: elke stap werkt zoals beschreven

## Aandachtspunten

- Een geplande workflow in een publieke repo wordt na 60 dagen zonder repo-activiteit automatisch uitgeschakeld. De bewaking mag zelf niet op dezelfde workflow leunen, anders valt hij samen met wat hij bewaakt. Overweeg een apart controlekanaal (bijvoorbeeld een controle vanuit een andere workflow of een externe dienst)
- Hoe repo-activiteit telt voor de 60-dagenregel is niet gecontroleerd; test dat tijdens dit component
- Of Supabase Free pauzeert ondanks een dagelijkse schrijfjob is niet bekend; leg de bevinding vast

## Schatting

Klein, ca. 3 tot 5 uur van Niels. Grove schatting, niet gemeten.
