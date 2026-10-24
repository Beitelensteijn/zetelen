# Component: core-model

Status: gebouwd en getest (24 oktober 2026). Open: Niels kijkt de handmatige tabellen na (`gecontroleerd_op`)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`, `docs/plan/api-check-rapport.md`

## Doel

Een opgeschoond datamodel boven de raw-laag (core-laag) waarop de analyses draaien. Het legt vast welke stemming bij welk besluit, welke zaak, welke persoon en welke fractie hoort, ook als fracties door de tijd veranderen.

## Laag

Backend (SQL-migraties)

## Interface

Biedt: core-tabellen en views in Supabase voor stemmingen, besluiten, zaken, personen en fracties, met stabiele sleutels. Het exacte schema volgt uit het API-checkrapport.

Verwacht: de raw-laag van `ingest`.

## Afhankelijkheden

`ingest`.

## Stories

**E1-S5 Core-laag.** Als beheerder wil ik een opgeschoond datamodel boven de raw-laag.
- Relaties tussen stemmingen, besluiten, zaken, personen en fracties zijn vastgelegd met controles op ontbrekende sleutels
- Fracties die door de tijd veranderen (splitsing, fusie, naamswijziging) zijn zo gemodelleerd dat een stemming altijd bij de fractie hoort die op dat moment bestond
- Het model is beschreven in een diagram en in een alinea per tabel

## Testen

- Controles op ontbrekende sleutels: geen stemming zonder besluit, geen besluit zonder verwijzing naar een geldige vergadering of zaak waar de bron dat vereist
- Een steekproef van fractiewijzigingen (splitsing, fusie) controleert dat een stemming bij de juiste fractie van dat moment hoort
- Het diagram komt overeen met het werkelijke schema (vergelijk met de database)

## Aandachtspunten

- Niels reviewt SQL en kan het model navertellen. Houd het schema zo klein als de analyses toelaten, en documenteer elke tabel in een alinea
- Alle veldnamen komen uit het API-checkrapport. Verzin er geen
- Het model moet de twee kanten van stemmen kunnen dragen: fractiestemmen en persoonsstemmen. Persoonsstemmen bestaan, vrijwel alleen bij hoofdelijke stemmingen: 8 tot 75 besluiten per jaar (API-checkrapport, 23 oktober 2026)
- Datum van een stemming: Stemming en Besluit hebben geen datum, die komt via `Besluit/Agendapunt/Activiteit/Datum`. 5.766 stemmingen (0,6%) hebben langs die weg geen datum; die krijgen geen periode en tellen niet mee in de analyses (besluit Niels, 23 oktober 2026). Maak ze telbaar voor `datakwaliteit`
- Fractie en partij zijn niet hetzelfde. Op 22 oktober 2026 telt de Kamer 17 fracties, waarvan Groep Markuszower (zeven PVV-Kamerleden die op 20 januari 2026 vertrokken, partij De Nederlandse Alliantie sinds april 2026, fractienaam niet gewijzigd) en Lid Keijzer (een enkel Kamerlid) geen gevestigde partij zijn. Het model moet een fractie aan een partij of aan niets kunnen koppelen en wijzigingen van naam en samenstelling door de tijd bewaren
- Periode is een eigen begrip met een soort (Kamerperiode of kabinet), een begin en een einde. Kamerperioden volgen uit de verkiezingsdata, kabinetten uit een handmatige tabel (E1-S8, bron Wikidata). De API bevat geen kabinetten (handmatige API-check, 23 oktober 2026)

## Gebouwd (24 oktober 2026)

- `db/migrations/003_core.sql`: schema `core` met drie handmatige tabellen (`kabinet`, `kamerperiode`, `fractie_partij`), zeven afgeleide tabellen (`besluit`, `fractiestem`, `persoonsstem`, `fractie`, `persoon`, `zaak`, `besluit_zaak`) en de functie `core.herbouw()`
- `db/migrations/004_core_unlogged.sql`: de afgeleide tabellen als unlogged, om de schrijflast van de herbouw te halveren
- `pipeline/ververs.py` roept na de verversing `core.herbouw()` aan, met een ruimere `statement_timeout` (20 minuten)
- `docs/datamodel.md`: diagram en een alinea per tabel

Keuzes (besluit Niels, 24 oktober 2026): tabellen in plaats van views, kabinetten uit Wikidata, Kamerperiodes vanaf de installatie van de Kamer (afgeleid uit de API) met de verkiezingsdatum erbij, partijkoppeling als handmatige tabel, de demissionaire fase telt bij het kabinet waar die uit voortkomt.

Bevindingen uit de data (24 oktober 2026):
- Bij hoofdelijke stemmingen levert de bron geen fractiestem, alleen stemmen per Kamerlid. Ongeveer 100 van de ruim 4.000 besluiten per jaar. Te beslissen bij `cohesie-analyse` (E2-S1)
- Een vergissing staat als vlag op de enige stem van de fractie; er is geen tweede, gecorrigeerde rij
- Een splitsing, fusie of naamswijziging levert een nieuw fractierecord op met een eigen begindatum (bijvoorbeeld GroenLinks-PvdA in 2023, PRO in juni 2026), zodat een stem altijd bij de fractie van dat moment hoort
- De API bevat 99 lege fractierecords (geen naam, geen datum, geen stemmen)

Incident (24 oktober 2026): de eerste herbouw op Supabase vulde de schijf. Supabase vergrootte de schijf automatisch en de database was enkele minuten onbereikbaar. Opgelost met unlogged tabellen en de overstap van rekencapaciteit Nano naar Micro (Niels).

## Getest (24 oktober 2026)

- 48 tests slagen lokaal en in CI, waaronder: demissionaire fase (dag voor Jetten is Schoof), datum in Nederlandse tijd, verwijderde en oude besluiten vallen weg, geen fractiestem bij hoofdelijk, periodes sluiten zonder gat aan, herbouw twee keer geeft hetzelfde, `docs/datamodel.md` komt overeen met het schema
- Op Supabase, volledige data: herbouw in 36 seconden. 60.133 besluiten, 899.200 fractiestemmen, 77.993 persoonsstemmen, 59.896 zaken, 60.133 koppelingen besluit en zaak
- Controle tegen het API-checkrapport: 60.137 besluiten met een stemming in 2010 tot en met 2026 volgens de API, 60.133 in core. Verschil 4, niet uitgezocht (waarschijnlijk besluiten waarvan alle stemmen verwijderd zijn)
- Niet getest: de steekproef van fractiewijzigingen tegen de werkelijkheid (alleen het mechanisme is bekeken)

## Schatting

Middel, ca. 6 tot 12 uur van Niels. Grove schatting, niet gemeten.
