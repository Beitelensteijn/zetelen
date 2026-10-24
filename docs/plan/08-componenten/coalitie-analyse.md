# Component: coalitie-analyse

Status: niet gestart (24 oktober 2026, toegevoegd aan R1 op besluit van Niels)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`, `../definitie-cohesie.md`, `cohesie-analyse.md`

## Doel

De definitie en de berekening achter de coalitiebouwer: voor een zelf gekozen groep fracties en een periode, hoe vaak de groep eensgezind stemde, hoe vaak ze daarbij een meerderheid had, en bij welke andere fracties ze die meerderheid haalde.

## Laag

Backend (SQL), met een keuze over waar de berekening draait (zie Aandachtspunten)

## Interface

Biedt: per periode de gegevens waarmee de site voor elke combinatie van fracties de uitkomst kan tonen, publiek via schema `api`. Verwacht: `analyses.fractie_besluit_stem` (stem per fractie per besluit, inclusief afgeleid bij hoofdelijk) en de fractiegrootte per stemming uit `core.fractiestem`.

## Afhankelijkheden

`cohesie-analyse`, `rechten`.

## Stories

**E2-S7 Definitie** en **E2-S8 Berekening**: zie `../06-epics.md`.

## Voorstel voor de definitie (Claude, nog niet goedgekeurd)

Voor een groep G en een periode P:
- Eensgezinde stemming: een besluit in P waarop elke fractie in G voor of tegen stemde, allemaal hetzelfde
- Zetels: de fractiegrootte op het moment van de stemming (zo telt een fractie die later kromp met haar toenmalige zetels)
- Meerderheid: de zetels aan de kant van G zijn meer dan de zetels aan de andere kant
- Meegestemd: een fractie buiten G stemde op een eensgezinde stemming hetzelfde als G
- Beslissend: G had de meerderheid, en zonder de zetels van die fractie niet meer
- Per fractie buiten G: aantal en aandeel keer meegestemd, en aantal keer beslissend. Onder 25 eensgezinde stemmingen "te weinig data" (voorstel, gelijk aan cohesie)

## Testen

- Scenario met bekende uitkomst: een groep met 76 zetels heeft altijd een meerderheid; een fractie die altijd meestemt en de groep over de grens tilt, is altijd beslissend
- Handmatige nacontrole van een steekproef
- Elke combinatie van fracties in een periode geeft een uitkomst binnen de gestelde tijd

## Aandachtspunten

- Het aantal combinaties is te groot om vooraf te berekenen (2 tot de macht 17 per periode). Twee opties, te kiezen bij de start van dit component:
  1. Per periode een compact bestand met per besluit de stem en grootte van elke fractie (orde van grootte 4.000 besluiten x 17 fracties); de browser rekent. Snel en interactief, geen belasting van de database, past bij een statische site
  2. Een functie in de database die de site aanroept. Vraagt een uitzondering in de rechtencontrole (bezoekers mogen nu geen functies uitvoeren) en valt onder de time-out voor bezoekers
- Politiek gevoelig: de uitkomst leest snel als advies. De lezingen (E2-S10) en de vaste uitlegtekst zijn onderdeel van R1, geen bijzaak
- Fracties per periode koppelen op de stemmen en de afkorting (zie `cohesie-pagina.md`, bevinding 50PLUS)

## Schatting

Middel, ca. 8 tot 14 uur van Niels (vooral de definitie en de nacontrole). Grove schatting, niet gemeten.
