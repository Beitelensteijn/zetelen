# Component: coalitie-pagina

Status: niet gestart (24 oktober 2026, toegevoegd aan R1 op besluit van Niels)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `ontwerpsysteem.md`, `cohesie-pagina.md`, `coalitie-analyse.md`

## Doel

De coalitiebouwer op de site: fracties aanklikken in de zaal, het totaal aan zetels zien, en zien bij welke fracties de groep in het verleden een meerderheid haalde.

## Laag

Frontend

## Interface

Biedt: een pagina met de zaal (hergebruikt uit `cohesie-pagina`), een keuzelijst van fracties, het totaal en het tekort of overschot ten opzichte van 76, en de rangorde van steunpartners. De keuze van fracties en periode staat in de URL.

Verwacht: de gegevens uit `coalitie-analyse` en de zaal en tokens uit `cohesie-pagina` en `ontwerpsysteem`.

## Afhankelijkheden

`coalitie-analyse`, `cohesie-pagina`.

## Stories

**E2-S9 Coalitiebouwer in de zaal**: zie `../06-epics.md`.

## Testen

- Een gekozen combinatie in de URL geeft na herladen dezelfde weergave
- Met het toetsenbord volledig te bedienen; de zaal is niet de enige drager (lijst met knoppen en een tabel met steunpartners)
- Bekeken op telefoon en groot scherm

## Aandachtspunten

- De vaste uitlegtekst ("terugkijken, geen voorspelling of advies") staat zichtbaar bij de uitkomst
- Deelplaatjes (`deelplaatjes`) voor een gekozen combinatie zijn waarschijnlijk het meest gedeelde onderdeel van de site

## Schatting

Middel, ca. 6 tot 12 uur van Niels. Grove schatting, niet gemeten.
