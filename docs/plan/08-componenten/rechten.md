# Component: rechten

Status: gebouwd en getest (24 oktober 2026). De test op de frontendbuild is verplaatst naar `site-shell`
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

## Gebouwd (24 oktober 2026)

Keuzes (besluit Niels, 24 oktober 2026):
- Een apart schema `api` is het enige schema dat in Supabase open staat (Data API, "Exposed schemas"). Het bevat views met `security_invoker = true` over `core` en later de analysetabellen. Elk component dat iets publiek maakt, voegt hier een view toe en zorgt dat de rechtencontrole slaagt
- Geen aparte schrijfrol voor de verversing: de migraties hebben de eigenaar `postgres` toch nodig, dus dat geheim blijft in GitHub. Een aparte rol beschermt dan vooral tegen fouten in het script, niet tegen een lek
- De test als bezoeker loopt via de echte Data API, met de publieke sleutel (GitHub-variabelen `SUPABASE_URL` en `SUPABASE_ANON_KEY`, een publishable key)

Onderdelen:
- `db/migrations/005_api_rechten.sql`: RLS aan op elke tabel in `core`, `raw` en `beheer`; leesbeleid alleen op de tabellen onder de api-views; geen uitvoerrecht op `core.herbouw()` voor bezoekers; schema `api` met `kabinet`, `kamerperiode`, `fractie` en `laatst_bijgewerkt`
- `pipeline/controleer_rechten.py`: zes controles in de database (RLS, geen schrijfrechten, raw dicht, beheer alleen tijdstip en status, `security_invoker`, geen functies). Alleen lezend
- `pipeline/rechtentest_api.py`: tien proeven als bezoeker via de API. Wijzigen en verwijderen met een filter dat niets raakt, zodat een lek geen data verandert
- Workflow Migreer draait beide na elke echte migratie; workflow Rechtentest draait ze los

Interface:
- `api.laatst_bijgewerkt` (kolom `laatst_bijgewerkt`): tijdstip van de laatste geslaagde verversing, voor `site-shell`
- `api.kabinet`, `api.kamerperiode`, `api.fractie`: voor de periodefilter en de fractienamen

## Getest (24 oktober 2026)

- 56 tests slagen lokaal en in CI. Als rol `anon`: `api` lezen lukt; schrijven, wijzigen en verwijderen worden geweigerd; `raw`, `beheer` en de herbouw zijn niet bereikbaar. Een tabel zonder RLS, een schrijfrecht voor anon en een view zonder `security_invoker` laten de controle falen
- Op Supabase: rechtencontrole in de database geslaagd (zes controles)
- Via de API als bezoeker: lezen uit `api` HTTP 200; toevoegen, wijzigen en verwijderen HTTP 401; `raw`, `core`, `beheer` en de herbouw HTTP 406 (schema niet open). Daarnaast weigert de database zelf die toegang (rechtencontrole), dus er zijn twee lagen
- Niet getest: de test op de frontendbuild (geen `service_role`-sleutel in de site). Er is nog geen site; verplaatst naar `site-shell`

## Schatting

Klein, ca. 3 tot 5 uur van Niels. Grove schatting, niet gemeten.
