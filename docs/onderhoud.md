# Onderhoud

Runbook voor wat er periodiek of bij een storing moet gebeuren. Aangemaakt door component `repo-ci`; component `bewaking` vult het aan met meldingen en de vaste maatregel.

## De 60-dagenregel van GitHub Actions

**Wat er gebeurt.** Een geplande workflow (`schedule`) in een publieke repo wordt na 60 dagen zonder activiteit in de repo automatisch uitgeschakeld. De dagelijkse verversing stopt dan zonder foutmelding: er draait gewoon niets meer.

**Wanneer het speelt.** Zodra component `ingest` de dagelijkse verversing heeft. Nu zijn er nog geen geplande workflows.

**Controleren.** Toont de status van alle workflows; `disabled_inactivity` betekent uitgeschakeld door deze regel:

```bash
gh workflow list --all --repo Beitelensteijn/zetelen
```

**Weer aanzetten.** Vervang `<workflow>` door de naam of het bestand uit de lijst hierboven:

```bash
gh workflow enable <workflow> --repo Beitelensteijn/zetelen
```

Gaat dat mis (bijvoorbeeld "could not find any workflows"), controleer dan de naam met het commando hierboven. Aanzetten kan ook in de Actions-tab op GitHub. De gemiste dagen haalt de volgende run in, op voorwaarde dat de verversing op wijzigingsdatum werkt (zie component `ingest`).

**Vaste maatregel.** Nog niet gekozen; dat doet component `bewaking`. Open punten daar: hoe repo-activiteit precies telt, en een controle die niet leunt op de workflow die hij bewaakt.

## Een sleutel gevonden door de secret scan

De repo is publiek, dus een sleutel die de scan vindt is al uitgelekt. Eerst de sleutel intrekken en vervangen bij de dienst (Supabase, Vercel), daarna pas uit de code en de historie halen.
