# Prompt voor Claude Design

Plak alles onder de streep in Claude Design. Gebruik het als vervanging van de huidige opdracht, niet als aanvulling.

---

## Opdracht

Ontwerp een publieke datasite over stemgedrag in de Nederlandse Tweede Kamer. De site moet er verbluffend uitzien en toch journalistiek en betrouwbaar aanvoelen: een diepe, koele nacht met warm koperlicht, een groot centraal beeld per scherm en uitzonderlijk nette typografie. Denk aan een datajournalistiek stuk dat in een planetarium wordt vertoond. Niet aan een BI-dashboard.

Taal van alle interface en teksten: Nederlands. Doelgroep: algemeen publiek, geen politicologen. Eén klant, één stem, geen marketingtaal.

## Wat het uitdrukkelijk NIET mag zijn

- Geen rij van drie gelijke kaarten, geen icoon-in-cirkel featuregrid, geen glassmorphism-stapels, geen paars-blauw verloop, geen emoji.
- Geen dashboard met negen widgets door elkaar. Eén groot beeld per scherm, de rest is ondersteunend.
- Geen partijlogo's en geen partijkleuren. Fracties worden getoond met naam en afkorting in het eigen palet.
- Geen rood tegen blauw (leest als Amerikaanse politiek).
- Geen Kapitool of ander buitenlands bouwwerk, geen stockfoto's.
- Geen merkelementen, lettertypes of kleurcodes van The Economist of een andere krant overnemen. De geest mag, de uitwerking is eigen.
- Geen Inter, Roboto, Arial of Playfair Display.

## Kleur (tokens, definieer ze als CSS-variabelen)

Donker is de basis voor de hele site.

- nacht-950 `#070B18` (paginabasis, diepste vlak)
- nacht-900 `#0B1226` (vlakken)
- nacht-800 `#111B36` (kaarten, panelen)
- nacht-700 `#1A2748` (verhoogd, hover)
- lijn `#2A3A63` (haarlijnen, 1px)
- tekst `#E8ECF5`, tekst-zacht `#A9B4CC`
- koper `#D08A55` (hoofdaccent: selectie, links, markeringen)
- goud `#E3B76A` (hoogtepunt: de hoogste waarde in een schaal, kleine glans)

Regels:
- Contrast voldoet overal aan WCAG AA. Controleer elke tekstkleur op elk vlak waarop hij staat.
- Warm (koper, goud) is voor wat de bezoeker kiest of waar de aandacht heen moet. Koel (blauwtinten) is alles daaromheen.
- Voeg een lichte korrel toe (circa 3 procent) en een zeer zachte radiale gloed achter het hoofdbeeld, zodat het diep voelt zonder te flitsen.

### Kleurschaal voor cohesie (de belangrijkste datakleur)

Cohesie is het percentage stemmingen waarop twee fracties hetzelfde stemden. Sequentiële schaal, laag naar hoog:
`#2B2F6B` (laag), `#3E7CB1`, `#7FB7C9`, `#F2D38B` (hoog, goud).

- De helderheid moet monotoon stijgen, zodat de schaal ook in grijstinten en voor kleurenblinde bezoekers leesbaar is. Controleer met een simulatie van deuteranopie en protanopie.
- Geen rood-groen. Zet de waarde als getal in de cel of tooltip, kleur is nooit de enige drager.
- "Te weinig data" is geen kleur op de schaal maar een gearceerd patroon (diagonale haarlijnen) met het label "Te weinig stemmingen".

## Typografie (alleen Google Fonts)

- Koppen, uitgelichte cijfers en de twee lezingen: **Newsreader** (editorial serif, optische groottes, ook cursief gebruiken). Grote cijfers met tabular lining numerals.
- Interface, labels, tabellen: **Hanken Grotesk**.
- Kleine datalabels en bronvermeldingen: **DM Mono**.
- Schaal: ruim contrast tussen groot en klein. Hero-kop circa 72 tot 96 px desktop, 44 px mobiel, regelhoogte krap (1,0 tot 1,05). Lopende tekst 17 tot 18 px met regelhoogte 1,6 en maximaal 68 tekens per regel.
- Kleine kapitalen met ruime letterspatiëring voor rubrieklabels ("COHESIE", "METHODIEK").

## Het hoofdbeeld: de zaal met 150 zetels

Dit is de ster van de site. Teken de Tweede Kamer als een zaal van 150 zetels (afzonderlijke punten of kleine zetelvormen, in rijen die de echte hoefijzervorm van de plenaire zaal benaderen). Eigen, vereenvoudigde vorm, geen kopie van een bestaand ontwerp.

Interactie:
- De bezoeker kiest een fractie (lijst of klikken op de zaal). De zetels van die fractie lichten koperkleurig op.
- Alle andere zetels kleuren naar de cohesie met de gekozen fractie, met de schaal hierboven. De overgang is een golf die vanaf de gekozen fractie door de zaal loopt, circa 600 ms, gestaffeld.
- Hover op een zetel of fractie: tooltip met fractienaam, afkorting, cohesie in procenten en het aantal stemmingen waarop dit gebaseerd is.
- Respecteer `prefers-reduced-motion`: dan geen golf, alleen een directe kleurwissel.

Twee andere weergaven van dezelfde data, te wisselen met een segmentbediening naast de zaal:
1. **Boog**: fracties als segmenten op een halve cirkel of als netwerk met lijnen waarvan de dikte de cohesie toont.
2. **Tabel**: de matrix van fracties tegen fracties als nette tabel, dezelfde cijfers, met kolomkoppen en sorteerbaar. Dit is ook het toegankelijke alternatief.

## Pagina's en schermen om te ontwerpen

Ontwerp elk scherm voor desktop (1440 px) en telefoon (390 px). Op telefoon blijft de zaal bruikbaar (kleinere punten, fractielijst eronder) en de tabel scrolt horizontaal met vaste eerste kolom.

1. **Voorpagina.** Hero met de zaal, een korte kop in Newsreader ("Hoe vaak stemmen fracties hetzelfde?" als voorbeeldtekst), één zin uitleg, een periodekeuze. Daaronder een rustige invalshoek naar de verkenner en naar de methodiek. Geen kaartenrij.
2. **Cohesie-verkenner.** De zaal, boog en tabel met de segmentbediening, periodefilter met een kleine segmentbediening "Kabinet / Kamerperiode", standaard op kabinet (beide in de URL), een schakelaar "Alle stemmingen / Alleen verdeelde stemmingen" (ook in de URL), een leeswijzer van enkele zinnen naast het beeld die uitlegt waarom die schakelaar er is, en een legenda van de kleurschaal.
3. **Fractiepagina.** Naam, afkorting, aantal zetels, de cohesie met elke andere fractie als gesorteerde lijst met kleine staafjes, periode en bronvermelding. Bij een fractie die geen gevestigde partij is (bijvoorbeeld Groep Markuszower of Lid Keijzer) een korte uitleg in een rustig kader.
4. **Twee lezingen.** Een blok met twee kolommen naast elkaar, elk een korte handgeschreven duiding van dezelfde cijfers vanuit een andere invalshoek, met een kop in Newsreader en daaronder de bronvermelding. Elke kolom heeft een duidelijk label "Lezing A" en "Lezing B". Ze zijn gelijkwaardig in gewicht, geen van beide wordt voorgetrokken.
5. **Methodiek en betrouwbaarheid.** Leesbare tekstpagina met de definitie van cohesie, wat de cijfers niet zeggen, bronvermelding (Tweede Kamer open data) en een datum van laatste verversing. Hier hoort de tweede hero: een **eigen, gestileerde lijnillustratie van het Binnenhof** in koper op nacht, met een zachte gloed. Originele tekening in vectorstijl, geen foto, geen stockbeeld.
6. **Lege staat en foutstaat** voor een periode zonder data, in dezelfde stijl, met een uitleg in gewone taal.

## Componenten die consistent terug moeten komen

Navigatie (sitenaam als eenvoudig letterwoordmerk, geen logo), periodekeuze, segmentbediening, fractiekiezer, tooltip, legenda van de kleurschaal, tabel, leeswijzer-kader, bronvoetregel met "Bron: Tweede Kamer open data" en de verversingsdatum, voetnoot met afzender (eigen naam, geen organisatie).

## Beweging

Spaarzaam en betekenisvol: de golf door de zaal, een zachte fade bij paginawissels, een subtiele gloed die meebeweegt met de selectie. Geen parallax, geen zwevende deeltjes, geen autoplay.

## Toegankelijkheid

WCAG AA, zichtbare focusranden in koper, alles bedienbaar met toetsenbord, de zaal heeft een tabelalternatief, kleur is nooit de enige drager van betekenis, `prefers-reduced-motion` gerespecteerd.

## Voorbeelddata

Gebruik 17 fracties met samen 150 zetels. Dit zijn voorbeeldcijfers, niet de actuele zetelverdeling en niet de echte cohesiewaarden. Zet onderaan elk scherm in kleine mono-letters "Voorbeelddata". Gebruik realistische fractienamen en afkortingen en neem Groep Markuszower (7 zetels) en Lid Keijzer (1 zetel) op als bijzondere fracties. Spreid de cohesiewaarden zo dat de hele kleurschaal zichtbaar is, inclusief minstens één paar met "Te weinig stemmingen".

## Sitenaam en toon

De site heet **Zetelen**. Zet de naam als letterwoordmerk in Newsreader, kleine kapitalen met ruime letterspatiëring, zonder logo of icoon.

Toon van alle teksten: droog en feitelijk met een lichte knipoog. Het woordspel zit in het werkwoord "zetelen", nooit in een oordeel over een partij. Koppen en cijfers blijven journalistiek en neutraal. Speelsheid hoort in rubrieklabels en microcopy, niet in elke kop. Gebruik deze formules:

- Onder de hoofdkop: "Wie zetelt naast wie, en wie stemt met wie."
- Rubriek bij de verkenner: "Zo wordt er gezeteld"
- Te weinig data: "Te weinig stemmingen om iets over te zeggen."
- Lege periode: "In deze periode is er niet gestemd."
- Bij de twee lezingen: "Twee manieren om naar dezelfde zetels te kijken."
- Voetnoot: "Gezeteld sinds [datum eerste stemming in de data]. Voorbeelddata."

Zetelen is een hobbyproject van één persoon, geen instituut. Laat dat in de voetnoot en op de methodiekpagina zien in gewone taal, zonder te excuseren.

## Opleveren

1. Eerst een kort ontwerpsysteem: de tokens hierboven, typografische schaal, spacing, grafiekstijl voor zaal, boog en tabel.
2. Dan de zes schermen in desktop en telefoon.
3. Benoem per scherm in een zin welke keuze het meest bepalend is voor het verbluffende effect, zodat ik gericht kan bijsturen.
