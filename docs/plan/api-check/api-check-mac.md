# API-check op de Mac

Vervangt de PowerShell-versie in `BRIEFING.md`, stap 1. Ca. 10 minuten.

Status: de logica van `api_check.py` is getest met nagebootste antwoorden, niet tegen de live API. Als de API een fout geeft, noteer de melding letterlijk en ga niet zelf raden.

## Voorbereiding

Open Terminal in de map met `api_check.py` en controleer dat Python er is:

```bash
python3 --version
```

## Stap 1: werkt de toegang zonder registratie?

```bash
python3 api_check.py basic
```

Verwacht: een status 200, een totaal aantal stemmingen en één record met de veldnamen. Noteer het totaal en de veldnamen.

## Stap 2: velden en relaties van Stemming

```bash
python3 api_check.py fields Stemming
```

Dit slaat ook `metadata.xml` op en toont alle entiteiten. Zoek in de uitvoer het veld of de relatie die een persoon aan een stemming koppelt. Bestaat die niet bij Stemming, kijk dan bij de andere entiteiten in de lijst en noteer dat.

## Stap 3: hoeveel stemmingen hebben een persoon?

Vervang `<veldnaam>` door wat je in stap 2 vond:

```bash
python3 api_check.py count Stemming --field <veldnaam>
```

Verwacht: een totaal en een aantal met ingevulde waarde. Het filter werkt alleen op gewone velden. Geeft de API een fout omdat het een relatie is, noteer de melding.

## Wat je noteert voor Claude Code

- Het totaal aantal stemmingen
- De veldnamen van Stemming, en welke een fractie en welke een persoon aanduidt
- Het aantal stemmingen met een persoon, naast het totaal
- Elke foutmelding, letterlijk, zonder sleutels of adressen

De uitkomst bevestigt of weerlegt de aanname dat individuele stemmen alleen bij hoofdelijke stemmingen bestaan. Dat is een aanname uit `BRIEFING.md`, geen vaststaand feit.
