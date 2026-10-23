# STATUS

Laatst bijgewerkt: 23 oktober 2026

## Huidige fase

Fase 4: koppelen en bouwen (stap 9). Het plan en het ontwerp staan in de repo `zetelen`; het eerste component, `repo-ci`, is klaar.

## Afgerond

- Stap 1: `01-idee.md` (akkoord Niels)
- Stap 2 en 3: `02-beoordeling.md`, drie iteraties
- Stap 5: `05-techniek.md` (akkoord Niels)
- Stap 6 en 7: `06-epics.md` (R1 niet kleiner gemaakt, besluit Niels)
- Stap 8: `08-componenten/` met `_conventies.md`, `_overzicht.md` en 16 componenten voor R1
- Stap 9, voorbereiding: `09-koppelingen.md`, `CLAUDE-snippet.md`, `BRIEFING.md`
- Handmatige API-check (23 oktober 2026): uitkomst in `api-check-handmatig.md`, verwerkt in `06-epics.md` (E1-S4, E1-S8, E2-S1, E6-S1)
- Ontwerp (23 oktober 2026): in `docs/ontwerp/`, verwerkt in `06-epics.md` (E3-S2) en `08-componenten/ontwerpsysteem.md`
- Repo `zetelen` aangemaakt met plan, ontwerp en `CLAUDE.md` (23 oktober 2026). Supabase en Vercel zijn nog niet gekoppeld
- Component `repo-ci` (23 oktober 2026): secret scan (gitleaks), CI-placeholder, README, pull request-sjabloon en `docs/onderhoud.md` met het onderhoudspad voor de 60-dagenregel. Getest: de scan faalt op een nepsleutel in een testbranch en slaagt op `main`

## Openstaand

- Secret scanning met push protection van GitHub aanzetten (voorstel Claude, 23 oktober 2026): blokkeert een sleutel al voor de push, gitleaks vindt hem pas erna. Instelling voor Niels
- Component `api-check`: het volledige rapport, met de telling per jaar vanaf 2010 en een grootte-schatting van de raw-laag
- Controles op de naam Zetelen (zie `01-idee.md`), domein registreren
- Demissionaire periodes (voorstel: tellen bij het kabinet waar ze uit voortkomen) en de bron van de handmatige kabinettentabel; periodesoorten en standaard zijn besloten
- Reactietermijn bij foutmelding. De drempel "te weinig data" (25) is besloten, maar nog te toetsen na de API-check
- Meetmoment en meetmethode van 500 bezoekers per maand
- Gebruiksvoorwaarden open data, foto-licentie, beleid bij verwijderverzoek
- Invalshoeken voor de lezingen bij het wetgevingsproces en de Kamerleden (bij cohesie besloten: samenwerking tegenover profilering, 22 oktober 2026)
- Blijven rankings van individuele Kamerleden in scope
- Gerichte controle op bestaande sites
- R2 tot en met R4 en Later: componenten nog niet uitgewerkt
- Afwijkend stemgedrag (E6-S1): met ongeveer 540 hoofdelijke stemmingen over de hele dataset is de dekking klein; beslissing na de telling per jaar
- Supabase Free (500 MB): ruim een miljoen stemmingen plus indexes kan krap worden; meten bij `ingest` (schatting Claude, niet gemeten)

## Uitkomst handmatige API-check

23 oktober 2026, details in `api-check-handmatig.md`. De API werkt zonder registratie. Individuele stemmen bestaan vrijwel alleen bij hoofdelijke stemmingen (538 besluiten 'Hoofdelijk', 561 met een persoonsstem, tegen 63.719 met handopsteken). Wijzigingen en verwijderingen zijn herkenbaar via `ApiGewijzigdOp` en `Verwijderd`. Er zijn geen kabinetten in de API. Stemming en Besluit hebben geen datum; die komt via Agendapunt en Activiteit.

## Besluit: ontwerp

Besluit Niels, 23 oktober 2026. Het ontwerp "nacht met koperlicht" in `docs/ontwerp/` is de basis voor de frontend. Het is gemaakt op een eerdere versie van de design-prompt; op vier punten (periodes, schakelaar verdeelde stemmingen, drempel, naam) gaat het plan voor, zie `08-componenten/ontwerpsysteem.md`.

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

Besluit Niels, 22 oktober 2026. Twee periodesoorten, kabinet (standaard, herkenbaarder voor het publiek) en Kamerperiode. Verwerkt in `06-epics.md` (E2-S4, nieuwe E1-S8), `core-model.md`, `cohesie-analyse.md`, `cohesie-pagina.md`. Kabinetten komen uit een handmatige tabel; de API bevat ze niet (handmatige API-check, 23 oktober 2026). Coalitie en oppositie als latere lezing is niet in R1.

## Gebruiksvoorwaarden open data

Op data.overheid.nl staat de dataset met licentie CC0 1.0 (22 oktober 2026). De licentielink in de sectie "Hergebruik" is daar leeg en de API-pagina op developer.overheid.nl vermeldt niets over licentie of limieten. Niet gecontroleerd: foto's van Kamerleden, tekst van documenten, persoonsgegevens. Voorstel voor de voetnoot: de bron noemen, ook al is dat niet verplicht.

## Vragen aan Niels

Geen openstaand.

## Eerstvolgende actie

Component `api-check`.
