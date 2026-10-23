# Component: core-model

Status: niet gestart (22 oktober 2026)
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
- Periode is een eigen begrip met een soort (Kamerperiode of kabinet), een begin en een einde. Kamerperioden volgen uit de verkiezingsdata, kabinetten uit een handmatige tabel (E1-S8). De API bevat geen kabinetten (handmatige API-check, 23 oktober 2026)

## Schatting

Middel, ca. 6 tot 12 uur van Niels. Grove schatting, niet gemeten.
