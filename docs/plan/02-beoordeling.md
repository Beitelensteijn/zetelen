# 02 Beoordeling

Beoordeeld: `01-idee.md` (22 oktober 2026)

## Iteratie 1

### Scores

| Criterium | Score 1-5 | Toelichting |
|---|---|---|
| Haalbaarheid (techniek, tijd, kunde) | 3 | Stack (Supabase, Vercel, GitHub) is bekend en past bij de data. Voorwaardelijk: de API kon ik niet zelf bevragen (robots.txt blokkeert de tool), dus volume, velden en toegang zijn niet getest. |
| Scope (is de MVP klein genoeg) | 2 | Vier analyses diep, tweetalig, data vanaf 2010, duiding met rankings, profielpagina per Kamerlid, deelplaatjes en methodiekpagina. Bij 6 tot 10 uur per week is dat een lange route. |
| Risico (wat breekt het, wat is onzeker) | 2 | Individuele stemmen onzeker, API-attribuutnamen zijn gewijzigd, gratis Supabase pauzeert na een week inactiviteit, en rankings van personen onder eigen naam geven reputatierisico. |
| Onderscheid (waarom niet iets bestaands gebruiken) | 3 | In mijn zoekactie geen publieke site gevonden met deze combinatie van analyses. De zoekactie was beperkt, dus dit is geen bewijs dat die er niet is. |

### Drie grootste aannames

**1. Individuele stemmen van Kamerleden zijn beschikbaar en bruikbaar.**
Het informatiemodel koppelt Stemming aan zowel Besluit, Fractie als Persoon. Maar de Kamer stemt standaard per fractie via handopsteking. Individueel wordt alleen gestemd bij een hoofdelijke stemming op verzoek van een lid. Hoe de afwijking van een enkel lid bij een stemming per fractie wordt vastgelegd, staat niet in de bronnen die ik las. Mijn werkhypothese is dat de Persoon-koppeling alleen bij hoofdelijke stemmingen is gevuld, maar dat is een aanname uit de procedure, niet uit de data.
Gecheckt: nee. Check: per jaar tellen hoeveel Stemming-records een Persoon hebben, en hoeveel Besluiten daarbij horen.

**2. De API is zonder registratie bereikbaar, stabiel, en bevat de volledige historie vanaf 2010.**
Het portaal meldt sinds de vernieuwing in juni 2022 dat toegang drempelloos is en geen registratie vraagt. Een oudere README van een bibliotheek noemt nog IP-whitelisting. Het informatiemodel waarschuwt dat de documentatie oude attribuutnamen kan bevatten na een API-update. Basis-URL en JSON-formaat zijn bevestigd, de rest niet.
Gecheckt: gedeeltelijk, alleen via documentatie. Check: een directe call vanaf Niels' laptop (zie volgende stap).

**3. Het past binnen de gratis Supabase-limieten, en blijft draaien.**
Free heeft 500 MB database en pauzeert projecten na een week inactiviteit. Pro kost vanaf 25 dollar per maand en bevat 8 GB. Het datavolume sinds 2010 is onbekend. De geplande verversing houdt het project in principe actief, maar valt de verversing een week uit, dan pauzeert de site.
Gecheckt: limieten ja (officiele prijspagina), volume nee. Check: record-aantallen per entiteit ophalen en groottes schatten.

## Zelfbeoordeling (stap 3)

### Niet onderbouwd in mijn analyse

- Eerder in het gesprek zei ik dat stemmingen "veruit de zwaarste tabel" zijn. Daar had ik geen bron voor. Dat is een aanname en telt pas als het gemeten is.
- De score voor Onderscheid is gebaseerd op een beperkte zoekactie. Een gerichte controle op bestaande Kamer-data-sites moet nog.
- "Persoon-koppeling alleen bij hoofdelijke stemmingen" volgt uit de procedure, niet uit de data.
- De Supabase-prijs staat in dollars, het budget in euro. Pro past hooguit net binnen 25 euro, afhankelijk van de koers.
- Het aanname-percentage van moties is niet triviaal: "aangenomen zonder stemming" en hamerstukken tellen anders dan gestemde moties. Dat vraagt een definitie voordat de analyse klopt.

### Gemist dat Niels wel noemde

- "Live en gebruikt" heeft in `01-idee.md` geen meetbare drempel. Zonder drempel is succes niet toetsbaar.
- Tweetalig is beslist, maar de kosten ervan zijn niet gewogen tegen "alle drie diep". Het is de goedkoopste scope-snede om later in te voeren.
- Niels reviewt alles en moet het kunnen uitleggen. Dat is een kwaliteitseis aan elke analyse (eenvoudige, navertelbare definities), en staat nog niet als eis in het plan.

### Wat een strenge reviewer anders zou scoren

- Scope: 1 tot 2. Alle drie diep, tweetalig en duiding tegelijk, zonder gefaseerde oplevering, is voor 6 tot 10 uur per week te veel. Ik houd 2 aan zolang er een fasering komt in de epics, anders zakt het naar 1.
- Haalbaarheid: 2 tot 3. Alles hangt af van de API-check. Blijkt afwijkend stemgedrag onhoudbaar, dan valt een van de vier must-haves weg.
- Risico: blijft 2. Eerst reputatie en data, daarna kosten.

### Nieuwe vragen aan Niels

1. Fasering: moet elke invalshoek los live kunnen, of pas alles samen? Beantwoord: per invalshoek live, tweetalig pas als alle vier de analyses live zijn.
2. Succesdrempel: wat telt als "gebruikt"? Beantwoord: 500 bezoekers per maand.

## Iteratie 2

Beoordeeld: `01-idee.md` na de wijzigingen van 22 oktober 2026 (fasering per invalshoek, Nederlands eerst, 500 bezoekers per maand, twee lezingen, lens en nieuws/podcasts als later).

### Scores

| Criterium | Score 1-5 | Toelichting |
|---|---|---|
| Haalbaarheid (techniek, tijd, kunde) | 3 | Ongewijzigd. Nog steeds voorwaardelijk op de API-check. Cohesie als eerste live-gang vermindert de afhankelijkheid van individuele stemmen. |
| Scope (is de MVP klein genoeg) | 3 | Was 2. De eerste live-gang is nu alleen de cohesie-matrix plus het lezingenformat op die ene analyse, in het Nederlands. Wel blijft de totale roadmap groot. |
| Risico (wat breekt het, wat is onzeker) | 2 | Ongewijzigd. AVG-risico en reputatierisico door rankings zijn lager (geen accounts, twee lezingen). Daar staat nieuw risico tegenover: kwaliteit van de lezingen (zie aannames). |
| Onderscheid (waarom niet iets bestaands gebruiken) | 3 | Twee onderbouwde lezingen naast elkaar bij elke analyse is een duidelijker onderscheid dan de analyses zelf. Kan naar 4 als de gerichte controle op bestaande sites bevestigt dat dit niet bestaat. |

### Drie grootste aannames

**1. Handgeschreven sjablonen met automatisch ingevulde cijfers blijven kloppen bij elke combinatie van filters.**
Een zin als "deze fracties stemmen vaak samen" is waar bij het ene filter en onwaar bij het andere. Zodra bezoekers filteren op periode, partij of onderwerp, kan het cijfer de conclusie omkeren, en dan staat er onder Niels' naam een onjuiste tekst. Sjablonen vragen dus drempels en tekstvarianten, geen simpele invulvelden. Dat is meer werk dan "sjabloon" doet vermoeden.
Gecheckt: nee. Check: bij de eerste analyse (cohesie) alle filtercombinaties benoemen waarbij de tekst moet wisselen, en dat testen.

**2. Niels kan per analyse twee lezingen schrijven die allebei de sterkste versie van het argument zijn.**
Dat is een inhoudelijke vaardigheid, geen bouwtaak, en Niels moet beide teksten kunnen verdedigen. Bij vier analyses plus varianten gaat het om een aanzienlijk aantal teksten.
Gecheckt: nee. Check: een proeflezing bij de eerste analyse en kijken hoeveel tijd het kost.

**3. De aannames uit iteratie 1 gelden nog** (individuele stemmen, API-toegang en historie, Supabase-volume). Nog steeds niet gecheckt.

## Zelfbeoordeling iteratie 2

- Niet onderbouwd: dat een Nederlandstalige eerste versie met alleen cohesie "klein genoeg" is. Zonder tijdschatting per component is dat gevoel, geen meting. Die komt bij het bouwplan (stap 8).
- Gemist: er is geen eis voor foutafhandeling bij onjuiste duiding. Hoe corrigeert Niels een fout snel, en hoe meldt een bezoeker of Kamerlid er een. Staat als open punt in `01-idee.md`, nog niet als eis.
- Strenge reviewer: Onderscheid zou 3 blijven, tot de gerichte controle is gedaan. Scope 3 is aannemelijk voor de eerste live-gang, maar de roadmap als geheel blijft groot, dus de reviewer zou in de epics een harde stopregel per fase willen zien.
- Geen nieuwe vragen aan Niels die het idee wijzigen.

## Iteratie 3 (controle)

`01-idee.md` is in deze ronde niet gewijzigd. Geen score verschuift. De open punten zijn nu de API-check, de definities (methodiek), de tijdschatting per component, en de eisen aan correctie van fouten. Daarmee is stap 1 tot en met 3 afgerond. Het idee is scherp genoeg om te vertalen naar techniek.

## Open punten voor de volgende fase

- API-check door Niels op zijn laptop (toegang, velden, aantallen, Stemming met Persoon per jaar)
- Definities voor aanname, afwijking, activiteit en cohesie (methodiek)
- Gerichte controle op bestaande sites
- Eis aan correctie van fouten in duiding
- Tijdschatting per component in het bouwplan

## Bronnen

- [Tweede Kamer OData API, developer.overheid.nl](https://developer.overheid.nl/apis/tweede-kamer-odata)
- [Informatiemodel, opendata.tweedekamer.nl](https://opendata.tweedekamer.nl/documentatie/informatiemodel)
- [Open data Tweede Kamer gemakkelijker toegankelijk (2022)](https://www.tweedekamer.nl/nieuws/kamernieuws/open-data-tweede-kamer-gemakkelijker-toegankelijk)
- [Wijze van stemmen in Tweede Kamer, parlement.com](https://www.parlement.com/id/vh8lnhrpmxva/wijze_van_stemmen_in_tweede_kamer)
- [De toerekenmethode, parlement.com](https://www.parlement.com/id/vk1eec3kwhrj)
- [Supabase pricing](https://supabase.com/pricing)
- [tkapi (Python bindings)](https://github.com/openkamer/tkapi)
