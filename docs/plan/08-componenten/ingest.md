# Component: ingest

Status: in bouw (23 oktober 2026), stap A en B klaar
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`, `docs/plan/api-check-rapport.md`

## Doel

Het Python-script en de GitHub Actions workflow die de 14 entiteiten uit het API-checkrapport vanaf 2010 in de raw-laag laden en daarna dagelijks incrementeel bijwerken.

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
- De 14 entiteiten uit het API-checkrapport worden geladen (besluit Niels, 23 oktober 2026), geen contactgegevens, geschenken, reizen, nevenfuncties of inkomsten van personen
- Entiteiten met een datum laden vanaf 2010. Persoon, Fractie, FractieZetel, FractieZetelPersoon en Commissie laden volledig. Het datumfilter per entiteit volgt uit de velden in het rapport
- Na de laad is het aantal records per entiteit gelijk aan het aantal in de API met hetzelfde filter (telling vergeleken en vastgelegd)
- Het script is herhaalbaar: opnieuw draaien na een onderbreking levert geen dubbele rijen op
- De totale databasegrootte inclusief indexes is gemeten en vastgelegd, met een vergelijking met de 500 MB van het Free plan
- Past de database na de eerste laad niet in Supabase Free (500 MB), dan wordt het Supabase Pro (besluit Niels, 23 oktober 2026)

**E1-S4 Dagelijkse incrementele verversing.** Als beheerder wil ik dat de data elke dag zelf bijgewerkt wordt.
- Een GitHub Actions workflow draait dagelijks en laadt alleen wat sinds de vorige run is gewijzigd (`ApiGewijzigdOp`, bij alle 14 entiteiten aanwezig en filterbaar volgens het API-checkrapport)
- Verwijderde records in de bron worden ook in de database verwerkt (vlag `Verwijderd`, bij alle 14 entiteiten aanwezig)
- De run is herhaalbaar en schrijft een log met aantallen en duur
- Bij een mislukte run krijgt de beheerder een melding

## Testen

- Eerste laad: vergelijk per entiteit het aantal in de database met het aantal uit de API
- Onderbreek de laad halverwege en start opnieuw: geen dubbele rijen
- Draai de verversing twee keer achter elkaar: de tweede run wijzigt niets
- Zet een fout in (onjuiste connectiestring) en controleer dat de melding komt
- Meet de databasegrootte na de eerste laad en leg het resultaat vast in `docs/plan/`

## Aandachtspunten

- De eerste volledige laad kan lang duren en meer API-verkeer geven dan de dagelijkse run; houd rekening met paginering en netwerkfouten (herhalen met uitstel). De API geeft maximaal 250 records per pagina; Stemming vanaf 2010 is ongeveer 3.900 pagina's, alle 14 entiteiten zonder datumfilter ongeveer 18.200
- Het datumfilter voor Stemming loopt via `Besluit/Agendapunt/Activiteit/Datum`; dat werkt in de API (API-checkrapport)
- Een GitHub Actions run heeft een maximale duur; een lange eerste laad moet daarom in te delen zijn (per entiteit of per periode) en hervatbaar zijn
- Of dit binnen Supabase Free past, is niet bekend. Schatting als JSON: 2,7 GB voor de 14 entiteiten. Meet de grootte vroeg, na de eerste entiteit, zodat de overstap naar Pro niet halverwege de laad komt (zie `../05-techniek.md`)

## Bouwstappen

| Stap | Wat | Status |
|---|---|---|
| A | `pipeline/verbindingstest.py` en workflow Verbindingstest | Klaar en getest (23 oktober 2026): verbinding via de session pooler, Postgres 17.11 |
| B | Schema `raw` (`db/migrations/001_raw_schema.sql`, gegenereerd door `pipeline/raw_schema.py`), migratierunner `pipeline/migreer.py`, workflow Migreer | Gebouwd, getest tegen een lokale Postgres en in CI; nog uit te voeren op Supabase |
| C | Laadscript en workflow voor de eerste laad, per entiteit hervatbaar | Niet gestart |
| D | Dagelijkse incrementele verversing | Niet gestart |

Keuzes (besluit Niels, 23 oktober 2026):
- Raw-laag met een kolom per veld uit `$metadata`, geen `jsonb`. Uitwerking door Claude: kolomnamen exact de API-namen tussen aanhalingstekens, tabelnamen de entiteitnaam in kleine letters, plus een eigen kolom `_geladen_op`
- Persoon zonder `Geslacht`, `Geboortedatum`, `Geboorteplaats`, `Geboorteland`, `Overlijdensdatum`, `Overlijdensplaats`, `Woonplaats`, `Land`, `ContentType`, `ContentLength`. Het laadscript vraagt alleen de bewaarde velden op (`$select`)
- Alleen de koppeling Besluit en Zaak extra (`raw.besluit_zaak`, via `$expand`); andere koppelingen pas als een release ze nodig heeft
- Zaak zonder datumfilter, zodat een zaak die voor 2010 begon en later is gestemd niet ontbreekt. Aanname Claude: ZaakActor dan ook zonder datumfilter, omdat het filter via Zaak zou lopen
- Voorlopig verbindt het script als `postgres`; een aparte schrijfrol volgt bij `rechten`

Feiten uit de API (23 oktober 2026, niet in het rapport):
- Pagineren werkt alleen zonder `$top`: dan geeft de API 250 records en een `@odata.nextLink` met `$skiptoken=Id-<guid>`, gesorteerd op `Id`. Met `$top` ontbreekt de volgende-link
- Koppelingen als Besluit en Zaak staan niet als veld in het record, alleen als relatie; `$expand=Zaak($select=Id)` werkt

## Schatting

Groot, ca. 10 tot 20 uur van Niels (inclusief herhaalde review van de eerste laad). Grove schatting, niet gemeten.
