#!/usr/bin/env python3
"""Schema van de raw-laag (component ingest, stap B).

Leidt uit de $metadata van de API per entiteit de kolommen af en schrijft de
SQL-migratie voor schema `raw`. Het laadscript gebruikt dezelfde kolomlijsten
voor `$select`, zodat weggelaten velden de database nooit bereiken.

Gebruik:
  python3 pipeline/raw_schema.py
  python3 pipeline/raw_schema.py --metadata docs/plan/api-check/metadata.xml --uitvoer db/migrations/001_raw_schema.sql
"""
import argparse
from pathlib import Path

from api_check import lees_metadata

ROOT = Path(__file__).resolve().parents[1]
METADATA = ROOT / "docs" / "plan" / "api-check" / "metadata.xml"
MIGRATIE = ROOT / "db" / "migrations" / "001_raw_schema.sql"

# De 14 entiteiten uit het API-checkrapport (besluit Niels, 23 oktober 2026)
ENTITEITEN = [
    "Stemming", "Besluit", "Zaak", "Persoon", "Fractie", "FractieZetel",
    "FractieZetelPersoon", "Activiteit", "ActiviteitActor", "Commissie",
    "Document", "ZaakActor", "Agendapunt", "Vergadering",
]

# Data-minimalisatie: persoonsgegevens die de analyses niet nodig hebben (besluit Niels, 23 oktober 2026)
UITGESLOTEN = {
    "Persoon": {
        "Geslacht", "Geboortedatum", "Geboorteplaats", "Geboorteland",
        "Overlijdensdatum", "Overlijdensplaats", "Woonplaats", "Land",
        "ContentType", "ContentLength",
    },
}

# OData-type naar Postgres-type
TYPEN = {
    "Edm.Guid": "uuid",
    "Edm.String": "text",
    "Edm.Int16": "smallint",
    "Edm.Int32": "integer",
    "Edm.Int64": "bigint",
    "Edm.Boolean": "boolean",
    "Edm.Date": "date",
    "Edm.DateTimeOffset": "timestamptz",
    "Edm.Decimal": "numeric",
    "Edm.Double": "double precision",
}


def tabelnaam(entiteit):
    return f"raw.{entiteit.lower()}"


def kolommen(meta, entiteit):
    """Lijst van (veldnaam, Postgres-type) voor een entiteit, zonder de uitgesloten velden."""
    uit = []
    for naam, edm in meta[entiteit]["velden"]:
        if naam in UITGESLOTEN.get(entiteit, set()):
            continue
        if edm not in TYPEN:
            raise ValueError(f"Onbekend type {edm} voor {entiteit}.{naam}; voeg het toe aan TYPEN")
        uit.append((naam, TYPEN[edm]))
    return uit


def create_table(meta, entiteit):
    regels = []
    for naam, pgtype in kolommen(meta, entiteit):
        sleutel = " primary key" if naam == "Id" else ""
        regels.append(f'    "{naam}" {pgtype}{sleutel}')
    regels.append("    _geladen_op timestamptz not null default now()")
    kop = ""
    if entiteit in UITGESLOTEN:
        kop = f"-- Weggelaten (data-minimalisatie): {', '.join(sorted(UITGESLOTEN[entiteit]))}\n"
    return f"{kop}create table {tabelnaam(entiteit)} (\n" + ",\n".join(regels) + "\n);\n"


def migratie_sql(meta):
    delen = [
        "-- Raw-laag: ruwe kopie van de entiteiten uit de Tweede Kamer OData API.\n"
        "-- Gegenereerd door pipeline/raw_schema.py uit docs/plan/api-check/metadata.xml. Niet met de hand aanpassen.\n"
        "-- Kolomnamen zijn exact de veldnamen uit de API, tussen aanhalingstekens omdat ze hoofdletters bevatten.\n"
        "-- _geladen_op is de enige eigen kolom: wanneer de rij voor het laatst is geladen.\n",
        "create schema if not exists raw;\n",
    ]
    for entiteit in ENTITEITEN:
        delen.append(create_table(meta, entiteit))
    delen.append(
        "-- Koppeling besluit en zaak: staat niet als veld in Besluit, alleen als relatie (ophalen met $expand)\n"
        "create table raw.besluit_zaak (\n"
        '    "Besluit_Id" uuid not null,\n'
        '    "Zaak_Id" uuid not null,\n'
        "    _geladen_op timestamptz not null default now(),\n"
        '    primary key ("Besluit_Id", "Zaak_Id")\n'
        ");\n"
    )
    delen.append(
        "-- Voortgang van het laden per entiteit: hervatten na een onderbreking en incrementeel verversen\n"
        "create table raw.laadstatus (\n"
        "    entiteit text primary key,\n"
        "    skiptoken text,\n"
        "    eerste_laad_klaar_op timestamptz,\n"
        "    laatste_api_gewijzigd_op timestamptz,\n"
        "    bijgewerkt_op timestamptz not null default now()\n"
        ");\n"
    )
    return "\n".join(delen)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--metadata", default=str(METADATA))
    parser.add_argument("--uitvoer", default=str(MIGRATIE))
    args = parser.parse_args()
    meta = lees_metadata(Path(args.metadata).read_bytes())
    sql = migratie_sql(meta)
    uitvoer = Path(args.uitvoer)
    uitvoer.parent.mkdir(parents=True, exist_ok=True)
    uitvoer.write_text(sql, encoding="utf-8")
    print(f"Migratie geschreven: {uitvoer}")


if __name__ == "__main__":
    main()
