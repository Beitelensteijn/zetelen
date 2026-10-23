# Component: rechten

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`

## Doel

Row Level Security en databaserollen zo inrichten dat bezoekers alleen kunnen lezen wat publiek mag zijn, en dat de test hierop bij elke wijziging meedraait.

## Laag

Backend (SQL en tests)

## Interface

Biedt:
- RLS aan op elke tabel in een blootgesteld schema
- Een schrijfrol voor het ingest-script en de anon-rol met alleen `select` op publieke tabellen
- Views met `security_invoker = true`
- Een geautomatiseerde test die de rechten controleert (pgTAP of een eigen controle) en een test op de frontendbuild

Verwacht: het core-model en later de analysetabellen. Elk nieuw component dat een publieke tabel toevoegt, voegt die toe aan de rechtentest.

## Afhankelijkheden

`core-model`.

## Stories

**E1-S6 Rechten.** Als beheerder wil ik dat bezoekers alleen kunnen lezen wat publiek mag zijn.
- Row Level Security staat aan op elke tabel in een blootgesteld schema
- De anon-rol kan alleen selecteren op de publieke analyse- en core-tabellen en kan nergens schrijven
- Views gebruiken `security_invoker` zodat ze RLS niet omzeilen
- Een geautomatiseerde test controleert deze rechten en draait bij elke wijziging aan de database
- De service_role-sleutel komt niet voor in de gebouwde frontend (gecontroleerd door een test op de build)

## Testen

- Probeer als anon te schrijven, aan te passen en te verwijderen: elke poging faalt
- Probeer als anon een raw-tabel te lezen: faalt
- Zoek in de gebouwde frontend naar de service_role-sleutel en naar elke tekst die op een geheim lijkt: niets gevonden
- Voeg een testtabel zonder RLS toe: de test faalt

## Aandachtspunten

- Views omzeilen RLS standaard. `security_invoker` is beschikbaar in Postgres 15 en hoger; controleer de versie van het project
- Alleen publieke tabellen blootstellen. Het raw-schema niet blootstellen

## Schatting

Klein, ca. 3 tot 5 uur van Niels. Grove schatting, niet gemeten.
