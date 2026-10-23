# Component: api-check

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`

## Doel

Een Python-controlescript dat de Tweede Kamer OData API doorlicht en een markdownrapport schrijft. Het rapport is de feitelijke basis voor alle andere componenten, vooral voor veldnamen, volumes en de beschikbaarheid van individuele stemmen.

## Laag

Backend

## Interface

Biedt: `docs/plan/api-check-rapport.md` met per entiteit:
- of de toegang zonder registratie werkt
- de velden (uit de metadata van de API)
- de paginering en de maximale paginagrootte
- het aantal records
- of wijzigingen en verwijderingen herkenbaar zijn
- per jaar vanaf 2010 het aantal stemmingen, en hoeveel daarvan een persoon hebben
- de grootte-schatting van de raw-laag

Verwacht: basis-URL `https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0/` (bevestigd in de documentatie van developer.overheid.nl). De API laat geautomatiseerde pagina-opvragers via sommige tools niet toe (robots.txt); het script draait daarom op Niels' laptop of in GitHub Actions, niet in een omgeving met een netwerk-allowlist.

## Afhankelijkheden

`repo-ci`. Extern: de API.

## Stories

**E1-S2 API-check.** Als beheerder wil ik een controlescript dat de API doorlicht, zodat het plan op feiten staat.
- Het rapport toont per entiteit uit het informatiemodel of de toegang zonder registratie werkt, welke velden bestaan, de paginering en maximale paginagrootte, en het aantal records
- Het rapport toont per jaar vanaf 2010 het aantal stemmingen, en hoeveel daarvan een Persoon hebben
- Het rapport meldt of wijzigingen en verwijderingen via de API herkenbaar zijn
- Het rapport bevat geen namen van personen, alleen aantallen
- Het rapport staat als markdown in `docs/plan/` zodat de epics erop bijgewerkt kunnen worden

## Testen

- Draai het script en controleer dat het rapport per entiteit een aantal en een lijst velden bevat
- Controleer dat er geen namen in het rapport staan
- Vergelijk een telling handmatig met een directe API-aanroep voor een entiteit

## Aandachtspunten

- Entiteiten om te doorlichten (volgens het informatiemodel): Stemming, Besluit, Zaak, Persoon, Fractie, FractieZetel, FractieZetelPersoon, Activiteit, ActiviteitActor, Commissie, Document, ZaakActor, Agendapunt, Vergadering
- De documentatie waarschuwt dat de API is bijgewerkt en dat oude documentatie verouderde attribuutnamen kan bevatten. Het rapport is leidend
- Na het rapport moeten `06-epics.md` (E2, E5, E6) en de componenten `core-model`, `cohesie-analyse` worden bijgewerkt waar het rapport afwijkt

## Schatting

Klein, ca. 2 tot 4 uur van Niels. Grove schatting, niet gemeten. Dit is de eerste stap die iets uit de buitenwereld bevestigt.
