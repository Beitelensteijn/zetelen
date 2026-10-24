# Component: bewaking

Status: gebouwd en getest (24 oktober 2026). Open: de test van de mail bij een uitblijvend signaal
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
- Of Supabase Free pauzeert ondanks een dagelijkse schrijfjob is niet bekend; leg de bevinding vast. Bevinding (23 oktober 2026): niet meer van toepassing, het project draait op Pro en Pro pauzeert niet

## Gebouwd (23 oktober 2026)

Keuzes (besluit Niels, 23 oktober 2026):
- Externe controle met healthchecks.io (dead man's switch), niet met een workflow in dezelfde repo: die valt onder dezelfde 60-dagenregel
- Drempel: check met periode 1 dag en gratie 1 dag, dus een mail na 2 dagen zonder geslaagde verversing
- Preventie: de workflow Ververs zet zichzelf na elke run via de API opnieuw aan. Niet gecontroleerd of dit de teller van 60 dagen reset; testen kost 60 dagen. Healthchecks is het vangnet

Onderdelen:
- `db/migrations/002_beheer_verversing.sql`: tabel `beheer.verversing`, een rij per run met start, einde, status (`bezig`, `geslaagd`, `mislukt`), aantal records en het fouttype. Bron voor de "laatst bijgewerkt"-datum (interface naar `site-shell`: de laatste `klaar_op` met status `geslaagd`; publiek leesbaar maken hoort bij `rechten`)
- `pipeline/ververs.py`: schrijft het logboek en stuurt signalen naar `HEALTHCHECK_URL` (`/start`, succes, `/fail`). Een mislukt signaal laat de verversing niet falen, en de log toont nooit het geheime pad van de URL
- `.github/workflows/ververs.yml`: invoer `test_fout` (een run met een ongeldige verbinding, zonder het geheim aan te raken) en een stap die de workflow actief houdt, ook na een mislukte run (recht `actions: write`)
- `docs/onderhoud.md`: runbook met meldingen, een mislukte run herhalen, de 60-dagenregel, een onderbroken laad hervatten, pauzering van Supabase en het testen van de bewaking

## Getest (23 oktober 2026)

- 34 tests slagen lokaal en in CI, waaronder het logboek bij een geslaagde en een mislukte run, en de signalen (ook dat het geheime pad niet in de log komt)
- Lokaal met een nagebootste healthchecks-server: de signalen `/start`, succes en `/fail` komen op de juiste adressen aan
- Op Supabase: migratie `002` uitgevoerd; verversing met de hand geslaagd (27 records)
- Run met `test_fout`: mislukt zoals bedoeld met "Verbinding geweigerd", de stap die de workflow actief houdt slaagde toch
- Geheim `HEALTHCHECK_URL` eerst onjuist geplakt (host `hc-ping.chttps`), opnieuw gezet op 23 oktober 22:30 UTC
- Met het juiste geheim (23 oktober, 22:30 tot 22:33 UTC): verversing met signalen geslaagd; run met `test_fout` gaf binnen een minuut de mails "DOWN" van healthchecks en "Run failed: Ververs" van GitHub; de volgende geslaagde run gaf de mail "UP". Bevestigd door Niels in zijn inbox
- Niet getest: de mail bij een uitblijvend signaal (periode tijdelijk op 1 minuut zetten, zie `docs/onderhoud.md`)

## Schatting

Klein, ca. 3 tot 5 uur van Niels. Grove schatting, niet gemeten.
