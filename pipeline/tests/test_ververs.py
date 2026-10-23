"""Tests voor pipeline/ververs.py. Integratietests alleen met TEST_DATABASE_URL (nooit Supabase)."""
import datetime as dt
import os
import sys
import urllib.parse
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import laad  # noqa: E402
import raw_schema  # noqa: E402
import ververs  # noqa: E402
from api_check import lees_metadata  # noqa: E402
from test_laad import BASE, NepApi, fracties  # noqa: E402

META = lees_metadata(raw_schema.METADATA.read_bytes())
COLS = raw_schema.kolommen(META, "Fractie")


def test_odata_tijd_in_utc():
    t = dt.datetime(2026, 10, 23, 6, 30, tzinfo=dt.timezone(dt.timedelta(hours=2)))
    assert ververs.odata_tijd(t) == "2026-10-23T04:30:00Z"


def test_filter_combineert_datum_en_wijziging():
    url = laad.basis_url("Stemming", raw_schema.kolommen(META, "Stemming"), BASE,
                         extra_filter="ApiGewijzigdOp ge 2026-10-22T00:00:00Z")
    flt = dict(urllib.parse.parse_qsl(urllib.parse.urlsplit(url).query))["$filter"]
    assert flt == ("Besluit/Agendapunt/Activiteit/Datum ge 2010-01-01T00:00:00Z "
                   "and ApiGewijzigdOp ge 2026-10-22T00:00:00Z")


URL = os.environ.get("TEST_DATABASE_URL")
db = pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL niet gezet")


@pytest.fixture
def conn():
    import migreer
    import psycopg

    with psycopg.connect(URL, autocommit=True) as c:
        c.execute("drop schema if exists raw cascade; drop schema if exists beheer cascade;")
        migreer.migreer(c)
        yield c


@db
def test_zonder_eerste_laad_overgeslagen(conn):
    assert ververs.ververs_entiteit(conn, "Fractie", COLS, haal=NepApi([]), base=BASE, pauze=0) is None


@db
def test_wijziging_en_verwijdering_komen_mee(conn):
    rec = fracties(300)
    laad.laad_entiteit(conn, "Fractie", COLS, haal=NepApi(rec), base=BASE, pauze=0)
    voor = conn.execute("select laatste_api_gewijzigd_op from raw.laadstatus").fetchone()[0]

    gewijzigd = [dict(rec[0], Afkorting="NIEUW"), dict(rec[1], Verwijderd=True)]
    api = NepApi(gewijzigd)
    assert ververs.ververs_entiteit(conn, "Fractie", COLS, haal=api, base=BASE, pauze=0) == 2
    assert "ApiGewijzigdOp ge" in urllib.parse.unquote(api.urls[0])

    assert conn.execute("select count(*) from raw.fractie").fetchone()[0] == 300
    assert conn.execute('select "Afkorting" from raw.fractie where "Id" = %s', (rec[0]["Id"],)).fetchone()[0] == "NIEUW"
    assert conn.execute('select "Verwijderd" from raw.fractie where "Id" = %s', (rec[1]["Id"],)).fetchone()[0] is True
    na = conn.execute("select laatste_api_gewijzigd_op from raw.laadstatus").fetchone()[0]
    assert na > voor
