#!/usr/bin/env python3
"""Migratierunner (component ingest, stap B).

Voert de SQL-bestanden in db/migrations/ op naamvolgorde uit, elk in een eigen
transactie, en noteert in beheer.migraties welke al gedraaid zijn. Een bestand
draait dus maar een keer. Mislukt een bestand, dan wordt dat bestand volledig
teruggedraaid en stopt de runner.

Gebruik:
  DATABASE_URL=... python3 pipeline/migreer.py
  DATABASE_URL=... python3 pipeline/migreer.py --droog   (alleen tonen wat zou draaien)
"""
import argparse
import os
import sys
from pathlib import Path

import psycopg

MAP = Path(__file__).resolve().parents[1] / "db" / "migrations"

# Schema beheer staat niet open voor de Data API van Supabase (alleen public is dat standaard)
BEHEER_SQL = """
create schema if not exists beheer;
create table if not exists beheer.migraties (
    bestand text primary key,
    uitgevoerd_op timestamptz not null default now()
);
"""


def bestanden(map_=MAP):
    return sorted(map_.glob("*.sql"))


def uitgevoerd(conn):
    return {r[0] for r in conn.execute("select bestand from beheer.migraties")}


def migreer(conn, map_=MAP, droog=False):
    """Geeft de namen terug van de bestanden die (zouden) zijn uitgevoerd."""
    if droog:
        # Een droge run wijzigt niets, ook niet het schema beheer
        bestaat = conn.execute("select to_regclass('beheer.migraties')").fetchone()[0]
        gedaan = uitgevoerd(conn) if bestaat else set()
        return [b.name for b in bestanden(map_) if b.name not in gedaan]
    conn.execute(BEHEER_SQL)
    gedaan = uitgevoerd(conn)
    open_ = [b for b in bestanden(map_) if b.name not in gedaan]
    for bestand in open_:
        with conn.transaction():
            conn.execute(bestand.read_text(encoding="utf-8"))
            conn.execute("insert into beheer.migraties (bestand) values (%s)", (bestand.name,))
        print(f"Uitgevoerd: {bestand.name}")
    return [b.name for b in open_]


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--droog", action="store_true", help="alleen tonen wat zou draaien")
    args = parser.parse_args()
    url = os.environ.get("DATABASE_URL")
    if not url:
        sys.exit("DATABASE_URL ontbreekt.")
    with psycopg.connect(url, autocommit=True) as conn:
        namen = migreer(conn, droog=args.droog)
    if not namen:
        print("Geen openstaande migraties.")
    elif args.droog:
        print("Zou uitvoeren: " + ", ".join(namen))


if __name__ == "__main__":
    main()
