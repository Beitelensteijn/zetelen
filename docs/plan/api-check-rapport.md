# API-check rapport

Gemaakt door `pipeline/api_check.py` op 2026-10-23. Basis-URL: `https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0`.
Alleen aantallen en veldnamen, geen waarden uit records en geen namen van personen.
Dit rapport is leidend boven oudere documentatie van de API.

## Overzicht per entiteit

| Entiteit | Toegang (HTTP) | Records | Verwijderd | Gewijzigd sinds 2026-10-16 | Standaard per pagina | Volgende-link | `$top=250` werkt | `$top=251` geeft fout | Bytes per record (JSON) | Schatting raw (MB) |
|---|---|---|---|---|---|---|---|---|---|---|
| Stemming | 200 | 1.030.560 | 7.247 | 0 | 250 | ja | ja | ja | 518,7 | 534,6 |
| Besluit | 200 | 741.199 | 67.967 | 971 | 250 | ja | ja | ja | 447,9 | 332,0 |
| Zaak | 200 | 343.805 | 38.966 | 1.325 | 250 | ja | ja | ja | 704,9 | 242,3 |
| Persoon | 200 | 4.480 | 20 | 0 | 250 | ja | ja | ja | 567,3 | 2,5 |
| Fractie | 200 | 160 | 1 | 0 | 160 | nee | ja | ja | 358,6 | 0,1 |
| FractieZetel | 200 | 945 | 0 | 0 | 250 | ja | ja | ja | 234,2 | 0,2 |
| FractieZetelPersoon | 200 | 1.236 | 7 | 0 | 250 | ja | ja | ja | 367,6 | 0,5 |
| Activiteit | 200 | 100.825 | 27.266 | 346 | 250 | ja | ja | ja | 1.226,4 | 123,6 |
| ActiviteitActor | 200 | 326.644 | 23.230 | 290 | 250 | ja | ja | ja | 566,7 | 185,1 |
| Commissie | 200 | 234 | 0 | 0 | 234 | nee | ja | ja | 413,9 | 0,1 |
| Document | 200 | 729.826 | 114.253 | 3.702 | 250 | ja | ja | ja | 772,6 | 563,8 |
| ZaakActor | 200 | 921.950 | 53.671 | 511 | 250 | ja | ja | ja | 534,7 | 493,0 |
| Agendapunt | 200 | 346.943 | 24.393 | 475 | 250 | ja | ja | ja | 593,7 | 206,0 |
| Vergadering | 200 | 7.580 | 2 | 16 | 250 | ja | ja | ja | 474,7 | 3,6 |

Schatting raw-laag voor alle 14 entiteiten samen: 2.687,4 MB.
Methode: gemiddelde JSON-grootte van de eerste 250 records per entiteit, maal het aantal records. Grof: de eerste pagina hoeft niet representatief te zijn, en opslag in Postgres en indexes wijken af van JSON. Meten bij component `ingest`.

## Wijzigingen en verwijderingen

Herkenbaar per entiteit als het veld `ApiGewijzigdOp` bestaat en erop gefilterd kan worden (kolom 'Gewijzigd sinds'), en verwijderingen als het veld `Verwijderd` bestaat (kolom 'Verwijderd').

## Stemmingen per jaar

Jaar van de vergadering: `Besluit/Agendapunt/Activiteit/Datum`. Stemming en Besluit hebben zelf geen datum.

| Jaar | Stemmingen | Niet verwijderd | Met persoon (`Persoon_Id`) |
|---|---|---|---|
| 2010 | 22.243 | 22.243 | 2.556 |
| 2011 | 38.270 | 38.270 | 2.700 |
| 2012 | 29.309 | 29.308 | 3.150 |
| 2013 | 33.840 | 33.840 | 1.051 |
| 2014 | 42.697 | 42.683 | 2.552 |
| 2015 | 56.377 | 56.377 | 3.305 |
| 2016 | 60.714 | 60.714 | 4.503 |
| 2017 | 36.193 | 36.192 | 4.951 |
| 2018 | 52.776 | 52.776 | 6.600 |
| 2019 | 58.578 | 57.963 | 2.846 |
| 2020 | 74.660 | 74.645 | 11.097 |
| 2021 | 79.201 | 78.685 | 2.999 |
| 2022 | 99.330 | 99.330 | 5.547 |
| 2023 | 71.340 | 71.319 | 2.998 |
| 2024 | 64.748 | 64.450 | 5.695 |
| 2025 | 76.389 | 76.389 | 9.594 |
| 2026 | 82.013 | 82.013 | 5.853 |

- Stemmingen totaal: 1.030.560
- Voor 2010: 46.116
- 2010 tot en met 2026: 978.678
- Niet te dateren via `Besluit/Agendapunt/Activiteit/Datum` (totaal min de rest): 5.766

## Velden per entiteit

Uit de live `$metadata`.

### Stemming

Velden: `Id` (Guid), `Besluit_Id` (Guid), `Soort` (String), `FractieGrootte` (Int32), `ActorNaam` (String), `ActorFractie` (String), `Vergissing` (Boolean), `SidActorLid` (String), `SidActorFractie` (String), `Persoon_Id` (Guid), `Fractie_Id` (Guid), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Besluit`, `Fractie`, `Persoon`

### Besluit

Velden: `Id` (Guid), `Agendapunt_Id` (Guid), `StemmingsSoort` (String), `BesluitSoort` (String), `BesluitTekst` (String), `Opmerking` (String), `Status` (String), `AgendapuntZaakBesluitVolgorde` (Int32), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Agendapunt`, `Stemming`, `Zaak`

### Zaak

Velden: `Id` (Guid), `Nummer` (String), `Soort` (String), `Titel` (String), `Citeertitel` (String), `Alias` (String), `Status` (String), `Onderwerp` (String), `GestartOp` (DateTimeOffset), `Organisatie` (String), `Grondslagvoorhang` (String), `Termijn` (DateTimeOffset), `Vergaderjaar` (String), `Volgnummer` (Int32), `HuidigeBehandelstatus` (String), `Afgedaan` (Boolean), `GrootProject` (Boolean), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean), `Kabinetsappreciatie` (String)

Relaties: `ZaakActor`, `Activiteit`, `Agendapunt`, `Besluit`, `Document`, `Kamerstukdossier`, `VervangenDoor`, `GerelateerdNaar`, `GerelateerdVanuit`, `VervangenVanuit`

### Persoon

Velden: `Id` (Guid), `Nummer` (Int32), `Titels` (String), `Initialen` (String), `Tussenvoegsel` (String), `Achternaam` (String), `Voornamen` (String), `Roepnaam` (String), `Geslacht` (String), `Functie` (String), `Geboortedatum` (Date), `Geboorteplaats` (String), `Geboorteland` (String), `Overlijdensdatum` (Date), `Overlijdensplaats` (String), `Woonplaats` (String), `Land` (String), `ContentType` (String), `ContentLength` (Int32), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean), `Fractielabel` (String)

Relaties: `ActiviteitActor`, `CommissieZetelVastPersoon`, `CommissieZetelVervangerPersoon`, `DocumentActor`, `FractieZetelPersoon`, `PersoonContactinformatie`, `PersoonGeschenk`, `PersoonLoopbaan`, `PersoonNevenfunctie`, `PersoonOnderwijs`, `PersoonReis`, `Stemming`, `ZaakActor`, `ToegezegdAan`

### Fractie

Velden: `Id` (Guid), `Nummer` (Int32), `Afkorting` (String), `NaamNL` (String), `NaamEN` (String), `AantalZetels` (Int32), `AantalStemmen` (Int32), `DatumActief` (DateTimeOffset), `DatumInactief` (DateTimeOffset), `ContentType` (String), `ContentLength` (Int32), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `ActiviteitActor`, `CommissieVastVacature`, `CommissieVervangerVacature`, `DocumentActor`, `FractieZetel`, `Stemming`, `ZaakActor`, `ToegezegdAan`

### FractieZetel

Velden: `Id` (Guid), `Gewicht` (Int32), `Fractie_Id` (Guid), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Fractie`, `FractieZetelPersoon`, `FractieZetelVacature`

### FractieZetelPersoon

Velden: `Id` (Guid), `FractieZetel_Id` (Guid), `Persoon_Id` (Guid), `Functie` (String), `Van` (DateTimeOffset), `TotEnMet` (DateTimeOffset), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `FractieZetel`, `Persoon`

### Activiteit

Velden: `Id` (Guid), `Soort` (String), `Nummer` (String), `Onderwerp` (String), `DatumSoort` (String), `Datum` (DateTimeOffset), `Aanvangstijd` (DateTimeOffset), `Eindtijd` (DateTimeOffset), `Locatie` (String), `Besloten` (Boolean), `Status` (String), `Vergaderjaar` (String), `Kamer` (String), `Noot` (String), `VRSNummer` (String), `SidVoortouw` (String), `Voortouwnaam` (String), `Voortouwafkorting` (String), `Voortouwkortenaam` (String), `Voortouwcommissie_Id` (Guid), `Aanvraagdatum` (DateTimeOffset), `DatumVerzoekEersteVerlenging` (DateTimeOffset), `DatumMededelingEersteVerlenging` (DateTimeOffset), `DatumVerzoekTweedeVerlenging` (DateTimeOffset), `DatumMededelingTweedeVerlenging` (DateTimeOffset), `Vervaldatum` (DateTimeOffset), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Voortouwcommissie`, `ActiviteitActor`, `Agendapunt`, `VoortgezetIn`, `VervangenDoor`, `VervangenVanuit`, `VoortgezetVanuit`, `Document`, `Reservering`, `Toezegging`, `Zaak`

### ActiviteitActor

Velden: `Id` (Guid), `Activiteit_Id` (Guid), `ActorNaam` (String), `ActorFractie` (String), `Relatie` (String), `Volgorde` (Int32), `Functie` (String), `Spreektijd` (String), `SidActor` (String), `Persoon_Id` (Guid), `Fractie_Id` (Guid), `Commissie_Id` (Guid), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Activiteit`, `Commissie`, `Fractie`, `Persoon`

### Commissie

Velden: `Id` (Guid), `Nummer` (Int32), `Soort` (String), `Afkorting` (String), `NaamNL` (String), `NaamEN` (String), `NaamWebNL` (String), `NaamWebEN` (String), `Inhoudsopgave` (String), `DatumActief` (DateTimeOffset), `DatumInactief` (DateTimeOffset), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Activiteit`, `ActiviteitActor`, `CommissieContactinformatie`, `CommissieZetel`, `DocumentActor`, `ZaakActor`

### Document

Velden: `Id` (Guid), `Soort` (String), `DocumentNummer` (String), `Titel` (String), `Onderwerp` (String), `Datum` (DateTimeOffset), `Vergaderjaar` (String), `Kamer` (Int32), `Volgnummer` (Int32), `Citeertitel` (String), `Alias` (String), `DatumRegistratie` (DateTimeOffset), `DatumOntvangst` (DateTimeOffset), `Aanhangselnummer` (String), `KenmerkAfzender` (String), `Organisatie` (String), `ContentType` (String), `ContentLength` (Int32), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean), `HuidigeDocumentVersie_Id` (Guid)

Relaties: `DocumentActor`, `DocumentVersie`, `HuidigeDocumentVersie`, `Activiteit`, `Agendapunt`, `BijlageDocument`, `BronDocument`, `Kamerstukdossier`, `Zaak`

### ZaakActor

Velden: `Id` (Guid), `Zaak_Id` (Guid), `ActorNaam` (String), `ActorFractie` (String), `ActorAfkorting` (String), `Functie` (String), `Relatie` (String), `SidActor` (String), `Persoon_Id` (Guid), `Fractie_Id` (Guid), `Commissie_Id` (Guid), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Commissie`, `Fractie`, `Persoon`, `Zaak`

### Agendapunt

Velden: `Id` (Guid), `Nummer` (String), `Onderwerp` (String), `Aanvangstijd` (DateTimeOffset), `Eindtijd` (DateTimeOffset), `Volgorde` (Int32), `Rubriek` (String), `Noot` (String), `Status` (String), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean), `Activiteit_Id` (Guid)

Relaties: `Activiteit`, `Besluit`, `Document`, `Zaak`

### Vergadering

Velden: `Id` (Guid), `Soort` (String), `Titel` (String), `Zaal` (String), `Vergaderjaar` (String), `VergaderingNummer` (Int32), `Datum` (DateTimeOffset), `Aanvangstijd` (DateTimeOffset), `Sluiting` (DateTimeOffset), `Kamer` (String), `GewijzigdOp` (DateTimeOffset), `ApiGewijzigdOp` (DateTimeOffset), `Verwijderd` (Boolean)

Relaties: `Verslag`
