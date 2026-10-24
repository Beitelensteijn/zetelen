# Onderhoud

Runbook voor wat er periodiek of bij een storing moet gebeuren. Aangemaakt door component `repo-ci`, aangevuld door component `bewaking`. Alle commando's draai je in Terminal in de map van de repo.

## Hoe je merkt dat er iets mis is

- **Mail van healthchecks.io** (check `zetelen-ververs`): de dagelijkse verversing heeft een fout gemeld, of er is twee dagen geen geslaagde verversing geweest. Dit dekt alle oorzaken: een fout in het script, een uitgeschakelde workflow, een storing bij GitHub of Supabase
- **Mail van GitHub** ("Run failed: Ververs"): een geplande run is mislukt
- **Logboek in de database**: de laatste runs met status en aantal records

```sql
select id, gestart_op, klaar_op, status, records, fout
from beheer.verversing
order by id desc
limit 10;
```

Begin bij een melding altijd met de laatste runs:

```bash
gh run list --workflow ververs.yml --limit 5 --repo Zetelen/zetelen
```

## Een mislukte run herhalen

1. Zoek de oorzaak in de log van de run. Vervang `<run-id>` door het nummer uit de lijst hierboven:

```bash
gh run view <run-id> --log-failed --repo Zetelen/zetelen
```

2. Ligt het aan iets tijdelijks (API van de Kamer of Supabase even onbereikbaar), start dan een nieuwe verversing. Er gaat niets verloren: de verversing haalt alles op wat sinds de laatste geslaagde run is gewijzigd.

```bash
gh workflow run ververs.yml --repo Zetelen/zetelen
```

3. Staat er "Wachtwoord klopt niet" of "Hostnaam onbekend", dan klopt het geheim `DATABASE_URL` niet meer. Zet het opnieuw met de connectiestring van de session pooler uit het Supabase-dashboard (Connect, Session pooler):

```bash
gh secret set DATABASE_URL --repo Zetelen/zetelen
```

Gaat het daarna nog mis, test dan alleen de verbinding: `gh workflow run verbindingstest.yml --repo Zetelen/zetelen`.

## De 60-dagenregel van GitHub Actions

**Wat er gebeurt.** Een geplande workflow in een publieke repo wordt na 60 dagen zonder activiteit in de repo automatisch uitgeschakeld. De verversing stopt dan zonder foutmelding van GitHub. Healthchecks mailt binnen twee dagen, omdat het succes-signaal uitblijft.

**Preventie.** De workflow Ververs zet zichzelf na elke run via de API opnieuw aan. Of dat de teller van 60 dagen reset, is niet gecontroleerd (23 oktober 2026). Elke push naar de repo telt in elk geval als activiteit.

**Controleren.** `disabled_inactivity` betekent uitgeschakeld door deze regel:

```bash
gh workflow list --all --repo Zetelen/zetelen
```

**Weer aanzetten en de gemiste dagen inhalen:**

```bash
gh workflow enable ververs.yml --repo Zetelen/zetelen
```

```bash
gh workflow run ververs.yml --repo Zetelen/zetelen
```

Gaat het aanzetten mis ("could not find any workflows"), controleer dan de naam met `gh workflow list --all`. Aanzetten kan ook in de Actions-tab op GitHub.

## Een onderbroken eerste laad hervatten

De eerste laad (workflow Laad) stopt netjes op de tijdslimiet en bewaart per entiteit waar hij was. Start hem opnieuw met dezelfde keuze; klare entiteiten worden overgeslagen:

```bash
gh workflow run laad.yml --repo Zetelen/zetelen -f entiteiten=alle -f max_mb=4000
```

Stopt hij op de groottegrens, dan is de database groter dan verwacht. Kijk eerst naar het gebruik in het Supabase-dashboard voordat je de grens verhoogt.

## Pauzering van Supabase

Niet van toepassing: het project draait op Supabase Pro, en Pro-projecten pauzeren niet. Op Free pauzeert een project na een week zonder activiteit; dan heractiveer je het in het dashboard.

## De bewaking zelf testen

- **Foutmelding:** start een run met een ongeldige verbinding. Binnen enkele minuten komen een mail van GitHub en van healthchecks. Het echte geheim wordt niet aangeraakt.

```bash
gh workflow run ververs.yml --repo Zetelen/zetelen -f test_fout=true
```

- **Uitblijvend signaal:** zet bij healthchecks de periode van de check tijdelijk op 1 minuut en de gratieperiode op 1 minuut. Binnen enkele minuten komt de mail. Zet daarna periode en gratie terug op 1 dag.

## Een sleutel gevonden door de secret scan

De repo is publiek, dus een sleutel die de scan vindt is al uitgelekt. Eerst de sleutel intrekken en vervangen bij de dienst (Supabase, Vercel, healthchecks), daarna pas uit de code en de historie halen.
