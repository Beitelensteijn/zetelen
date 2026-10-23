# Tekst voor CLAUDE.md in de root van de repo

Plak dit in `CLAUDE.md`:

```markdown
## Project: Tweede Kamer data-website

Het plan staat in `docs/plan/`. Begin elke sessie met `docs/plan/STATUS.md`.

- Idee en randvoorwaarden: `docs/plan/01-idee.md`
- Beoordeling: `docs/plan/02-beoordeling.md`
- Techniek en beperkingen: `docs/plan/05-techniek.md`
- Epics en stories: `docs/plan/06-epics.md`
- Componenten: `docs/plan/08-componenten/_overzicht.md` en per component een eigen bestand
- Koppelingen: `docs/plan/09-koppelingen.md`

Regels:

- Bouw een component tegelijk, in de volgorde van `_overzicht.md`
- Lees voor elk component `_conventies.md` en het componentbestand
- Verzin geen veld- of kolomnamen; ze komen uit `docs/plan/api-check-rapport.md`
- Geen geheimen in de repo: die is publiek
- Pas een bestaand bestand niet aan zonder dat Niels de wijziging eerst ziet
- Noem niets klaar zonder dat de tests draaien
- Meld interfacewijzigingen en werk het componentbestand en `STATUS.md` bij
```
