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
- Fracties worden getoond met naam en afkorting, zonder logo's of partijkleuren (besluit Niels). Fractienamen volgen de data, bijvoorbeeld Groep Markuszower en Lid Keijzer. Toon die zoals ze in de bron heten, met een korte uitleg bij een fractie die geen gevestigde partij is
- Fracties kunnen in verschillende periodes verschillen; de matrix toont alleen de fracties van de gekozen periode
- De grafiekbibliotheek is nog niet gekozen (D3, Observable Plot of ECharts); leg een keuze met reden voor aan Niels

## Schatting

Groot, ca. 10 tot 18 uur van Niels. Grove schatting, niet gemeten.
