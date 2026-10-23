# Component: deelplaatjes

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `ontwerpsysteem.md`, `cohesie-pagina.md`

## Doel

Een automatisch gegenereerd deelplaatje per fractiepagina, zodat resultaten op social media kunnen circuleren.

## Laag

Frontend (met een server-side afbeelding)

## Interface

Biedt: per fractiepagina een afbeelding met het cijfer, de periode, de bron en de datum, bruikbaar als voorbeeldafbeelding bij delen.

Verwacht: de fractiepagina's van `cohesie-pagina`, de tokens van `ontwerpsysteem`.

## Afhankelijkheden

`cohesie-pagina`.

## Stories

**E3-S5 Deelplaatjes.** Als bezoeker wil ik een plaatje van een resultaat kunnen delen.
- Per fractiepagina wordt automatisch een plaatje gegenereerd met het cijfer, de periode, de bron en de datum
- Het plaatje toont nooit een cijfer dat niet in de database staat

## Testen

- Het plaatje van een testfractie bevat het juiste cijfer, de periode, de bron en de datum
- Wijzig het cijfer in de testdatabase: het plaatje volgt
- Een fractie zonder data geeft een plaatje met "te weinig data", niet een verzonnen cijfer

## Aandachtspunten

- Gebruik geen logo's of merkelementen van anderen
- Het plaatje is een weergave van de database; er komt geen tekst of duiding in die niet op de site staat
- Vercel Hobby heeft een grens op functieduur en gebruik; houd het genereren licht

## Schatting

Klein tot middel, ca. 4 tot 8 uur van Niels. Grove schatting, niet gemeten.
