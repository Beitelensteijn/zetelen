# Overdracht ontwerp: Kamerdata (werktitel "Sitenaam")

Publieke datasite over stemgedrag in de Tweede Kamer. Dit document is voor Claude Code: wat er is ontworpen, hoe het zich gedraagt en wat nog open staat.

Bron van het ontwerp: artifact "Kamerdata, ontwerp" (privé, link niet in deze publieke repo).
De bestanden in `boards/` zijn een kopie van dat artifact per 23 oktober 2026.
Op vier punten gaat het plan voor dit ontwerp; zie `docs/plan/08-componenten/ontwerpsysteem.md`, sectie "Waar het plan voor het ontwerp gaat".

## Hoe lees je de bestanden

- `boards/*.dc.html` zijn borden uit een ontwerptool (formaat "Design Component"). Het is HTML met een paar eigen elementen: `<sc-for>` (lus), `<sc-if>` (voorwaarde), `<dc-import>` (ander bord als component) en `{{punt.notatie}}` voor waarden uit `renderVals()` in het script onderaan.
- Het is geen productiecode. Neem de opmaak, de tokens en de logica in `renderVals()` over naar de echte stack (Vercel). Inline stijlen zijn bedoeld om te lezen, niet om te kopiëren.
- `boards/canvas.json` zegt welk bord welke afmeting heeft en welke bij elkaar horen.
- Er is geen rendering getest. Er is nog geen bord in een browser bekeken.

## Borden

| Bestand | Wat |
|---|---|
| Main | Voorpagina desktop |
| Telefoon | Voorpagina op 390 px (Main in smal kader) |
| Zaal | Component: zaal, boog en tabel, met uitleesvak, legenda en fractiekiezer |
| Nav, Voet | Gedeelde navigatie en voet |
| Verkenner | Zaal/boog/tabel met periodekeuze en leeswijzer |
| Fractie | Fractiepagina (prop `fractie`); `FractieBijzonder` toont Groep Markuszower |
| Lezingen | Twee lezingen naast elkaar |
| Methodiek | Tekstpagina met Binnenhof-lijnillustratie (`IllBinnenhof`) |
| LeegFout | Lege staat en foutstaat |
| *Tel | Telefoonvarianten van de bovenstaande, elk in een kader van 390 px |
| Ontwerpsysteem | Tokens, contrasten, schaalsimulatie, typografie, ruimte, grafiekstijl, componenten |

## Tokens

CSS-variabelen, donker als basis:

| Token | Waarde | Gebruik |
|---|---|---|
| nacht-950 | #070B18 | paginabasis |
| nacht-900 | #0B1226 | vlakken |
| nacht-800 | #111B36 | kaarten, panelen |
| nacht-700 | #1A2748 | verhoogd, hover, gekozen knop |
| lijn | #2A3A63 | haarlijnen 1px |
| lijn-licht | #566AA6 | rand van zetels, knopen en schaalbalken (toegevoegd, voor 3:1 op grafische vormen) |
| tekst | #E8ECF5 | tekst |
| tekst-zacht | #A9B4CC | secundaire tekst |
| koper | #D08A55 | selectie, links, markeringen, focusrand |
| goud | #E3B76A | hoogste waarde, rand om de gekozen fractie |

Lettertypes (Google Fonts): Newsreader (koppen, grote cijfers, tabulaire lining numerals), Hanken Grotesk (interface), DM Mono (datalabels en bronnen).
Hero-kop 72 tot 96 px desktop, 44 px mobiel, regelhoogte 1,02. Lopende tekst 17 px, regelhoogte 1,6, maximaal 68 tekens.
Korrel ca. 3% (SVG feTurbulence) en een zachte radiale gloed achter het hoofdbeeld.

## Cohesieschaal

Vier stops, lineair geïnterpoleerd in sRGB: 0% `#2B2F6B`, 33% `#3E7CB1`, 67% `#7FB7C9`, 100% `#F2D38B`.
- Helderheid stijgt monotoon, ook na simulatie van deuteranopie en protanopie.
- Tekst in een cel is wit (#FFFFFF) of zwart (#000000), gekozen op relatieve luminantie < 0,179. Minimaal contrast 4,6.
- "Te weinig stemmingen" is een arcering, geen schaalkleur: `repeating-linear-gradient(45deg, #8A97BD 0 1px, #111B36 1px 4px)`. De drempel is nog te bepalen (`[DREMPEL]`, in het voorbeeld n < 60).
- Kleur is nooit de enige drager: het getal staat in de cel, het uitleesvak of de lijst.

## Zaal

- 150 zetels, zes rijen, hoefijzer van 220 graden. Rijen en aantallen: straal 150/205/260/315/370/425 met 13/18/23/27/32/37 zetels, middelpunt (500, 455) in een viewBox van 1000 x 630.
- Zetels worden op hoek gesorteerd en in volgorde aan de fracties toegekend, zodat elke fractie een wig is. Volgorde van fracties in de zaal is de voorbeeldvolgorde `p` in de data.
- Gekozen fractie: koper met gouden rand. Andere fracties: schaalkleur van hun cohesie met de gekozen fractie. Hover: lichte rand.
- Golf: elke zetel krijgt `transition: background-color 320ms` met `transition-delay` van 0 tot 280 ms naar afstand tot het zwaartepunt van de gekozen fractie. Totaal ca. 600 ms.
- `prefers-reduced-motion`: geen overgang, directe wissel.
- Uitleesvak (tooltip) in het midden van de zaal: fractie, afkorting, cohesie in procenten en aantal gezamenlijke stemmingen. Op smalle breedte (container query, < 640 px) komt het onder de zaal.
- Zetels zijn alleen met de muis te kiezen. Toetsenbord en schermlezer gebruiken de lijst met 17 knoppen onder de zaal (`aria-pressed`).
- Boog: 17 knopen op een halve cirkel (grootte naar zetels), lijnen van de gekozen fractie naar alle andere, dikte naar cohesie, gestreepte dunne lijn bij te weinig stemmingen. Labels verdwijnen op smalle breedte.
- Tabel: matrix 17 x 17, kolomkop sorteert de rijen op die kolom, eerste kolom blijft staan bij horizontaal scrollen. Opgebouwd uit `div`s met `role="table"`, niet uit `<table>`.

## Data

De voorbeelddata is verzonnen en zit in `renderVals()` van `Zaal.dc.html` en `Fractie.dc.html` (dubbel, houd gelijk):
- Per fractie: sleutel, afkorting, naam, zetels `z`, stemmingen `n`, positie `p`.
- Cohesie per paar: `97 - 90 * |p1 - p2|^0.95 + ruis`, begrensd op 3 tot 97. Dit is neppe data, geen model.
- Pairs `n = min(n1, n2) * periodefactor * (0,8 tot 1,0)`; `low` als `n < 60`.
- Periodes: zittingsperiode (1,0), laatste 12 maanden (0,5), laatste 3 maanden (0,15).

Echte data: vervang door een query op de Tweede Kamer open data. Het datamodel dat de UI nodig heeft is:
`fractie(k, afkorting, naam, zetels, stemmingen_in_periode, bijzonder: groep|lid|null)` en
`cohesie(fractie_a, fractie_b, periode, percentage, aantal_stemmingen)`.

## Placeholders en open punten

- `[DATUM]`, `[EIGEN NAAM]`, `[DREMPEL]`, `[KEUZE]`, `[LINK NAAR DOCUMENTATIE]`, `[FREQUENTIE]`, `[UITLEG OVER DE ONTSTAANSGESCHIEDENIS ...]` zijn echte invulpunten.
- Teksten bij Twee lezingen zijn voorbeeldtekst (`[VOORBEELDTEKST]`).
- De fractie "PRO": naam en afkorting zijn gelijk gezet omdat de volledige naam niet is geverifieerd.
- Zetelaantallen komen uit een eerdere opzoeking en zijn bedoeld als voorbeeld, niet als actuele verdeling.
- Geen partijlogo's en geen partijkleuren in de eerste release (bewuste keuze).
- Menu: Verkenner, Fracties, Lezingen, Methodiek. "Fracties" linkt nu naar één fractiepagina; in de echte site is dat een overzicht plus pagina per fractie.
- Foutstaat: "Probeer opnieuw" is een mock en meldt alleen dat het mislukte.
- Niet getest in een browser: schaling van de zaal op 390 px, geneste dc-imports (Telefoon importeert Main, die Zaal importeert), container queries.

## Toegankelijkheid

WCAG AA op tekst, zichtbare koperen focusrand (2 px, 3 px afstand), alles met het toetsenbord te bedienen via knoppen en links, knoppen minimaal 44 px, `prefers-reduced-motion` gerespecteerd.
