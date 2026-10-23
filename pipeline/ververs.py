#!/usr/bin/env python3
"""Dagelijkse incrementele verversing van de raw-laag (component ingest, stap D).

Haalt per entiteit alleen de records op waarvan ApiGewijzigdOp na de vorige
verversing ligt (met een uur marge), binnen hetzelfde datumfilter als de eerste
laad, en schrijft ze met dezelfde upsert weg. Verwijderingen komen zo ook mee:
de API zet dan de vlag Verwijderd en werkt ApiGewijzigdOp bij.

Entiteiten waarvan de eerste laad nog niet klaar is, worden overgeslagen.
De log bevat alleen aantallen en duur.

Gebruik:
  DATABASE_URL=... python3 pipeline/ververs.py
"""
import datetime as dt
import os
import sys
import time
import urllib.parse
from pathlib import Path

import psycopg

from api_check import BASE, lees_metadata
from laad import PAUZE, VOLGORDE, getal, http_json, basis_url, mb, database_grootte, schrijf_pagina, skiptoken_uit
from raw_schema import METADATA, kolommen

MARGE = dt.timedelta(hours=1)  # overlap met de vorige run; de upsert maakt dubbel ophalen onschadelijk


def odata_tijd(t):
    return t.astimezone(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def ververs_entiteit(conn, entiteit, cols, haal=http_json, base=BASE, pauze=PAUZE):
    """Geeft het aantal opgehaalde records terug, of None als de eerste laad nog niet klaar is."""
    rij = conn.execute(
        "select laatste_api_gewijzigd_op, eerste_laad_klaar_op from raw.laadstatus where entiteit = %s",
        (entiteit,),
    ).fetchone()
    if rij is None or rij[1] is None:
        print(f"{entiteit}: eerste laad nog niet klaar, overgeslagen")
        return None
    run_start = conn.execute("select now()").fetchone()[0]
    sinds = odata_tijd(rij[0] - MARGE)
    eerste = basis_url(entiteit, cols, base, extra_filter=f"ApiGewijzigdOp ge {sinds}")
    url = eerste
    rijen = 0
    while True:
        data = haal(url)
        records = data.get("value", [])
        if records:
            schrijf_pagina(conn, entiteit, cols, records, None, voortgang=False)
        rijen += len(records)
        volgende = data.get("@odata.nextLink")
        if not volgende:
            break
        time.sleep(pauze)
        url = eerste + "&$skiptoken=" + urllib.parse.quote(skiptoken_uit(volgende), safe="")
    # Pas na een volledige entiteit het startpunt verschuiven: bij een fout haalt de volgende run meer op, maar mist niets
    conn.execute(
        "update raw.laadstatus set laatste_api_gewijzigd_op = %s, bijgewerkt_op = now() where entiteit = %s",
        (run_start, entiteit),
    )
    print(f"{entiteit}: {getal(rijen)} gewijzigde records sinds {sinds}")
    return rijen


def main():
    url = os.environ.get("DATABASE_URL")
    if not url:
        sys.exit("DATABASE_URL ontbreekt.")
    meta = lees_metadata(Path(METADATA).read_bytes())
    start = time.monotonic()
    totaal = 0
    with psycopg.connect(url, autocommit=True) as conn:
        for entiteit in VOLGORDE:
            totaal += ververs_entiteit(conn, entiteit, kolommen(meta, entiteit)) or 0
        grootte = database_grootte(conn)
    minuten = f"{(time.monotonic() - start) / 60:.1f}".replace(".", ",")
    print(f"Verversing klaar: {getal(totaal)} records in {minuten} min, "
          f"database {mb(grootte)} MB")


if __name__ == "__main__":
    main()
