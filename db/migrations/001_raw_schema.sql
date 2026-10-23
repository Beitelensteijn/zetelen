-- Raw-laag: ruwe kopie van de entiteiten uit de Tweede Kamer OData API.
-- Gegenereerd door pipeline/raw_schema.py uit docs/plan/api-check/metadata.xml. Niet met de hand aanpassen.
-- Kolomnamen zijn exact de veldnamen uit de API, tussen aanhalingstekens omdat ze hoofdletters bevatten.
-- _geladen_op is de enige eigen kolom: wanneer de rij voor het laatst is geladen.

create schema if not exists raw;

create table raw.stemming (
    "Id" uuid primary key,
    "Besluit_Id" uuid,
    "Soort" text,
    "FractieGrootte" integer,
    "ActorNaam" text,
    "ActorFractie" text,
    "Vergissing" boolean,
    "SidActorLid" text,
    "SidActorFractie" text,
    "Persoon_Id" uuid,
    "Fractie_Id" uuid,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.besluit (
    "Id" uuid primary key,
    "Agendapunt_Id" uuid,
    "StemmingsSoort" text,
    "BesluitSoort" text,
    "BesluitTekst" text,
    "Opmerking" text,
    "Status" text,
    "AgendapuntZaakBesluitVolgorde" integer,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.zaak (
    "Id" uuid primary key,
    "Nummer" text,
    "Soort" text,
    "Titel" text,
    "Citeertitel" text,
    "Alias" text,
    "Status" text,
    "Onderwerp" text,
    "GestartOp" timestamptz,
    "Organisatie" text,
    "Grondslagvoorhang" text,
    "Termijn" timestamptz,
    "Vergaderjaar" text,
    "Volgnummer" integer,
    "HuidigeBehandelstatus" text,
    "Afgedaan" boolean,
    "GrootProject" boolean,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    "Kabinetsappreciatie" text,
    _geladen_op timestamptz not null default now()
);

-- Weggelaten (data-minimalisatie): ContentLength, ContentType, Geboortedatum, Geboorteland, Geboorteplaats, Geslacht, Land, Overlijdensdatum, Overlijdensplaats, Woonplaats
create table raw.persoon (
    "Id" uuid primary key,
    "Nummer" integer,
    "Titels" text,
    "Initialen" text,
    "Tussenvoegsel" text,
    "Achternaam" text,
    "Voornamen" text,
    "Roepnaam" text,
    "Functie" text,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    "Fractielabel" text,
    _geladen_op timestamptz not null default now()
);

create table raw.fractie (
    "Id" uuid primary key,
    "Nummer" integer,
    "Afkorting" text,
    "NaamNL" text,
    "NaamEN" text,
    "AantalZetels" integer,
    "AantalStemmen" integer,
    "DatumActief" timestamptz,
    "DatumInactief" timestamptz,
    "ContentType" text,
    "ContentLength" integer,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.fractiezetel (
    "Id" uuid primary key,
    "Gewicht" integer,
    "Fractie_Id" uuid,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.fractiezetelpersoon (
    "Id" uuid primary key,
    "FractieZetel_Id" uuid,
    "Persoon_Id" uuid,
    "Functie" text,
    "Van" timestamptz,
    "TotEnMet" timestamptz,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.activiteit (
    "Id" uuid primary key,
    "Soort" text,
    "Nummer" text,
    "Onderwerp" text,
    "DatumSoort" text,
    "Datum" timestamptz,
    "Aanvangstijd" timestamptz,
    "Eindtijd" timestamptz,
    "Locatie" text,
    "Besloten" boolean,
    "Status" text,
    "Vergaderjaar" text,
    "Kamer" text,
    "Noot" text,
    "VRSNummer" text,
    "SidVoortouw" text,
    "Voortouwnaam" text,
    "Voortouwafkorting" text,
    "Voortouwkortenaam" text,
    "Voortouwcommissie_Id" uuid,
    "Aanvraagdatum" timestamptz,
    "DatumVerzoekEersteVerlenging" timestamptz,
    "DatumMededelingEersteVerlenging" timestamptz,
    "DatumVerzoekTweedeVerlenging" timestamptz,
    "DatumMededelingTweedeVerlenging" timestamptz,
    "Vervaldatum" timestamptz,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.activiteitactor (
    "Id" uuid primary key,
    "Activiteit_Id" uuid,
    "ActorNaam" text,
    "ActorFractie" text,
    "Relatie" text,
    "Volgorde" integer,
    "Functie" text,
    "Spreektijd" text,
    "SidActor" text,
    "Persoon_Id" uuid,
    "Fractie_Id" uuid,
    "Commissie_Id" uuid,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.commissie (
    "Id" uuid primary key,
    "Nummer" integer,
    "Soort" text,
    "Afkorting" text,
    "NaamNL" text,
    "NaamEN" text,
    "NaamWebNL" text,
    "NaamWebEN" text,
    "Inhoudsopgave" text,
    "DatumActief" timestamptz,
    "DatumInactief" timestamptz,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.document (
    "Id" uuid primary key,
    "Soort" text,
    "DocumentNummer" text,
    "Titel" text,
    "Onderwerp" text,
    "Datum" timestamptz,
    "Vergaderjaar" text,
    "Kamer" integer,
    "Volgnummer" integer,
    "Citeertitel" text,
    "Alias" text,
    "DatumRegistratie" timestamptz,
    "DatumOntvangst" timestamptz,
    "Aanhangselnummer" text,
    "KenmerkAfzender" text,
    "Organisatie" text,
    "ContentType" text,
    "ContentLength" integer,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    "HuidigeDocumentVersie_Id" uuid,
    _geladen_op timestamptz not null default now()
);

create table raw.zaakactor (
    "Id" uuid primary key,
    "Zaak_Id" uuid,
    "ActorNaam" text,
    "ActorFractie" text,
    "ActorAfkorting" text,
    "Functie" text,
    "Relatie" text,
    "SidActor" text,
    "Persoon_Id" uuid,
    "Fractie_Id" uuid,
    "Commissie_Id" uuid,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

create table raw.agendapunt (
    "Id" uuid primary key,
    "Nummer" text,
    "Onderwerp" text,
    "Aanvangstijd" timestamptz,
    "Eindtijd" timestamptz,
    "Volgorde" integer,
    "Rubriek" text,
    "Noot" text,
    "Status" text,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    "Activiteit_Id" uuid,
    _geladen_op timestamptz not null default now()
);

create table raw.vergadering (
    "Id" uuid primary key,
    "Soort" text,
    "Titel" text,
    "Zaal" text,
    "Vergaderjaar" text,
    "VergaderingNummer" integer,
    "Datum" timestamptz,
    "Aanvangstijd" timestamptz,
    "Sluiting" timestamptz,
    "Kamer" text,
    "GewijzigdOp" timestamptz,
    "ApiGewijzigdOp" timestamptz,
    "Verwijderd" boolean,
    _geladen_op timestamptz not null default now()
);

-- Koppeling besluit en zaak: staat niet als veld in Besluit, alleen als relatie (ophalen met $expand)
create table raw.besluit_zaak (
    "Besluit_Id" uuid not null,
    "Zaak_Id" uuid not null,
    _geladen_op timestamptz not null default now(),
    primary key ("Besluit_Id", "Zaak_Id")
);

-- Voortgang van het laden per entiteit: hervatten na een onderbreking en incrementeel verversen
create table raw.laadstatus (
    entiteit text primary key,
    skiptoken text,
    eerste_laad_klaar_op timestamptz,
    laatste_api_gewijzigd_op timestamptz,
    bijgewerkt_op timestamptz not null default now()
);
