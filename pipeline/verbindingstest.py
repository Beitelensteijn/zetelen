#!/usr/bin/env python3
"""Verbindingstest met de database (component ingest, stap A).

Verbindt met DATABASE_URL, toont versie, gebruiker, database, grootte en het
aantal tabellen in de eigen schema's (raw, beheer), en stopt.
Schrijft niets. De connectiestring en het wachtwoord komen nooit in de uitvoer:
de repo en de logs van GitHub Actions zijn publiek.

Gebruik:
  DATABASE_URL=... python3 pipeline/verbindingstest.py
"""
import os
import re
import sys

import psycopg

# Herkenbare foutmeldingen, vertaald naar een uitleg zonder hostnaam of gebruikersnaam
BEKENDE_FOUTEN = [
    ("password authentication failed", "Wachtwoord klopt niet. Zet DATABASE_URL opnieuw met het juiste wachtwoord."),
    ("could not translate host name", "Hostnaam onbekend. Controleer de host in de connectiestring (session pooler)."),
    ("failed to resolve host", "Hostnaam onbekend. Controleer de host in de connectiestring (session pooler)."),
    ("timeout", "Geen antwoord binnen de tijd. Controleer host en poort (session pooler: 5432)."),
    ("Network is unreachable", "Netwerk onbereikbaar. Gebruik de session pooler (IPv4), niet de directe verbinding (IPv6)."),
    ("Connection refused", "Verbinding geweigerd. Controleer host en poort."),
    ("statement timeout", "Query afgebroken omdat hij te lang duurde (statement_timeout van de database)."),
    ("Tenant or user not found", "Gebruiker of project niet gevonden. Controleer de gebruikersnaam (postgres.<projectcode>)."),
]


def zonder_gegevens(tekst):
    """Haalt host, gebruiker en IP-adres uit een foutmelding, zodat hij in een publieke log mag."""
    tekst = re.sub(r"[\w.-]+\.(supabase\.(com|co)|pooler\.supabase\.com)", "<host>", tekst)
    tekst = re.sub(r"postgres\.[a-z0-9]+", "<gebruiker>", tekst)
    tekst = re.sub(r"\b\d{1,3}(\.\d{1,3}){3}\b", "<ip>", tekst)
    tekst = re.sub(r'user "[^"]*"', 'user "<gebruiker>"', tekst)
    return tekst


def uitleg(fout):
    tekst = str(fout)
    for sleutel, melding in BEKENDE_FOUTEN:
        if sleutel.lower() in tekst.lower():
            return melding
    # Onbekende fout: de tekst zonder host, gebruiker en IP-adres, plus de foutcode van Postgres als die er is
    code = getattr(fout, "sqlstate", None)
    return (f"Onbekende fout van het type {type(fout).__name__}"
            + (f" (code {code})" if code else "")
            + f": {zonder_gegevens(tekst).strip()}")


def mb(n):
    return f"{n / 1_000_000:,.1f}".replace(",", "_").replace(".", ",").replace("_", ".")


def main():
    url = os.environ.get("DATABASE_URL")
    if not url:
        sys.exit("DATABASE_URL ontbreekt. Zet het als GitHub Actions secret of als omgevingsvariabele.")
    try:
        with psycopg.connect(url, connect_timeout=15) as conn:
            versie, gebruiker, database, grootte = conn.execute(
                "select current_setting('server_version'), current_user, current_database(), "
                "pg_database_size(current_database())"
            ).fetchone()
            tabellen = conn.execute(
                "select table_schema, count(*) from information_schema.tables "
                "where table_schema in ('raw', 'beheer') group by table_schema order by table_schema"
            ).fetchall()
    except psycopg.Error as fout:
        sys.exit(f"Verbinding mislukt. {uitleg(fout)}")
    print("Verbinding gelukt.")
    print(f"Postgres-versie: {versie}")
    print(f"Gebruiker: {gebruiker}")
    print(f"Database: {database}")
    print(f"Databasegrootte: {mb(grootte)} MB")
    for schema, aantal in tabellen:
        print(f"Tabellen in schema {schema}: {aantal}")
    if not tabellen:
        print("Nog geen tabellen in de schema's raw en beheer.")


if __name__ == "__main__":
    main()
