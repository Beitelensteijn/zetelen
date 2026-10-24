"""Tests voor pipeline/laad.py met een nagebootste API.

De unittests hebben geen database nodig. De integratietests draaien alleen als
TEST_DATABASE_URL gezet is (in CI: een Postgres-container) en gooien de schema's
raw, core en beheer leeg, dus nooit tegen Supabase draaien.
"""
import os
import sys
import urllib.parse
import uuid
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import laad  # noqa: E402
import raw_schema  # noqa: E402
from api_check import lees_metadata  # noqa: E402

META = lees_metadata(raw_schema.METADATA.read_bytes())
BASE = "https://nep"


class NepApi:
    """Bootst paginering met $skiptoken (gesorteerd op Id) en $count na."""

    def __init__(self, records, pagina=250):
        self.records = sorted(records, key=lambda r: r["Id"])
        self.pagina = pagina
        self.urls = []

    def __call__(self, url):
        self.urls.append(url)
        params = dict(urllib.parse.parse_qsl(urllib.parse.urlsplit(url).query))
        if params.get("$count") == "true":
            return {"@odata.count": len(self.records), "value": []}
        rest = self.records
        if "$skiptoken" in params:
            na = params["$skiptoken"].removeprefix("Id-")
            rest = [r for r in self.records if r["Id"] > na]
        deel = rest[: self.pagina]
        data = {"value": deel}
        if len(rest) > self.pagina:
            data["@odata.nextLink"] = url.split("&$skiptoken=")[0] + f"&$skiptoken=Id-{deel[-1]['Id']}"
        return data


def fracties(n):
    return [{"Id": str(uuid.uuid4()), "Afkorting": f"F{i}", "Nummer": i,
             "ApiGewijzigdOp": "2026-10-01T10:00:00+02:00", "Verwijderd": False} for i in range(n)]


# Unittests (geen database)

def test_basis_url_zonder_top_met_select_en_filter():
    url = laad.basis_url("Stemming", raw_schema.kolommen(META, "Stemming"), BASE)
    params = dict(urllib.parse.parse_qsl(urllib.parse.urlsplit(url).query))
    assert "$top" not in params
    assert params["$filter"] == "Besluit/Agendapunt/Activiteit/Datum ge 2010-01-01T00:00:00Z"
    assert params["$select"].split(",")[0] == "Id"


def test_persoon_vraagt_geen_uitgesloten_velden_op():
    url = laad.basis_url("Persoon", raw_schema.kolommen(META, "Persoon"), BASE)
    select = dict(urllib.parse.parse_qsl(urllib.parse.urlsplit(url).query))["$select"].split(",")
    assert "Achternaam" in select
    assert "Geboortedatum" not in select and "Woonplaats" not in select


def test_besluit_haalt_zaak_koppeling_op():
    url = laad.basis_url("Besluit", raw_schema.kolommen(META, "Besluit"), BASE)
    assert dict(urllib.parse.parse_qsl(urllib.parse.urlsplit(url).query))["$expand"] == "Zaak($select=Id)"


def test_elke_entiteit_heeft_een_filterkeuze_en_staat_in_de_volgorde():
    assert set(laad.FILTERPAD) == set(raw_schema.ENTITEITEN)
    assert sorted(laad.VOLGORDE) == sorted(raw_schema.ENTITEITEN)


def test_skiptoken_uit_volgende_link():
    # GUID wordt hier gemaakt: een vaste GUID achter "token=" ziet de secret scan als sleutel
    token = f"Id-{uuid.uuid4()}"
    link = f"https://x/Stemming?$filter=a&$skiptoken={token}"
    assert laad.skiptoken_uit(link) == token


# Integratietests (Postgres)

URL = os.environ.get("TEST_DATABASE_URL")
db = pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL niet gezet")


@pytest.fixture
def conn():
    import migreer
    import psycopg

    with psycopg.connect(URL, autocommit=True) as c:
        c.execute("drop schema if exists core cascade; drop schema if exists raw cascade; "
                  "drop schema if exists beheer cascade;")
        migreer.migreer(c)
        yield c


def laad_fractie(conn, api, **kw):
    return laad.laad_entiteit(conn, "Fractie", raw_schema.kolommen(META, "Fractie"),
                              haal=api, base=BASE, pauze=0, **kw)


@db
def test_volledige_laad_en_aantallen(conn):
    api = NepApi(fracties(600))
    assert laad_fractie(conn, api) == "klaar"
    assert conn.execute("select count(*) from raw.fractie").fetchone()[0] == 600
    assert laad.controleer_aantal(conn, "Fractie", haal=api, base=BASE)
    status = conn.execute("select skiptoken, eerste_laad_klaar_op, laatste_api_gewijzigd_op "
                          "from raw.laadstatus where entiteit = 'Fractie'").fetchone()
    assert status[0] is None and status[1] is not None and status[2] is not None
    # Nog een keer: overgeslagen
    assert laad_fractie(conn, api) == "al klaar"


@db
def test_onderbreken_en_hervatten_geeft_geen_dubbele_rijen(conn):
    api = NepApi(fracties(600))
    aanroepen = iter([False, True])  # na een pagina stoppen
    assert laad_fractie(conn, api, moet_stoppen=lambda: next(aanroepen)) == "tijd"
    assert conn.execute("select count(*) from raw.fractie").fetchone()[0] == 250
    assert conn.execute("select skiptoken from raw.laadstatus").fetchone()[0].startswith("Id-")
    assert laad_fractie(conn, api) == "klaar"
    assert conn.execute("select count(*), count(distinct \"Id\") from raw.fractie").fetchone() == (600, 600)
    # Hervat met het bewaarde skiptoken, niet vanaf het begin
    assert "$skiptoken=" in api.urls[1]


@db
def test_groottegrens_stopt_de_laad(conn):
    api = NepApi(fracties(10))
    assert laad_fractie(conn, api, max_bytes=0) == "grootte"
    assert conn.execute("select count(*) from raw.fractie").fetchone()[0] == 0


@db
def test_besluit_met_zaak_koppelingen(conn):
    zaak1, zaak2 = str(uuid.uuid4()), str(uuid.uuid4())
    besluiten = [
        {"Id": str(uuid.uuid4()), "BesluitSoort": "x", "Verwijderd": False, "Zaak": [{"Id": zaak1}, {"Id": zaak2}]},
        {"Id": str(uuid.uuid4()), "BesluitSoort": "y", "Verwijderd": False, "Zaak": []},
    ]
    api = NepApi(besluiten)
    assert laad.laad_entiteit(conn, "Besluit", raw_schema.kolommen(META, "Besluit"),
                              haal=api, base=BASE, pauze=0) == "klaar"
    assert conn.execute("select count(*) from raw.besluit").fetchone()[0] == 2
    assert conn.execute("select count(*) from raw.besluit_zaak").fetchone()[0] == 2


@db
def test_upsert_werkt_bestaande_rij_bij(conn):
    rec = fracties(1)
    laad_fractie(conn, NepApi(rec))
    conn.execute("delete from raw.laadstatus")
    rec[0]["Afkorting"] = "NIEUW"
    laad_fractie(conn, NepApi(rec))
    assert conn.execute('select count(*), max("Afkorting") from raw.fractie').fetchone() == (1, "NIEUW")
