# Component: repo-ci

Status: klaar (23 oktober 2026)
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

## Gebouwd (23 oktober 2026)

- `.github/workflows/secret-scan.yml`: gitleaks 8.30.1 (vaste versie, checksum gecontroleerd) bij elke push en pull request. Scant de volledige historie die bereikbaar is vanaf de gescande commit, niet alle branches, zodat een fout op een andere branch `main` niet rood kleurt. Gevonden sleutels worden in het log gemaskeerd
- `.github/workflows/ci.yml`: placeholder die slaagt. Elk component voegt hier een eigen job toe voor zijn tests
- `README.md`: een alinea over het project en de datastroom
- `.github/pull_request_template.md`: checklist met bron, definitie, beide invalshoeken, geen geheimen en tests
- `docs/onderhoud.md`: runbook met het onderhoudspad voor de 60-dagenregel (controleren met `gh workflow list --all`, heractiveren met `gh workflow enable`). De vaste maatregel kiest component `bewaking`

Afwijking van de interface: de mapindeling (`pipeline/`, `db/`, `web/`, `content/`) is niet aangemaakt, omdat git geen lege mappen bewaart. Elk component maakt zijn eigen map aan.

Niet in dit component: het tweede criterium van E1-S1 (schrijfrol alleen als GitHub Actions secret, anon-sleutel alleen als Vercel environment variable). Dat volgt bij de koppelingen (`../09-koppelingen.md`) en component `ingest`.

## Getest (23 oktober 2026)

- Lokaal: scan op de historie van `main`, geen sleutels gevonden. Scan op een losse repo met een nepsleutel, wel gevonden
- Op GitHub: testbranch `test/nepsleutel` met een nepsleutel in het formaat van een GitHub-token. De secret scan faalde (regel `github-pat`, sleutel gemaskeerd in het log). Op `main` slaagden de secret scan en de CI. De testbranch is daarna lokaal en op GitHub verwijderd
- README beschrijft de datastroom in een alinea

## Schatting

Klein, ca. 2 tot 4 uur van Niels (review en koppelen). Grove schatting, niet gemeten.
