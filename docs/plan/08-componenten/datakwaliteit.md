# Component: datakwaliteit

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`

## Doel

Geautomatiseerde en handmatige controles dat de cijfers in de database overeenkomen met de officiele uitslagen, zodat een fout niet onder Niels' naam live gaat.

## Laag

Backend

## Interface

Biedt:
- Geautomatiseerde controles die bij elke verversing en in CI draaien
- Een vastgelegde steekproefvergelijking per release (in `docs/`)

Verwacht: het core-model en de cohesie-analyse.

## Afhankelijkheden

`core-model`, `cohesie-analyse`.

## Stories

**E7-S5 Datakwaliteitscontrole.** Als beheerder wil ik afwijkingen tussen mijn cijfers en de officiele uitslagen kunnen vinden.
- Een geautomatiseerde controle toetst dat het totaal aantal zetels per stemming nooit boven 150 komt
- Een steekproef van besluiten (aantal: voorstel 10 per release) is vergeleken met de officiele stemmingsuitslagen en vastgelegd

## Testen

- Voeg een bewust foute testrij toe (meer dan 150 zetels): de controle slaat aan
- Voer de steekproef uit en leg per besluit vast of het klopt, met een verwijzing naar de officiele uitslag

## Aandachtspunten

- De Tweede Kamer toont stemmingsuitslagen per datum op haar eigen site. Gebruik die als referentie
- Vastleggen zonder namen van personen waar het niet nodig is

## Schatting

Klein, ca. 3 tot 6 uur van Niels. Grove schatting, niet gemeten.
