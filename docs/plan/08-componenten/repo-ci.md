# Component: repo-ci

Status: niet gestart (22 oktober 2026)
Eerst lezen: `_conventies.md`, `_overzicht.md`, `../05-techniek.md`

## Doel

De publieke GitHub-repo met de mapindeling, een geautomatiseerde controle op geheimen en een eerste CI die tests draait. Zorgt dat nooit een sleutel in een publieke repo terechtkomt.

## Laag

Backend (infrastructuur)

## Interface

Biedt:
- Een repo met de mapindeling uit `_conventies.md`
- Een CI-workflow die bij elke push en pull request een secret scan draait en de tests van de andere componenten uitvoert zodra die er zijn
- Een README van een alinea over het project en de datastroom
- Een pull request-sjabloon met een checklist (bron, definitie, beide invalshoeken voor lezingen)

Verwacht: een GitHub-account en een lege repo (zie `../09-koppelingen.md`).

## Afhankelijkheden

Geen andere componenten. Extern: GitHub.

## Stories

**E1-S1 Repo en geheimen.** Als beheerder wil ik een publieke repo waarin nooit een geheim terechtkomt.
- Er is een geautomatiseerde controle (secret scan) bij elke push die faalt als een sleutel in de code of historie staat
- Schrijfrol van de database staat alleen als GitHub Actions secret, de anon-sleutel alleen als Vercel environment variable
- De README beschrijft in een alinea wat het project doet en hoe de data verloopt

## Testen

- Zet bewust een nepsleutel in een testbranch en controleer dat de CI faalt
- Controleer dat de README de datastroom in een alinea beschrijft

## Aandachtspunten

- Maak ook het onderhoudspad voor de 60-dagenregel van GitHub Actions in dit component zichtbaar (zie component `bewaking`)

## Schatting

Klein, ca. 2 tot 4 uur van Niels (review en koppelen). Grove schatting, niet gemeten.
