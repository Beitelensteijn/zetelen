# Component: cohesie-pagina

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`, `ontwerpsysteem.md`, `cohesie-analyse.md`

## Doel

De matrixvisual, het periodefilter, de leeswijzer en de fractiepagina's: het zichtbare deel van de cohesie-analyse.

## Laag

Frontend

## Interface

Biedt:
- Een verkenner met de cohesie-matrix voor een gekozen periode
- Een periodefilter dat in de URL staat
- Een leeswijzer naast de matrix
- Een deelbare pagina per fractie met de cohesie met elke andere fractie

Verwacht:
- De voorberekende cohesietabel uit `cohesie-analyse`, via de anon-rol
- Het ontwerpsysteem en de paginastructuur

## Afhankelijkheden

`cohesie-analyse`, `rechten`, `ontwerpsysteem`, `site-shell`.

## Stories

**E2-S3 Matrix.** Als bezoeker wil ik een matrix van fracties met kleur voor cohesie.
- De matrix toont alle fracties van de gekozen periode
- Een legenda, een tooltip met cijfer en aantal stemmingen, en een tabelweergave als alternatief zijn aanwezig
- Een schakelaar wisselt tussen alle stemmingen en alleen verdeelde stemmingen; de gekozen variant staat in de URL
- De kleurschaal is leesbaar voor kleurenblinde bezoekers
- Op een telefoonscherm blijft de matrix bruikbaar (scrollen of een andere weergave, ontwerpkeuze)

**E2-S4 Periodefilter.** Als bezoeker wil ik de periode kiezen.
- De gekozen periode staat in de URL, zodat die deelbaar is
- Er zijn twee periodesoorten, kabinet (standaard) en Kamerperiode; de gekozen soort staat ook in de URL
- Bij een periode zonder data staat een lege staat met uitleg die de gekozen periodesoort noemt

**E2-S5 Leeswijzer.** Als bezoeker wil ik uitleg bij de matrix.
- Een korte leeswijzer van maximaal een paar zinnen staat naast de matrix, met een link naar de volledige definitie
- De leeswijzer legt uit waarom de schakelaar tussen alle en verdeelde stemmingen bestaat

**E2-S6 Fractiepagina.** Als bezoeker wil ik per fractie een pagina met die fractie's cohesie met anderen.
- Elke fractie heeft een stabiele, deelbare URL
- De pagina toont de cohesie met elke andere fractie, de periode en de bron

## Testen

- De matrix toont voor een testperiode het juiste aantal fracties en de juiste waarden (vergelijk met de database)
- De tabelweergave bevat dezelfde cijfers als de matrix
- Controle met een kleurenblindheidssimulatie
- Bij een telefoonbreedte is de matrix bruikbaar
- De periode in de URL werkt bij herladen en bij delen
- Een fractie zonder data in een periode toont de lege staat

## Aandachtspunten

- De matrix toont "te weinig data" waar `cohesie-analyse` dat aangeeft, niet een getal
- Uit de data (24 oktober 2026): de stemmen van 50PLUS sinds november 2025 staan in de bron op het oude fractierecord (inactief sinds 2021); het nieuwe record heeft geen stemmen. Koppel fracties per periode dus op de stemmen en de afkorting, niet alleen op `actief_van` en `actief_tot`; de zetels komen van het actuele record
- Toon bij moties en amendementen het onderwerp van de zaak, niet de titel: de titel is die van het hele dossier (`docs/datamodel.md`)
- De Data API geeft maximaal 1.000 rijen per verzoek: vraag per periode en variant op
- Zaal, feedback Niels op de schets (24 oktober 2026): elke fractie als omlijnd vak met een label buiten de zaal (naam en percentage), zodat het beeld zonder hoveren leesbaar is; hover en klik lichten de hele fractie op, niet een losse zetel (binnen een fractie verschilt de score niet); het uitleesvak staat binnen het hoefijzer. Wijkt af van het ontwerp (uitleesvak per zetel); dit gaat voor
- Volgorde van de fracties in de zaal: voorstel Claude, uit de data (eerste as van een schaling op 1 min cohesie, in de schets voor Jetten 64% van de verschillen), niet een eigen links-rechtsindeling. Te beslissen door Niels
- Fracties worden getoond met naam en afkorting, zonder logo's of partijkleuren (besluit Niels). Fractienamen volgen de data, bijvoorbeeld Groep Markuszower en Lid Keijzer. Toon die zoals ze in de bron heten, met een korte uitleg bij een fractie die geen gevestigde partij is
- Fracties kunnen in verschillende periodes verschillen; de matrix toont alleen de fracties van de gekozen periode
- De grafiekbibliotheek is nog niet gekozen (D3, Observable Plot of ECharts); leg een keuze met reden voor aan Niels

## Schatting

Groot, ca. 10 tot 18 uur van Niels. Grove schatting, niet gemeten.
