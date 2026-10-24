# Definitie: cohesie tussen fracties

Goedgekeurd door Niels op 24 oktober 2026 (story E2-S1). Uitgewerkt in `db/migrations/006_analyse_cohesie.sql`, tabel `analyses.cohesie`, publiek als `api.cohesie`. Deze tekst is ook de basis voor de methodiekpagina.

## In een alinea

Cohesie tussen twee fracties is het percentage van hun gezamenlijke stemmingen waarin ze hetzelfde stemden. Een gezamenlijke stemming is een besluit waarover beide fracties voor of tegen stemden; stemmingen waarbij een van de twee niet deelnam of afwezig was, tellen niet mee. Bij een hoofdelijke stemming telt als stem van de fractie wat de meerderheid van haar leden stemde. We berekenen het per kabinet en per Kamerperiode, over alle stemmingen en over alleen de stemmingen waarover de Kamer verdeeld was.

## Formule

Voor fracties A en B, periode P en variant V:

- G = de besluiten in P (binnen variant V) waarop A en B allebei voor of tegen stemden
- S = het deel van G waarop A en B hetzelfde stemden
- cohesie = S / G x 100%, afgerond op een decimaal
- Is G kleiner dan 25, dan is er geen percentage maar "te weinig data" (drempel: besluit Niels, 22 oktober 2026)

## Keuzes

| Vraag | Keuze | Reden en omvang |
|---|---|---|
| Niet deelgenomen of afwezig | Telt niet mee: het besluit valt voor dat paar weg | Er is geen stem om te vergelijken. Niet deelgenomen staat als soort in de bron; afwezig betekent geen stem |
| Hamerstukken en besluiten zonder stemming | Tellen niet mee | Ze hebben in de bron geen stemmen |
| Hoofdelijke stemmingen | Fractiestem afgeleid uit de meerderheid van de leden die voor of tegen stemden (besluit Niels, 24 oktober 2026). Bij een gelijke stand binnen de fractie geen fractiestem | De bron levert bij hoofdelijke stemmingen alleen stemmen per lid. In 2025 en 2026 was een fractie bij 12 van de 1.619 hoofdelijke stemmingen intern verdeeld; een gelijke stand kwam niet voor |
| Vergissing | Telt niet mee voor die fractie op dat besluit | De bron meldt dat de stem een vergissing was, niet wat de fractie bedoelde. Ongeveer 1.400 van ruim een miljoen stemmen |
| Verdeelde stemming (tweede variant) | Minstens een fractie stemde voor en minstens een tegen, afgeleide fractiestemmen meegerekend | Voorstel Claude (22 oktober), bevestigd 24 oktober. In 2025 en 2026 was 8% van de besluiten unaniem (allemaal voor) |
| Fracties die niet tegelijk bestonden | Komen niet samen voor | Ze hebben geen gezamenlijke stemmingen |
| Periode | Kabinet (standaard op de site) en Kamerperiode; de demissionaire fase telt bij het kabinet waar die uit voortkomt | Besluiten Niels, 22 en 24 oktober 2026. Een stemming hoort bij de periode van de datum van de vergadering |
| Stemmingen zonder datum | Tellen niet mee | 5.766 stemmingen (0,6%), besluit Niels 23 oktober 2026 |

## Eensgezindheid binnen een fractie

Naast cohesie, op verzoek van Niels (24 oktober 2026), tabel `analyses.eensgezindheid`, publiek als `api.eensgezindheid`. Per fractie en periode:

- hoofdelijk: het aantal hoofdelijke stemmingen waarin minstens een lid van de fractie voor of tegen stemde
- hoofdelijk_verdeeld: het deel daarvan waarin leden aan beide kanten stemden
- afwijkers_handopsteken: het aantal stemmingen met handopsteken waarin een lid zich liet aantekenen met een andere stem dan de fractie

Beperking: alleen bij hoofdelijke stemmingen (ongeveer 100 per jaar) kent de bron de stem van elk lid; bij handopsteken alleen de leden die zich laten aantekenen. De maat zegt dus hoe vaak een fractie verdeeld was als het hoofdelijk ging, niet hoe eensgezind ze in het algemeen stemt. Of en hoe dit op de site komt, beslist Niels bij `cohesie-pagina`.
