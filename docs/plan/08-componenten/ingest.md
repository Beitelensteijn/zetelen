# Component: ingest

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`, `docs/plan/api-check-rapport.md`

## Doel

Het Python-script en de GitHub Actions workflow die de benodigde entiteiten vanaf 2010 in de raw-laag laden en daarna dagelijks incrementeel bijwerken.

## Laag

Backend

## Interface

Biedt:
- Een raw-laag in Supabase met een tabel per geladen entiteit (veld- en tabelnamen volgen uit het API-checkrapport)
- Een herhaalbaar script: opnieuw draaien geeft geen dubbele rijen
- Een logregel per run met aantallen en duur
- Een dagelijkse GitHub Actions workflow

Verwacht:
- Het API-checkrapport (veldnamen, paginering, volume, herkenning van wijzigingen en verwijderingen)
- Schrijfrol en connectiestring van de database als GitHub Actions secrets (via de session pooler)

## Afhankelijkheden

`repo-ci`, `api-check`. Extern: Tweede Kamer API, Supabase.

## Stories

**E1-S3 Volledige eerste laad.** Als beheerder wil ik de benodigde entiteiten vanaf 2010 in de raw-laag laden.
- Alleen de entiteiten uit `../05-techniek.md` onder "Datamodel op hoofdlijnen" worden geladen, geen contactgegevens, geschenken, reizen, nevenfuncties of inkomsten van personen
- Na de laad is het aantal records per entiteit gelijk aan het aantal in de API (telling vergeleken en vastgelegd)
- Het script is herhaalbaar: opnieuw draaien na een onderbreking levert geen dubbele rijen op
- De totale databasegrootte inclusief indexes is gemeten en vastgelegd, met een vergelijking met de 500 MB van het Free plan

**E1-S4 Dagelijkse incrementele verversing.** Als beheerder wil ik dat de data elke dag zelf bijgewerkt wordt.
- Een GitHub Actions workflow draait dagelijks en laadt alleen wat sinds de vorige run is gewijzigd (of volledig, als het API-checkrapport laat zien dat wijzigingen niet herkenbaar zijn)
- Verwijderde records in de bron worden ook in de database verwerkt, voor zover de API ze aangeeft
- De run is herhaalbaar en schrijft een log met aantallen en duur
- Bij een mislukte run krijgt de beheerder een melding

## Testen

- Eerste laad: vergelijk per entiteit het aantal in de database met het aantal uit de API
- Onderbreek de laad halverwege en start opnieuw: geen dubbele rijen
- Draai de verversing twee keer achter elkaar: de tweede run wijzigt niets
- Zet een fout in (onjuiste connectiestring) en controleer dat de melding komt
- Meet de databasegrootte na de eerste laad en leg het resultaat vast in `docs/plan/`

## Aandachtspunten

- De eerste volledige laad kan lang duren en meer API-verkeer geven dan de dagelijkse run; houd rekening met paginering en netwerkfouten (herhalen met uitstel)
- Een GitHub Actions run heeft een maximale duur; een lange eerste laad moet daarom in te delen zijn (per entiteit of per periode) en hervatbaar zijn
- Of dit binnen Supabase Free past, is niet bekend (zie `../05-techniek.md`)

## Schatting

Groot, ca. 10 tot 20 uur van Niels (inclusief herhaalde review van de eerste laad). Grove schatting, niet gemeten.
