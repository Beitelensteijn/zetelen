# Component: analytics

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`

## Doel

De 500 bezoekers per maand kunnen meten zonder bezoekers te volgen.

## Laag

Frontend

## Interface

Biedt: een meetvoorziening op de site en een vastgelegde definitie van "bezoeker" en het meetmoment.

Verwacht: de paginastructuur van `site-shell`.

## Afhankelijkheden

`site-shell`.

## Stories

**E3-S6 Analytics.** Als beheerder wil ik de 500 bezoekers per maand kunnen meten, zonder bezoekers te volgen.
- Gekozen analyses leggen geen persoonlijke identificatie vast, de keuze is gedocumenteerd
- Het meetmoment en de definitie van "bezoeker" zijn vastgelegd

## Testen

- Bekijk de site in een testbrowser en controleer dat de bezoek in de analyses verschijnt
- Controleer wat de analyses vastleggen en dat dit overeenkomt met de privacyverklaring

## Aandachtspunten

- Keuze nog open: Vercel Web Analytics (Hobby: 50.000 events per maand inbegrepen, daarna pauzeert de verzameling) of een privacyvriendelijk alternatief. Events zijn geen unieke bezoekers, dus de definitie van "bezoeker" bepaalt wat meetbaar is
- Open punt uit `../01-idee.md`: vanaf wanneer telt de 500 bezoekers per maand (vanaf start, of vanaf de eerste live-gang)
- Of een cookiemelding nodig is hangt af van de gekozen tool; leg dat vast na een controle van de actuele documentatie

## Schatting

Klein, ca. 2 tot 4 uur van Niels. Grove schatting, niet gemeten.
