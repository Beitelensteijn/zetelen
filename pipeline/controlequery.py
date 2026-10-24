#!/usr/bin/env python3
"""Draait een vaste query uit db/controles/ op de database, alleen lezend, en print de uitkomst.

Voor onderzoek zonder lokale toegang tot de database. Alleen bestanden uit db/controles/ en
alleen in een transactie die niets mag schrijven. De queries in die map geven aantallen, geen
namen: de log van GitHub Actions is publiek.

Gebruik:
  DATABASE_URL=... python3 pipeline/controlequery.py extra_rijen.sql
"""
import os
import sys
from pathlib import Path

import psycopg

from verbindingstest import uitleg

MAP = Path(__file__).resolve().parents[1] / "db" / "controles"


def main():
    if len(sys.argv) != 2:
        sys.exit("Geef de naam van een bestand in db/controles/.")
    bestand = (MAP / sys.argv[1]).resolve()
    if bestand.parent != MAP or not bestand.is_file():
        sys.exit(f"Geen bestand in db/controles/: {sys.argv[1]}")
    url = os.environ.get("DATABASE_URL")
    if not url:
        sys.exit("DATABASE_URL ontbreekt.")
    try:
        with psycopg.connect(url) as conn:
            conn.execute("set transaction read only")
            cur = conn.execute(bestand.read_text(encoding="utf-8"))
            kop = [k.name for k in cur.description]
            rijen = cur.fetchall()
            conn.rollback()
    except psycopg.Error as fout:
        sys.exit(f"Query mislukt. {uitleg(fout)}")
    print(" | ".join(kop))
    for r in rijen:
        print(" | ".join("" if v is None else str(v) for v in r))


if __name__ == "__main__":
    main()
