# 05 Techniek

Opgesteld: 22 oktober 2026. Versies en prijzen moeten bij de bouw opnieuw gecontroleerd worden.

## Besluiten van Niels

- Standaardstack: GitHub, Vercel en Supabase
- Dataverversing in Python, via GitHub Actions
- GitHub-repo is publiek
- Nieuw project, geen hergebruik van eerdere web apps
- Kosten: gratis beginnen, tot ca. 25 euro per maand als het groeit

## Opzet

```
Tweede Kamer OData API
        |  (dagelijks, Python in GitHub Actions)
        v
Supabase Postgres
  - raw-laag: ruwe kopie van de benodigde entiteiten
  - core-laag: opgeschoond datamodel (stemmingen, besluiten, zaken, personen, fracties)
  - analyse-laag: voorberekende tabellen per analyse
        |  (alleen lezen, anon-rol met RLS)
        v
Next.js-site op Vercel
```

Reden voor de lagen: de zware berekening (cohesie over 2010 tot nu) staat in SQL in de database, de site leest alleen voorberekende tabellen. Dat houdt de site snel en laat Niels elke stap in SQL lezen en navertellen.

## Keuze per onderdeel

| Onderdeel | Keuze | Reden | Status |
|---|---|---|---|
| Dataverversing | Python-script in GitHub Actions, dagelijks | Niels leest en reviewt Python. Gratis. | Besloten |
| Database | Supabase Postgres | Standaardstack, SQL voor de analyses | Besloten |
| Verbinding vanuit Actions | Supabase session pooler (IPv4) | De directe verbinding is standaard alleen IPv6. De pooler werkt op elk plan over IPv4. | Voorstel, te testen bij bouw |
| Frontend | Next.js met TypeScript | Standaard op Vercel, goed voor deelbare URL's en server-side rendering (SEO voor "gebruikt") | Voorstel |
| Hosting | Vercel Hobby | Gratis, past bij personal gebruik | Voorstel |
| Grafieken | Nog te kiezen (D3, Observable Plot, ECharts) | Keuze hangt af van de stijl (journalistiek, strak) en de matrixvisual | Open |
| Analytics | Nog te kiezen (Vercel Web Analytics of een privacyvriendelijk alternatief) | Nodig om de 500 bezoekers per maand te meten | Open |
| Vertaling | Nederlands eerst, vertaalbestanden meteen opzetten | Engels komt pas na de vier analyses. Zo voorkom je later herschrijven van elke tekst. Advies van Claude, niet door Niels besloten. | Voorstel |

## Beperkingen en risico's per onderdeel

### GitHub Actions
- Een geplande workflow in een publieke repo wordt na 60 dagen zonder repo-activiteit automatisch uitgeschakeld. De documentatie noemt hierbij geen manier om dat te voorkomen, wel dat je hem kunt heractiveren via de Actions-tab, de REST API of `gh workflow enable`. Gevolg zonder maatregel: de dagelijkse verversing stopt zonder dat iemand het merkt.
- Maatregel (te testen): een melding bij falen en bij uitblijven van een run, plus een vaste onderhoudsroutine die repo-activiteit oplevert. Hoe repo-activiteit exact telt is niet gecontroleerd.

### Supabase
- Free: 500 MB per project, pauzeert na een week zonder activiteit, beperkt tot twee actieve projecten.
- Pro: vanaf 25 dollar per maand, 8 GB inbegrepen. Dollar, geen euro, dus in de praktijk net rond of boven 25 euro afhankelijk van de koers.
- Niet gecontroleerd: of indexes meetellen in de 500 MB, wat er gebeurt bij overschrijding, en of een dagelijkse schrijfjob de pauzering voorkomt.
- Row Level Security aan op elke tabel in een blootgesteld schema. Views omzeilen RLS standaard. In Postgres 15 en hoger lost `security_invoker = true` dat op.

### Vercel
- Hobby is beperkt tot niet-commercieel, persoonlijk gebruik. Een portfolio-site valt daaronder. Komen er advertenties of betaalde functies, dan geldt Pro.
- Cron op Hobby: maximaal een keer per dag, met een precisie van een uur. Niet relevant als de verversing in GitHub Actions draait.
- Functies mogen op Hobby maximaal 300 seconden draaien.
- Web Analytics op Hobby: 50.000 events per maand inbegrepen. Daarna pauzeert de verzameling. Events zijn geen unieke bezoekers, dus het meetmoment van de 500 bezoekers vraagt een definitie.

### Next.js
- Eind oktober 2026 is een 16.x-versie actueel (16.2 verscheen in april 2026). Welke exact moet bij de bouw gecontroleerd worden.

## Security

- Secrets: alleen in GitHub Actions secrets (schrijfrol van de database) en Vercel environment variables (alleen de publieke anon-sleutel). De repo is publiek, dus geen enkel geheim in code, historie of voorbeeldbestanden.
- Twee databaserollen: een schrijfrol voor het script, en de anon-rol met alleen `select` op de analyse- en core-tabellen die publiek mogen zijn.
- Nooit de `service_role`-sleutel in de browser of in de Next.js client.
- Data-minimalisatie op personen: alleen importeren wat de vier analyses nodig hebben (naam, fractie, periode, stemmen, moties, vragen, aanwezigheid). Niet importeren: contactinformatie, geschenken, reizen, nevenfuncties en inkomsten. Ze zijn openbaar maar niet nodig, en het verkleint risico en volume.
- Er zijn geen bezoekersaccounts en geen opgeslagen politieke opvattingen. Een eventuele lens-keuze blijft in de browser.
- Tests op de RLS-rechten (pgTAP of een eigen controle) als onderdeel van het databasecomponent.

## Datamodel op hoofdlijnen

De volgende entiteiten bestaan volgens het informatiemodel en zijn relevant: Stemming (gekoppeld aan Besluit, Fractie en Persoon), Besluit (gekoppeld aan Agendapunt, Stemming en Zaak), Zaak, Persoon, Fractie, FractieZetel, FractieZetelPersoon, Activiteit, ActiviteitActor, Commissie, Document, ZaakActor.

Veld- en kolomnamen staan bewust niet in dit plan. De documentatie waarschuwt dat die na een API-update kunnen zijn gewijzigd, en ik heb de live API niet kunnen bevragen. De exacte velden komen uit de API-check (`$metadata`).

## Open punten

- API-check door Niels: toegang zonder registratie, veldnamen, paginering en maximale paginagrootte, volume per entiteit, of de API wijzigingen en verwijderingen aangeeft, en het aantal stemmingen met een Persoon per jaar
- Database-grootte inclusief indexes, schatten na eerste volledige laad
- Pauzering Supabase Free bij een dagelijkse schrijfjob
- Keuze grafiekbibliotheek en analytics
- Naam en domein
- Maatregel tegen de 60-dagenregel in GitHub Actions

## Alternatieven overwogen

- Geen database, maar statische bestanden gegenereerd door het script. Eenvoudiger en goedkoper, maar Niels heeft in de aanpak om een database gevraagd en wil SQL en datamodellering oefenen. Niet gekozen.
- Verversing via Vercel Cron: op Hobby maximaal een keer per dag, met een uur imprecisie, en functies van maximaal 300 seconden. Voor een grote initiele laad ongeschikt. Niet gekozen.
- Supabase Edge Function met pg_cron: bleef buiten beeld door de keuze voor Python.

## Bronnen

- [Tweede Kamer OData API](https://developer.overheid.nl/apis/tweede-kamer-odata)
- [Informatiemodel Tweede Kamer](https://opendata.tweedekamer.nl/documentatie/informatiemodel)
- [Supabase pricing](https://supabase.com/pricing)
- [Supabase, verbinden met Postgres](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Supabase, Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Vercel Hobby plan](https://vercel.com/docs/plans/hobby)
- [Vercel cron jobs, gebruik en prijzen](https://vercel.com/docs/cron-jobs/usage-and-pricing)
- [GitHub, workflows uitschakelen en inschakelen](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/disable-and-enable-workflows)
