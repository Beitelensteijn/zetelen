# STATUS

Laatst bijgewerkt: 22 oktober 2026

## Huidige fase

Fase 4: koppelen en bouwen (stap 9). Het plan staat; er is nog niets gebouwd.

## Afgerond

- Stap 1: `01-idee.md` (akkoord Niels)
- Stap 2 en 3: `02-beoordeling.md`, drie iteraties
- Stap 5: `05-techniek.md` (akkoord Niels)
- Stap 6 en 7: `06-epics.md` (R1 niet kleiner gemaakt, besluit Niels)
- Stap 8: `08-componenten/` met `_conventies.md`, `_overzicht.md` en 16 componenten voor R1
- Stap 9, voorbereiding: `09-koppelingen.md`, `CLAUDE-snippet.md`, `BRIEFING.md`. De koppelingen zelf zijn niet uitgevoerd

## Openstaand

- API-check (handmatig, zie `BRIEFING.md`), daarna component `api-check`
- Controles op de naam Zetelen (zie `01-idee.md`), domein registreren, naam van de repo
- Demissionaire periodes (voorstel: tellen bij het kabinet waar ze uit voortkomen) en de bron van de handmatige kabinettentabel; periodesoorten en standaard zijn besloten
- Reactietermijn bij foutmelding. De drempel "te weinig data" (25) is besloten, maar nog te toetsen na de API-check
- Meetmoment en meetmethode van 500 bezoekers per maand
- Gebruiksvoorwaarden open data, foto-licentie, beleid bij verwijderverzoek
- Invalshoeken voor de lezingen bij het wetgevingsproces en de Kamerleden (bij cohesie besloten: samenwerking tegenover profilering, 22 oktober 2026)
- Blijven rankings van individuele Kamerleden in scope
- Gerichte controle op bestaande sites
- R2 tot en met R4 en Later: componenten nog niet uitgewerkt

## Idee voor Later: Eerste Kamer

Opgenomen op verzoek van Niels (22 oktober 2026) in `01-idee.md` en `06-epics.md` (E8-S4) als Later. In de eerste zoekronde vond ik geen vergelijkbare open data API; niet uitputtend onderzocht. Eerste stap bij oppakken: een gerichte controle van de bronnen.

## Fracties op 22 oktober 2026

De Tweede Kamer toont 17 fracties met samen 150 zetels. Twee daarvan zijn geen gevestigde partij: Groep Markuszower (7 zetels) en Lid Keijzer (1 zetel). Dat bevestigt dat fracties door de tijd veranderen, wat het datamodel (E1-S5) moet kunnen dragen.

## Besluit: geen partijlogo's of partijkleuren in R1

Besluit Niels, 22 oktober 2026. Partijen worden getoond met naam en afkorting in het eigen palet. Verwerkt in `01-idee.md`, `06-epics.md` (E3-S2) en de componenten `ontwerpsysteem`, `cohesie-pagina` en `core-model`. Gevonden: officiële huisstijl-PDF's van CDA en ChristenUnie, en logodownloads van Volt Europa met de voorwaarde dat derden vooraf toestemming nodig hebben (behalve redactioneel gebruik door media). Voor 11 andere partijen vond ik geen officiële huisstijl of logopagina; de zoekronde was grof.

## Besluit: naam Zetelen

Besluit Niels, 22 oktober 2026. Journalistiek met een speelse knipoog; een hobbyproject onder eigen naam. Verwerkt in `01-idee.md`, `08-componenten/ontwerpsysteem.md` en `claude-design-prompt.md`. Reden voor het werkwoord (door Claude aangedragen): het geeft herhaalbare formules voor de microcopy. Niet gecontroleerd: betekenis van het woord, merkenregister, zoekresultaten, sociale handles, domeinvoorwaarden.

## Besluit: cohesie en drempel

Besluit Niels, 22 oktober 2026. Cohesie is het percentage gezamenlijke stemmingen met dezelfde stem; twee varianten met een schakelaar (alle stemmingen, alleen verdeelde stemmingen); drempel 25 gezamenlijke stemmingen per variant. Verwerkt in `08-componenten/cohesie-analyse.md`, `cohesie-pagina.md` en `01-idee.md`. De definitie van "verdeeld" (niet unaniem) is een voorstel van Claude en de drempel is grof gekozen; beide zijn te toetsen na de API-check.

## Besluit: periodesoorten

Besluit Niels, 22 oktober 2026. Twee periodesoorten, kabinet (standaard, herkenbaarder voor het publiek) en Kamerperiode. Verwerkt in `06-epics.md` (E2-S4, nieuwe E1-S8), `core-model.md`, `cohesie-analyse.md`, `cohesie-pagina.md`. Kabinetten komen uit een handmatige tabel; of de API ze bevat is niet vastgesteld. Coalitie en oppositie als latere lezing is niet in R1.

## Gebruiksvoorwaarden open data

Op data.overheid.nl staat de dataset met licentie CC0 1.0 (22 oktober 2026). De licentielink in de sectie "Hergebruik" is daar leeg en de API-pagina op developer.overheid.nl vermeldt niets over licentie of limieten. Niet gecontroleerd: foto's van Kamerleden, tekst van documenten, persoonsgegevens. Voorstel voor de voetnoot: de bron noemen, ook al is dat niet verplicht.

## Vragen aan Niels

Geen openstaand.

## Eerstvolgende actie

Niels doet de handmatige API-check en start Claude Code met de opdracht uit `BRIEFING.md`. Daarna component `repo-ci`, dan `api-check`.
