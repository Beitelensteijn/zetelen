# 09 Koppelingen

Status: uitgevoerd tot en met Vercel (24 oktober 2026), zie de tabel. Niets hieronder is door mij getest; ik had geen toegang tot jouw laptop of accounts. Controleer elke opdracht voordat je hem draait en pas namen aan.

## Wat er gekoppeld moet worden

| Koppeling | Status | Wie |
|---|---|---|
| Repo op GitHub (publiek) | Gedaan: `Zetelen/zetelen`, in de organisatie Zetelen (verhuisd van het persoonlijke account op 24 oktober 2026; geheimen, variabelen en workflows zijn meeverhuisd) | Niels |
| Supabase-project aangemaakt | Gedaan (23 oktober 2026): Pro, rekencapaciteit Micro (sinds 24 oktober 2026), regio Ierland (eu-west-1) | Niels |
| Geheimen in GitHub Actions | Gedaan (23 oktober 2026): `DATABASE_URL` (session pooler, gebruiker `postgres`), getest met de workflow Verbindingstest | Niels |
| Vercel-project gekoppeld aan de repo | Gedaan (24 oktober 2026): Hobby, root `web`, https://zetelen.vercel.app. Hobby werkt met een publieke repo van een organisatie | Niels |
| Environment variables in Vercel | Gedaan (24 oktober 2026): `SUPABASE_URL` en `SUPABASE_PUBLISHABLE_KEY` | Niels |
| Data API: schema `api` open (Exposed schemas) | Gedaan (24 oktober 2026) | Niels |
| GitHub-variabelen `SUPABASE_URL` en `SUPABASE_ANON_KEY` (publishable key, publiek) voor de rechtentest | Gedaan (24 oktober 2026) | Niels |
| `CLAUDE.md` verwijst naar `docs/plan/` | Gedaan (23 oktober 2026) | Claude Code, na akkoord |

## Voorbereiding: tools controleren (PowerShell)

Draai dit en kijk welke ontbreken:

```powershell
git --version
gh --version
node --version
python --version
```

Voor Vercel en Supabase staan de installatiestappen in hun actuele documentatie; controleer die op de dag zelf, want versies en commando's veranderen.

## Stap 1: repo

De naam van de site is nog niet bepaald. Gebruik een tijdelijke repo-naam; hernoemen kan later in GitHub.

```powershell
gh auth login
gh repo create <repo-naam> --public --clone
```

Kopieer daarna de map `docs/plan/` uit dit plan naar de nieuwe repo en commit die als eerste commit.

## Stap 2: Supabase-project

In het Supabase-dashboard een nieuw project aanmaken in een EU-regio dicht bij Nederland. Je hebt daarna drie dingen nodig:

1. De project-URL
2. De publieke sleutel (anon of publishable, de naam wisselt per versie; neem de publieke)
3. De connectiestring van de **session pooler** (niet de directe verbinding: die is standaard alleen IPv6)

Plak de sleutels en de connectiestring niet in een chat of in een bestand in de repo.

## Stap 3: geheimen in GitHub Actions

`gh secret set` vraagt om de waarde in de terminal, dus de waarde staat niet in je commandogeschiedenis:

```powershell
gh secret set DATABASE_URL
```

De naam `DATABASE_URL` is een voorstel; het ingest-component gebruikt dezelfde naam. Zet hier alleen de schrijfrol van de database, nooit de publieke sleutel.

## Stap 4: Vercel

Wacht hiermee tot er een Next.js-app in `web/` staat (component `site-shell`). Daarna:

- Maak een Vercel-project (Hobby), importeer `Zetelen/zetelen` en zet de Root Directory op `web`
- Environment variables: `SUPABASE_URL` (alleen `https://<project>.supabase.co`, zonder `/rest/v1`) en `SUPABASE_PUBLISHABLE_KEY` (de publieke sleutel). Bewust geen `NEXT_PUBLIC_`: de site leest op de server. Nooit de secret- of `service_role`-sleutel
- Vercel toont opgeslagen waarden niet meer. Twijfel je, voer ze opnieuw in; een wijziging geldt pas na een nieuwe build (Deployments, Redeploy)

## Wat Claude Code mag voorstellen en pas na jouw akkoord mag uitvoeren

Commando's met `gh`, `vercel` of `supabase` die iets aanmaken of wijzigen. Eerst het commando laten zien, dan pas draaien.

## Hoe Claude Code het plan leest

Zet in `CLAUDE.md` in de root van de repo de tekst uit `CLAUDE-snippet.md`.

## Agents

De bouwcyclus gebruikt agents in `.claude/agents/` (`backend-developer`, `frontend-developer`, `test-runner`, `code-reviewer`). Niet gecontroleerd of die op jouw laptop bestaan. Ontbreken ze, dan bouwt Claude Code zelf in de hoofdsessie volgens dezelfde cyclus.

## Open punten

- Naam en domein van de site
- Aparte schrijfrol in plaats van `postgres` (component `rechten`; het wachtwoord zet Niels zelf)
