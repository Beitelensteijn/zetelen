# Briefing: Tweede Kamer data-website

Voor: Niels, op je eigen laptop, vrijdag 23 oktober 2026
Opgesteld: 22 oktober 2026

## In drie zinnen

Een publieke website over de Tweede Kamer, gebouwd op de open data van de Kamer. Een Python-script ververst dagelijks een Supabase-database, de analyses draaien in SQL, en een Next.js-site op Vercel toont ze, met bij elke analyse twee onderbouwde lezingen naast elkaar. De eerste live-gang bevat alleen de cohesie-analyse tussen fracties.

## Wat vaststaat (jouw keuzes)

- Website onder je eigen naam, geen Power BI
- Vier analyses: cohesie van fracties, afwijkend stemgedrag, wetgevingsproces en aanname, activiteit per Kamerlid
- Gefaseerd live: cohesie eerst, daarna proces, daarna Kamerleden. Engels pas als alle vier live zijn
- Twee lezingen naast elkaar bij elke analyse, handgeschreven sjablonen, jij keurt goed. Geen account, geen opgeslagen opvattingen
- Succes: live en 500 bezoekers per maand
- Python in GitHub Actions, Supabase, Next.js op Vercel, publieke repo, nieuw project
- Gratis beginnen, tot ca. 25 euro per maand
- Stijl: journalistiek en strak, eigen kleurpalet
- Jij reviewt, Claude Code bouwt, een component tegelijk
- R1 is niet kleiner gemaakt

## Wat ik niet kon controleren

- **De live API.** Ik kon hem niet bevragen. Basis-URL en JSON-formaat zijn bevestigd, maar toegang, veldnamen, volume en of individuele stemmen beschikbaar zijn, niet. Daarom staan er in het plan geen veld- of kolomnamen.
- Of Supabase Free past bij het volume, en of een dagelijkse schrijfjob de pauzering voorkomt.
- Hoe repo-activiteit telt voor de 60-dagenregel van GitHub Actions.
- Gebruiksvoorwaarden van de open data.
- Een Eerste Kamer-uitbreiding: in mijn zoekopdrachten vond ik geen vergelijkbare API. Niet onderzocht, staat als Later-idee.

## Wat ik verwacht dat tegenvalt

- **Afwijkend stemgedrag.** De Kamer stemt standaard per fractie. Individuele stemmen bestaan vermoedelijk alleen bij hoofdelijke stemmingen. Een van je vier must-haves rust daarop.
- **Tijd.** R1 is 16 componenten en grof geschat 83 tot 152 uur van jou. Bij 6 tot 10 uur per week is dat 8 tot 25 weken. Het is een gokschatting zonder meting; stel hem bij na het eerste component.

## Morgen, in volgorde

**1. API-check, handmatig (ca. 10 minuten).** Op een Mac: gebruik `api-check/api-check-mac.md` met `api-check/api_check.py` (Python, logica getest met nagebootste antwoorden, niet tegen de live API). Op Windows: de PowerShell-versie hieronder. Die heb ik niet getest.

```powershell
$base = 'https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0'

# a. Werkt de toegang zonder registratie? Verwacht: JSON met een record
$r = Invoke-RestMethod -Uri ($base + '/Stemming?$top=1&$count=true')
$r | ConvertTo-Json -Depth 5
$r.'@odata.count'

# b. Alle entiteiten en velden opslaan
Invoke-WebRequest -Uri ($base + '/$metadata') -OutFile .\metadata.xml
```

Zoek in de uitvoer van a het veld dat een persoon aan de stemming koppelt, en tel dan hoeveel stemmingen een persoon hebben (vervang `<veldnaam>`):

```powershell
$p = Invoke-RestMethod -Uri ($base + '/Stemming?$filter=<veldnaam>%20ne%20null&$top=1&$count=true')
$p.'@odata.count'
```

Vergelijk dat aantal met het totaal uit a. Past het in de verwachting dat individuele stemmen alleen bij hoofdelijke stemmingen bestaan? Meldt de API een fout of vraagt hij om registratie of een IP-adres, noteer dan de melding.

**2. Het plan in de repo.** Maak de repo (zie `09-koppelingen.md`), kopieer `docs/plan/` erin, en zet de tekst uit `CLAUDE-snippet.md` in `CLAUDE.md`.

**3. Start Claude Code in de repo** en geef deze opdracht:

> Lees `docs/plan/BRIEFING.md`, `docs/plan/STATUS.md` en `docs/plan/08-componenten/_overzicht.md`. Ik heb de API-check handmatig gedaan, dit is de uitkomst: [plak je aantekeningen, zonder sleutels]. Werk waar nodig `06-epics.md` en `STATUS.md` bij en laat de wijzigingen eerst zien. Begin daarna met het component `repo-ci`.

**4. Bouw per component** volgens `_overzicht.md`. Na `api-check` stoppen: het rapport kan het plan wijzigen.

## Beslissingen die op jou wachten

| Beslissing | Waar | Wanneer nodig |
|---|---|---|
| Naam en domein van de site | `01-idee.md` | Voor koppelen van Vercel |
| Demissionaire periodes (voorstel: tellen bij het kabinet waar ze uit voortkomen) en bron van de kabinettentabel (E1-S8); periodesoorten besloten: kabinet standaard, Kamerperiode | `cohesie-analyse.md` | Voor de definitie van cohesie |
| Drempel "te weinig data": besloten op 25 gezamenlijke stemmingen, te toetsen | `06-epics.md` E2-S2, E6-S2 | Na de API-check |
| Invalshoeken van de lezingen bij wetgevingsproces en Kamerleden (bij cohesie besloten: samenwerking tegenover profilering) | `01-idee.md` | Voor `lezingen` in R2 en R3 |
| Blijven rankings van individuele Kamerleden in scope | `01-idee.md` | R3 |
| Meetmoment van de 500 bezoekers | `01-idee.md` | Voor `analytics` |
| Adres voor foutmeldingen en reactietermijn | `06-epics.md` E7-S2 | Voor `methodiek-betrouwbaarheid` |
| Grafiekbibliotheek en analytics-tool | `05-techniek.md` | Bij `cohesie-pagina` en `analytics` |
| Beleid bij verwijderverzoek van een Kamerlid | `06-epics.md` | Voor de eerste live-gang |
| Eerste Kamer als Later-idee opnemen | `STATUS.md` | Eenvoudig, wanneer je wilt |

## Bestanden

| Bestand | Wat |
|---|---|
| `STATUS.md` | Waar we staan en wat openstaat |
| `01-idee.md` | Doel, doelgroep, scope, toon, randvoorwaarden |
| `02-beoordeling.md` | Scores, aannames, zelfbeoordeling in drie rondes |
| `05-techniek.md` | Stack, beperkingen, security |
| `06-epics.md` | Epics, stories, releases, controle |
| `08-componenten/` | Overzicht, conventies, 16 componenten |
| `09-koppelingen.md` | Stappen voor repo, Supabase, GitHub, Vercel |
| `CLAUDE-snippet.md` | Tekst voor `CLAUDE.md` |
