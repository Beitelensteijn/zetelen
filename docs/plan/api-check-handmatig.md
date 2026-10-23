# Uitkomst handmatige API-check

Gedraaid: 23 oktober 2026, met `api-check/api_check.py` en een paar losse tellingen via de API.
Dit is niet het rapport van component `api-check` (dat wordt `api-check-rapport.md`); het is de snelle controle uit `BRIEFING.md`, stap 1. Alleen aantallen, geen namen.

## Toegang

- Basis-URL `https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0` werkt zonder registratie, status 200, JSON
- Paginering: zonder `$top` 250 records per pagina, met `@odata.nextLink`
- `$count=true` en `$filter` werken, ook `any()` over een relatie (`Besluit?$filter=Stemming/any(s:s/Persoon_Id ne null)`)
- De volledige metadata staat in `api-check/metadata.xml`

Op de Mac van Niels faalde python.org Python 3.11 eerst op `CERTIFICATE_VERIFY_FAILED`. Opgelost voor de run met `SSL_CERT_FILE=/etc/ssl/cert.pem`. Speelt niet in GitHub Actions.

## Entiteiten in de API

Activiteit, ActiviteitActor, Agendapunt, Besluit, Commissie, CommissieContactinformatie, CommissieZetel, CommissieZetelVastPersoon, CommissieZetelVastVacature, CommissieZetelVervangerPersoon, CommissieZetelVervangerVacature, Document, DocumentActor, DocumentPublicatie, DocumentPublicatieMetadata, DocumentVersie, Fractie, FractieZetel, FractieZetelPersoon, FractieZetelVacature, Kamerstukdossier, Persoon, PersoonContactinformatie, PersoonGeschenk, PersoonLoopbaan, PersoonNevenfunctie, PersoonNevenfunctieInkomsten, PersoonOnderwijs, PersoonReis, Reservering, Stemming, ToegezegdAan, Toezegging, Vergadering, Verslag, Zaak, ZaakActor, Zaal

Er is geen entiteit voor kabinetten.

## Velden

Stemming: `Id`, `Besluit_Id`, `Soort`, `FractieGrootte`, `ActorNaam`, `ActorFractie`, `Vergissing`, `SidActorLid`, `SidActorFractie`, `Persoon_Id`, `Fractie_Id`, `GewijzigdOp`, `ApiGewijzigdOp`, `Verwijderd`. Relaties: Besluit, Fractie, Persoon.

Besluit: `Id`, `Agendapunt_Id`, `StemmingsSoort`, `BesluitSoort`, `BesluitTekst`, `Opmerking`, `Status`, `AgendapuntZaakBesluitVolgorde`, `GewijzigdOp`, `ApiGewijzigdOp`, `Verwijderd`.

Stemming en Besluit hebben geen datum van de stemming. Die moet via Agendapunt en Activiteit komen.

## Aantallen

| Wat | Aantal |
|---|---|
| Stemming, totaal | 1.030.560 |
| Stemming, `Verwijderd` = false | 1.023.313 |
| Stemming, `Verwijderd` = true | 7.247 |
| Stemming, `Vergissing` = true | 1.437 |
| Stemming met `Persoon_Id` | 80.256 (geen daarvan verwijderd) |
| Besluit, totaal | 741.199 |
| Besluit met minstens een Stemming | 64.140 |
| Besluit met `StemmingsSoort` = 'Met handopsteken' | 63.719 |
| Besluit met `StemmingsSoort` = 'Hoofdelijk' | 538 |
| Besluit met minstens een Stemming met `Persoon_Id` | 561 |

## Wat dit zegt

- De aanname uit `BRIEFING.md` klopt: individuele stemmen bestaan vrijwel alleen bij hoofdelijke stemmingen, ongeveer 540 besluiten over de hele dataset. Het verschil tussen 538 en 561 is niet uitgezocht
- Wijzigingen (`ApiGewijzigdOp`) en verwijderingen (vlag `Verwijderd`) zijn herkenbaar, dus incrementeel verversen is mogelijk
- Kabinetten komen niet uit de API; de handmatige tabel (E1-S8) blijft nodig

## Niet gedaan

- Telling per jaar vanaf 2010 (vraagt de datum via Agendapunt en Activiteit)
- Maximale paginagrootte met `$top`
- Tellingen van de andere entiteiten
- Grootte-schatting van de raw-laag
