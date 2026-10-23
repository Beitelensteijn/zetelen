# Component: prestatie-audit

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`

## Doel

Een afsluitende controle van R1 op snelheid en toegankelijkheid, en het oplossen van wat de controle vindt.

## Laag

Frontend

## Interface

Biedt: een auditrapport in `docs/` met scores en een lijst verbeteringen die zijn doorgevoerd.

Verwacht: een volledig werkende R1-site.

## Afhankelijkheden

`cohesie-pagina`, `lezingen`, `site-shell`, `methodiek-betrouwbaarheid`.

## Stories

**E3-S8 Prestatie en toegankelijkheid.** Als bezoeker wil ik een snelle, toegankelijke site.
- Voorstel: de voorpagina en de matrixpagina scoren minstens 90 op prestatie en toegankelijkheid in een standaard audit
- Bedienbaar met toetsenbord, met zichtbare focus

## Testen

- Draai een standaard audit op de voorpagina en de matrixpagina, op mobiel en desktop, en leg de scores vast
- Bedien de hele site met alleen het toetsenbord
- Controleer de focus op alle interactieve elementen

## Aandachtspunten

- De drempel van 90 is een voorstel van Claude, niet door Niels besloten
- Controleer ook de matrix-tabelweergave voor schermlezers

## Schatting

Klein, ca. 2 tot 4 uur van Niels. Grove schatting, niet gemeten.
